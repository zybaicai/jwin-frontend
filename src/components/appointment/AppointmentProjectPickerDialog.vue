<script setup lang="ts">
import { computed, ref, watch } from 'vue'

import { fetchGoodsList } from '@/api/catalog'
import { fetchProjectCategoryTree, fetchProjectPage } from '@/api/project'
import { fetchSaleChannelOptions } from '@/api/sale-channel'
import type { ProjectCategoryTreeNode, ProjectItem } from '@/types/project'
import type { SaleChannelOption } from '@/types/sale-channel'
import { getUserFriendlyErrorMessage, runExclusive, uiMessage } from '@/utils/ui'

defineOptions({ name: 'AppointmentProjectPickerDialog' })

const visible = defineModel<boolean>({ default: false })

const props = defineProps<{
  modelSelected?: Array<{ id: number; name: string; treatTime: number | null }>
}>()

const emit = defineEmits<{
  confirm: [items: Array<{ id: number; name: string; treatTime: number | null }>]
}>()

const loading = ref(false)
const keyword = ref('')
const channelId = ref<number | null>(null)
const channels = ref<SaleChannelOption[]>([])
const categoryTree = ref<ProjectCategoryTreeNode[]>([])
const selectedL1 = ref<number | null>(null)
const selectedL2 = ref<number | null>(null)
const goods = ref<Array<{ id: number; name: string; categoryName: string | null }>>([])
const projectMeta = ref<Map<number, ProjectItem>>(new Map())
const selectedMap = ref<Map<number, { id: number; name: string; treatTime: number | null }>>(
  new Map(),
)
const page = ref(1)
const pageSize = 20
let keywordTimer: ReturnType<typeof setTimeout> | null = null

const selectedList = computed(() => [...selectedMap.value.values()])
const totalDuration = computed(() =>
  selectedList.value.reduce((s, p) => s + (p.treatTime && p.treatTime > 0 ? p.treatTime : 60), 0),
)

const l1Categories = computed(() => categoryTree.value || [])
const l2Categories = computed(() => {
  if (selectedL1.value == null) return [] as ProjectCategoryTreeNode[]
  return categoryTree.value.find((c) => c.id === selectedL1.value)?.children ?? []
})

const filteredGoods = computed(() => {
  let list = goods.value
  const kw = keyword.value.trim()
  if (kw) {
    list = list.filter((g) => (g.name || '').includes(kw))
  }
  // 分类过滤：优先用 meta.categoryId，否则用名称弱匹配
  if (selectedL2.value != null || selectedL1.value != null) {
    const l2Ids = new Set(
      (selectedL1.value != null
        ? (categoryTree.value.find((c) => c.id === selectedL1.value)?.children ?? []).map(
            (c) => c.id,
          )
        : []
      ).filter((id): id is number => id != null),
    )
    list = list.filter((g) => {
      const meta = projectMeta.value.get(g.id)
      if (meta?.categoryId != null) {
        if (selectedL2.value != null) return meta.categoryId === selectedL2.value
        if (selectedL1.value != null) {
          return meta.categoryId === selectedL1.value || l2Ids.has(meta.categoryId)
        }
      }
      return true
    })
  }
  return list
})

const pagedGoods = computed(() => {
  const start = (page.value - 1) * pageSize
  return filteredGoods.value.slice(start, start + pageSize)
})

watch(visible, (open) => {
  if (!open) {
    if (keywordTimer) clearTimeout(keywordTimer)
    return
  }
  const map = new Map<number, { id: number; name: string; treatTime: number | null }>()
  for (const p of props.modelSelected ?? []) map.set(p.id, { ...p })
  selectedMap.value = map
  keyword.value = ''
  selectedL1.value = null
  selectedL2.value = null
  page.value = 1
  void bootstrap()
})

async function bootstrap(): Promise<void> {
  await runExclusive(loading, async () => {
    try {
      const [tree, ch] = await Promise.all([
        fetchProjectCategoryTree(true).catch(() => [] as ProjectCategoryTreeNode[]),
        fetchSaleChannelOptions().catch(() => [] as SaleChannelOption[]),
      ])
      categoryTree.value = tree
      channels.value = ch.filter((c) => c.active !== false)
      if (channelId.value == null && channels.value.length === 1) {
        channelId.value = channels.value[0]!.id
      }
      await loadGoods()
    } catch (e) {
      uiMessage.error(getUserFriendlyErrorMessage(e))
    }
  })
}

