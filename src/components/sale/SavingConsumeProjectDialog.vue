<script setup lang="ts">
import { computed, ref, watch } from 'vue'

import { fetchSavingCardDetail } from '@/api/card'
import { fetchProjectCategoryTree, fetchProjectPage } from '@/api/project'
import type { ProjectCategoryTreeNode, ProjectItem } from '@/types/project'
import type { SavingCardItem, SavingCardRangeProjectLine } from '@/types/card'
import type { TreatSavingAsset } from '@/types/treat'
import { formatAmountDisplay } from '@/utils/amount'
import { getUserFriendlyErrorMessage, runExclusive, uiMessage } from '@/utils/ui'

defineOptions({ name: 'SavingConsumeProjectDialog' })

const visible = defineModel<boolean>({ default: false })

const props = defineProps<{
  asset: TreatSavingAsset | null
}>()

const emit = defineEmits<{
  select: [
    payload: {
      accountId: number
      savingCardId: number | null
      projectId: number
      projectName: string
      fundSource: 'principal' | 'bonus'
      projectPrice: string | number | null
      cardName: string
    },
  ]
}>()

type FundSource = 'principal' | 'bonus'

const loading = ref(false)
const cardDetail = ref<SavingCardItem | null>(null)
const categoryTree = ref<ProjectCategoryTreeNode[]>([])
const projects = ref<ProjectItem[]>([])
const keyword = ref('')
const fundSource = ref<FundSource>('principal')
const selectedRootId = ref<number | null>(null)
const selectedCategoryId = ref<number | null>(null)

const title = computed(() => {
  const name = props.asset?.name || '储值卡'
  const id = props.asset?.accountId
  return id != null ? `储值卡消耗 - ${name} - 账户 ${id}` : `储值卡消耗 - ${name}`
})

const balanceText = computed(() => {
  const a = props.asset
  if (!a) {
    return '—'
  }
  return `本金 ¥${formatAmountDisplay(a.principalBalance)} / 赠金 ¥${formatAmountDisplay(a.bonusBalance)}`
})

const rangeHint = computed(() => {
  const card = cardDetail.value
  if (!card) {
    return '加载卡定义中…'
  }
  if (fundSource.value === 'principal') {
    return card.goodsRange
      ? '本金货品范围已配置：仅展示范围内可耗项目'
      : '本金货品范围为空：展示全部符合门店消耗规则的有效项目'
  }
  return card.largessGoodsRange
    ? '赠金货品范围已配置：仅展示范围内可耗项目'
    : '赠金货品范围为空：展示全部符合门店消耗规则的有效项目'
})

const rootCategories = computed(() => categoryTree.value)

const childCategories = computed(() => {
  if (selectedRootId.value == null) {
    return [] as ProjectCategoryTreeNode[]
  }
  const root = categoryTree.value.find((n) => n.id === selectedRootId.value)
  return root?.children ?? []
})

function allowedProjectIds(card: SavingCardItem, source: FundSource): number[] | null {
  const useRange = source === 'principal' ? card.goodsRange : card.largessGoodsRange
  if (!useRange) {
    return null
  }
  const lines: SavingCardRangeProjectLine[] = card.projects ?? []
  const wantLargess = source === 'bonus'
  return lines
    .filter((line) => Boolean(line.largess) === wantLargess)
    .map((line) => line.projectId)
    .filter((id) => Number.isFinite(id))
}

async function loadDialogData(): Promise<void> {
  const asset = props.asset
  if (!asset?.savingCardId) {
    cardDetail.value = null
    projects.value = []
    return
  }
  await runExclusive(loading, async () => {
    try {
      const [card, tree] = await Promise.all([
        fetchSavingCardDetail(asset.savingCardId!),
        fetchProjectCategoryTree(true),
      ])
      cardDetail.value = card
      categoryTree.value = tree
      await loadProjects()
    } catch (error) {
      cardDetail.value = null
      projects.value = []
      uiMessage.error(getUserFriendlyErrorMessage(error))
    }
  })
}

async function loadProjects(): Promise<void> {
  const card = cardDetail.value
  if (!card) {
    projects.value = []
    return
  }
  const allowed = allowedProjectIds(card, fundSource.value)
  try {
    const page = await fetchProjectPage({
      page: 1,
      size: 200,
      keyword: keyword.value.trim() || undefined,
      categoryId: selectedCategoryId.value ?? selectedRootId.value ?? undefined,
      consumable: true,
      sortField: 'name',
      sortOrder: 'asc',
    })
    let records = page.records ?? []
    if (allowed != null) {
      const set = new Set(allowed)
      records = records.filter((p) => set.has(p.id))
    }
    projects.value = records.filter((p) => p.allowConsume !== false)
  } catch (error) {
    projects.value = []
    uiMessage.error(getUserFriendlyErrorMessage(error))
  }
}

function selectRoot(id: number | null): void {
  selectedRootId.value = id
  selectedCategoryId.value = null
  void loadProjects()
}

function selectChild(id: number | null): void {
  selectedCategoryId.value = id
  void loadProjects()
}

function handleSearch(): void {
  void loadProjects()
}

function projectOf(row: unknown): ProjectItem {
  return row as ProjectItem
}