async function loadGoods(): Promise<void> {
  try {
    if (channelId.value != null) {
      const list = await fetchGoodsList({
        itemType: 'PROJECT',
        keyword: keyword.value.trim() || undefined,
        saleChannelId: channelId.value,
      })
      goods.value = list
        .filter((g) => g.itemId != null)
        .map((g) => ({
          id: g.itemId!,
          name: g.name?.trim() || `项目#${g.itemId}`,
          categoryName: g.categoryName ?? null,
        }))
    } else {
      const data = await fetchProjectPage({
        page: 1,
        size: 200,
        keyword: keyword.value.trim() || undefined,
        sellable: true,
        sortField: 'name',
        sortOrder: 'asc',
      })
      const records = data.records ?? []
      const meta = new Map<number, ProjectItem>()
      goods.value = records.map((p) => {
        meta.set(p.id, p)
        return {
          id: p.id,
          name: p.name?.trim() || `项目#${p.id}`,
          categoryName: p.categoryName ?? null,
        }
      })
      projectMeta.value = meta
      return
    }
    // 补时长与分类
    const pageData = await fetchProjectPage({
      page: 1,
      size: 200,
      sellable: true,
    })
    const meta = new Map<number, ProjectItem>()
    for (const p of pageData.records ?? []) meta.set(p.id, p)
    projectMeta.value = meta
  } catch (e) {
    goods.value = []
    uiMessage.error(getUserFriendlyErrorMessage(e))
  }
}

function onKeywordInput(): void {
  page.value = 1
  if (keywordTimer) clearTimeout(keywordTimer)
  keywordTimer = setTimeout(() => void loadGoods(), 300)
}

function onSelectChannel(id: number): void {
  channelId.value = id
  page.value = 1
  void loadGoods()
}

function onSelectL1(id: number | null): void {
  selectedL1.value = id
  selectedL2.value = null
  page.value = 1
}

function onSelectL2(id: number | null): void {
  selectedL2.value = id
  page.value = 1
}

function isChecked(id: number): boolean {
  return selectedMap.value.has(id)
}

function toggle(id: number, name: string, checked: boolean): void {
  if (checked) {
    const meta = projectMeta.value.get(id)
    selectedMap.value.set(id, {
      id,
      name,
      treatTime: meta?.treatTime ?? null,
    })
  } else {
    selectedMap.value.delete(id)
  }
  selectedMap.value = new Map(selectedMap.value)
}

function removeSelected(id: number): void {
  selectedMap.value.delete(id)
  selectedMap.value = new Map(selectedMap.value)
}

function confirm(): void {
  emit('confirm', selectedList.value)
  visible.value = false
}
</script>