function handleSelect(row: unknown): void {
  const project = projectOf(row)
  const asset = props.asset
  if (!asset) {
    return
  }
  emit('select', {
    accountId: asset.accountId,
    savingCardId: asset.savingCardId,
    projectId: project.id,
    projectName: project.name?.trim() || `项目#${project.id}`,
    fundSource: fundSource.value,
    projectPrice: project.price,
    cardName: asset.name?.trim() || '储值卡',
  })
  visible.value = false
}

watch(visible, (open) => {
  if (!open) {
    return
  }
  keyword.value = ''
  fundSource.value = 'principal'
  selectedRootId.value = null
  selectedCategoryId.value = null
  void loadDialogData()
})

watch(fundSource, () => {
  if (visible.value) {
    void loadProjects()
  }
})
</script>

<template>
  <el-dialog
    v-model="visible"
    :title="title"
    width="960px"
    top="6vh"
    append-to-body
    destroy-on-close
    :close-on-click-modal="false"
  >
    <div v-loading="loading" class="saving-dialog">
      <div class="toolbar">
        <el-input
          v-model="keyword"
          clearable
          placeholder="项目名称 / 别名 / 关键字"
          style="max-width: 280px"
          @keyup.enter="handleSearch"
          @clear="handleSearch"
        />
        <el-button type="primary" @click="handleSearch">搜索</el-button>
        <el-radio-group v-model="fundSource" size="small">
          <el-radio-button value="principal">本金范围</el-radio-button>
          <el-radio-button value="bonus">赠金范围</el-radio-button>
        </el-radio-group>
      </div>
      <p class="range-hint">{{ rangeHint }}</p>
      <p class="deduct-hint">
        扣款金额由后端在提交消耗单时按「项目现价 × 区域折扣」计算；本弹窗不预计算、不伪造成交价。
      </p>

      <div class="body">
        <aside class="col root-col">
          <div class="col-title">项目类型</div>
          <button
            type="button"
            class="cat-item"
            :class="{ active: selectedRootId == null }"
            @click="selectRoot(null)"
          >
            全部
          </button>
          <button
            v-for="node in rootCategories"
            :key="node.id"
            type="button"
            class="cat-item"
            :class="{ active: selectedRootId === node.id }"
            @click="selectRoot(node.id)"
          >
            {{ node.name || `分类#${node.id}` }}
          </button>
        </aside>

        <aside class="col child-col">
          <div class="col-title">二级分类</div>
          <button
            type="button"
            class="cat-item"
            :class="{ active: selectedCategoryId == null }"
            @click="selectChild(null)"
          >
            全部
          </button>
          <button
            v-for="node in childCategories"
            :key="node.id"
            type="button"
            class="cat-item"
            :class="{ active: selectedCategoryId === node.id }"
            @click="selectChild(node.id)"
          >
            {{ node.name || `分类#${node.id}` }}
          </button>
        </aside>

        <div class="col list-col">
          <el-table :data="projects" size="small" border height="360" empty-text="无可耗项目">
            <el-table-column label="项目名称" min-width="140" show-overflow-tooltip>
              <template #default="{ row }">{{ row.name || '—' }}</template>
            </el-table-column>
            <el-table-column label="项目价格" width="100" align="right">
              <template #default="{ row }">¥ {{ formatAmountDisplay(row.price) }}</template>
            </el-table-column>
            <el-table-column label="储值扣款" width="120" align="center">
              <template #default>提交时后端计算</template>
            </el-table-column>
            <el-table-column label="可用" width="72" align="center">
              <template #default="{ row }">
                <el-tag size="small" :type="row.allowConsume === false ? 'info' : 'success'">
                  {{ row.allowConsume === false ? '不可耗' : '可耗' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="" width="80" align="center" fixed="right">
              <template #default="{ row }">
                <el-button
                  link
                  type="primary"
                  size="small"
                  :disabled="row.allowConsume === false"
                  @click="handleSelect(row)"
                >
                  选择
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>

      <div class="footer-meta">
        <span>储值卡余额：{{ balanceText }}</span>
        <span>当前筛选：{{ fundSource === 'principal' ? '本金' : '赠金' }}货品范围</span>
      </div>
    </div>
    <template #footer>
      <el-button @click="visible = false">取消</el-button>
    </template>
  </el-dialog>
</template>

<style scoped>
.saving-dialog {
  display: flex;
  flex-direction: column;
  gap: 10px;
  min-height: 420px;
}

.toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}

.range-hint,
.deduct-hint {
  margin: 0;
  font-size: 12px;
  color: #909399;
  line-height: 1.5;
}

.deduct-hint {
  color: #e6a23c;
}

.body {
  display: grid;
  grid-template-columns: 160px 160px minmax(0, 1fr);
  gap: 8px;
  min-height: 380px;
}

.col {
  border: 1px solid #ebeef5;
  background: #fff;
  overflow: auto;
}

.col-title {
  padding: 8px 10px;
  font-size: 13px;
  font-weight: 600;
  background: #fff4e8;
  border-bottom: 1px solid #f0e0d0;
  color: #a15c1a;
}

.cat-item {
  display: block;
  width: 100%;
  padding: 8px 10px;
  border: 0;
  border-bottom: 1px solid #f5f5f5;
  background: transparent;
  text-align: left;
  font-size: 13px;
  color: #606266;
  cursor: pointer;
}

.cat-item:hover {
  background: #fffaf5;
}

.cat-item.active {
  background: #fff0e0;
  color: #d46b08;
  font-weight: 600;
}

.list-col {
  padding: 0;
}

.footer-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  font-size: 13px;
  color: #606266;
}
</style>