<template>
  <el-dialog
    v-model="visible"
    title="选择预约项目"
    width="960px"
    top="5vh"
    append-to-body
    destroy-on-close
    :close-on-click-modal="false"
  >
    <div v-loading="loading" class="picker">
      <div class="left-pane">
        <el-input
          v-model="keyword"
          clearable
          size="small"
          placeholder="输入项目名称，自动搜索"
          @input="onKeywordInput"
          @clear="onKeywordInput"
        />
        <div class="catalog-cascade">
          <div class="cascade-col cat-l1">
            <button
              type="button"
              class="cascade-item"
              :class="{ active: selectedL1 == null }"
              @click="onSelectL1(null)"
            >
              全部
            </button>
            <button
              v-for="root in l1Categories"
              :key="root.id"
              type="button"
              class="cascade-item"
              :class="{ active: selectedL1 === root.id }"
              @click="onSelectL1(root.id)"
            >
              {{ root.name || `分类#${root.id}` }}
            </button>
          </div>
          <div v-if="l2Categories.length" class="cascade-col cat-l2">
            <button
              type="button"
              class="cascade-item"
              :class="{ active: selectedL2 == null }"
              @click="onSelectL2(null)"
            >
              全部
            </button>
            <button
              v-for="child in l2Categories"
              :key="child.id"
              type="button"
              class="cascade-item"
              :class="{ active: selectedL2 === child.id }"
              @click="onSelectL2(child.id)"
            >
              {{ child.name || `分类#${child.id}` }}
            </button>
          </div>
          <div v-if="channels.length" class="cascade-col channel-col">
            <button
              v-for="ch in channels"
              :key="ch.id"
              type="button"
              class="cascade-item"
              :class="{ active: channelId === ch.id }"
              @click="onSelectChannel(ch.id)"
            >
              {{ ch.name || ch.code || String(ch.id) }}
            </button>
          </div>
          <div class="cascade-col items-col">
            <label
              v-for="row in pagedGoods"
              :key="row.id"
              class="goods-card"
              :class="{ checked: isChecked(row.id) }"
            >
              <el-checkbox
                :model-value="isChecked(row.id)"
                @change="(v: boolean | string | number) => toggle(row.id, row.name, !!v)"
              />
              <div class="goods-main">
                <div class="goods-name">{{ row.name }}</div>
                <div v-if="row.categoryName" class="goods-sub">{{ row.categoryName }}</div>
              </div>
            </label>
            <div v-if="!pagedGoods.length" class="empty">
              {{ channelId == null && channels.length ? '请先选择销售渠道' : '暂无项目' }}
            </div>
            <div v-if="filteredGoods.length > pageSize" class="pager">
              <el-pagination
                v-model:current-page="page"
                small
                layout="prev, pager, next"
                :page-size="pageSize"
                :total="filteredGoods.length"
              />
            </div>
          </div>
        </div>
      </div>
      <div class="right-pane">
        <div class="summary">
          已选 {{ selectedList.length }} 个项目，合计时长 {{ totalDuration }} 分钟
        </div>
        <el-table :data="selectedList" stripe border height="380" empty-text="尚未选择项目">
          <el-table-column prop="name" label="项目名称" min-width="200" />
          <el-table-column label="操作" width="90" align="center">
            <template #default="{ row }">
              <el-button link type="danger" @click="removeSelected(row.id)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </div>
    <template #footer>
      <el-button @click="visible = false">取消</el-button>
      <el-button type="primary" @click="confirm">确认</el-button>
    </template>
  </el-dialog>
</template>

<style scoped>
.picker {
  display: flex;
  gap: 14px;
  min-height: 440px;
}
.left-pane {
  flex: 1 1 62%;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.right-pane {
  flex: 0 0 34%;
  min-width: 240px;
}
.catalog-cascade {
  display: flex;
  flex: 1;
  min-height: 0;
  border: 1px solid #ebeef5;
  border-radius: 6px;
  overflow: hidden;
  background: #fff;
}
.cascade-col {
  display: flex;
  flex-direction: column;
  overflow: auto;
  border-right: 1px solid #ebeef5;
  max-height: 400px;
}
.cat-l1,
.cat-l2,
.channel-col {
  flex: 0 0 112px;
}
.items-col {
  flex: 1;
  border-right: none;
  padding: 8px;
  gap: 6px;
}
.cascade-item {
  padding: 10px 12px;
  border: 0;
  background: transparent;
  text-align: left;
  font-size: 13px;
  color: #606266;
  cursor: pointer;
}
.cascade-item:hover {
  background: var(--el-color-primary-light-9);
}
.cascade-item.active {
  background: var(--el-color-primary-light-8);
  color: var(--el-color-primary);
  font-weight: 600;
}
.goods-card {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  padding: 8px 10px;
  border: 1px solid #ebeef5;
  border-radius: 6px;
  cursor: pointer;
}
.goods-card.checked,
.goods-card:hover {
  border-color: var(--el-color-primary-light-5);
  background: var(--el-color-primary-light-9);
}
.goods-name {
  font-size: 13px;
  color: #303133;
  line-height: 1.4;
}
.goods-sub {
  font-size: 12px;
  color: #909399;
  margin-top: 2px;
}
.summary {
  margin-bottom: 8px;
  font-size: 13px;
  color: #606266;
}
.empty {
  padding: 24px;
  text-align: center;
  color: #c0c4cc;
  font-size: 13px;
}
.pager {
  display: flex;
  justify-content: center;
  padding-top: 8px;
}
</style>
