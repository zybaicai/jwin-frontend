-- =====================================================
-- SQL Server init.sql
-- Generated from 系统表结构.xlsx
-- Compatible with SpringBoot database initialization
-- =====================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 额外收入管理
IF OBJECT_ID(N'TB_AdditionalIncome', N'U') IS NOT NULL DROP TABLE [TB_AdditionalIncome];
GO
CREATE TABLE [TB_AdditionalIncome] (
    [ID] int NOT NULL,
    [IncomeCategoryID] int NOT NULL,
    [EntityID] int NOT NULL,
    [InComeDate] date NOT NULL,
    [PaymentsID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [IncomeSource] nvarchar(50) NOT NULL,
    [Content] nvarchar(500) NULL,
    [EmployeeID] nvarchar(50) NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_AdditionalIncome] PRIMARY KEY ([ID])
);
GO

-- 额外收入管理附件
IF OBJECT_ID(N'TB_AdditionalIncomeAttachment', N'U') IS NOT NULL DROP TABLE [TB_AdditionalIncomeAttachment];
GO
CREATE TABLE [TB_AdditionalIncomeAttachment] (
    [ID] int NOT NULL,
    [AdditionalIncomeID] int NOT NULL,
    [AttachmentURL] nvarchar(200) NOT NULL,
    [AttachmentType] int NOT NULL,
    CONSTRAINT [PK_TB_AdditionalIncomeAttachment] PRIMARY KEY ([ID])
);
GO

-- 收入类别
IF OBJECT_ID(N'TB_AdditionalIncomeCategor', N'U') IS NOT NULL DROP TABLE [TB_AdditionalIncomeCategor];
GO
CREATE TABLE [TB_AdditionalIncomeCategor] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_AdditionalIncomeCategor] PRIMARY KEY ([ID])
);
GO

-- 收支方式
IF OBJECT_ID(N'TB_AdditionalPayments', N'U') IS NOT NULL DROP TABLE [TB_AdditionalPayments];
GO
CREATE TABLE [TB_AdditionalPayments] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_AdditionalPayments] PRIMARY KEY ([ID])
);
GO

-- 额外支出管理
IF OBJECT_ID(N'TB_AdditionalSpending', N'U') IS NOT NULL DROP TABLE [TB_AdditionalSpending];
GO
CREATE TABLE [TB_AdditionalSpending] (
    [ID] int NOT NULL,
    [SpendingCategoryID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SpendingDate] date NOT NULL,
    [Payer] nvarchar(50) NOT NULL,
    [PaymentsID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [Content] nvarchar(500) NULL,
    [EmployeeID] nvarchar(50) NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_AdditionalSpending] PRIMARY KEY ([ID])
);
GO

-- 额外支出管理附件
IF OBJECT_ID(N'TB_AdditionalSpendingAttachment', N'U') IS NOT NULL DROP TABLE [TB_AdditionalSpendingAttachment];
GO
CREATE TABLE [TB_AdditionalSpendingAttachment] (
    [ID] int NOT NULL,
    [AdditionalSpendingID] int NOT NULL,
    [AttachmentURL] nvarchar(200) NOT NULL,
    [AttachmentType] int NOT NULL,
    CONSTRAINT [PK_TB_AdditionalSpendingAttachment] PRIMARY KEY ([ID])
);
GO

-- 支出类别
IF OBJECT_ID(N'TB_AdditionalSpendingCategory', N'U') IS NOT NULL DROP TABLE [TB_AdditionalSpendingCategory];
GO
CREATE TABLE [TB_AdditionalSpendingCategory] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_AdditionalSpendingCategory] PRIMARY KEY ([ID])
);
GO

-- 预约订单
IF OBJECT_ID(N'TB_AppointmentBill', N'U') IS NOT NULL DROP TABLE [TB_AppointmentBill];
GO
CREATE TABLE [TB_AppointmentBill] (
    [ID] nvarchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    [CustomerID] int NOT NULL,
    [Status] nvarchar(2) NOT NULL,
    [AppointmentDate] datetime NOT NULL,
    [Period] int NOT NULL,
    [AppointmentTypeID] int NULL,
    [Remark] nvarchar(500) NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [Channel] nvarchar(50) NULL,
    [BusinessMsg] nvarchar(500) NULL,
    [AppointmentSource] int NULL,
    [IsSendRemindMessage] bit NULL,
    CONSTRAINT [PK_TB_AppointmentBill] PRIMARY KEY ([ID])
);
GO

-- 预约媒体
IF OBJECT_ID(N'TB_AppointmentBillAudio', N'U') IS NOT NULL DROP TABLE [TB_AppointmentBillAudio];
GO
CREATE TABLE [TB_AppointmentBillAudio] (
    [ID] int NOT NULL,
    [AppointmentBillID] nvarchar(50) NOT NULL,
    [AudioURL] nvarchar(200) NOT NULL,
    CONSTRAINT [PK_TB_AppointmentBillAudio] PRIMARY KEY ([ID])
);
GO

-- 预约员工
IF OBJECT_ID(N'TB_AppointmentBillEmployee', N'U') IS NOT NULL DROP TABLE [TB_AppointmentBillEmployee];
GO
CREATE TABLE [TB_AppointmentBillEmployee] (
    [ID] int NOT NULL,
    [AppointmentBillID] nvarchar(50) NOT NULL,
    [AppointmentService
rID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TB_AppointmentBillEmployee] PRIMARY KEY ([ID])
);
GO

-- 预约操作过程
IF OBJECT_ID(N'TB_AppointmentBillProcess', N'U') IS NOT NULL DROP TABLE [TB_AppointmentBillProcess];
GO
CREATE TABLE [TB_AppointmentBillProcess] (
    [ID] int NOT NULL,
    [AppointmentBillID] nvarchar(50) NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [ActionType] nvarchar(2) NOT NULL,
    CONSTRAINT [PK_TB_AppointmentBillProcess] PRIMARY KEY ([ID])
);
GO

-- 预约项目
IF OBJECT_ID(N'TB_AppointmentBillProject', N'U') IS NOT NULL DROP TABLE [TB_AppointmentBillProject];
GO
CREATE TABLE [TB_AppointmentBillProject] (
    [ID] int NOT NULL,
    [AppointmentBillID] nvarchar(50) NOT NULL,
    [ProjectID] int NOT NULL,
    CONSTRAINT [PK_TB_AppointmentBillProject] PRIMARY KEY ([ID])
);
GO

-- 预约配置
IF OBJECT_ID(N'TB_AppointmentConfig', N'U') IS NOT NULL DROP TABLE [TB_AppointmentConfig];
GO
CREATE TABLE [TB_AppointmentConfig] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [StartTime] nvarchar(5) NOT NULL,
    [EndTime] nvarchar(5) NOT NULL,
    [Period] int NOT NULL,
    [AppointmentService
rIsRequired] bit NOT NULL,
    [CanChooseRestEmployee] bit NOT NULL,
    CONSTRAINT [PK_TB_AppointmentConfig] PRIMARY KEY ([ID])
);
GO

-- 门店班次
IF OBJECT_ID(N'TB_AppointmentSchedule', N'U') IS NOT NULL DROP TABLE [TB_AppointmentSchedule];
GO
CREATE TABLE [TB_AppointmentSchedule] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [StartTime] nvarchar(5) NOT NULL,
    [EndTime] nvarchar(5) NOT NULL,
    [Name] nvarchar(20) NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_AppointmentSchedule] PRIMARY KEY ([ID])
);
GO

-- 员工排班
IF OBJECT_ID(N'TB_AppointmentScheduleEmployee', N'U') IS NOT NULL DROP TABLE [TB_AppointmentScheduleEmployee];
GO
CREATE TABLE [TB_AppointmentScheduleEmployee] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [AppointmentService
rID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [ScheduleDate] datetime NOT NULL,
    [AppointmentScheduleID] int NULL,
    [IsRest] bit NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_AppointmentScheduleEmployee] PRIMARY KEY ([ID])
);
GO

-- 预约角色
IF OBJECT_ID(N'TB_AppointmentServicer', N'U') IS NOT NULL DROP TABLE [TB_AppointmentServicer];
GO
CREATE TABLE [TB_AppointmentServicer] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [AppointmentNumber] int NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_AppointmentServicer] PRIMARY KEY ([ID])
);
GO

-- 预约角色适用门店
IF OBJECT_ID(N'TB_AppointmentServicerEntity', N'U') IS NOT NULL DROP TABLE [TB_AppointmentServicerEntity];
GO
CREATE TABLE [TB_AppointmentServicerEntity] (
    [AppointmentService
rID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_AppointmentServicerEntity] PRIMARY KEY ([AppointmentService
rID],[EntityID])
);
GO

-- 预约角色适用职务
IF OBJECT_ID(N'TB_AppointmentServicerJobType', N'U') IS NOT NULL DROP TABLE [TB_AppointmentServicerJobType];
GO
CREATE TABLE [TB_AppointmentServicerJobType] (
    [AppointmentService
rID] int NOT NULL,
    [JobType] int NOT NULL,
    [Sequence] int NOT NULL,
    CONSTRAINT [PK_TB_AppointmentServicerJobType] PRIMARY KEY ([AppointmentService
rID],[JobType])
);
GO

-- 预约类型
IF OBJECT_ID(N'TB_AppointmentType', N'U') IS NOT NULL DROP TABLE [TB_AppointmentType];
GO
CREATE TABLE [TB_AppointmentType] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_AppointmentType] PRIMARY KEY ([ID])
);
GO

-- 话术
IF OBJECT_ID(N'TB_ArtSpeak', N'U') IS NOT NULL DROP TABLE [TB_ArtSpeak];
GO
CREATE TABLE [TB_ArtSpeak] (
    [ID] int NOT NULL,
    [Name] nvarchar(100) NOT NULL,
    [ArtSpeakCategoryID] int NULL,
    [Content] text NULL,
    CONSTRAINT [PK_TB_ArtSpeak] PRIMARY KEY ([ID])
);
GO

-- 话术类目
IF OBJECT_ID(N'TB_ArtSpeakCategory', N'U') IS NOT NULL DROP TABLE [TB_ArtSpeakCategory];
GO
CREATE TABLE [TB_ArtSpeakCategory] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [ParentID] int NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_ArtSpeakCategory] PRIMARY KEY ([ID])
);
GO

-- 回访方式
IF OBJECT_ID(N'TB_CallbackMethod', N'U') IS NOT NULL DROP TABLE [TB_CallbackMethod];
GO
CREATE TABLE [TB_CallbackMethod] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_CallbackMethod] PRIMARY KEY ([ID])
);
GO

-- 回访周期
IF OBJECT_ID(N'TB_CallbackPlan', N'U') IS NOT NULL DROP TABLE [TB_CallbackPlan];
GO
CREATE TABLE [TB_CallbackPlan] (
    [ID] int NOT NULL,
    [CallbackRuleID] int NOT NULL,
    [CallbackCycle] int NOT NULL,
    [CallbackContent] nvarchar(200) NOT NULL,
    CONSTRAINT [PK_TB_CallbackPlan] PRIMARY KEY ([ID])
);
GO

-- 回访记录
IF OBJECT_ID(N'TB_CallbackRecord', N'U') IS NOT NULL DROP TABLE [TB_CallbackRecord];
GO
CREATE TABLE [TB_CallbackRecord] (
    [ID] int NOT NULL,
    [CustomerID] int NOT NULL,
    [CallbackMethodID] int NOT NULL,
    [CallbackStatusID] int NULL,
    [IsCallback] bit NULL,
    [PlannedOn] datetime NOT NULL,
    [CallbackOn] datetime NULL,
    [CallbackBy] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TB_CallbackRecord] PRIMARY KEY ([ID])
);
GO

-- 回访记录项目
IF OBJECT_ID(N'TB_CallbackRecordProject', N'U') IS NOT NULL DROP TABLE [TB_CallbackRecordProject];
GO
CREATE TABLE [TB_CallbackRecordProject] (
    [ID] int NOT NULL,
    [CallbackRecordID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [ProjectID] int NOT NULL,
    [CallbackCycle] int NOT NULL,
    [CallbackRemark] nvarchar(200) NOT NULL,
    [CallbackContent] text NULL,
    CONSTRAINT [PK_TB_CallbackRecordProject] PRIMARY KEY ([ID])
);
GO

-- 回访记录项目附件
IF OBJECT_ID(N'TB_CallbackRecordProjectAttachment', N'U') IS NOT NULL DROP TABLE [TB_CallbackRecordProjectAttachment];
GO
CREATE TABLE [TB_CallbackRecordProjectAttachment] (
    [ID] int NOT NULL,
    [CallbackRecordProjectID] int NOT NULL,
    [AttachmentURL] nvarchar(200) NOT NULL,
    [AttachmentType] int NOT NULL,
    CONSTRAINT [PK_TB_CallbackRecordProjectAttachment] PRIMARY KEY ([ID])
);
GO

-- 回访规则
IF OBJECT_ID(N'TB_CallbackRule', N'U') IS NOT NULL DROP TABLE [TB_CallbackRule];
GO
CREATE TABLE [TB_CallbackRule] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [CallbackMethodID] int NOT NULL,
    [HandlerType] nvarchar(50) NOT NULL,
    [ServicerID] int NULL,
    [ProjectTreatHandlerI] int NULL,
    [SavingCardProjectTr
eatHandlerID] int NULL,
    [EmployeeID] nvarchar(50) NULL,
    CONSTRAINT [PK_TB_CallbackRule] PRIMARY KEY ([ID])
);
GO

-- 回访规则适应组
IF OBJECT_ID(N'TB_CallbackRuleEntity', N'U') IS NOT NULL DROP TABLE [TB_CallbackRuleEntity];
GO
CREATE TABLE [TB_CallbackRuleEntity] (
    [CallbackRuleID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_CallbackRuleEntity] PRIMARY KEY ([CallbackRuleID],[EntityID])
);
GO

-- 回访规则项目
IF OBJECT_ID(N'TB_CallbackRuleProject', N'U') IS NOT NULL DROP TABLE [TB_CallbackRuleProject];
GO
CREATE TABLE [TB_CallbackRuleProject] (
    [CallbackRuleID] int NOT NULL,
    [ProjectID] int NOT NULL,
    CONSTRAINT [PK_TB_CallbackRuleProject] PRIMARY KEY ([CallbackRuleID],[ProjectID])
);
GO

-- 回访规则项目分类
IF OBJECT_ID(N'TB_CallbackRuleProjectCategory', N'U') IS NOT NULL DROP TABLE [TB_CallbackRuleProjectCategory];
GO
CREATE TABLE [TB_CallbackRuleProjectCategory] (
    [CallbackRuleID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    CONSTRAINT [PK_TB_CallbackRuleProjectCategory] PRIMARY KEY ([CallbackRuleID],[ProjectCategoryID])
);
GO

-- 回访状态
IF OBJECT_ID(N'TB_CallbackStatus', N'U') IS NOT NULL DROP TABLE [TB_CallbackStatus];
GO
CREATE TABLE [TB_CallbackStatus] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_CallbackStatus] PRIMARY KEY ([ID])
);
GO

-- 渠道
IF OBJECT_ID(N'TB_Channel', N'U') IS NOT NULL DROP TABLE [TB_Channel];
GO
CREATE TABLE [TB_Channel] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [ChannelTypeID] int NOT NULL,
    [ChannelLevelID] int NULL,
    [ApprovalStatus] nvarchar(2) NOT NULL,
    [ParentID] int NOT NULL,
    [ContactPersonName] nvarchar(50) NULL,
    [ContactPersonMobil] nvarchar(50) NULL,
    [ContactPersonIDNumber] nvarchar(50) NULL,
    [ProvinceCode] nvarchar(50) NULL,
    [CityCode] nvarchar(50) NULL,
    [AreaCode] nvarchar(50) NULL,
    [AddressDetail] nvarchar(100) NULL,
    [Longitude] decimal(13,10) NULL,
    [Latitude] decimal(12,10) NULL,
    [Remark] nvarchar(200) NULL,
    [Sequence] int NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_Channel] PRIMARY KEY ([ID])
);
GO

-- 渠道操作过程
IF OBJECT_ID(N'TB_ChannelApprovalProcess', N'U') IS NOT NULL DROP TABLE [TB_ChannelApprovalProcess];
GO
CREATE TABLE [TB_ChannelApprovalProcess] (
    [ID] int NOT NULL,
    [ChannelID] varchar(50) NOT NULL,
    [ApprovalBy] varchar(50) NOT NULL,
    [ApprovalOn] datetime NOT NULL,
    [ApprovalRemark] varchar(500) NULL,
    [ActionType] nvarchar(2) NOT NULL,
    CONSTRAINT [PK_TB_ChannelApprovalProcess] PRIMARY KEY ([ID])
);
GO

-- 渠道法人
IF OBJECT_ID(N'TB_ChannelCompany', N'U') IS NOT NULL DROP TABLE [TB_ChannelCompany];
GO
CREATE TABLE [TB_ChannelCompany] (
    [ID] int NOT NULL,
    [ChannelID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [LegalPerson] nvarchar(50) NOT NULL,
    [PhoneNumber] nvarchar(50) NOT NULL,
    [BankName] nvarchar(50) NOT NULL,
    [BankBranchName] nvarchar(50) NOT NULL,
    [BankAccount] nvarchar(50) NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TB_ChannelCompany] PRIMARY KEY ([ID])
);
GO

-- 渠道市场咨询
IF OBJECT_ID(N'TB_ChannelConsultant', N'U') IS NOT NULL DROP TABLE [TB_ChannelConsultant];
GO
CREATE TABLE [TB_ChannelConsultant] (
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PerformanceRate] decimal(5,4) NOT NULL,
    CONSTRAINT [PK_TB_ChannelConsultant] PRIMARY KEY ([ChannelID],[EmployeeID])
);
GO

-- 渠道合同
IF OBJECT_ID(N'TB_ChannelContract', N'U') IS NOT NULL DROP TABLE [TB_ChannelContract];
GO
CREATE TABLE [TB_ChannelContract] (
    [ID] int NOT NULL,
    [ChannelID] int NOT NULL,
    [Code] nvarchar(50) NOT NULL,
    [BeginDate] date NOT NULL,
    [EndDate] date NOT NULL,
    CONSTRAINT [PK_TB_ChannelContract] PRIMARY KEY ([ID])
);
GO

-- 渠道合同附件
IF OBJECT_ID(N'TB_ChannelContractAttachment', N'U') IS NOT NULL DROP TABLE [TB_ChannelContractAttachment];
GO
CREATE TABLE [TB_ChannelContractAttachment] (
    [ID] int NOT NULL,
    [ChannelContractID] int NOT NULL,
    [AttachmentURL] nvarchar(200) NOT NULL,
    [AttachmentType] int NOT NULL,
    CONSTRAINT [PK_TB_ChannelContractAttachment] PRIMARY KEY ([ID])
);
GO

-- 
IF OBJECT_ID(N'TB_ChannelDeveloper', N'U') IS NOT NULL DROP TABLE [TB_ChannelDeveloper];
GO
CREATE TABLE [TB_ChannelDeveloper] (
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PerformanceRate] decimal(5,4) NOT NULL,
    CONSTRAINT [PK_TB_ChannelDeveloper] PRIMARY KEY ([ChannelID],[EmployeeID])
);
GO

-- 渠道介绍人
IF OBJECT_ID(N'TB_ChannelIntroducer', N'U') IS NOT NULL DROP TABLE [TB_ChannelIntroducer];
GO
CREATE TABLE [TB_ChannelIntroducer] (
    [ChannelID] int NOT NULL,
    [IntroducerID] int NOT NULL,
    CONSTRAINT [PK_TB_ChannelIntroducer] PRIMARY KEY ([ChannelID],[IntroducerID])
);
GO

-- 渠道等级
IF OBJECT_ID(N'TB_ChannelLevel', N'U') IS NOT NULL DROP TABLE [TB_ChannelLevel];
GO
CREATE TABLE [TB_ChannelLevel] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_ChannelLevel] PRIMARY KEY ([ID])
);
GO

-- 渠道类型
IF OBJECT_ID(N'TB_ChannelType', N'U') IS NOT NULL DROP TABLE [TB_ChannelType];
GO
CREATE TABLE [TB_ChannelType] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_ChannelType] PRIMARY KEY ([ID])
);
GO

-- 渠道拜访
IF OBJECT_ID(N'TB_ChannelVisit', N'U') IS NOT NULL DROP TABLE [TB_ChannelVisit];
GO
CREATE TABLE [TB_ChannelVisit] (
    [ID] int NOT NULL,
    [ChannelID] int NOT NULL,
    [VisitType] nvarchar(50) NOT NULL,
    [VisitBy] nvarchar(50) NOT NULL,
    [VisitStatus] nvarchar(50) NOT NULL,
    [IsPlan] bit NOT NULL,
    [PlannedOn] datetime NOT NULL,
    [PlannedRemark] text NULL,
    [SignInOn] datetime NULL,
    [SignInAddress] nvarchar(200) NULL,
    [SignInLongitude] decimal(13,10) NULL,
    [SignInLatitude] decimal(12,10) NULL,
    [SignInRemark] text NULL,
    [VisitRecord] text NULL,
    [SignOutOn] datetime NULL,
    [SignOutAddress] nvarchar(200) NULL,
    [SignOutLongitude] decimal(13,10) NULL,
    [SignOutLatitude] decimal(12,10) NULL,
    [SignOutRemark] text NULL,
    CONSTRAINT [PK_TB_ChannelVisit] PRIMARY KEY ([ID])
);
GO

-- 渠道协防人员
IF OBJECT_ID(N'TB_ChannelVisitAssistor', N'U') IS NOT NULL DROP TABLE [TB_ChannelVisitAssistor];
GO
CREATE TABLE [TB_ChannelVisitAssistor] (
    [ChannelVisitID] int NOT NULL,
    [AssistBy] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TB_ChannelVisitAssistor] PRIMARY KEY ([ChannelVisitID],[AssistBy])
);
GO

-- 渠道拜访记录附件
IF OBJECT_ID(N'TB_ChannelVisitRecordAttachment', N'U') IS NOT NULL DROP TABLE [TB_ChannelVisitRecordAttachment];
GO
CREATE TABLE [TB_ChannelVisitRecordAttachment] (
    [ID] int NOT NULL,
    [ChannelVisitID] int NOT NULL,
    [AttachmentURL] nvarchar(200) NOT NULL,
    [AttachmentType] int NOT NULL,
    CONSTRAINT [PK_TB_ChannelVisitRecordAttachment] PRIMARY KEY ([ID])
);
GO

-- 渠道拜访签到附件
IF OBJECT_ID(N'TB_ChannelVisitSignInAttachment', N'U') IS NOT NULL DROP TABLE [TB_ChannelVisitSignInAttachment];
GO
CREATE TABLE [TB_ChannelVisitSignInAttachment] (
    [ID] int NOT NULL,
    [ChannelVisitID] int NOT NULL,
    [AttachmentURL] nvarchar(200) NOT NULL,
    [AttachmentType] int NOT NULL,
    CONSTRAINT [PK_TB_ChannelVisitSignInAttachment] PRIMARY KEY ([ID])
);
GO

-- 渠道拜访签退附件
IF OBJECT_ID(N'TB_ChannelVisitSignOutAttachment', N'U') IS NOT NULL DROP TABLE [TB_ChannelVisitSignOutAttachment];
GO
CREATE TABLE [TB_ChannelVisitSignOutAttachment] (
    [ID] int NOT NULL,
    [ChannelVisitID] int NOT NULL,
    [AttachmentURL] nvarchar(200) NOT NULL,
    [AttachmentType] int NOT NULL,
    CONSTRAINT [PK_TB_ChannelVisitSignOutAttachment] PRIMARY KEY ([ID])
);
GO

-- 顾客表
IF OBJECT_ID(N'TB_Customer', N'U') IS NOT NULL DROP TABLE [TB_Customer];
GO
CREATE TABLE [TB_Customer] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [PhoneNumber] nvarchar(50) NOT NULL,
    [Gender] varchar(1) NOT NULL,
    [IsMember] bit NOT NULL,
    [IsLockMemberLevel] bit NOT NULL,
    [MemberOn] datetime NULL,
    [CustomerSourceID] int NULL,
    [ChannelID] int NULL,
    [CustomerLevelID] int NULL,
    [Code] nvarchar(50) NULL,
    [BirthdayType] nvarchar(50) NULL,
    [Birthday] date NULL,
    [Avatar] nvarchar(500) NULL,
    [OpenID] nvarchar(100) NULL,
    [OffiaccountOpenID] nvarchar(100) NULL,
    [UnionID] nvarchar(40) NULL,
    [Introducer] int NULL,
    [ProvinceCode] nvarchar(50) NULL,
    [CityCode] nvarchar(50) NULL,
    [AreaCode] nvarchar(50) NULL,
    [Address] nvarchar(200) NULL,
    [Job] nvarchar(50) NULL,
    [IdentityCard] nvarchar(50) NULL,
    [Remark] nvarchar(200) NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_Customer] PRIMARY KEY ([ID])
);
GO

-- 顾客基本档案
IF OBJECT_ID(N'TB_CustomerBasicFile', N'U') IS NOT NULL DROP TABLE [TB_CustomerBasicFile];
GO
CREATE TABLE [TB_CustomerBasicFile] (
    [ID] int NOT NULL,
    [Name] nvarchar(20) NOT NULL,
    [Type] int NOT NULL,
    [Sequence] int NOT NULL,
    [ComponentsPropert] ntext NULL,
    CONSTRAINT [PK_TB_CustomerBasicFile] PRIMARY KEY ([ID])
);
GO

-- 顾客基本档案信
IF OBJECT_ID(N'TB_CustomerBasicFileInfo', N'U') IS NOT NULL DROP TABLE [TB_CustomerBasicFileInfo];
GO
CREATE TABLE [TB_CustomerBasicFileInfo] (
    [CustomerID] int NOT NULL,
    [CustomerBasicFileID] int NOT NULL,
    [Value] nvarchar(200) NOT NULL,
    CONSTRAINT [PK_TB_CustomerBasicFileInfo] PRIMARY KEY ([CustomerID],[CustomerBasicFileID],[Value])
);
GO

-- 入会门槛
IF OBJECT_ID(N'TB_CustomerCondition', N'U') IS NOT NULL DROP TABLE [TB_CustomerCondition];
GO
CREATE TABLE [TB_CustomerCondition] (
    [Type] nvarchar(50) NOT NULL,
    [Amount] int NULL,
    CONSTRAINT [PK_TB_CustomerCondition] PRIMARY KEY ([Type])
);
GO

-- 入会门槛指定商
IF OBJECT_ID(N'TB_CustomerConditionGood', N'U') IS NOT NULL DROP TABLE [TB_CustomerConditionGood];
GO
CREATE TABLE [TB_CustomerConditionGood] (
    [ID] int NOT NULL,
    [GoodsType] nvarchar(50) NOT NULL,
    [GoodsID] int NOT NULL,
    [CustomerLevelID] int NOT NULL,
    CONSTRAINT [PK_TB_CustomerConditionGood] PRIMARY KEY ([ID])
);
GO

-- 入会门槛指定商品类型
IF OBJECT_ID(N'TB_CustomerConditionGoodsType', N'U') IS NOT NULL DROP TABLE [TB_CustomerConditionGoodsType];
GO
CREATE TABLE [TB_CustomerConditionGoodsType] (
    [GoodsType] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TB_CustomerConditionGoodsType] PRIMARY KEY ([GoodsType])
);
GO

-- 顾客电子病历
IF OBJECT_ID(N'TB_CustomerElectronicMedicalRecord', N'U') IS NOT NULL DROP TABLE [TB_CustomerElectronicMedicalRecord];
GO
CREATE TABLE [TB_CustomerElectronicMedicalRecord] (
    [ID] int NOT NULL,
    [Type] nvarchar(50) NOT NULL,
    [CustomerID] int NOT NULL,
    [Doctor] nvarchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    [TreatmentDate] date NOT NULL,
    [MedicalRecord] ntext NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TB_CustomerElectronicMedicalRecord] PRIMARY KEY ([ID])
);
GO

-- 顾客所在门店
IF OBJECT_ID(N'TB_CustomerEntity', N'U') IS NOT NULL DROP TABLE [TB_CustomerEntity];
GO
CREATE TABLE [TB_CustomerEntity] (
    [ID] int NOT NULL,
    [CustomerID] int NOT NULL,
    [EntityID] int NOT NULL,
    [IsBelongEntity] bit NOT NULL,
    CONSTRAINT [PK_TB_CustomerEntity] PRIMARY KEY ([ID])
);
GO

-- 顾客文件档案
IF OBJECT_ID(N'TB_CustomerFile', N'U') IS NOT NULL DROP TABLE [TB_CustomerFile];
GO
CREATE TABLE [TB_CustomerFile] (
    [ID] int NOT NULL,
    [CustomerFileCategoryID] int NULL,
    [CustomerID] int NOT NULL,
    [Remark] text NULL,
    [CreatedBy] varchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_CustomerFile] PRIMARY KEY ([ID])
);
GO

-- 顾客档案应用场景
IF OBJECT_ID(N'TB_CustomerFileApplicationScene', N'U') IS NOT NULL DROP TABLE [TB_CustomerFileApplicationScene];
GO
CREATE TABLE [TB_CustomerFileApplicationScene] (
    [Code] nvarchar(50) NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Type] int NOT NULL,
    [AllowEdit] bit NOT NULL,
    [IsRequired] bit NOT NULL,
    [Sequence] int NOT NULL,
    CONSTRAINT [PK_TB_CustomerFileApplicationScene] PRIMARY KEY ([Code])
);
GO

-- 顾客文件附件
IF OBJECT_ID(N'TB_CustomerFileAttachment', N'U') IS NOT NULL DROP TABLE [TB_CustomerFileAttachment];
GO
CREATE TABLE [TB_CustomerFileAttachment] (
    [ID] int NOT NULL,
    [Name] nvarchar(200) NOT NULL,
    [MimeType] nvarchar(50) NOT NULL,
    [CustomerFileID] int NOT NULL,
    [AttachmentURL] nvarchar(200) NOT NULL,
    [AttachmentType] int NOT NULL,
    CONSTRAINT [PK_TB_CustomerFileAttachment] PRIMARY KEY ([ID])
);
GO

-- 顾客文件类别
IF OBJECT_ID(N'TB_CustomerFileCategory', N'U') IS NOT NULL DROP TABLE [TB_CustomerFileCategory];
GO
CREATE TABLE [TB_CustomerFileCategory] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_CustomerFileCategory] PRIMARY KEY ([ID])
);
GO

-- 顾客成长值
IF OBJECT_ID(N'TB_CustomerGrowth', N'U') IS NOT NULL DROP TABLE [TB_CustomerGrowth];
GO
CREATE TABLE [TB_CustomerGrowth] (
    [ID] int NOT NULL,
    [CustomerID] int NOT NULL,
    [CustomerGrowthTypeID] nvarchar(50) NOT NULL,
    [GrowthValue] decimal(18,2) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TB_CustomerGrowth] PRIMARY KEY ([ID])
);
GO

-- 顾客成长值配置
IF OBJECT_ID(N'TB_CustomerGrowthConfig', N'U') IS NOT NULL DROP TABLE [TB_CustomerGrowthConfig];
GO
CREATE TABLE [TB_CustomerGrowthConfig] (
    [CustomerGrowthTypeCode] nvarchar(50) NOT NULL,
    [CustomerGrowthPay
ChannelType] nvarchar(50) NOT NULL,
    [Growth] decimal(18,2) NOT NULL,
    [Limited] bit NOT NULL,
    [DayLimit] int NULL,
    CONSTRAINT [PK_TB_CustomerGrowthConfig] PRIMARY KEY ([CustomerGrowthTypeCode],[CustomerGrowthPay
ChannelType])
);
GO

-- 顾客成长值支付
方式
IF OBJECT_ID(N'TB_CustomerGrowthPayChannelType', N'U') IS NOT NULL DROP TABLE [TB_CustomerGrowthPayChannelType];
GO
CREATE TABLE [TB_CustomerGrowthPayChannelType] (
    [Code] nvarchar(50) NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    CONSTRAINT [PK_TB_CustomerGrowthPayChannelType] PRIMARY KEY ([Code])
);
GO

-- 顾客成长值生成
类型
IF OBJECT_ID(N'TB_CustomerGrowthType', N'U') IS NOT NULL DROP TABLE [TB_CustomerGrowthType];
GO
CREATE TABLE [TB_CustomerGrowthType] (
    [Code] nvarchar(50) NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_CustomerGrowthType] PRIMARY KEY ([Code])
);
GO

-- 顾客等级
IF OBJECT_ID(N'TB_CustomerLevel', N'U') IS NOT NULL DROP TABLE [TB_CustomerLevel];
GO
CREATE TABLE [TB_CustomerLevel] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [LevelValue] int NOT NULL,
    [ReduceLevelValue] int NULL,
    CONSTRAINT [PK_TB_CustomerLevel] PRIMARY KEY ([ID])
);
GO

-- 顾客等级设置
IF OBJECT_ID(N'TB_CustomerLevelSetting', N'U') IS NOT NULL DROP TABLE [TB_CustomerLevelSetting];
GO
CREATE TABLE [TB_CustomerLevelSetting] (
    [IsGrowth] bit NULL,
    [IsUpdateCustomerLevel] bit NULL
);
GO

-- 顾客等级有效期
IF OBJECT_ID(N'TB_CustomerLevelValidity', N'U') IS NOT NULL DROP TABLE [TB_CustomerLevelValidity];
GO
CREATE TABLE [TB_CustomerLevelValidity] (
    [CustomerID] int NOT NULL,
    [ModifyOn] datetime NOT NULL,
    [ValidityOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_CustomerLevelValidity] PRIMARY KEY ([CustomerID])
);
GO

-- 顾客项目
IF OBJECT_ID(N'TB_CustomerProject', N'U') IS NOT NULL DROP TABLE [TB_CustomerProject];
GO
CREATE TABLE [TB_CustomerProject] (
    [CustomerID] int NOT NULL,
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    CONSTRAINT [PK_TB_CustomerProject] PRIMARY KEY ([CustomerID],[EntityID],[ProjectID])
);
GO

-- 顾客升降级规则
IF OBJECT_ID(N'TB_CustomerReduceConfig', N'U') IS NOT NULL DROP TABLE [TB_CustomerReduceConfig];
GO
CREATE TABLE [TB_CustomerReduceConfig] (
    [IsReduce] bit NOT NULL,
    [ReduceRule] nvarchar(50) NULL,
    [ReduceMode] nvarchar(50) NULL,
    [VaildModeDay] int NULL,
    [RegularModeType] nvarchar(50) NULL,
    [RegularModeMonth] int NULL,
    [RegularModeUpdate
Date] date NULL
);
GO

-- 顾客服务人员
IF OBJECT_ID(N'TB_CustomerServicer', N'U') IS NOT NULL DROP TABLE [TB_CustomerServicer];
GO
CREATE TABLE [TB_CustomerServicer] (
    [CustomerID] int NOT NULL,
    [ServicerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TB_CustomerServicer] PRIMARY KEY ([CustomerID],[ServicerID],[EmployeeID])
);
GO

-- 顾客来源
IF OBJECT_ID(N'TB_CustomerSource', N'U') IS NOT NULL DROP TABLE [TB_CustomerSource];
GO
CREATE TABLE [TB_CustomerSource] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [ParentID] int NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_CustomerSource] PRIMARY KEY ([ID])
);
GO

-- 顾客标签
IF OBJECT_ID(N'TB_CustomerTag', N'U') IS NOT NULL DROP TABLE [TB_CustomerTag];
GO
CREATE TABLE [TB_CustomerTag] (
    [CustomerID] int NOT NULL,
    [CustomerTagID] int NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_CustomerTag] PRIMARY KEY ([CustomerID],[CustomerTagID])
);
GO

-- 接诊记录
IF OBJECT_ID(N'TB_DiagnosisRecord', N'U') IS NOT NULL DROP TABLE [TB_DiagnosisRecord];
GO
CREATE TABLE [TB_DiagnosisRecord] (
    [ID] int NOT NULL,
    [AppointmentBillID] nvarchar(50) NOT NULL,
    [CustomerID] int NOT NULL,
    [IsDiagnosis] bit NOT NULL,
    [Guidance] nvarchar(100) NULL,
    [DiagnosisContent] text NULL,
    [DiagnosisOn] datetime NULL,
    [DiagnosisBy] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TB_DiagnosisRecord] PRIMARY KEY ([ID])
);
GO

-- 接诊记录附件
IF OBJECT_ID(N'TB_DiagnosisRecordAttachment', N'U') IS NOT NULL DROP TABLE [TB_DiagnosisRecordAttachment];
GO
CREATE TABLE [TB_DiagnosisRecordAttachment] (
    [ID] int NOT NULL,
    [DiagnosisRecordID] int NOT NULL,
    [AttachmentURL] nvarchar(200) NOT NULL,
    [AttachmentType] int NOT NULL,
    CONSTRAINT [PK_TB_DiagnosisRecordAttachment] PRIMARY KEY ([ID])
);
GO

-- 电子病历类别
IF OBJECT_ID(N'TB_ElectronicMedicalRecord
Category', N'U') IS NOT NULL DROP TABLE [TB_ElectronicMedicalRecord
Category];
GO
CREATE TABLE [TB_ElectronicMedicalRecord
Category] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    CONSTRAINT [PK_TB_ElectronicMedicalRecord
Category] PRIMARY KEY ([ID])
);
GO

-- 电子病历模板
IF OBJECT_ID(N'TB_ElectronicMedicalRecordTemplate', N'U') IS NOT NULL DROP TABLE [TB_ElectronicMedicalRecordTemplate];
GO
CREATE TABLE [TB_ElectronicMedicalRecordTemplate] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [ElectronicMedicalRe
cordCategoryID] int NOT NULL,
    [Template] ntext NOT NULL,
    [Sequence] int NOT NULL,
    CONSTRAINT [PK_TB_ElectronicMedicalRecordTemplate] PRIMARY KEY ([ID])
);
GO

-- 员工权限门店
IF OBJECT_ID(N'TB_EmployeeEntityPermissio', N'U') IS NOT NULL DROP TABLE [TB_EmployeeEntityPermissio];
GO
CREATE TABLE [TB_EmployeeEntityPermissio] (
    [EmployeeID] nvarchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_EmployeeEntityPermissio] PRIMARY KEY ([EmployeeID],[EntityID])
);
GO

-- 员工登录门店
IF OBJECT_ID(N'TB_EmployeeLoginEntity', N'U') IS NOT NULL DROP TABLE [TB_EmployeeLoginEntity];
GO
CREATE TABLE [TB_EmployeeLoginEntity] (
    [EmployeeID] nvarchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_EmployeeLoginEntity] PRIMARY KEY ([EmployeeID])
);
GO

-- 小程序员工登录
门店
IF OBJECT_ID(N'TB_EmployeeLoginEntityMini
Program', N'U') IS NOT NULL DROP TABLE [TB_EmployeeLoginEntityMini
Program];
GO
CREATE TABLE [TB_EmployeeLoginEntityMini
Program] (
    [EmployeeID] nvarchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_EmployeeLoginEntityMini
Program] PRIMARY KEY ([EmployeeID])
);
GO

-- 员工角色
IF OBJECT_ID(N'TB_EmployeeRole', N'U') IS NOT NULL DROP TABLE [TB_EmployeeRole];
GO
CREATE TABLE [TB_EmployeeRole] (
    [EmployeeID] nvarchar(50) NOT NULL,
    [RoleID] int NOT NULL,
    CONSTRAINT [PK_TB_EmployeeRole] PRIMARY KEY ([EmployeeID],[RoleID])
);
GO

-- 门店预约仪器
IF OBJECT_ID(N'TB_EntityInstrument', N'U') IS NOT NULL DROP TABLE [TB_EntityInstrument];
GO
CREATE TABLE [TB_EntityInstrument] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [Name] varchar(50) NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_EntityInstrument] PRIMARY KEY ([ID])
);
GO

-- 门店预约房间
IF OBJECT_ID(N'TB_EntityRoom', N'U') IS NOT NULL DROP TABLE [TB_EntityRoom];
GO
CREATE TABLE [TB_EntityRoom] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [Name] varchar(50) NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_EntityRoom] PRIMARY KEY ([ID])
);
GO

-- 跟进方式
IF OBJECT_ID(N'TB_FollowUpMethod', N'U') IS NOT NULL DROP TABLE [TB_FollowUpMethod];
GO
CREATE TABLE [TB_FollowUpMethod] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_FollowUpMethod] PRIMARY KEY ([ID])
);
GO

-- 跟进记录
IF OBJECT_ID(N'TB_FollowUpRecord', N'U') IS NOT NULL DROP TABLE [TB_FollowUpRecord];
GO
CREATE TABLE [TB_FollowUpRecord] (
    [ID] int NOT NULL,
    [CustomerID] int NOT NULL,
    [FollowUpMethodID] int NULL,
    [FollowUpStatusID] int NULL,
    [FollowUpContent] text NULL,
    [IsFollowUp] bit NOT NULL,
    [PlannedOn] datetime NOT NULL,
    [PlannedRemark] text NULL,
    [FollowUpOn] datetime NULL,
    [FollowUpBy] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TB_FollowUpRecord] PRIMARY KEY ([ID])
);
GO

-- 跟进记录附件
IF OBJECT_ID(N'TB_FollowUpRecordAttachment', N'U') IS NOT NULL DROP TABLE [TB_FollowUpRecordAttachment];
GO
CREATE TABLE [TB_FollowUpRecordAttachment] (
    [ID] int NOT NULL,
    [FollowUpRecordID] int NOT NULL,
    [AttachmentURL] nvarchar(200) NOT NULL,
    [AttachmentType] int NOT NULL,
    CONSTRAINT [PK_TB_FollowUpRecordAttachment] PRIMARY KEY ([ID])
);
GO

-- 跟进规则
IF OBJECT_ID(N'TB_FollowUpRule', N'U') IS NOT NULL DROP TABLE [TB_FollowUpRule];
GO
CREATE TABLE [TB_FollowUpRule] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [FollowUpMethodID] int NOT NULL,
    [ServicerID] int NULL,
    [EmployeeID] nvarchar(50) NULL,
    [ScheduleType] nvarchar(50) NOT NULL,
    [ScheduleInterval] int NULL,
    [ScheduleBeginDate] datetime NOT NULL,
    [ScheduleEndDate] datetime NOT NULL,
    [FollowUpContent] nvarchar(200) NULL,
    [Active] bit NOT NULL,
    [LastExecutionDate] datetime NULL,
    CONSTRAINT [PK_TB_FollowUpRule] PRIMARY KEY ([ID])
);
GO

-- 跟进规则条件
IF OBJECT_ID(N'TB_FollowUpRuleCondition', N'U') IS NOT NULL DROP TABLE [TB_FollowUpRuleCondition];
GO
CREATE TABLE [TB_FollowUpRuleCondition] (
    [Code] nvarchar(50) NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Type] nvarchar(50) NOT NULL,
    [Sequence
Active] int
bit NOT NULL,
    CONSTRAINT [PK_TB_FollowUpRuleCondition] PRIMARY KEY ([Code])
);
GO

-- 跟进规则适用门
IF OBJECT_ID(N'TB_FollowUpRuleEntity', N'U') IS NOT NULL DROP TABLE [TB_FollowUpRuleEntity];
GO
CREATE TABLE [TB_FollowUpRuleEntity] (
    [FollowUpRuleID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_FollowUpRuleEntity] PRIMARY KEY ([FollowUpRuleID],[EntityID])
);
GO

-- 跟进规则条件值
IF OBJECT_ID(N'TB_FollowUpRuleFilterCondition', N'U') IS NOT NULL DROP TABLE [TB_FollowUpRuleFilterCondition];
GO
CREATE TABLE [TB_FollowUpRuleFilterCondition] (
    [FollowUpRuleID] int NOT NULL,
    [FollowUpConditionI] nvarchar(50) NOT NULL,
    [Value] nvarchar(200) NOT NULL,
    CONSTRAINT [PK_TB_FollowUpRuleFilterCondition] PRIMARY KEY ([FollowUpRuleID],[FollowUpConditionI])
);
GO

-- 跟进状态
IF OBJECT_ID(N'TB_FollowUpStatus', N'U') IS NOT NULL DROP TABLE [TB_FollowUpStatus];
GO
CREATE TABLE [TB_FollowUpStatus] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_FollowUpStatus] PRIMARY KEY ([ID])
);
GO

-- 通用次卡管理
IF OBJECT_ID(N'TB_GeneralCard', N'U') IS NOT NULL DROP TABLE [TB_GeneralCard];
GO
CREATE TABLE [TB_GeneralCard] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [NameFullPinYin] nvarchar(200) NULL,
    [NameAbbrPinYin] nvarchar(50) NULL,
    [Alias] nvarchar(50) NULL,
    [AliasFullPinYin] nvarchar(200) NULL,
    [AliasAbbrPinYin] nvarchar(200) NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Amount] int NOT NULL,
    [TreatProjectNumber] int NOT NULL,
    [SaleStartDate] date NOT NULL,
    [SaleEndingDate] date NOT NULL,
    [ValidType] int NOT NULL,
    [ValidDay] int NULL,
    [IsAllowSell] bit NOT NULL,
    [IsAllowLargess] bit NOT NULL,
    [Remark] nvarchar(200) NULL,
    [Memo] ntext NULL,
    CONSTRAINT [PK_TB_GeneralCard] PRIMARY KEY ([ID])
);
GO

-- 通用次卡账户
IF OBJECT_ID(N'TB_GeneralCardAccount', N'U') IS NOT NULL DROP TABLE [TB_GeneralCardAccount];
GO
CREATE TABLE [TB_GeneralCardAccount] (
    [ID] int NOT NULL,
    [CustomerID] int NOT NULL,
    [EntityID] int NOT NULL,
    [BuyDate] datetime NOT NULL,
    [GeneralCardID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [CardTimes] int NOT NULL,
    [PayAmount] decimal(18,2) NOT NULL,
    [SavingCardDeductionAmount] decimal(18,2) NOT NULL,
    [SavingCardDeductio
nLargessAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [Balance] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [ValidType] int NOT NULL,
    [ValidDay] int NULL,
    [ValidDate] datetime NULL,
    [SaleBillGeneralCardI] int NULL,
    [PackageCardAccountID] int NULL,
    [SaleBillPackageCard
GeneralCardID] int NULL,
    [PayPerformanceBala
nceAmount] decimal(18,2) NOT NULL,
    [CardPerformanceBal
anceAmount] decimal(18,2) NOT NULL,
    [CardLargessPerform
anceBalanceAmount] decimal(18,2) NOT NULL,
    [LargessPerformance
BalanceAmount] decimal(18,2) NOT NULL,
    [Channel] varchar(2) NOT NULL,
    [Active] bit NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TB_GeneralCardAccount] PRIMARY KEY ([ID])
);
GO

-- 通用次卡平账记录
IF OBJECT_ID(N'TB_GeneralCardAccountArre
arAmountProcess', N'U') IS NOT NULL DROP TABLE [TB_GeneralCardAccountArre
arAmountProcess];
GO
CREATE TABLE [TB_GeneralCardAccountArre
arAmountProcess] (
    [ID] int NOT NULL,
    [GeneralCardAccount
ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [BeforeArrearAmount] decimal(18,2) NOT NULL,
    [AfterArrearAmount] decimal(18,2) NOT NULL,
    [BeforeQuantity] int NOT NULL,
    [AfterQuantity] int NOT NULL,
    [PackageCardAccoun
tArrearAmountProce
ssID] int NULL,
    [CreatedBy] varchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_GeneralCardAccountArre
arAmountProcess] PRIMARY KEY ([ID])
);
GO

-- 通用次卡类别
IF OBJECT_ID(N'TB_GeneralCardCategory', N'U') IS NOT NULL DROP TABLE [TB_GeneralCardCategory];
GO
CREATE TABLE [TB_GeneralCardCategory] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_GeneralCardCategory] PRIMARY KEY ([ID])
);
GO

-- 通用次卡消耗适用门店
IF OBJECT_ID(N'TB_GeneralCardConsumeEntity', N'U') IS NOT NULL DROP TABLE [TB_GeneralCardConsumeEntity];
GO
CREATE TABLE [TB_GeneralCardConsumeEntity] (
    [GeneralCardID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_GeneralCardConsumeEntity] PRIMARY KEY ([GeneralCardID],[EntityID])
);
GO

-- 通用次卡图片
IF OBJECT_ID(N'TB_GeneralCardImage', N'U') IS NOT NULL DROP TABLE [TB_GeneralCardImage];
GO
CREATE TABLE [TB_GeneralCardImage] (
    [ID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ImageURL] nvarchar(200) NOT NULL,
    [Sequence] int NOT NULL,
    CONSTRAINT [PK_TB_GeneralCardImage] PRIMARY KEY ([ID])
);
GO

-- 通用次卡价格修
改适用门店
IF OBJECT_ID(N'TB_GeneralCardModifyPriceEntity', N'U') IS NOT NULL DROP TABLE [TB_GeneralCardModifyPriceEntity];
GO
CREATE TABLE [TB_GeneralCardModifyPriceEntity] (
    [GeneralCardID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_GeneralCardModifyPriceEntity] PRIMARY KEY ([GeneralCardID],[EntityID])
);
GO

-- 通用次卡价格调整
IF OBJECT_ID(N'TB_GeneralCardPriceAdjustment', N'U') IS NOT NULL DROP TABLE [TB_GeneralCardPriceAdjustment];
GO
CREATE TABLE [TB_GeneralCardPriceAdjustment] (
    [GeneralCardID] int NOT NULL,
    [EntityID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_GeneralCardPriceAdjustment] PRIMARY KEY ([GeneralCardID],[EntityID])
);
GO

-- 通用次卡适应项
IF OBJECT_ID(N'TB_GeneralCardProject', N'U') IS NOT NULL DROP TABLE [TB_GeneralCardProject];
GO
CREATE TABLE [TB_GeneralCardProject] (
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [ConsumeAmount] int NOT NULL,
    [LimitConsumeTimes] int NOT NULL,
    CONSTRAINT [PK_TB_GeneralCardProject] PRIMARY KEY ([GeneralCardID],[ProjectID])
);
GO

-- 通用次卡销售适用门店
IF OBJECT_ID(N'TB_GeneralCardSaleEntity', N'U') IS NOT NULL DROP TABLE [TB_GeneralCardSaleEntity];
GO
CREATE TABLE [TB_GeneralCardSaleEntity] (
    [GeneralCardID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_GeneralCardSaleEntity] PRIMARY KEY ([GeneralCardID],[EntityID])
);
GO

-- 通用次卡销售经手人
IF OBJECT_ID(N'TB_GeneralCardSaleHandler', N'U') IS NOT NULL DROP TABLE [TB_GeneralCardSaleHandler];
GO
CREATE TABLE [TB_GeneralCardSaleHandler] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_GeneralCardSaleHandler] PRIMARY KEY ([ID])
);
GO

-- 通用次卡销售经
手人适应职务
IF OBJECT_ID(N'TB_GeneralCardSaleHandlerJobType', N'U') IS NOT NULL DROP TABLE [TB_GeneralCardSaleHandlerJobType];
GO
CREATE TABLE [TB_GeneralCardSaleHandlerJobType] (
    [GeneralCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TB_GeneralCardSaleHandlerJobType] PRIMARY KEY ([GeneralCardSaleHandlerID],[JobTypeID])
);
GO

-- 商品展示
IF OBJECT_ID(N'TB_GoodsDisplay', N'U') IS NOT NULL DROP TABLE [TB_GoodsDisplay];
GO
CREATE TABLE [TB_GoodsDisplay] (
    [ID] int NOT NULL,
    [Name] nvarchar(200) NOT NULL,
    [CategoryID] int NOT NULL,
    [Price] decimal(18,2) NULL,
    [ImageURL] nvarchar(256) NULL,
    [Memo] ntext NULL,
    CONSTRAINT [PK_TB_GoodsDisplay] PRIMARY KEY ([ID])
);
GO

-- 商品展示类别
IF OBJECT_ID(N'TB_GoodsDisplayCategory', N'U') IS NOT NULL DROP TABLE [TB_GoodsDisplayCategory];
GO
CREATE TABLE [TB_GoodsDisplayCategory] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [ParentID] int NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    [ImageURL] nvarchar(256) NULL,
    [Memo] ntext NULL,
    CONSTRAINT [PK_TB_GoodsDisplayCategory] PRIMARY KEY ([ID])
);
GO

-- 菜单权限
IF OBJECT_ID(N'TB_MenuPermission', N'U') IS NOT NULL DROP TABLE [TB_MenuPermission];
GO
CREATE TABLE [TB_MenuPermission] (
    [Code] nvarchar(100) NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [ParentCode] nvarchar(100) NOT NULL,
    [Type] nvarchar(1) NOT NULL,
    [IsMenu] bit NOT NULL,
    [IsVerifyStore] bit NOT NULL,
    [IsVerifyWarehouse] bit NOT NULL,
    [IconStyle] nvarchar(50) NULL,
    [RouterPath] nvarchar(100) NULL,
    [RouterComponentPath] nvarchar(100) NULL,
    [RouterName] nvarchar(100) NULL,
    [ExternalLinks] nvarchar(100) NULL,
    [Sequence] int NOT NULL,
    CONSTRAINT [PK_TB_MenuPermission] PRIMARY KEY ([Code])
);
GO

-- 微信推送消息类
IF OBJECT_ID(N'TB_MessageCategory', N'U') IS NOT NULL DROP TABLE [TB_MessageCategory];
GO
CREATE TABLE [TB_MessageCategory] (
    [Code] nvarchar(50) NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Type] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    CONSTRAINT [PK_TB_MessageCategory] PRIMARY KEY ([Code])
);
GO

-- 维信消息推送配
IF OBJECT_ID(N'TB_MessageConfig', N'U') IS NOT NULL DROP TABLE [TB_MessageConfig];
GO
CREATE TABLE [TB_MessageConfig] (
    [Code] nvarchar(50) NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [MessageCategoryCode] nvarchar(50) NOT NULL,
    [IsSendWechat] bit NOT NULL,
    [WechatEnterpriseTemplate] nvarchar(50) NULL,
    [WechatPublicLibrary
Template] nvarchar(50) NULL,
    [Sequence] int NOT NULL,
    [LastExecutionDate] date NULL,
    CONSTRAINT [PK_TB_MessageConfig] PRIMARY KEY ([Code])
);
GO

-- 服务日志记录
IF OBJECT_ID(N'TB_NursingLog', N'U') IS NOT NULL DROP TABLE [TB_NursingLog];
GO
CREATE TABLE [TB_NursingLog] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [CustomerID] int NOT NULL,
    [NursingLogContent] text NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_NursingLog] PRIMARY KEY ([ID])
);
GO

-- 服务日志音频
IF OBJECT_ID(N'TB_NursingLogAudio', N'U') IS NOT NULL DROP TABLE [TB_NursingLogAudio];
GO
CREATE TABLE [TB_NursingLogAudio] (
    [ID] int NOT NULL,
    [NursingLogID] int NOT NULL,
    [AudioURL] varchar(200) NOT NULL,
    [AudioTimeLength] int NULL,
    CONSTRAINT [PK_TB_NursingLogAudio] PRIMARY KEY ([ID])
);
GO

-- 服务日志评论
IF OBJECT_ID(N'TB_NursingLogComment', N'U') IS NOT NULL DROP TABLE [TB_NursingLogComment];
GO
CREATE TABLE [TB_NursingLogComment] (
    [ID] int NOT NULL,
    [NursingLogID] int NOT NULL,
    [CommentType] int NOT NULL,
    [Comment] varchar(200) NULL,
    [AudioURL] varchar(200) NULL,
    [CreatedBy] varchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [ReplyID] int NULL,
    CONSTRAINT [PK_TB_NursingLogComment] PRIMARY KEY ([ID])
);
GO

-- 服务日志媒体
IF OBJECT_ID(N'TB_NursingLogMedia', N'U') IS NOT NULL DROP TABLE [TB_NursingLogMedia];
GO
CREATE TABLE [TB_NursingLogMedia] (
    [ID] int NOT NULL,
    [NursingLogID] int NOT NULL,
    [MediaURL] varchar(200) NOT NULL,
    [MediaType] int NOT NULL,
    CONSTRAINT [PK_TB_NursingLogMedia] PRIMARY KEY ([ID])
);
GO

-- 服务日志标签
IF OBJECT_ID(N'TB_NursingLogTag', N'U') IS NOT NULL DROP TABLE [TB_NursingLogTag];
GO
CREATE TABLE [TB_NursingLogTag] (
    [ID] int NOT NULL,
    [NursingLogID] int NOT NULL,
    [TagID] int NOT NULL,
    CONSTRAINT [PK_TB_NursingLogTag] PRIMARY KEY ([ID])
);
GO

-- 服务日志点赞
IF OBJECT_ID(N'TB_NursingLogThumbsUp', N'U') IS NOT NULL DROP TABLE [TB_NursingLogThumbsUp];
GO
CREATE TABLE [TB_NursingLogThumbsUp] (
    [ID] int NOT NULL,
    [NursingLogID] int NOT NULL,
    [CreatedBy] varchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_NursingLogThumbsUp] PRIMARY KEY ([ID])
);
GO

-- 套餐卡管理
IF OBJECT_ID(N'TB_PackageCard', N'U') IS NOT NULL DROP TABLE [TB_PackageCard];
GO
CREATE TABLE [TB_PackageCard] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [NameFullPinYin] nvarchar(200) NULL,
    [NameAbbrPinYin] nvarchar(50) NULL,
    [Alias] nvarchar(50) NULL,
    [AliasFullPinYin] nvarchar(200) NULL,
    [AliasAbbrPinYin] nvarchar(200) NULL,
    [PackageCardCategoryID] int NOT NULL,
    [SaleStartDate] date NOT NULL,
    [SaleEndingDate] date NOT NULL,
    [ValidType] int NOT NULL,
    [ValidDay] int NULL,
    [IsAllowLargess] bit NOT NULL,
    [IsAllowSell] bit NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Remark] nvarchar(200) NULL,
    [Memo] ntext NULL,
    CONSTRAINT [PK_TB_PackageCard] PRIMARY KEY ([ID])
);
GO

-- 套餐卡账户
IF OBJECT_ID(N'TB_PackageCardAccount', N'U') IS NOT NULL DROP TABLE [TB_PackageCardAccount];
GO
CREATE TABLE [TB_PackageCardAccount] (
    [ID] int NOT NULL,
    [CustomerID] int NOT NULL,
    [EntityID] int NOT NULL,
    [BuyDate] datetime NOT NULL,
    [PackageCardID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [PayAmount] decimal(18,2) NOT NULL,
    [SavingCardDeductionAmount] decimal(18,2) NOT NULL,
    [SavingCardDeductio
nLargessAmount] decimal(18,2) NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [IsLargess] bit NOT NULL,
    [ValidType] int NOT NULL,
    [ValidDay] int NULL,
    [ValidDate] datetime NULL,
    [SaleBillPackageCardID] int NULL,
    [Channel] varchar(2) NOT NULL,
    [Active] bit NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TB_PackageCardAccount] PRIMARY KEY ([ID])
);
GO

-- 套餐卡账户平账
记录
IF OBJECT_ID(N'TB_PackageCardAccountArre
arAmountProcess', N'U') IS NOT NULL DROP TABLE [TB_PackageCardAccountArre
arAmountProcess];
GO
CREATE TABLE [TB_PackageCardAccountArre
arAmountProcess] (
    [ID] int NOT NULL,
    [PackageCardAccountID] int NOT NULL,
    [EntityID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [BeforeArrearAmount] decimal(18,2) NOT NULL,
    [AfterArrearAmount] decimal(18,2) NOT NULL,
    [CreatedBy] varchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_PackageCardAccountArre
arAmountProcess] PRIMARY KEY ([ID])
);
GO

-- 套餐卡类别
IF OBJECT_ID(N'TB_PackageCardCategory', N'U') IS NOT NULL DROP TABLE [TB_PackageCardCategory];
GO
CREATE TABLE [TB_PackageCardCategory] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_PackageCardCategory] PRIMARY KEY ([ID])
);
GO

-- 套餐卡里通用次
IF OBJECT_ID(N'TB_PackageCardGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_PackageCardGeneralCard];
GO
CREATE TABLE [TB_PackageCardGeneralCard] (
    [ID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Amount] int NOT NULL,
    [TotalPrice] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_PackageCardGeneralCard] PRIMARY KEY ([ID])
);
GO

-- 套餐卡图片
IF OBJECT_ID(N'TB_PackageCardImage', N'U') IS NOT NULL DROP TABLE [TB_PackageCardImage];
GO
CREATE TABLE [TB_PackageCardImage] (
    [ID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ImageURL] nvarchar(200) NOT NULL,
    [Sequence] int NOT NULL,
    CONSTRAINT [PK_TB_PackageCardImage] PRIMARY KEY ([ID])
);
GO

-- 套餐卡价格修改
适用门店
IF OBJECT_ID(N'TB_PackageCardModifyPrice
Entity', N'U') IS NOT NULL DROP TABLE [TB_PackageCardModifyPrice
Entity];
GO
CREATE TABLE [TB_PackageCardModifyPrice
Entity] (
    [PackageCardID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_PackageCardModifyPrice
Entity] PRIMARY KEY ([PackageCardID],[EntityID])
);
GO

-- 套餐卡里产品
IF OBJECT_ID(N'TB_PackageCardProduct', N'U') IS NOT NULL DROP TABLE [TB_PackageCardProduct];
GO
CREATE TABLE [TB_PackageCardProduct] (
    [ID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Amount] int NOT NULL,
    [TotalPrice] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_PackageCardProduct] PRIMARY KEY ([ID])
);
GO

-- 套餐卡里项目
IF OBJECT_ID(N'TB_PackageCardProject', N'U') IS NOT NULL DROP TABLE [TB_PackageCardProject];
GO
CREATE TABLE [TB_PackageCardProject] (
    [ID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Amount] int NOT NULL,
    [TotalPrice] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_PackageCardProject] PRIMARY KEY ([ID])
);
GO

-- 套餐卡替换产品
IF OBJECT_ID(N'TB_PackageCardReplaceProduct', N'U') IS NOT NULL DROP TABLE [TB_PackageCardReplaceProduct];
GO
CREATE TABLE [TB_PackageCardReplaceProduct] (
    [PackageCardProduct
ID] int NOT NULL,
    [ProductID] int NOT NULL,
    CONSTRAINT [PK_TB_PackageCardReplaceProduct] PRIMARY KEY ([PackageCardProduct
ID],[ProductID])
);
GO

-- 套餐卡替换项目
IF OBJECT_ID(N'TB_PackageCardReplaceProject', N'U') IS NOT NULL DROP TABLE [TB_PackageCardReplaceProject];
GO
CREATE TABLE [TB_PackageCardReplaceProject] (
    [PackageCardProjectID] int NOT NULL,
    [ProjectID] int NOT NULL,
    CONSTRAINT [PK_TB_PackageCardReplaceProject] PRIMARY KEY ([PackageCardProjectID],[ProjectID])
);
GO

-- 套餐卡销售适用
门店
IF OBJECT_ID(N'TB_PackageCardSaleEntity', N'U') IS NOT NULL DROP TABLE [TB_PackageCardSaleEntity];
GO
CREATE TABLE [TB_PackageCardSaleEntity] (
    [PackageCardID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_PackageCardSaleEntity] PRIMARY KEY ([PackageCardID],[EntityID])
);
GO

-- 套餐卡销售经手
IF OBJECT_ID(N'TB_PackageCardSaleHandler', N'U') IS NOT NULL DROP TABLE [TB_PackageCardSaleHandler];
GO
CREATE TABLE [TB_PackageCardSaleHandler] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_PackageCardSaleHandler] PRIMARY KEY ([ID])
);
GO

-- 套餐卡销售经手
人适用职务
IF OBJECT_ID(N'TB_PackageCardSaleHandlerJobType', N'U') IS NOT NULL DROP TABLE [TB_PackageCardSaleHandlerJobType];
GO
CREATE TABLE [TB_PackageCardSaleHandlerJobType] (
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TB_PackageCardSaleHandlerJobType] PRIMARY KEY ([PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 套餐卡里储值卡
IF OBJECT_ID(N'TB_PackageCardSavingCard', N'U') IS NOT NULL DROP TABLE [TB_PackageCardSavingCard];
GO
CREATE TABLE [TB_PackageCardSavingCard] (
    [ID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Amount] int NOT NULL,
    [TotalPrice] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_PackageCardSavingCard] PRIMARY KEY ([ID])
);
GO

-- 套餐卡里时效卡
IF OBJECT_ID(N'TB_PackageCardTimeCard', N'U') IS NOT NULL DROP TABLE [TB_PackageCardTimeCard];
GO
CREATE TABLE [TB_PackageCardTimeCard] (
    [ID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Amount] int NOT NULL,
    [TotalPrice] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_PackageCardTimeCard] PRIMARY KEY ([ID])
);
GO

-- 支付方式
IF OBJECT_ID(N'TB_PayMethod', N'U') IS NOT NULL DROP TABLE [TB_PayMethod];
GO
CREATE TABLE [TB_PayMethod] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_PayMethod] PRIMARY KEY ([ID])
);
GO

-- 支付方式适用门
IF OBJECT_ID(N'TB_PayMethodEntity', N'U') IS NOT NULL DROP TABLE [TB_PayMethodEntity];
GO
CREATE TABLE [TB_PayMethodEntity] (
    [PayMethodID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_PayMethodEntity] PRIMARY KEY ([PayMethodID],[EntityID])
);
GO

-- 对比照
IF OBJECT_ID(N'TB_PhotoCompare', N'U') IS NOT NULL DROP TABLE [TB_PhotoCompare];
GO
CREATE TABLE [TB_PhotoCompare] (
    [ID] int NOT NULL,
    [CustomerID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TB_PhotoCompare] PRIMARY KEY ([ID])
);
GO

-- 对比照附件
IF OBJECT_ID(N'TB_PhotoCompareAttachme', N'U') IS NOT NULL DROP TABLE [TB_PhotoCompareAttachme];
GO
CREATE TABLE [TB_PhotoCompareAttachme] (
    [ID] int NOT NULL,
    [PhotoCompareID] int NOT NULL,
    [PhotoType] int NOT NULL,
    [AttachmentURL] nvarchar(200) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_PhotoCompareAttachme] PRIMARY KEY ([ID])
);
GO

-- 延期订单
IF OBJECT_ID(N'TB_PostponeBill', N'U') IS NOT NULL DROP TABLE [TB_PostponeBill];
GO
CREATE TABLE [TB_PostponeBill] (
    [ID] varchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    [CustomerID] int NOT NULL,
    [ApprovalStatus] nvarchar(2) NOT NULL,
    [CreatedBy] varchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [PostponeRemark] varchar(500) NULL,
    [Channel] varchar(50) NULL,
    CONSTRAINT [PK_TB_PostponeBill] PRIMARY KEY ([ID])
);
GO

-- 延期订单通用次卡账户
IF OBJECT_ID(N'TB_PostponeBillGeneralCard
Account', N'U') IS NOT NULL DROP TABLE [TB_PostponeBillGeneralCard
Account];
GO
CREATE TABLE [TB_PostponeBillGeneralCard
Account] (
    [PostponeBillID] varchar(50) NOT NULL,
    [GeneralCardAccount
ID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ValidType] int NOT NULL,
    [ValidDay] int NULL,
    [ValidDate] datetime NULL,
    [IsEverlasting] bit NOT NULL,
    [NewValidDate] datetime NULL,
    CONSTRAINT [PK_TB_PostponeBillGeneralCard
Account] PRIMARY KEY ([PostponeBillID],[GeneralCardAccount
ID],[GeneralCardID])
);
GO

-- 延期订单套餐卡
账户
IF OBJECT_ID(N'TB_PostponeBillPackageCard
Account', N'U') IS NOT NULL DROP TABLE [TB_PostponeBillPackageCard
Account];
GO
CREATE TABLE [TB_PostponeBillPackageCard
Account] (
    [PostponeBillID] varchar(50) NOT NULL,
    [PackageCardAccountID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ValidType] int NOT NULL,
    [ValidDay] int NULL,
    [ValidDate] datetime NULL,
    [IsEverlasting] bit NOT NULL,
    [NewValidDate] datetime NULL,
    CONSTRAINT [PK_TB_PostponeBillPackageCard
Account] PRIMARY KEY ([PostponeBillID],[PackageCardAccountID],[PackageCardID])
);
GO

-- 延期订单储值卡
账户
IF OBJECT_ID(N'TB_PostponeBillSavingCardAccount', N'U') IS NOT NULL DROP TABLE [TB_PostponeBillSavingCardAccount];
GO
CREATE TABLE [TB_PostponeBillSavingCardAccount] (
    [PostponeBillID] varchar(50) NOT NULL,
    [SavingCardAccountI] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [ValidType] int NOT NULL,
    [ValidDay] int NULL,
    [ValidDate] datetime NULL,
    [IsEverlasting] bit NOT NULL,
    [NewValidDate] datetime NULL,
    CONSTRAINT [PK_TB_PostponeBillSavingCardAccount] PRIMARY KEY ([PostponeBillID],[SavingCardAccountI],[SavingCardID])
);
GO

-- 延期订单时效卡
账户
IF OBJECT_ID(N'TB_PostponeBillTimeCardAccount', N'U') IS NOT NULL DROP TABLE [TB_PostponeBillTimeCardAccount];
GO
CREATE TABLE [TB_PostponeBillTimeCardAccount] (
    [PostponeBillID] varchar(50) NOT NULL,
    [TimeCardAccountID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ValidType] int NOT NULL,
    [ValidDay] int NULL,
    [ValidDate] datetime NULL,
    [IsEverlasting] bit NOT NULL,
    [NewValidDate] datetime NULL,
    CONSTRAINT [PK_TB_PostponeBillTimeCardAccount] PRIMARY KEY ([PostponeBillID],[TimeCardAccountID],[TimeCardID])
);
GO

-- 延期操作过程
IF OBJECT_ID(N'TB_PostponeProcess', N'U') IS NOT NULL DROP TABLE [TB_PostponeProcess];
GO
CREATE TABLE [TB_PostponeProcess] (
    [ID] int NOT NULL,
    [PostponeBillID] varchar(50) NOT NULL,
    [ApprovalBy] varchar(50) NOT NULL,
    [ApprovalOn] datetime NOT NULL,
    [ApprovalRemark] varchar(500) NULL,
    [ActionType] nvarchar(2) NOT NULL,
    CONSTRAINT [PK_TB_PostponeProcess] PRIMARY KEY ([ID])
);
GO

-- 产品管理
IF OBJECT_ID(N'TB_Product', N'U') IS NOT NULL DROP TABLE [TB_Product];
GO
CREATE TABLE [TB_Product] (
    [ProductID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [OriginalText] nvarchar(50) NULL,
    [IsAllowSell] bit NOT NULL,
    [IsAllowLargess] bit NOT NULL,
    [Memo] ntext NULL,
    CONSTRAINT [PK_TB_Product] PRIMARY KEY ([ProductID])
);
GO

-- 产品账户
IF OBJECT_ID(N'TB_ProductAccount', N'U') IS NOT NULL DROP TABLE [TB_ProductAccount];
GO
CREATE TABLE [TB_ProductAccount] (
    [ID] int NOT NULL,
    [CustomerID] int NULL,
    [EntityID] int NOT NULL,
    [BuyDate] datetime NOT NULL,
    [ProductID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [PayAmount] decimal(18,2) NOT NULL,
    [SavingCardDeductionAmount] decimal(18,2) NOT NULL,
    [SavingCardDeductio
nLargessAmount] decimal(18,2) NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [Balance] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [SaleBillProductID] int NULL,
    [PackageCardAccountID] int NULL,
    [SaleBillPackageCard
ProductID] int NULL,
    [PayPerformanceBala
nceAmount] decimal(18,2) NOT NULL,
    [CardPerformanceBal
anceAmount] decimal(18,2) NOT NULL,
    [CardLargessPerform
anceBalanceAmount] decimal(18,2) NOT NULL,
    [LargessPerformance
BalanceAmount] decimal(18,2) NOT NULL,
    [Channel] varchar(2) NOT NULL,
    [Active] bit NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TB_ProductAccount] PRIMARY KEY ([ID])
);
GO

-- 产品账户欠款平账记录
IF OBJECT_ID(N'TB_ProductAccountArrearAm
ountProcess', N'U') IS NOT NULL DROP TABLE [TB_ProductAccountArrearAm
ountProcess];
GO
CREATE TABLE [TB_ProductAccountArrearAm
ountProcess] (
    [ID] int NOT NULL,
    [ProductAccountID] int NOT NULL,
    [EntityID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [BeforeArrearAmount] decimal(18,2) NOT NULL,
    [AfterArrearAmount] decimal(18,2) NOT NULL,
    [BeforeQuantity] int NOT NULL,
    [AfterQuantity] int NOT NULL,
    [PackageCardAccoun
tArrearAmountProce
ssID] int NULL,
    [CreatedBy] varchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_ProductAccountArrearAm
ountProcess] PRIMARY KEY ([ID])
);
GO

-- 产品图片
IF OBJECT_ID(N'TB_ProductImage', N'U') IS NOT NULL DROP TABLE [TB_ProductImage];
GO
CREATE TABLE [TB_ProductImage] (
    [ID] int NOT NULL,
    [ProductID] int NOT NULL,
    [ImageURL] nvarchar(200) NOT NULL,
    [Sequence] int NOT NULL,
    CONSTRAINT [PK_TB_ProductImage] PRIMARY KEY ([ID])
);
GO

-- 产品价格修改适用门店
IF OBJECT_ID(N'TB_ProductModifyPriceEntity', N'U') IS NOT NULL DROP TABLE [TB_ProductModifyPriceEntity];
GO
CREATE TABLE [TB_ProductModifyPriceEntity] (
    [ProductID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_ProductModifyPriceEntity] PRIMARY KEY ([ProductID],[EntityID])
);
GO

-- 产品调整价格
IF OBJECT_ID(N'TB_ProductPriceAdjustment', N'U') IS NOT NULL DROP TABLE [TB_ProductPriceAdjustment];
GO
CREATE TABLE [TB_ProductPriceAdjustment] (
    [ProductID] int NOT NULL,
    [EntityID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_ProductPriceAdjustment] PRIMARY KEY ([ProductID],[EntityID])
);
GO

-- 产品销售适应门
IF OBJECT_ID(N'TB_ProductSaleEntity', N'U') IS NOT NULL DROP TABLE [TB_ProductSaleEntity];
GO
CREATE TABLE [TB_ProductSaleEntity] (
    [ProductID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_ProductSaleEntity] PRIMARY KEY ([ProductID],[EntityID])
);
GO

-- 产品销售经手人
IF OBJECT_ID(N'TB_ProductSaleHandler', N'U') IS NOT NULL DROP TABLE [TB_ProductSaleHandler];
GO
CREATE TABLE [TB_ProductSaleHandler] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_ProductSaleHandler] PRIMARY KEY ([ID])
);
GO

-- 产品销售经手人
适用职务
IF OBJECT_ID(N'TB_ProductSaleHandlerJobType', N'U') IS NOT NULL DROP TABLE [TB_ProductSaleHandlerJobType];
GO
CREATE TABLE [TB_ProductSaleHandlerJobType] (
    [ProductSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TB_ProductSaleHandlerJobType] PRIMARY KEY ([ProductSaleHandlerID],[JobTypeID])
);
GO

-- 产品消耗经手人
IF OBJECT_ID(N'TB_ProductTreatHandler', N'U') IS NOT NULL DROP TABLE [TB_ProductTreatHandler];
GO
CREATE TABLE [TB_ProductTreatHandler] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_ProductTreatHandler] PRIMARY KEY ([ID])
);
GO

-- 产品消耗经手人
适用职务
IF OBJECT_ID(N'TB_ProductTreatHandlerJobType', N'U') IS NOT NULL DROP TABLE [TB_ProductTreatHandlerJobType];
GO
CREATE TABLE [TB_ProductTreatHandlerJobType] (
    [ProductTreatHandler
ID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TB_ProductTreatHandlerJobType] PRIMARY KEY ([ProductTreatHandler
ID],[JobTypeID])
);
GO

-- 项目管理
IF OBJECT_ID(N'TB_Project', N'U') IS NOT NULL DROP TABLE [TB_Project];
GO
CREATE TABLE [TB_Project] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NULL,
    [NameFullPinYin] nvarchar(200) NULL,
    [NameAbbrPinYin] nvarchar(50) NULL,
    [Alias] nvarchar(50) NULL,
    [AliasFullPinYin] nvarchar(200) NULL,
    [AliasAbbrPinYin] nvarchar(200) NULL,
    [Price] decimal(18,2) NOT NULL,
    [OriginalText] nvarchar(50) NULL,
    [ProjectCategoryID] int NOT NULL,
    [TreatTime] int NULL,
    [IsAllowSell] bit NOT NULL,
    [IsAllowConsume] bit NOT NULL,
    [IsAllowLargess] bit NOT NULL,
    [ProjectBrandID] int NULL,
    [Remark] nvarchar(200) NULL,
    [Memo] ntext NULL,
    CONSTRAINT [PK_TB_Project] PRIMARY KEY ([ID])
);
GO

-- 项目账户
IF OBJECT_ID(N'TB_ProjectAccount', N'U') IS NOT NULL DROP TABLE [TB_ProjectAccount];
GO
CREATE TABLE [TB_ProjectAccount] (
    [ID] int NOT NULL,
    [CustomerID] int NULL,
    [EntityID] int NOT NULL,
    [BuyDate] datetime NOT NULL,
    [ProjectID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [PayAmount] decimal(18,2) NOT NULL,
    [SavingCardDeductionAmount] decimal(18,2) NOT NULL,
    [SavingCardDeductio
nLargessAmount] decimal(18,2) NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [Balance] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [SaleBillProjectID] int NULL,
    [PackageCardAccountID] int NULL,
    [SaleBillPackageCard
ProjectID] int NULL,
    [PayPerformanceBala
nceAmount] decimal(18,2) NOT NULL,
    [CardPerformanceBal
anceAmount] decimal(18,2) NOT NULL,
    [CardLargessPerform
anceBalanceAmount] decimal(18,2) NOT NULL,
    [LargessPerformance
BalanceAmount] decimal(18,2) NOT NULL,
    [Channel] varchar(2) NOT NULL,
    [Active] bit NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TB_ProjectAccount] PRIMARY KEY ([ID])
);
GO

-- 项目账户欠款平账记录
IF OBJECT_ID(N'TB_ProjectAccountArrearAm
ountProcess', N'U') IS NOT NULL DROP TABLE [TB_ProjectAccountArrearAm
ountProcess];
GO
CREATE TABLE [TB_ProjectAccountArrearAm
ountProcess] (
    [ID] int NOT NULL,
    [ProjectAccountID] int NOT NULL,
    [EntityID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [BeforeArrearAmount] decimal(18,2) NOT NULL,
    [AfterArrearAmount] decimal(18,2) NOT NULL,
    [BeforeQuantity] int NOT NULL,
    [AfterQuantity] int NOT NULL,
    [PackageCardAccoun
tArrearAmountProce
ssID] int NULL,
    [CreatedBy] varchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_ProjectAccountArrearAm
ountProcess] PRIMARY KEY ([ID])
);
GO

-- 项目品牌
IF OBJECT_ID(N'TB_ProjectBrand', N'U') IS NOT NULL DROP TABLE [TB_ProjectBrand];
GO
CREATE TABLE [TB_ProjectBrand] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_ProjectBrand] PRIMARY KEY ([ID])
);
GO

-- 项目类别
IF OBJECT_ID(N'TB_ProjectCategory', N'U') IS NOT NULL DROP TABLE [TB_ProjectCategory];
GO
CREATE TABLE [TB_ProjectCategory] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [ParentID] int NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_ProjectCategory] PRIMARY KEY ([ID])
);
GO

-- 项目耗材类别
IF OBJECT_ID(N'TB_ProjectConsumableCategory', N'U') IS NOT NULL DROP TABLE [TB_ProjectConsumableCategory];
GO
CREATE TABLE [TB_ProjectConsumableCategory] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [ParentID] int NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_ProjectConsumableCategory] PRIMARY KEY ([ID])
);
GO

-- 项目耗材模板
IF OBJECT_ID(N'TB_ProjectConsumableTemplate', N'U') IS NOT NULL DROP TABLE [TB_ProjectConsumableTemplate];
GO
CREATE TABLE [TB_ProjectConsumableTemplate] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [ProjectConsumableCategoryID] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_ProjectConsumableTemplate] PRIMARY KEY ([ID])
);
GO

-- 项目耗材模板产品
IF OBJECT_ID(N'TB_ProjectConsumableTempl
ateProduct', N'U') IS NOT NULL DROP TABLE [TB_ProjectConsumableTempl
ateProduct];
GO
CREATE TABLE [TB_ProjectConsumableTempl
ateProduct] (
    [ProjectConsumableTemplateID] int NOT NULL,
    [ProductID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    CONSTRAINT [PK_TB_ProjectConsumableTempl
ateProduct] PRIMARY KEY ([ProjectConsumableTemplateID],[ProductID])
);
GO

-- 项目耗材适用项目
IF OBJECT_ID(N'TB_ProjectConsumableTemplateProject', N'U') IS NOT NULL DROP TABLE [TB_ProjectConsumableTemplateProject];
GO
CREATE TABLE [TB_ProjectConsumableTemplateProject] (
    [ProjectConsumableTemplateID] int NOT NULL,
    [ProjectID] int NOT NULL,
    CONSTRAINT [PK_TB_ProjectConsumableTemplateProject] PRIMARY KEY ([ProjectConsumableTemplateID],[ProjectID])
);
GO

-- 项目耗材适用项目类别
IF OBJECT_ID(N'TB_ProjectConsumableTempl
ateProjectCategory', N'U') IS NOT NULL DROP TABLE [TB_ProjectConsumableTempl
ateProjectCategory];
GO
CREATE TABLE [TB_ProjectConsumableTempl
ateProjectCategory] (
    [ProjectConsumableTemplateID] int NOT NULL,
    [ProjectCategoryID] nchar(10) NOT NULL,
    CONSTRAINT [PK_TB_ProjectConsumableTempl
ateProjectCategory] PRIMARY KEY ([ProjectConsumableTemplateID],[ProjectCategoryID])
);
GO

-- 项目消耗适用门
IF OBJECT_ID(N'TB_ProjectConsumeEntity', N'U') IS NOT NULL DROP TABLE [TB_ProjectConsumeEntity];
GO
CREATE TABLE [TB_ProjectConsumeEntity] (
    [ProjectID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_ProjectConsumeEntity] PRIMARY KEY ([ProjectID],[EntityID])
);
GO

-- 项目图片
IF OBJECT_ID(N'TB_ProjectImage', N'U') IS NOT NULL DROP TABLE [TB_ProjectImage];
GO
CREATE TABLE [TB_ProjectImage] (
    [ID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [ImageURL] nvarchar(200) NOT NULL,
    [Sequence] int NOT NULL,
    CONSTRAINT [PK_TB_ProjectImage] PRIMARY KEY ([ID])
);
GO

-- 项目价格修改适用门店
IF OBJECT_ID(N'TB_ProjectModifyPriceEntity', N'U') IS NOT NULL DROP TABLE [TB_ProjectModifyPriceEntity];
GO
CREATE TABLE [TB_ProjectModifyPriceEntity] (
    [ProjectID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_ProjectModifyPriceEntity] PRIMARY KEY ([ProjectID],[EntityID])
);
GO

-- 项目价格调整
IF OBJECT_ID(N'TB_ProjectPriceAdjustment', N'U') IS NOT NULL DROP TABLE [TB_ProjectPriceAdjustment];
GO
CREATE TABLE [TB_ProjectPriceAdjustment] (
    [ProjectID] int NOT NULL,
    [EntityID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_ProjectPriceAdjustment] PRIMARY KEY ([ProjectID],[EntityID])
);
GO

-- 项目销售适用门
IF OBJECT_ID(N'TB_ProjectSaleEntity', N'U') IS NOT NULL DROP TABLE [TB_ProjectSaleEntity];
GO
CREATE TABLE [TB_ProjectSaleEntity] (
    [ProjectID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_ProjectSaleEntity] PRIMARY KEY ([ProjectID],[EntityID])
);
GO

-- 项目销售经手人
IF OBJECT_ID(N'TB_ProjectSaleHandler', N'U') IS NOT NULL DROP TABLE [TB_ProjectSaleHandler];
GO
CREATE TABLE [TB_ProjectSaleHandler] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_ProjectSaleHandler] PRIMARY KEY ([ID])
);
GO

-- 项目销售经手人
适用职务
IF OBJECT_ID(N'TB_ProjectSaleHandlerJobType', N'U') IS NOT NULL DROP TABLE [TB_ProjectSaleHandlerJobType];
GO
CREATE TABLE [TB_ProjectSaleHandlerJobType] (
    [ProjectSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TB_ProjectSaleHandlerJobType] PRIMARY KEY ([ProjectSaleHandlerID],[JobTypeID])
);
GO

-- 项目标签
IF OBJECT_ID(N'TB_ProjectTag', N'U') IS NOT NULL DROP TABLE [TB_ProjectTag];
GO
CREATE TABLE [TB_ProjectTag] (
    [ProjectID] int NOT NULL,
    [TagID] int NOT NULL,
    CONSTRAINT [PK_TB_ProjectTag] PRIMARY KEY ([ProjectID],[TagID])
);
GO

-- 项目消耗经手人
IF OBJECT_ID(N'TB_ProjectTreatHandler', N'U') IS NOT NULL DROP TABLE [TB_ProjectTreatHandler];
GO
CREATE TABLE [TB_ProjectTreatHandler] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_ProjectTreatHandler] PRIMARY KEY ([ID])
);
GO

-- 项目消耗经手人
适用职务
IF OBJECT_ID(N'TB_ProjectTreatHandlerJobType', N'U') IS NOT NULL DROP TABLE [TB_ProjectTreatHandlerJobType];
GO
CREATE TABLE [TB_ProjectTreatHandlerJobType] (
    [ProjectTreatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TB_ProjectTreatHandlerJobType] PRIMARY KEY ([ProjectTreatHandlerID],[JobTypeID])
);
GO

-- 小票打印设置
IF OBJECT_ID(N'TB_ReceiptConfig', N'U') IS NOT NULL DROP TABLE [TB_ReceiptConfig];
GO
CREATE TABLE [TB_ReceiptConfig] (
    [EntityID] int NOT NULL,
    [PrintWidth] int NOT NULL,
    [PrintQuantity] int NOT NULL,
    [NameEncrypt] bit NOT NULL,
    [MobileEncrypt] bit NOT NULL,
    [SaleGoodsOriginPric] bit NOT NULL,
    [SalePromotions] bit NOT NULL,
    [SaleRefundBuyQuantity] bit NOT NULL,
    [SaleRefundBuyAmount] bit NOT NULL,
    [SaleRefundableAmount] bit NOT NULL,
    [SaleArrearBuyQuantity] bit NOT NULL,
    [SaleArrearBuyAmount] bit NOT NULL,
    [TreatGoodsOriginPrice] bit NOT NULL,
    [TreatPromotions] bit NOT NULL,
    [TreatAmount] bit NOT NULL,
    [WriteTextFirst] nvarchar(50) NULL,
    [WriteTextSecond] nvarchar(50) NULL,
    [EntityAddress] bit NOT NULL,
    [SaleArrearBalanceAmount] bit NOT NULL,
    CONSTRAINT [PK_TB_ReceiptConfig] PRIMARY KEY ([EntityID])
);
GO

-- 退款订单
IF OBJECT_ID(N'TB_RefundSaleBill', N'U') IS NOT NULL DROP TABLE [TB_RefundSaleBill];
GO
CREATE TABLE [TB_RefundSaleBill] (
    [ID] varchar(50) NOT NULL,
    [BillDate] datetime NOT NULL,
    [EntityID] int NOT NULL,
    [CustomerID] int NOT NULL,
    [ApprovalStatus] nvarchar(2) NOT NULL,
    [CreatedBy] varchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [PayAmount] decimal(18,2) NOT NULL,
    [CardDeductionAmount] decimal(18,2) NOT NULL,
    [CardDeductionLargessAmount] decimal(18,2) NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [RefundRemark] varchar(500) NULL,
    [Channel] varchar(50) NULL,
    CONSTRAINT [PK_TB_RefundSaleBill] PRIMARY KEY ([ID])
);
GO

-- 退款订单明细-
通用次卡
IF OBJECT_ID(N'TB_RefundSaleBillGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_RefundSaleBillGeneralCard];
GO
CREATE TABLE [TB_RefundSaleBillGeneralCard] (
    [ID] int NOT NULL,
    [RefundBillID] varchar(50) NOT NULL,
    [GeneralCardAccount
ID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [RefundBillPackageCardID] int NULL,
    CONSTRAINT [PK_TB_RefundSaleBillGeneralCard] PRIMARY KEY ([ID])
);
GO

-- 退款单通用次卡
经手人
IF OBJECT_ID(N'TB_RefundSaleBillHandlerGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_RefundSaleBillHandlerGeneralCard];
GO
CREATE TABLE [TB_RefundSaleBillHandlerGeneralCard] (
    [RefundBillGeneralCardID] int NOT NULL,
    [GeneralCardSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    CONSTRAINT [PK_TB_RefundSaleBillHandlerGeneralCard] PRIMARY KEY ([RefundBillGeneralCardID],[GeneralCardSaleHandlerID],[EmployeeID])
);
GO

-- 退款单套餐卡经手人
IF OBJECT_ID(N'TB_RefundSaleBillHandlerPackageCard', N'U') IS NOT NULL DROP TABLE [TB_RefundSaleBillHandlerPackageCard];
GO
CREATE TABLE [TB_RefundSaleBillHandlerPackageCard] (
    [RefundBillPackageCardID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    CONSTRAINT [PK_TB_RefundSaleBillHandlerPackageCard] PRIMARY KEY ([RefundBillPackageCardID],[PackageCardSaleHandlerID],[EmployeeID])
);
GO

-- 退款单产品经手人
IF OBJECT_ID(N'TB_RefundSaleBillHandlerProduct', N'U') IS NOT NULL DROP TABLE [TB_RefundSaleBillHandlerProduct];
GO
CREATE TABLE [TB_RefundSaleBillHandlerProduct] (
    [RefundBillProductID] int NOT NULL,
    [ProductSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    CONSTRAINT [PK_TB_RefundSaleBillHandlerProduct] PRIMARY KEY ([RefundBillProductID],[ProductSaleHandlerID],[EmployeeID])
);
GO

-- 退款单项目经手人
IF OBJECT_ID(N'TB_RefundSaleBillHandlerProject', N'U') IS NOT NULL DROP TABLE [TB_RefundSaleBillHandlerProject];
GO
CREATE TABLE [TB_RefundSaleBillHandlerProject] (
    [RefundBillProjectID] int NOT NULL,
    [ProjectSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    CONSTRAINT [PK_TB_RefundSaleBillHandlerProject] PRIMARY KEY ([RefundBillProjectID],[ProjectSaleHandlerID],[EmployeeID])
);
GO

-- 退款单储值卡经手人
IF OBJECT_ID(N'TB_RefundSaleBillHandlerSavingCard', N'U') IS NOT NULL DROP TABLE [TB_RefundSaleBillHandlerSavingCard];
GO
CREATE TABLE [TB_RefundSaleBillHandlerSavingCard] (
    [RefundBillSavingCar
dID] int NOT NULL,
    [SavingCardSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    CONSTRAINT [PK_TB_RefundSaleBillHandlerSavingCard] PRIMARY KEY ([RefundBillSavingCar
dID],[SavingCardSaleHandlerID],[EmployeeID])
);
GO

-- 退款单时效卡经手人
IF OBJECT_ID(N'TB_RefundSaleBillHandlerTimeCard', N'U') IS NOT NULL DROP TABLE [TB_RefundSaleBillHandlerTimeCard];
GO
CREATE TABLE [TB_RefundSaleBillHandlerTimeCard] (
    [RefundBillTimeCardID] int NOT NULL,
    [TimeCardSaleHandle
rID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    CONSTRAINT [PK_TB_RefundSaleBillHandlerTimeCard] PRIMARY KEY ([RefundBillTimeCardID],[TimeCardSaleHandle
rID],[EmployeeID])
);
GO

-- 退款单明细-套餐卡
IF OBJECT_ID(N'TB_RefundSaleBillPackageCard', N'U') IS NOT NULL DROP TABLE [TB_RefundSaleBillPackageCard];
GO
CREATE TABLE [TB_RefundSaleBillPackageCard] (
    [ID] int NOT NULL,
    [RefundBillID] varchar(50) NOT NULL,
    [PackageCardAccountID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_RefundSaleBillPackageCard] PRIMARY KEY ([ID])
);
GO

-- 退款订单支付方
IF OBJECT_ID(N'TB_RefundSaleBillPay', N'U') IS NOT NULL DROP TABLE [TB_RefundSaleBillPay];
GO
CREATE TABLE [TB_RefundSaleBillPay] (
    [ID] int NOT NULL,
    [RefundBillID] nvarchar(50) NOT NULL,
    [PayMethodID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_RefundSaleBillPay] PRIMARY KEY ([ID])
);
GO

-- 退款单储值卡抵扣
IF OBJECT_ID(N'TB_RefundSaleBillPaySavingC
ardDeduction', N'U') IS NOT NULL DROP TABLE [TB_RefundSaleBillPaySavingC
ardDeduction];
GO
CREATE TABLE [TB_RefundSaleBillPaySavingC
ardDeduction] (
    [ID] int NOT NULL,
    [RefundBillID] nvarchar(50) NOT NULL,
    [SavingCardAccountI] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_RefundSaleBillPaySavingC
ardDeduction] PRIMARY KEY ([ID])
);
GO

-- 退款单操作过程
IF OBJECT_ID(N'TB_RefundSaleBillProcess', N'U') IS NOT NULL DROP TABLE [TB_RefundSaleBillProcess];
GO
CREATE TABLE [TB_RefundSaleBillProcess] (
    [ID] int NOT NULL,
    [RefundBillID] varchar(50) NOT NULL,
    [ApprovalBy] varchar(50) NOT NULL,
    [ApprovalOn] datetime NOT NULL,
    [ApprovalRemark] varchar(500) NULL,
    [ActionType] nvarchar(2) NOT NULL,
    CONSTRAINT [PK_TB_RefundSaleBillProcess] PRIMARY KEY ([ID])
);
GO

-- 退款单明细-产
IF OBJECT_ID(N'TB_RefundSaleBillProduct', N'U') IS NOT NULL DROP TABLE [TB_RefundSaleBillProduct];
GO
CREATE TABLE [TB_RefundSaleBillProduct] (
    [ID] int NOT NULL,
    [RefundBillID] varchar(50) NOT NULL,
    [ProductAccountID] int NOT NULL,
    [ProductID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [RefundBillPackageCardID] int NULL,
    CONSTRAINT [PK_TB_RefundSaleBillProduct] PRIMARY KEY ([ID])
);
GO

-- 退款单明细-项
IF OBJECT_ID(N'TB_RefundSaleBillProject', N'U') IS NOT NULL DROP TABLE [TB_RefundSaleBillProject];
GO
CREATE TABLE [TB_RefundSaleBillProject] (
    [ID] int NOT NULL,
    [RefundBillID] varchar(50) NOT NULL,
    [ProjectAccountID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [RefundBillPackageCardID] int NULL,
    CONSTRAINT [PK_TB_RefundSaleBillProject] PRIMARY KEY ([ID])
);
GO

-- 退款单明细-储值卡
IF OBJECT_ID(N'TB_RefundSaleBillSavingCard', N'U') IS NOT NULL DROP TABLE [TB_RefundSaleBillSavingCard];
GO
CREATE TABLE [TB_RefundSaleBillSavingCard] (
    [ID] int NOT NULL,
    [RefundBillID] varchar(50) NOT NULL,
    [SavingCardAccountI] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [RefundBillPackageCardID] int NULL,
    CONSTRAINT [PK_TB_RefundSaleBillSavingCard] PRIMARY KEY ([ID])
);
GO

-- 退款单明细-时效卡
IF OBJECT_ID(N'TB_RefundSaleBillTimeCard', N'U') IS NOT NULL DROP TABLE [TB_RefundSaleBillTimeCard];
GO
CREATE TABLE [TB_RefundSaleBillTimeCard] (
    [ID] int NOT NULL,
    [RefundBillID] varchar(50) NOT NULL,
    [TimeCardAccountID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [RefundBillPackageCardID] int NULL,
    [ValidType] int NULL,
    [ValidDay] int NULL,
    [ValidDate] datetime NULL,
    CONSTRAINT [PK_TB_RefundSaleBillTimeCard] PRIMARY KEY ([ID])
);
GO

-- 退消耗订单
IF OBJECT_ID(N'TB_RefundTreatBill', N'U') IS NOT NULL DROP TABLE [TB_RefundTreatBill];
GO
CREATE TABLE [TB_RefundTreatBill] (
    [ID] varchar(50) NOT NULL,
    [BillDate] datetime NOT NULL,
    [EntityID] int NOT NULL,
    [CustomerID] int NOT NULL,
    [ApprovalStatus] nvarchar(2) NOT NULL,
    [CreatedBy] varchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [RefundRemark] varchar(500) NULL,
    [Amount] decimal(18,2) NOT NULL,
    [PayAmount] decimal(18,2) NOT NULL,
    [CardDeductionAmount] decimal(18,2) NOT NULL,
    [Channel] varchar(50) NULL,
    CONSTRAINT [PK_TB_RefundTreatBill] PRIMARY KEY ([ID])
);
GO

-- 退消耗订单明细
-通用次卡
IF OBJECT_ID(N'TB_RefundTreatBillGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_RefundTreatBillGeneralCard];
GO
CREATE TABLE [TB_RefundTreatBillGeneralCard] (
    [ID] int NOT NULL,
    [RefundTreatBillID] varchar(50) NOT NULL,
    [GeneralCardAccount
ID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [CardTreatTimes] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillGeneralCard
ID] int NOT NULL,
    [PackageCardAccountID] int NULL,
    [PackageCardID] int NULL,
    CONSTRAINT [PK_TB_RefundTreatBillGeneralCard] PRIMARY KEY ([ID])
);
GO

-- 退消耗-通用次
卡经手人
IF OBJECT_ID(N'TB_RefundTreatBillHandlerGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_RefundTreatBillHandlerGeneralCard];
GO
CREATE TABLE [TB_RefundTreatBillHandlerGeneralCard] (
    [RefundTreatBillGeneralCardID] int NOT NULL,
    [GeneralCardTreatHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    CONSTRAINT [PK_TB_RefundTreatBillHandlerGeneralCard] PRIMARY KEY ([RefundTreatBillGeneralCardID],[GeneralCardTreatHandlerID],[EmployeeID])
);
GO

-- 退消耗-产品经手人
IF OBJECT_ID(N'TB_RefundTreatBillHandlerProduct', N'U') IS NOT NULL DROP TABLE [TB_RefundTreatBillHandlerProduct];
GO
CREATE TABLE [TB_RefundTreatBillHandlerProduct] (
    [RefundTreatBillProductID] int NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    CONSTRAINT [PK_TB_RefundTreatBillHandlerProduct] PRIMARY KEY ([RefundTreatBillProductID],[ProductTreatHandler
ID],[EmployeeID])
);
GO

-- 退消耗-项目经手人
IF OBJECT_ID(N'TB_RefundTreatBillHandlerProject', N'U') IS NOT NULL DROP TABLE [TB_RefundTreatBillHandlerProject];
GO
CREATE TABLE [TB_RefundTreatBillHandlerProject] (
    [RefundTreatBillProjectID] int NOT NULL,
    [ProjectTreatHandlerI] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    CONSTRAINT [PK_TB_RefundTreatBillHandlerProject] PRIMARY KEY ([RefundTreatBillProjectID],[ProjectTreatHandlerI],[EmployeeID])
);
GO

-- 退消耗-储值卡
经手人
IF OBJECT_ID(N'TB_RefundTreatBillHandlerSavingCard', N'U') IS NOT NULL DROP TABLE [TB_RefundTreatBillHandlerSavingCard];
GO
CREATE TABLE [TB_RefundTreatBillHandlerSavingCard] (
    [RefundTreatBillSavingCardID] int NOT NULL,
    [SavingCardTreatHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    CONSTRAINT [PK_TB_RefundTreatBillHandlerSavingCard] PRIMARY KEY ([RefundTreatBillSavingCardID],[SavingCardTreatHandlerID],[EmployeeID])
);
GO

-- 退消耗-时效卡
经手人
IF OBJECT_ID(N'TB_RefundTreatBillHandlerTimeCard', N'U') IS NOT NULL DROP TABLE [TB_RefundTreatBillHandlerTimeCard];
GO
CREATE TABLE [TB_RefundTreatBillHandlerTimeCard] (
    [RefundTreatBillTime
CardID] int NOT NULL,
    [TimeCardTreatHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    CONSTRAINT [PK_TB_RefundTreatBillHandlerTimeCard] PRIMARY KEY ([RefundTreatBillTime
CardID],[TimeCardTreatHandlerID],[EmployeeID])
);
GO

-- 退消耗操作过程
IF OBJECT_ID(N'TB_RefundTreatBillProcess', N'U') IS NOT NULL DROP TABLE [TB_RefundTreatBillProcess];
GO
CREATE TABLE [TB_RefundTreatBillProcess] (
    [ID] int NOT NULL,
    [RefundTreatBillID] varchar(50) NOT NULL,
    [ApprovalBy] varchar(50) NOT NULL,
    [ApprovalOn] datetime NOT NULL,
    [ApprovalRemark] varchar(500) NULL,
    [ActionType] nvarchar(2) NOT NULL,
    CONSTRAINT [PK_TB_RefundTreatBillProcess] PRIMARY KEY ([ID])
);
GO

-- 退消耗订单明细
-产品
IF OBJECT_ID(N'TB_RefundTreatBillProduct', N'U') IS NOT NULL DROP TABLE [TB_RefundTreatBillProduct];
GO
CREATE TABLE [TB_RefundTreatBillProduct] (
    [ID] int NOT NULL,
    [RefundTreatBillID] varchar(50) NOT NULL,
    [ProductAccountID] int NOT NULL,
    [ProductID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProductID] int NOT NULL,
    [PackageCardAccountID] int NULL,
    [PackageCardID] int NULL,
    CONSTRAINT [PK_TB_RefundTreatBillProduct] PRIMARY KEY ([ID])
);
GO

-- 退消耗订单明细
-项目
IF OBJECT_ID(N'TB_RefundTreatBillProject', N'U') IS NOT NULL DROP TABLE [TB_RefundTreatBillProject];
GO
CREATE TABLE [TB_RefundTreatBillProject] (
    [ID] int NOT NULL,
    [RefundTreatBillID] varchar(50) NOT NULL,
    [ProjectAccountID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProjectID] int NOT NULL,
    [PackageCardAccountID] int NULL,
    [PackageCardID] int NULL,
    CONSTRAINT [PK_TB_RefundTreatBillProject] PRIMARY KEY ([ID])
);
GO

-- 退消耗订单明细
-储值卡
IF OBJECT_ID(N'TB_RefundTreatBillSavingCard', N'U') IS NOT NULL DROP TABLE [TB_RefundTreatBillSavingCard];
GO
CREATE TABLE [TB_RefundTreatBillSavingCard] (
    [ID] int NOT NULL,
    [RefundTreatBillID] varchar(50) NOT NULL,
    [SavingCardAccountI] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [Quantity] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillSavingCardI] int NOT NULL,
    [PackageCardAccountID] int NULL,
    [PackageCardID] int NULL,
    CONSTRAINT [PK_TB_RefundTreatBillSavingCard] PRIMARY KEY ([ID])
);
GO

-- 退消耗订单明细
-时效卡
IF OBJECT_ID(N'TB_RefundTreatBillTimeCard', N'U') IS NOT NULL DROP TABLE [TB_RefundTreatBillTimeCard];
GO
CREATE TABLE [TB_RefundTreatBillTimeCard] (
    [ID] int NOT NULL,
    [RefundTreatBillID] varchar(50) NOT NULL,
    [TimeCardAccountID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillTimeCardID] int NOT NULL,
    [PackageCardAccountID] int NULL,
    [PackageCardID] int NULL,
    CONSTRAINT [PK_TB_RefundTreatBillTimeCard] PRIMARY KEY ([ID])
);
GO

-- 角色
IF OBJECT_ID(N'TB_Role', N'U') IS NOT NULL DROP TABLE [TB_Role];
GO
CREATE TABLE [TB_Role] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TB_Role] PRIMARY KEY ([ID])
);
GO

-- 菜单权限
IF OBJECT_ID(N'TB_RoleMenuPermission', N'U') IS NOT NULL DROP TABLE [TB_RoleMenuPermission];
GO
CREATE TABLE [TB_RoleMenuPermission] (
    [RoleID] int NOT NULL,
    [MenuPermissionCod] nvarchar(100) NOT NULL,
    CONSTRAINT [PK_TB_RoleMenuPermission] PRIMARY KEY ([RoleID],[MenuPermissionCod])
);
GO

-- 销售订单
IF OBJECT_ID(N'TB_SaleBill', N'U') IS NOT NULL DROP TABLE [TB_SaleBill];
GO
CREATE TABLE [TB_SaleBill] (
    [ID] nvarchar(50) NOT NULL,
    [BillDate] datetime NOT NULL,
    [EntityID] int NOT NULL,
    [CustomerID] int NULL,
    [BillType] nvarchar(50) NOT NULL,
    [BillStatus] nvarchar(50) NOT NULL,
    [EmployeeID] nvarchar(50) NULL,
    [Amount] decimal(18,2) NOT NULL,
    [PayAmount] decimal(18,2) NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [CardDeductionAmount] decimal(18,2) NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NOT NULL,
    [CardPreferentialAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [Channel] nvarchar(50) NOT NULL,
    [Remark] nvarchar(1000) NULL,
    [CreatedOn] datetime NOT NULL,
    [IsFastBill] bit NULL,
    CONSTRAINT [PK_TB_SaleBill] PRIMARY KEY ([ID])
);
GO

-- 销售订单附件
IF OBJECT_ID(N'TB_SaleBillAttachment', N'U') IS NOT NULL DROP TABLE [TB_SaleBillAttachment];
GO
CREATE TABLE [TB_SaleBillAttachment] (
    [ID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [AttachmentURL] nvarchar(200) NOT NULL,
    [AttachmentType] int NOT NULL,
    CONSTRAINT [PK_TB_SaleBillAttachment] PRIMARY KEY ([ID])
);
GO

-- 销售订单操作过
IF OBJECT_ID(N'TB_SaleBillCancelProcess', N'U') IS NOT NULL DROP TABLE [TB_SaleBillCancelProcess];
GO
CREATE TABLE [TB_SaleBillCancelProcess] (
    [Bill ID] nvarchar(50) NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [Remark] nvarchar(500) NULL,
    CONSTRAINT [PK_TB_SaleBillCancelProcess] PRIMARY KEY ([Bill ID])
);
GO

-- 销售订单明细-
通用次卡
IF OBJECT_ID(N'TB_SaleBillGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillGeneralCard];
GO
CREATE TABLE [TB_SaleBillGeneralCard] (
    [ID] int NOT NULL,
    [Bill ID] nvarchar(50) NOT NULL,
    [GeneralCardID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [CardTimes] int NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NULL,
    [CardPreferentialAmount] decimal(18,2) NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [IsLargess] bit NOT NULL,
    [GeneralCardAccount
ID] int NULL,
    CONSTRAINT [PK_TB_SaleBillGeneralCard] PRIMARY KEY ([ID])
);
GO

-- 
IF OBJECT_ID(N'TB_SaleBillHandlerGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillHandlerGeneralCard];
GO
CREATE TABLE [TB_SaleBillHandlerGeneralCard] (
    [SaleBillGeneralCardID] int NOT NULL,
    [GeneralCardSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [IsCalculatePassenger
Flow] bit NOT NULL,
    CONSTRAINT [PK_TB_SaleBillHandlerGeneralCard] PRIMARY KEY ([SaleBillGeneralCardID],[GeneralCardSaleHandlerID],[EmployeeID])
);
GO

-- 销售套餐卡经手人
IF OBJECT_ID(N'TB_SaleBillHandlerPackageCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillHandlerPackageCard];
GO
CREATE TABLE [TB_SaleBillHandlerPackageCard] (
    [SaleBillPackageCardID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [IsCalculatePassenger
Flow] bit NOT NULL,
    CONSTRAINT [PK_TB_SaleBillHandlerPackageCard] PRIMARY KEY ([SaleBillPackageCardID],[PackageCardSaleHandlerID],[EmployeeID])
);
GO

-- 销售产品经手人
IF OBJECT_ID(N'TB_SaleBillHandlerProduct', N'U') IS NOT NULL DROP TABLE [TB_SaleBillHandlerProduct];
GO
CREATE TABLE [TB_SaleBillHandlerProduct] (
    [SaleBillProductID] int NOT NULL,
    [ProductSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [IsCalculatePassenger
Flow] bit NOT NULL,
    CONSTRAINT [PK_TB_SaleBillHandlerProduct] PRIMARY KEY ([SaleBillProductID],[ProductSaleHandlerID],[EmployeeID])
);
GO

-- 销售项目经手人
IF OBJECT_ID(N'TB_SaleBillHandlerProject', N'U') IS NOT NULL DROP TABLE [TB_SaleBillHandlerProject];
GO
CREATE TABLE [TB_SaleBillHandlerProject] (
    [SaleBillProjectID] int NOT NULL,
    [ProjectSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [IsCalculatePassenger
Flow] bit NOT NULL,
    CONSTRAINT [PK_TB_SaleBillHandlerProject] PRIMARY KEY ([SaleBillProjectID],[ProjectSaleHandlerID],[EmployeeID])
);
GO

-- 销售储值卡经手人
IF OBJECT_ID(N'TB_SaleBillHandlerSavingCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillHandlerSavingCard];
GO
CREATE TABLE [TB_SaleBillHandlerSavingCard] (
    [SaleBillSavingCardID] int NOT NULL,
    [SavingCardSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [IsCalculatePassenger
Flow] bit NOT NULL,
    CONSTRAINT [PK_TB_SaleBillHandlerSavingCard] PRIMARY KEY ([SaleBillSavingCardID],[SavingCardSaleHandlerID],[EmployeeID])
);
GO

-- 销售时效卡经手人
IF OBJECT_ID(N'TB_SaleBillHandlerTimeCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillHandlerTimeCard];
GO
CREATE TABLE [TB_SaleBillHandlerTimeCard] (
    [SaleBillTimeCardID] int NOT NULL,
    [TimeCardSaleHandle
rID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [IsCalculatePassenger
Flow] bit NOT NULL,
    CONSTRAINT [PK_TB_SaleBillHandlerTimeCard] PRIMARY KEY ([SaleBillTimeCardID],[TimeCardSaleHandle
rID],[EmployeeID])
);
GO

-- 销售订单明细-
套餐卡
IF OBJECT_ID(N'TB_SaleBillPackageCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPackageCard];
GO
CREATE TABLE [TB_SaleBillPackageCard] (
    [ID] int NOT NULL,
    [Bill ID] nvarchar(50) NOT NULL,
    [PackageCardID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NULL,
    [CardPreferentialAmount] decimal(18,2) NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [IsLargess] bit NOT NULL,
    [PackageCardAccountID] int NULL,
    CONSTRAINT [PK_TB_SaleBillPackageCard] PRIMARY KEY ([ID])
);
GO

-- 销售订单明细-
套餐卡通用次卡
IF OBJECT_ID(N'TB_SaleBillPackageCardGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPackageCardGeneralCard];
GO
CREATE TABLE [TB_SaleBillPackageCardGeneralCard] (
    [ID] int NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PackagePrice] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [CardTimes] int NULL,
    [PackageTotalPrice] decimal(18,2) NOT NULL,
    [PackageQuantity] int NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NOT NULL,
    [CardPreferentialAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [IsLargess] bit NOT NULL,
    [GeneralCardAccount
ID] int NULL,
    CONSTRAINT [PK_TB_SaleBillPackageCardGeneralCard] PRIMARY KEY ([ID])
);
GO

-- 销售订单明细-
套餐卡产品
IF OBJECT_ID(N'TB_SaleBillPackageCardProduct', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPackageCardProduct];
GO
CREATE TABLE [TB_SaleBillPackageCardProduct] (
    [ID] int NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PackagePrice] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [PackageTotalPrice] decimal(18,2) NOT NULL,
    [PackageQuantity] int NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NOT NULL,
    [CardPreferentialAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [IsLargess] bit NOT NULL,
    [ProductAccountID] int NULL,
    CONSTRAINT [PK_TB_SaleBillPackageCardProduct] PRIMARY KEY ([ID])
);
GO

-- 销售订单明细-
套餐卡项目
IF OBJECT_ID(N'TB_SaleBillPackageCardProject', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPackageCardProject];
GO
CREATE TABLE [TB_SaleBillPackageCardProject] (
    [ID] int NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PackagePrice] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [PackageTotalPrice] decimal(18,2) NOT NULL,
    [PackageQuantity] int NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NOT NULL,
    [CardPreferentialAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [IsLargess] bit NOT NULL,
    [ProjectAccountID] int NULL,
    CONSTRAINT [PK_TB_SaleBillPackageCardProject] PRIMARY KEY ([ID])
);
GO

-- 销售订单明细-
套餐卡储值卡
IF OBJECT_ID(N'TB_SaleBillPackageCardSavingCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPackageCardSavingCard];
GO
CREATE TABLE [TB_SaleBillPackageCardSavingCard] (
    [ID] int NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [Quantity] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [TotalPrice] decimal(18,2) NOT NULL,
    [IsLargess] bit NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [PackageQuantity] int NOT NULL,
    [SavingCardAccountI] int NULL,
    CONSTRAINT [PK_TB_SaleBillPackageCardSavingCard] PRIMARY KEY ([ID])
);
GO

-- 销售订单明细-
套餐卡时效卡
IF OBJECT_ID(N'TB_SaleBillPackageCardTime
Card', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPackageCardTime
Card];
GO
CREATE TABLE [TB_SaleBillPackageCardTime
Card] (
    [ID] int NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PackagePrice] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [PackageTotalPrice] decimal(18,2) NOT NULL,
    [PackageQuantity] int NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NOT NULL,
    [CardPreferentialAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [IsLargess] bit NOT NULL,
    [TimeCardAccountID] int NULL,
    CONSTRAINT [PK_TB_SaleBillPackageCardTime
Card] PRIMARY KEY ([ID])
);
GO

-- 销售支付
IF OBJECT_ID(N'TB_SaleBillPay', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPay];
GO
CREATE TABLE [TB_SaleBillPay] (
    [ID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [PayMethodID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPay] PRIMARY KEY ([ID])
);
GO

-- 销售支付明细-
通用次卡
IF OBJECT_ID(N'TB_SaleBillPayGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPayGeneralCard];
GO
CREATE TABLE [TB_SaleBillPayGeneralCard] (
    [ID] int NOT NULL,
    [SaleBillPayID] int NOT NULL,
    [SaleBillGeneralCardID] int NOT NULL,
    [PayMethodID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPayGeneralCard] PRIMARY KEY ([ID])
);
GO

-- 销售支付明细-
套餐卡
IF OBJECT_ID(N'TB_SaleBillPayPackageCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPayPackageCard];
GO
CREATE TABLE [TB_SaleBillPayPackageCard] (
    [ID] int NOT NULL,
    [SaleBillPayID] int NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [PayMethodID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPayPackageCard] PRIMARY KEY ([ID])
);
GO

-- 销售支付明细-
套餐卡通用次卡
IF OBJECT_ID(N'TB_SaleBillPayPackageCardG
eneralCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPayPackageCardG
eneralCard];
GO
CREATE TABLE [TB_SaleBillPayPackageCardG
eneralCard] (
    [ID] int NOT NULL,
    [SaleBillPayID] int NOT NULL,
    [SaleBillPackageCard
GeneralCardID] int NOT NULL,
    [PayMethodID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPayPackageCardG
eneralCard] PRIMARY KEY ([ID])
);
GO

-- 销售支付明细-
套餐卡产品
IF OBJECT_ID(N'TB_SaleBillPayPackageCardProduct', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPayPackageCardProduct];
GO
CREATE TABLE [TB_SaleBillPayPackageCardProduct] (
    [ID] int NOT NULL,
    [SaleBillPayID] int NOT NULL,
    [SaleBillPackageCard
ProductID] int NOT NULL,
    [PayMethodID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPayPackageCardProduct] PRIMARY KEY ([ID])
);
GO

-- 销售支付明细-
套餐卡项目
IF OBJECT_ID(N'TB_SaleBillPayPackageCardProject', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPayPackageCardProject];
GO
CREATE TABLE [TB_SaleBillPayPackageCardProject] (
    [ID] int NOT NULL,
    [SaleBillPayID] int NOT NULL,
    [SaleBillPackageCard
ProjectID] int NOT NULL,
    [PayMethodID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPayPackageCardProject] PRIMARY KEY ([ID])
);
GO

-- 销售支付明细-
套餐卡储值卡
IF OBJECT_ID(N'TB_SaleBillPayPackageCardSavingCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPayPackageCardSavingCard];
GO
CREATE TABLE [TB_SaleBillPayPackageCardSavingCard] (
    [ID] int NOT NULL,
    [SaleBillPayID] int NOT NULL,
    [SaleBillPackageCard
SavingCardID] int NOT NULL,
    [PayMethodID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPayPackageCardSavingCard] PRIMARY KEY ([ID])
);
GO

-- 销售支付明细-
套餐卡时效卡
IF OBJECT_ID(N'TB_SaleBillPayPackageCardTimeCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPayPackageCardTimeCard];
GO
CREATE TABLE [TB_SaleBillPayPackageCardTimeCard] (
    [ID] int NOT NULL,
    [SaleBillPayID] int NOT NULL,
    [SaleBillPackageCard
TimeCardID] int NOT NULL,
    [PayMethodID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPayPackageCardTimeCard] PRIMARY KEY ([ID])
);
GO

-- 销售支付明细-
套餐卡
IF OBJECT_ID(N'TB_SaleBillPayProduct', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPayProduct];
GO
CREATE TABLE [TB_SaleBillPayProduct] (
    [ID] int NOT NULL,
    [SaleBillPayID] int NOT NULL,
    [SaleBillProductID] int NOT NULL,
    [PayMethodID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPayProduct] PRIMARY KEY ([ID])
);
GO

-- 销售支付明细-
套餐卡
IF OBJECT_ID(N'TB_SaleBillPayProject', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPayProject];
GO
CREATE TABLE [TB_SaleBillPayProject] (
    [ID] int NOT NULL,
    [SaleBillPayID] int NOT NULL,
    [SaleBillProjectID] int NOT NULL,
    [PayMethodID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPayProject] PRIMARY KEY ([ID])
);
GO

-- 销售支付明细-
套餐卡
IF OBJECT_ID(N'TB_SaleBillPaySavingCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPaySavingCard];
GO
CREATE TABLE [TB_SaleBillPaySavingCard] (
    [ID] int NOT NULL,
    [SaleBillPayID] int NOT NULL,
    [SaleBillSavingCardID] int NOT NULL,
    [PayMethodID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPaySavingCard] PRIMARY KEY ([ID])
);
GO

-- 销售储值卡抵扣
IF OBJECT_ID(N'TB_SaleBillPaySavingCardDeduction', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPaySavingCardDeduction];
GO
CREATE TABLE [TB_SaleBillPaySavingCardDeduction] (
    [ID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SavingCardAccountI] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [PreferentialAmount] decimal(18,2) NOT NULL,
    [LargessPreferentialAmount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPaySavingCardDeduction] PRIMARY KEY ([ID])
);
GO

-- 销售储值卡抵扣
-通用次卡
IF OBJECT_ID(N'TB_SaleBillPaySavingCardDed
uctionGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPaySavingCardDed
uctionGeneralCard];
GO
CREATE TABLE [TB_SaleBillPaySavingCardDed
uctionGeneralCard] (
    [ID] int NOT NULL,
    [SaleBillGeneralCardID] int NOT NULL,
    [SavingCardAccountI] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [PreferentialAmount] decimal(18,2) NOT NULL,
    [LargessPreferentialAmount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPaySavingCardDed
uctionGeneralCard] PRIMARY KEY ([ID])
);
GO

-- 销售储值卡抵扣
-套餐卡
IF OBJECT_ID(N'TB_SaleBillPaySavingCardDed
uctionPackageCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPaySavingCardDed
uctionPackageCard];
GO
CREATE TABLE [TB_SaleBillPaySavingCardDed
uctionPackageCard] (
    [ID] int NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SavingCardAccountI] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [PreferentialAmount] decimal(18,2) NOT NULL,
    [LargessPreferentialAmount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPaySavingCardDed
uctionPackageCard] PRIMARY KEY ([ID])
);
GO

-- 销售储值卡抵扣
-套餐卡通用次
IF OBJECT_ID(N'TB_SaleBillPaySavingCardDed
uctionPackageCardGeneralC', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPaySavingCardDed
uctionPackageCardGeneralC];
GO
CREATE TABLE [TB_SaleBillPaySavingCardDed
uctionPackageCardGeneralC] (
    [ID] int NOT NULL,
    [SaleBillPackageCard
GeneralCardID] int NOT NULL,
    [SavingCardAccountI] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [PreferentialAmount] decimal(18,2) NOT NULL,
    [LargessPreferentialAmount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPaySavingCardDed
uctionPackageCardGeneralC] PRIMARY KEY ([ID])
);
GO

-- 销售储值卡抵扣
-套餐卡产品
IF OBJECT_ID(N'TB_SaleBillPaySavingCardDed
uctionPackageCardProduct', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPaySavingCardDed
uctionPackageCardProduct];
GO
CREATE TABLE [TB_SaleBillPaySavingCardDed
uctionPackageCardProduct] (
    [ID] int NOT NULL,
    [SaleBillPackageCard
ProductID] int NOT NULL,
    [SavingCardAccountI] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [PreferentialAmount] decimal(18,2) NOT NULL,
    [LargessPreferentialAmount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPaySavingCardDed
uctionPackageCardProduct] PRIMARY KEY ([ID])
);
GO

-- 销售储值卡抵扣
-套餐卡项目
IF OBJECT_ID(N'TB_SaleBillPaySavingCardDed
uctionPackageCardProject', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPaySavingCardDed
uctionPackageCardProject];
GO
CREATE TABLE [TB_SaleBillPaySavingCardDed
uctionPackageCardProject] (
    [ID] int NOT NULL,
    [SaleBillPackageCard
ProjectID] int NOT NULL,
    [SavingCardAccountI] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [PreferentialAmount] decimal(18,2) NOT NULL,
    [LargessPreferentialAmount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPaySavingCardDed
uctionPackageCardProject] PRIMARY KEY ([ID])
);
GO

-- 销售储值卡抵扣
-套餐卡时效卡
IF OBJECT_ID(N'TB_SaleBillPaySavingCardDed
uctionPackageCardTimeCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPaySavingCardDed
uctionPackageCardTimeCard];
GO
CREATE TABLE [TB_SaleBillPaySavingCardDed
uctionPackageCardTimeCard] (
    [ID] int NOT NULL,
    [SaleBillPackageCard
TimeCardID] int NOT NULL,
    [SavingCardAccountI] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [PreferentialAmount] decimal(18,2) NOT NULL,
    [LargessPreferentialAmount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPaySavingCardDed
uctionPackageCardTimeCard] PRIMARY KEY ([ID])
);
GO

-- 销售储值卡抵扣
-产品
IF OBJECT_ID(N'TB_SaleBillPaySavingCardDed
uctionProduct', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPaySavingCardDed
uctionProduct];
GO
CREATE TABLE [TB_SaleBillPaySavingCardDed
uctionProduct] (
    [ID] int NOT NULL,
    [SaleBillProductID] int NOT NULL,
    [SavingCardAccountI] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [PreferentialAmount] decimal(18,2) NOT NULL,
    [LargessPreferentialAmount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPaySavingCardDed
uctionProduct] PRIMARY KEY ([ID])
);
GO

-- 销售储值卡抵扣
-项目
IF OBJECT_ID(N'TB_SaleBillPaySavingCardDed
uctionProject', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPaySavingCardDed
uctionProject];
GO
CREATE TABLE [TB_SaleBillPaySavingCardDed
uctionProject] (
    [ID] int NOT NULL,
    [SaleBillProjectID] int NOT NULL,
    [SavingCardAccountI] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [PreferentialAmount] decimal(18,2) NOT NULL,
    [LargessPreferentialAmount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPaySavingCardDed
uctionProject] PRIMARY KEY ([ID])
);
GO

-- 销售储值卡抵扣
-时效卡
IF OBJECT_ID(N'TB_SaleBillPaySavingCardDed
uctionTimeCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPaySavingCardDed
uctionTimeCard];
GO
CREATE TABLE [TB_SaleBillPaySavingCardDed
uctionTimeCard] (
    [ID] int NOT NULL,
    [SaleBillTimeCardID] int NOT NULL,
    [SavingCardAccountI] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [PreferentialAmount] decimal(18,2) NOT NULL,
    [LargessPreferentialAmount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPaySavingCardDed
uctionTimeCard] PRIMARY KEY ([ID])
);
GO

-- 销售支付明细-
时效卡
IF OBJECT_ID(N'TB_SaleBillPayTimeCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPayTimeCard];
GO
CREATE TABLE [TB_SaleBillPayTimeCard] (
    [ID] int NOT NULL,
    [SaleBillTimeCardID] int NOT NULL,
    [PayMethodID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [SaleBillPayID] int NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPayTimeCard] PRIMARY KEY ([ID])
);
GO

-- 
IF OBJECT_ID(N'TB_SaleBillPending', N'U') IS NOT NULL DROP TABLE [TB_SaleBillPending];
GO
CREATE TABLE [TB_SaleBillPending] (
    [SaleBillID] nvarchar(50) NOT NULL,
    [Content] text NOT NULL,
    CONSTRAINT [PK_TB_SaleBillPending] PRIMARY KEY ([SaleBillID])
);
GO

-- 销售订单明细-
产品
IF OBJECT_ID(N'TB_SaleBillProduct', N'U') IS NOT NULL DROP TABLE [TB_SaleBillProduct];
GO
CREATE TABLE [TB_SaleBillProduct] (
    [ID] int NOT NULL,
    [Bill ID] nvarchar(50) NOT NULL,
    [ProductID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NULL,
    [CardPreferentialAmount] decimal(18,2) NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [IsLargess] bit NOT NULL,
    [ProductAccountID] int NULL,
    CONSTRAINT [PK_TB_SaleBillProduct] PRIMARY KEY ([ID])
);
GO

-- 销售订单明细-
项目
IF OBJECT_ID(N'TB_SaleBillProject', N'U') IS NOT NULL DROP TABLE [TB_SaleBillProject];
GO
CREATE TABLE [TB_SaleBillProject] (
    [ID] int NOT NULL,
    [Bill ID] nvarchar(50) NOT NULL,
    [ProjectID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NOT NULL,
    [CardPreferentialAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [IsLargess] bit NOT NULL,
    [ProjectAccountID] int NULL,
    CONSTRAINT [PK_TB_SaleBillProject] PRIMARY KEY ([ID])
);
GO

-- 销售订单明细-
储值卡
IF OBJECT_ID(N'TB_SaleBillSavingCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillSavingCard];
GO
CREATE TABLE [TB_SaleBillSavingCard] (
    [ID] int NOT NULL,
    [Bill ID] nvarchar(50) NOT NULL,
    [SavingCardID] int NOT NULL,
    [Quantity] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [SavingCardAccountID] int NULL,
    CONSTRAINT [PK_TB_SaleBillSavingCard] PRIMARY KEY ([ID])
);
GO

-- 销售订单签名
IF OBJECT_ID(N'TB_SaleBillSignature', N'U') IS NOT NULL DROP TABLE [TB_SaleBillSignature];
GO
CREATE TABLE [TB_SaleBillSignature] (
    [SaleBillID] nvarchar(50) NOT NULL,
    [ImageURL] nvarchar(200) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_SaleBillSignature] PRIMARY KEY ([SaleBillID])
);
GO

-- 销售订单明细-
时效卡
IF OBJECT_ID(N'TB_SaleBillTimeCard', N'U') IS NOT NULL DROP TABLE [TB_SaleBillTimeCard];
GO
CREATE TABLE [TB_SaleBillTimeCard] (
    [ID] int NOT NULL,
    [Bill ID] nvarchar(50) NOT NULL,
    [TimeCardID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NULL,
    [CardPreferentialAmount] decimal(18,2) NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [IsLargess] bit NOT NULL,
    [TimeCardAccountID] int NULL,
    CONSTRAINT [PK_TB_SaleBillTimeCard] PRIMARY KEY ([ID])
);
GO

-- 销售渠道市场咨
询人员业绩-通
用次卡
IF OBJECT_ID(N'TB_SaleChannelConsultantPe
rformanceGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelConsultantPe
rformanceGeneralCard];
GO
CREATE TABLE [TB_SaleChannelConsultantPe
rformanceGeneralCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillGeneralCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelConsultantPe
rformanceGeneralCard] PRIMARY KEY ([ID])
);
GO

-- 销售渠道市场咨
询人员业绩-套
餐卡通用次卡
IF OBJECT_ID(N'TB_SaleChannelConsultantPe
rformancePackageCardGener
alCard', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelConsultantPe
rformancePackageCardGener
alCard];
GO
CREATE TABLE [TB_SaleChannelConsultantPe
rformancePackageCardGener
alCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
GeneralCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelConsultantPe
rformancePackageCardGener
alCard] PRIMARY KEY ([ID])
);
GO

-- 销售渠道市场咨
询人员业绩-套
餐卡产品
IF OBJECT_ID(N'TB_SaleChannelConsultantPe
rformancePackageCardProdu
ct', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelConsultantPe
rformancePackageCardProdu
ct];
GO
CREATE TABLE [TB_SaleChannelConsultantPe
rformancePackageCardProdu
ct] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
ProductID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelConsultantPe
rformancePackageCardProdu
ct] PRIMARY KEY ([ID])
);
GO

-- 销售渠道市场咨
询人员业绩-套
餐卡项目
IF OBJECT_ID(N'TB_SaleChannelConsultantPe
rformancePackageCardProje
ct', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelConsultantPe
rformancePackageCardProje
ct];
GO
CREATE TABLE [TB_SaleChannelConsultantPe
rformancePackageCardProje
ct] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
ProjectID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelConsultantPe
rformancePackageCardProje
ct] PRIMARY KEY ([ID])
);
GO

-- 销售渠道市场咨
询人员业绩-套
餐卡储值卡
IF OBJECT_ID(N'TB_SaleChannelConsultantPe
rformancePackageCardSavin
gCard', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelConsultantPe
rformancePackageCardSavin
gCard];
GO
CREATE TABLE [TB_SaleChannelConsultantPe
rformancePackageCardSavin
gCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
SavingCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelConsultantPe
rformancePackageCardSavin
gCard] PRIMARY KEY ([ID])
);
GO

-- 销售渠道市场咨
询人员业绩-套
餐卡时效卡
IF OBJECT_ID(N'TB_SaleChannelConsultantPe
rformancePackageCardTime
Card', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelConsultantPe
rformancePackageCardTime
Card];
GO
CREATE TABLE [TB_SaleChannelConsultantPe
rformancePackageCardTime
Card] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
TimeCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelConsultantPe
rformancePackageCardTime
Card] PRIMARY KEY ([ID])
);
GO

-- 销售渠道市场咨
询人员业绩-产
IF OBJECT_ID(N'TB_SaleChannelConsultantPe
rformanceProduct', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelConsultantPe
rformanceProduct];
GO
CREATE TABLE [TB_SaleChannelConsultantPe
rformanceProduct] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillProductID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelConsultantPe
rformanceProduct] PRIMARY KEY ([ID])
);
GO

-- 销售渠道市场咨
询人员业绩-项
IF OBJECT_ID(N'TB_SaleChannelConsultantPe
rformanceProject', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelConsultantPe
rformanceProject];
GO
CREATE TABLE [TB_SaleChannelConsultantPe
rformanceProject] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillProjectID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelConsultantPe
rformanceProject] PRIMARY KEY ([ID])
);
GO

-- 销售渠道市场咨
询人员业绩-储
IF OBJECT_ID(N'TB_SaleChannelConsultantPe
rformanceSavingCard', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelConsultantPe
rformanceSavingCard];
GO
CREATE TABLE [TB_SaleChannelConsultantPe
rformanceSavingCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillSavingCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelConsultantPe
rformanceSavingCard] PRIMARY KEY ([ID])
);
GO

-- 销售渠道市场咨
询人员业绩-时
IF OBJECT_ID(N'TB_SaleChannelConsultantPe
rformanceTimeCard', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelConsultantPe
rformanceTimeCard];
GO
CREATE TABLE [TB_SaleChannelConsultantPe
rformanceTimeCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillTimeCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelConsultantPe
rformanceTimeCard] PRIMARY KEY ([ID])
);
GO

-- 销售渠道开发人
员业绩-通用次
IF OBJECT_ID(N'TB_SaleChannelDeveloperPer
formanceGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelDeveloperPer
formanceGeneralCard];
GO
CREATE TABLE [TB_SaleChannelDeveloperPer
formanceGeneralCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillGeneralCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelDeveloperPer
formanceGeneralCard] PRIMARY KEY ([ID])
);
GO

-- 销售渠道开发人
员业绩-套餐卡
通用次卡
IF OBJECT_ID(N'TB_SaleChannelDeveloperPer
formancePackageCardGener
alCard', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelDeveloperPer
formancePackageCardGener
alCard];
GO
CREATE TABLE [TB_SaleChannelDeveloperPer
formancePackageCardGener
alCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
GeneralCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelDeveloperPer
formancePackageCardGener
alCard] PRIMARY KEY ([ID])
);
GO

-- 销售渠道开发人
员业绩-套餐卡
IF OBJECT_ID(N'TB_SaleChannelDeveloperPer
formancePackageCardProdu', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelDeveloperPer
formancePackageCardProdu];
GO
CREATE TABLE [TB_SaleChannelDeveloperPer
formancePackageCardProdu] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
ProductID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelDeveloperPer
formancePackageCardProdu] PRIMARY KEY ([ID])
);
GO

-- 销售渠道开发人
员业绩-套餐卡
IF OBJECT_ID(N'TB_SaleChannelDeveloperPer
formancePackageCardProject', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelDeveloperPer
formancePackageCardProject];
GO
CREATE TABLE [TB_SaleChannelDeveloperPer
formancePackageCardProject] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
ProjectID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelDeveloperPer
formancePackageCardProject] PRIMARY KEY ([ID])
);
GO

-- 销售渠道开发人
员业绩-套餐卡
储值卡
IF OBJECT_ID(N'TB_SaleChannelDeveloperPer
formancePackageCardSaving
Card', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelDeveloperPer
formancePackageCardSaving
Card];
GO
CREATE TABLE [TB_SaleChannelDeveloperPer
formancePackageCardSaving
Card] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
SavingCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelDeveloperPer
formancePackageCardSaving
Card] PRIMARY KEY ([ID])
);
GO

-- 销售渠道开发人
员业绩-套餐卡
时效卡
IF OBJECT_ID(N'TB_SaleChannelDeveloperPer
formancePackageCardTimeC
ard', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelDeveloperPer
formancePackageCardTimeC
ard];
GO
CREATE TABLE [TB_SaleChannelDeveloperPer
formancePackageCardTimeC
ard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
TimeCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelDeveloperPer
formancePackageCardTimeC
ard] PRIMARY KEY ([ID])
);
GO

-- 销售渠道开发人
员业绩-产品
IF OBJECT_ID(N'TB_SaleChannelDeveloperPer
formanceProduct', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelDeveloperPer
formanceProduct];
GO
CREATE TABLE [TB_SaleChannelDeveloperPer
formanceProduct] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillProductID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelDeveloperPer
formanceProduct] PRIMARY KEY ([ID])
);
GO

-- 销售渠道开发人
员业绩-项目
IF OBJECT_ID(N'TB_SaleChannelDeveloperPer
formanceProject', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelDeveloperPer
formanceProject];
GO
CREATE TABLE [TB_SaleChannelDeveloperPer
formanceProject] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillProjectID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelDeveloperPer
formanceProject] PRIMARY KEY ([ID])
);
GO

-- 销售渠道开发人
员业绩-储值卡
IF OBJECT_ID(N'TB_SaleChannelDeveloperPer
formanceSavingCard', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelDeveloperPer
formanceSavingCard];
GO
CREATE TABLE [TB_SaleChannelDeveloperPer
formanceSavingCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillSavingCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelDeveloperPer
formanceSavingCard] PRIMARY KEY ([ID])
);
GO

-- 销售渠道开发人
员业绩-时效卡
IF OBJECT_ID(N'TB_SaleChannelDeveloperPer
formanceTimeCard', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelDeveloperPer
formanceTimeCard];
GO
CREATE TABLE [TB_SaleChannelDeveloperPer
formanceTimeCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillTimeCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelDeveloperPer
formanceTimeCard] PRIMARY KEY ([ID])
);
GO

-- 销售渠道业绩-
通用次卡
IF OBJECT_ID(N'TB_SaleChannelPerformance
GeneralCard', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelPerformance
GeneralCard];
GO
CREATE TABLE [TB_SaleChannelPerformance
GeneralCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillGeneralCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelPerformance
GeneralCard] PRIMARY KEY ([ID])
);
GO

-- 销售渠道业绩-
套餐卡通用次卡
IF OBJECT_ID(N'TB_SaleChannelPerformance
PackageCardGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelPerformance
PackageCardGeneralCard];
GO
CREATE TABLE [TB_SaleChannelPerformance
PackageCardGeneralCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
GeneralCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelPerformance
PackageCardGeneralCard] PRIMARY KEY ([ID])
);
GO

-- 销售渠道业绩-
套餐卡产品
IF OBJECT_ID(N'TB_SaleChannelPerformance
PackageCardProduct', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelPerformance
PackageCardProduct];
GO
CREATE TABLE [TB_SaleChannelPerformance
PackageCardProduct] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
ProductID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelPerformance
PackageCardProduct] PRIMARY KEY ([ID])
);
GO

-- 销售渠道业绩-
套餐卡项目
IF OBJECT_ID(N'TB_SaleChannelPerformance
PackageCardProject', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelPerformance
PackageCardProject];
GO
CREATE TABLE [TB_SaleChannelPerformance
PackageCardProject] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
ProjectID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelPerformance
PackageCardProject] PRIMARY KEY ([ID])
);
GO

-- 销售渠道业绩-
套餐卡储值卡
IF OBJECT_ID(N'TB_SaleChannelPerformance
PackageCardSavingCard', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelPerformance
PackageCardSavingCard];
GO
CREATE TABLE [TB_SaleChannelPerformance
PackageCardSavingCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
SavingCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelPerformance
PackageCardSavingCard] PRIMARY KEY ([ID])
);
GO

-- 销售渠道业绩-
套餐卡时效卡
IF OBJECT_ID(N'TB_SaleChannelPerformance
PackageCardTimeCard', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelPerformance
PackageCardTimeCard];
GO
CREATE TABLE [TB_SaleChannelPerformance
PackageCardTimeCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
TimeCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelPerformance
PackageCardTimeCard] PRIMARY KEY ([ID])
);
GO

-- 销售渠道业绩-
产品
IF OBJECT_ID(N'TB_SaleChannelPerformance
Product', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelPerformance
Product];
GO
CREATE TABLE [TB_SaleChannelPerformance
Product] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillProductID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelPerformance
Product] PRIMARY KEY ([ID])
);
GO

-- 销售渠道业绩-
项目
IF OBJECT_ID(N'TB_SaleChannelPerformance
Project', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelPerformance
Project];
GO
CREATE TABLE [TB_SaleChannelPerformance
Project] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillProjectID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelPerformance
Project] PRIMARY KEY ([ID])
);
GO

-- 销售渠道业绩-
储值卡
IF OBJECT_ID(N'TB_SaleChannelPerformance
SavingCard', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelPerformance
SavingCard];
GO
CREATE TABLE [TB_SaleChannelPerformance
SavingCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillSavingCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelPerformance
SavingCard] PRIMARY KEY ([ID])
);
GO

-- 销售渠道业绩-
时效卡
IF OBJECT_ID(N'TB_SaleChannelPerformance
TimeCard', N'U') IS NOT NULL DROP TABLE [TB_SaleChannelPerformance
TimeCard];
GO
CREATE TABLE [TB_SaleChannelPerformance
TimeCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillTimeCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleChannelPerformance
TimeCard] PRIMARY KEY ([ID])
);
GO

-- 销售员工业绩提
成-通用次卡
IF OBJECT_ID(N'TB_SaleEmployeePerformanc
eCommissionGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_SaleEmployeePerformanc
eCommissionGeneralCard];
GO
CREATE TABLE [TB_SaleEmployeePerformanc
eCommissionGeneralCard] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillGeneralCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [GeneralCardSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardRateCommission] decimal(18,2) NOT NULL,
    [SavingCardFixedCommission] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    [SavingCardLargessR
ateCommission] decimal(18,2) NOT NULL,
    [SavingCardLargessFi
xedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEmployeePerformanc
eCommissionGeneralCard] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillGeneralCardID],[GeneralCardID],[GeneralCardSaleHandlerID],[EmployeeID])
);
GO

-- 销售员工业绩提
成-套餐卡通用
次卡
IF OBJECT_ID(N'TB_SaleEmployeePerformanc
eCommissionPackageCardGe
neralCard', N'U') IS NOT NULL DROP TABLE [TB_SaleEmployeePerformanc
eCommissionPackageCardGe
neralCard];
GO
CREATE TABLE [TB_SaleEmployeePerformanc
eCommissionPackageCardGe
neralCard] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
GeneralCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardRateCommission] decimal(18,2) NOT NULL,
    [SavingCardFixedCommission] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    [SavingCardLargessR
ateCommission] decimal(18,2) NOT NULL,
    [SavingCardLargessFi
xedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEmployeePerformanc
eCommissionPackageCardGe
neralCard] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillPackageCardID],[SaleBillPackageCard
GeneralCardID],[PackageCardID],[GeneralCardID],[PackageCardSaleHandlerID],[EmployeeID])
);
GO

-- 销售员工业绩提
成-套餐卡产品
IF OBJECT_ID(N'TB_SaleEmployeePerformanc
eCommissionPackageCardPr
oduct', N'U') IS NOT NULL DROP TABLE [TB_SaleEmployeePerformanc
eCommissionPackageCardPr
oduct];
GO
CREATE TABLE [TB_SaleEmployeePerformanc
eCommissionPackageCardPr
oduct] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
ProductID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardRateCommission] decimal(18,2) NOT NULL,
    [SavingCardFixedCommission] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    [SavingCardLargessR
ateCommission] decimal(18,2) NOT NULL,
    [SavingCardLargessFi
xedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEmployeePerformanc
eCommissionPackageCardPr
oduct] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillPackageCardID],[SaleBillPackageCard
ProductID],[PackageCardID],[ProductID],[PackageCardSaleHandlerID],[EmployeeID])
);
GO

-- 销售员工业绩提
成-套餐卡项目
IF OBJECT_ID(N'TB_SaleEmployeePerformanc
eCommissionPackageCardPr
oject', N'U') IS NOT NULL DROP TABLE [TB_SaleEmployeePerformanc
eCommissionPackageCardPr
oject];
GO
CREATE TABLE [TB_SaleEmployeePerformanc
eCommissionPackageCardPr
oject] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
ProjectID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardRateCommission] decimal(18,2) NOT NULL,
    [SavingCardFixedCommission] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    [SavingCardLargessR
ateCommission] decimal(18,2) NOT NULL,
    [SavingCardLargessFi
xedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEmployeePerformanc
eCommissionPackageCardPr
oject] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillPackageCardID],[SaleBillPackageCard
ProjectID],[PackageCardID],[ProjectID],[PackageCardSaleHandlerID],[EmployeeID])
);
GO

-- 销售员工业绩提
成-套餐卡储值
卡
IF OBJECT_ID(N'TB_SaleEmployeePerformanc
eCommissionPackageCardSa
vingCard', N'U') IS NOT NULL DROP TABLE [TB_SaleEmployeePerformanc
eCommissionPackageCardSa
vingCard];
GO
CREATE TABLE [TB_SaleEmployeePerformanc
eCommissionPackageCardSa
vingCard] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
SavingCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEmployeePerformanc
eCommissionPackageCardSa
vingCard] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillPackageCardID],[SaleBillPackageCard
SavingCardID],[PackageCardID],[SavingCardID],[PackageCardSaleHandlerID],[EmployeeID])
);
GO

-- 销售员工业绩提
成-套餐卡时效
卡
IF OBJECT_ID(N'TB_SaleEmployeePerformanc
eCommissionPackageCardTi
meCard', N'U') IS NOT NULL DROP TABLE [TB_SaleEmployeePerformanc
eCommissionPackageCardTi
meCard];
GO
CREATE TABLE [TB_SaleEmployeePerformanc
eCommissionPackageCardTi
meCard] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
TimeCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardRateCommission] decimal(18,2) NOT NULL,
    [SavingCardFixedCommission] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    [SavingCardLargessR
ateCommission] decimal(18,2) NOT NULL,
    [SavingCardLargessFi
xedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEmployeePerformanc
eCommissionPackageCardTi
meCard] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillPackageCardID],[SaleBillPackageCard
TimeCardID],[PackageCardID],[TimeCardID],[PackageCardSaleHandlerID],[EmployeeID])
);
GO

-- 销售员工业绩提成-产品
IF OBJECT_ID(N'TB_SaleEmployeePerformanc
eCommissionProduct', N'U') IS NOT NULL DROP TABLE [TB_SaleEmployeePerformanc
eCommissionProduct];
GO
CREATE TABLE [TB_SaleEmployeePerformanc
eCommissionProduct] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillProductID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ProductSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardRateCommission] decimal(18,2) NOT NULL,
    [SavingCardFixedCommission] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    [SavingCardLargessR
ateCommission] decimal(18,2) NOT NULL,
    [SavingCardLargessFi
xedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEmployeePerformanc
eCommissionProduct] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillProductID],[ProductID],[ProductSaleHandlerID],[EmployeeID])
);
GO

-- 销售员工业绩提成-项目
IF OBJECT_ID(N'TB_SaleEmployeePerformanc
eCommissionProject', N'U') IS NOT NULL DROP TABLE [TB_SaleEmployeePerformanc
eCommissionProject];
GO
CREATE TABLE [TB_SaleEmployeePerformanc
eCommissionProject] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillProjectID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ProjectSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardRateCommission] decimal(18,2) NOT NULL,
    [SavingCardFixedCommission] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    [SavingCardLargessR
ateCommission] decimal(18,2) NOT NULL,
    [SavingCardLargessFi
xedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEmployeePerformanc
eCommissionProject] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillProjectID],[ProjectID],[ProjectSaleHandlerID],[EmployeeID])
);
GO

-- 销售员工业绩提
成-储值卡
IF OBJECT_ID(N'TB_SaleEmployeePerformanc
eCommissionSavingCard', N'U') IS NOT NULL DROP TABLE [TB_SaleEmployeePerformanc
eCommissionSavingCard];
GO
CREATE TABLE [TB_SaleEmployeePerformanc
eCommissionSavingCard] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillSavingCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [SavingCardSaleHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEmployeePerformanc
eCommissionSavingCard] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillSavingCardID],[SavingCardID],[SavingCardSaleHandlerID],[EmployeeID])
);
GO

-- 销售员工业绩提
成-时效卡
IF OBJECT_ID(N'TB_SaleEmployeePerformanc
eCommissionTimeCard', N'U') IS NOT NULL DROP TABLE [TB_SaleEmployeePerformanc
eCommissionTimeCard];
GO
CREATE TABLE [TB_SaleEmployeePerformanc
eCommissionTimeCard] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillTimeCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [TimeCardSaleHandle
rID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardRateCommission] decimal(18,2) NOT NULL,
    [SavingCardFixedCommission] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    [SavingCardLargessR
ateCommission] decimal(18,2) NOT NULL,
    [SavingCardLargessFi
xedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEmployeePerformanc
eCommissionTimeCard] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillTimeCardID],[TimeCardID],[TimeCardSaleHandle
rID],[EmployeeID])
);
GO

-- 销售门店业绩-
通用次卡
IF OBJECT_ID(N'TB_SaleEntityPerformanceGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_SaleEntityPerformanceGeneralCard];
GO
CREATE TABLE [TB_SaleEntityPerformanceGeneralCard] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillGeneralCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEntityPerformanceGeneralCard] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillGeneralCardID],[GeneralCardID])
);
GO

-- 销售门店业绩-
套餐卡通用次卡
IF OBJECT_ID(N'TB_SaleEntityPerformancePac
kageCardGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_SaleEntityPerformancePac
kageCardGeneralCard];
GO
CREATE TABLE [TB_SaleEntityPerformancePac
kageCardGeneralCard] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
GeneralCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEntityPerformancePac
kageCardGeneralCard] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillPackageCardID],[SaleBillPackageCard
GeneralCardID],[PackageCardID],[GeneralCardID])
);
GO

-- 销售门店业绩-
套餐卡产品
IF OBJECT_ID(N'TB_SaleEntityPerformancePac
kageCardProduct', N'U') IS NOT NULL DROP TABLE [TB_SaleEntityPerformancePac
kageCardProduct];
GO
CREATE TABLE [TB_SaleEntityPerformancePac
kageCardProduct] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
ProductID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEntityPerformancePac
kageCardProduct] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillPackageCardID],[SaleBillPackageCard
ProductID],[PackageCardID],[ProductID])
);
GO

-- 销售门店业绩-
套餐卡项目
IF OBJECT_ID(N'TB_SaleEntityPerformancePac
kageCardProject', N'U') IS NOT NULL DROP TABLE [TB_SaleEntityPerformancePac
kageCardProject];
GO
CREATE TABLE [TB_SaleEntityPerformancePac
kageCardProject] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
ProjectID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEntityPerformancePac
kageCardProject] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillPackageCardID],[SaleBillPackageCard
ProjectID],[PackageCardID],[ProjectID])
);
GO

-- 销售门店业绩-
套餐卡储值卡
IF OBJECT_ID(N'TB_SaleEntityPerformancePac
kageCardSavingCard', N'U') IS NOT NULL DROP TABLE [TB_SaleEntityPerformancePac
kageCardSavingCard];
GO
CREATE TABLE [TB_SaleEntityPerformancePac
kageCardSavingCard] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
SavingCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEntityPerformancePac
kageCardSavingCard] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillPackageCardID],[SaleBillPackageCard
SavingCardID],[PackageCardID],[SavingCardID])
);
GO

-- 销售门店业绩-
套餐卡时效卡
IF OBJECT_ID(N'TB_SaleEntityPerformancePac
kageCardTimeCard', N'U') IS NOT NULL DROP TABLE [TB_SaleEntityPerformancePac
kageCardTimeCard];
GO
CREATE TABLE [TB_SaleEntityPerformancePac
kageCardTimeCard] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillPackageCardID] int NOT NULL,
    [SaleBillPackageCard
TimeCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEntityPerformancePac
kageCardTimeCard] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillPackageCardID],[SaleBillPackageCard
TimeCardID],[PackageCardID],[TimeCardID])
);
GO

-- 销售门店业绩-
产品
IF OBJECT_ID(N'TB_SaleEntityPerformanceProduct', N'U') IS NOT NULL DROP TABLE [TB_SaleEntityPerformanceProduct];
GO
CREATE TABLE [TB_SaleEntityPerformanceProduct] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillProductID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEntityPerformanceProduct] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillProductID],[ProductID])
);
GO

-- 销售门店业绩-
项目
IF OBJECT_ID(N'TB_SaleEntityPerformanceProject', N'U') IS NOT NULL DROP TABLE [TB_SaleEntityPerformanceProject];
GO
CREATE TABLE [TB_SaleEntityPerformanceProject] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillProjectID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEntityPerformanceProject] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillProjectID],[ProjectID])
);
GO

-- 销售门店业绩-
储值卡
IF OBJECT_ID(N'TB_SaleEntityPerformanceSavingCard', N'U') IS NOT NULL DROP TABLE [TB_SaleEntityPerformanceSavingCard];
GO
CREATE TABLE [TB_SaleEntityPerformanceSavingCard] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillSavingCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEntityPerformanceSavingCard] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillSavingCardID],[SavingCardID])
);
GO

-- 销售门店业绩-
时效卡
IF OBJECT_ID(N'TB_SaleEntityPerformanceTimeCard', N'U') IS NOT NULL DROP TABLE [TB_SaleEntityPerformanceTimeCard];
GO
CREATE TABLE [TB_SaleEntityPerformanceTimeCard] (
    [EntityID] int NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    [SaleBillTimeCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [SavingCardPerformance] decimal(18,2) NOT NULL,
    [SavingCardLargessP
erformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SaleEntityPerformanceTimeCard] PRIMARY KEY ([EntityID],[SaleBillID],[SaleBillTimeCardID],[TimeCardID])
);
GO

-- 销售通用次卡类
别佣金提成员工
IF OBJECT_ID(N'TB_SaleGeneralCardCategory
Commission', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardCategory
Commission];
GO
CREATE TABLE [TB_SaleGeneralCardCategory
Commission] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardCategory
Commission] PRIMARY KEY ([EntityID],[GeneralCardCategoryID])
);
GO

-- 销售通用次卡类
别业绩门店配置
IF OBJECT_ID(N'TB_SaleGeneralCardCategory
EntityPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardCategory
EntityPerformance];
GO
CREATE TABLE [TB_SaleGeneralCardCategory
EntityPerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardCategory
EntityPerformance] PRIMARY KEY ([EntityID],[GeneralCardCategoryID])
);
GO

-- 销售通用次卡类
别经手人佣金提
成员工配置
IF OBJECT_ID(N'TB_SaleGeneralCardCategory
HandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardCategory
HandlerCommission];
GO
CREATE TABLE [TB_SaleGeneralCardCategory
HandlerCommission] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [GeneralCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardCategory
HandlerCommission] PRIMARY KEY ([EntityID],[GeneralCardCategoryID],[GeneralCardSaleHandlerID])
);
GO

-- 销售通用次卡类
别经手人职务佣
金提成员工配置
IF OBJECT_ID(N'TB_SaleGeneralCardCategory
HandlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardCategory
HandlerJobTypeCommission];
GO
CREATE TABLE [TB_SaleGeneralCardCategory
HandlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [GeneralCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardCategory
HandlerJobTypeCommission] PRIMARY KEY ([EntityID],[GeneralCardCategoryID],[GeneralCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售通用次卡类
别经手人职务业
绩员工配置
IF OBJECT_ID(N'TB_SaleGeneralCardCategory
HandlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardCategory
HandlerJobTypePerformance];
GO
CREATE TABLE [TB_SaleGeneralCardCategory
HandlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [GeneralCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardCategory
HandlerJobTypePerformance] PRIMARY KEY ([EntityID],[GeneralCardCategoryID],[GeneralCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售通用次卡类
别经手人业绩员
工配置
IF OBJECT_ID(N'TB_SaleGeneralCardCategory
HandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardCategory
HandlerPerformance];
GO
CREATE TABLE [TB_SaleGeneralCardCategory
HandlerPerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [GeneralCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardCategory
HandlerPerformance] PRIMARY KEY ([EntityID],[GeneralCardCategoryID],[GeneralCardSaleHandlerID])
);
GO

-- 销售通用次卡类
别业绩员工配置
IF OBJECT_ID(N'TB_SaleGeneralCardCategory
Performance', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardCategory
Performance];
GO
CREATE TABLE [TB_SaleGeneralCardCategory
Performance] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardCategory
Performance] PRIMARY KEY ([EntityID],[GeneralCardCategoryID])
);
GO

-- 销售通用次卡佣
金提成员工配置
IF OBJECT_ID(N'TB_SaleGeneralCardCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardCommission];
GO
CREATE TABLE [TB_SaleGeneralCardCommission] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardCommission] PRIMARY KEY ([EntityID],[GeneralCardID])
);
GO

-- 销售通用次卡佣
金提成员工配置
IF OBJECT_ID(N'TB_SaleGeneralCardCommiss
ionScheme', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardCommiss
ionScheme];
GO
CREATE TABLE [TB_SaleGeneralCardCommiss
ionScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardCommiss
ionScheme] PRIMARY KEY ([EntityID])
);
GO

-- 销售通用次卡业
绩门店配置
IF OBJECT_ID(N'TB_SaleGeneralCardEntityPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardEntityPerformance];
GO
CREATE TABLE [TB_SaleGeneralCardEntityPerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardEntityPerformance] PRIMARY KEY ([EntityID],[GeneralCardID])
);
GO

-- 销售通用次卡业
绩门店配置方案
IF OBJECT_ID(N'TB_SaleGeneralCardEntityPer
formanceScheme', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardEntityPer
formanceScheme];
GO
CREATE TABLE [TB_SaleGeneralCardEntityPer
formanceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardEntityPer
formanceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 销售通用次卡经
手人佣金提成员
工配置
IF OBJECT_ID(N'TB_SaleGeneralCardHandlerC
ommission', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardHandlerC
ommission];
GO
CREATE TABLE [TB_SaleGeneralCardHandlerC
ommission] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [GeneralCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardHandlerC
ommission] PRIMARY KEY ([EntityID],[GeneralCardID],[GeneralCardSaleHandlerID])
);
GO

-- 销售通用次卡经
手人职务佣金提
成员工配置
IF OBJECT_ID(N'TB_SaleGeneralCardHandlerJ
obTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardHandlerJ
obTypeCommission];
GO
CREATE TABLE [TB_SaleGeneralCardHandlerJ
obTypeCommission] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [GeneralCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardHandlerJ
obTypeCommission] PRIMARY KEY ([EntityID],[GeneralCardID],[GeneralCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售通用次卡经
手人职务业绩员
工配置
IF OBJECT_ID(N'TB_SaleGeneralCardHandlerJ
obTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardHandlerJ
obTypePerformance];
GO
CREATE TABLE [TB_SaleGeneralCardHandlerJ
obTypePerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [GeneralCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardHandlerJ
obTypePerformance] PRIMARY KEY ([EntityID],[GeneralCardID],[GeneralCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售通用次卡经
手人业绩员工配
IF OBJECT_ID(N'TB_SaleGeneralCardHandlerP
erformance', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardHandlerP
erformance];
GO
CREATE TABLE [TB_SaleGeneralCardHandlerP
erformance] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [GeneralCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardHandlerP
erformance] PRIMARY KEY ([EntityID],[GeneralCardID],[GeneralCardSaleHandlerID])
);
GO

-- 销售通用次卡业
绩员工配置
IF OBJECT_ID(N'TB_SaleGeneralCardPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardPerformance];
GO
CREATE TABLE [TB_SaleGeneralCardPerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardPerformance] PRIMARY KEY ([EntityID],[GeneralCardID])
);
GO

-- 销售通用次卡业
绩员工配置方案
IF OBJECT_ID(N'TB_SaleGeneralCardPerforma
nceScheme', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardPerforma
nceScheme];
GO
CREATE TABLE [TB_SaleGeneralCardPerforma
nceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardPerforma
nceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 销售所有通用次
卡经手人佣金提
成员工配置
IF OBJECT_ID(N'TB_SaleGeneralCardScheme
HandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardScheme
HandlerCommission];
GO
CREATE TABLE [TB_SaleGeneralCardScheme
HandlerCommission] (
    [EntityID] int NOT NULL,
    [GeneralCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardScheme
HandlerCommission] PRIMARY KEY ([EntityID],[GeneralCardSaleHandlerID])
);
GO

-- 销售所有通用次
卡经手人职务佣
金提成员工配置
IF OBJECT_ID(N'TB_SaleGeneralCardScheme
HandlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardScheme
HandlerJobTypeCommission];
GO
CREATE TABLE [TB_SaleGeneralCardScheme
HandlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [GeneralCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardScheme
HandlerJobTypeCommission] PRIMARY KEY ([EntityID],[GeneralCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售通用次卡所
有经手人职务业
绩员工配置
IF OBJECT_ID(N'TB_SaleGeneralCardScheme
HandlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardScheme
HandlerJobTypePerformance];
GO
CREATE TABLE [TB_SaleGeneralCardScheme
HandlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardScheme
HandlerJobTypePerformance] PRIMARY KEY ([EntityID],[GeneralCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售通用次卡所
有经手人业绩员
工配置
IF OBJECT_ID(N'TB_SaleGeneralCardScheme
HandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleGeneralCardScheme
HandlerPerformance];
GO
CREATE TABLE [TB_SaleGeneralCardScheme
HandlerPerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleGeneralCardScheme
HandlerPerformance] PRIMARY KEY ([EntityID],[GeneralCardSaleHandlerID])
);
GO

-- 销售套餐卡分类
佣金提成员工配
IF OBJECT_ID(N'TB_SalePackageCardCategor
yCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardCategor
yCommission];
GO
CREATE TABLE [TB_SalePackageCardCategor
yCommission] (
    [EntityID] int NOT NULL,
    [PackageCardCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardCategor
yCommission] PRIMARY KEY ([EntityID],[PackageCardCategoryID])
);
GO

-- 销售套餐卡分类
经手人佣金提成
员工配置
IF OBJECT_ID(N'TB_SalePackageCardCategor
yHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardCategor
yHandlerCommission];
GO
CREATE TABLE [TB_SalePackageCardCategor
yHandlerCommission] (
    [EntityID] int NOT NULL,
    [PackageCardCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardCategor
yHandlerCommission] PRIMARY KEY ([EntityID],[PackageCardCategoryID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡分类
经手人职务佣金
提成员工配置
IF OBJECT_ID(N'TB_SalePackageCardCategor
yHandlerJobTypeCommissio
n', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardCategor
yHandlerJobTypeCommissio
n];
GO
CREATE TABLE [TB_SalePackageCardCategor
yHandlerJobTypeCommissio
n] (
    [EntityID] int NOT NULL,
    [PackageCardCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardCategor
yHandlerJobTypeCommissio
n] PRIMARY KEY ([EntityID],[PackageCardCategoryID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡佣金
提成员工配置
IF OBJECT_ID(N'TB_SalePackageCardCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardCommission];
GO
CREATE TABLE [TB_SalePackageCardCommission] (
    [EntityID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardCommission] PRIMARY KEY ([EntityID],[PackageCardID])
);
GO

-- 销售套餐卡佣金
提成员工配置方
IF OBJECT_ID(N'TB_SalePackageCardCommis
sionScheme', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardCommis
sionScheme];
GO
CREATE TABLE [TB_SalePackageCardCommis
sionScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardCommis
sionScheme] PRIMARY KEY ([EntityID])
);
GO

-- 销售套餐卡通用
次卡分类经手人
职务佣金提成员
IF OBJECT_ID(N'TB_SalePackageCardGeneral
CardCategoryHandlerCommi
ssion', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardGeneral
CardCategoryHandlerCommi
ssion];
GO
CREATE TABLE [TB_SalePackageCardGeneral
CardCategoryHandlerCommi
ssion] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardGeneral
CardCategoryHandlerCommi
ssion] PRIMARY KEY ([EntityID],[GeneralCardCategoryID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡通用
次卡分类经手人
职务佣金提成员
IF OBJECT_ID(N'TB_SalePackageCardGeneral
CardCategoryHandlerJobTyp
eCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardGeneral
CardCategoryHandlerJobTyp
eCommission];
GO
CREATE TABLE [TB_SalePackageCardGeneral
CardCategoryHandlerJobTyp
eCommission] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardGeneral
CardCategoryHandlerJobTyp
eCommission] PRIMARY KEY ([EntityID],[GeneralCardCategoryID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡通用
次卡分类经手人
职务业绩员工配
IF OBJECT_ID(N'TB_SalePackageCardGeneral
CardCategoryHandlerJobTyp
ePerformance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardGeneral
CardCategoryHandlerJobTyp
ePerformance];
GO
CREATE TABLE [TB_SalePackageCardGeneral
CardCategoryHandlerJobTyp
ePerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardGeneral
CardCategoryHandlerJobTyp
ePerformance] PRIMARY KEY ([EntityID],[GeneralCardCategoryID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡通用
次卡分类经手人
业绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardGeneral
CardCategoryHandlerPerfor
mance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardGeneral
CardCategoryHandlerPerfor
mance];
GO
CREATE TABLE [TB_SalePackageCardGeneral
CardCategoryHandlerPerfor
mance] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardGeneral
CardCategoryHandlerPerfor
mance] PRIMARY KEY ([EntityID],[GeneralCardCategoryID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡通用
次卡经手人佣金
提成员工配置
IF OBJECT_ID(N'TB_SalePackageCardGeneral
CardHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardGeneral
CardHandlerCommission];
GO
CREATE TABLE [TB_SalePackageCardGeneral
CardHandlerCommission] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardGeneral
CardHandlerCommission] PRIMARY KEY ([EntityID],[GeneralCardID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡通用
次卡经手人职务
佣金提成员工配
IF OBJECT_ID(N'TB_SalePackageCardGeneral
CardHandlerJobTypeCommis
sion', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardGeneral
CardHandlerJobTypeCommis
sion];
GO
CREATE TABLE [TB_SalePackageCardGeneral
CardHandlerJobTypeCommis
sion] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardGeneral
CardHandlerJobTypeCommis
sion] PRIMARY KEY ([EntityID],[GeneralCardID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡通用
次卡经手人职务
业绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardGeneral
CardHandlerJobTypePerform
ance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardGeneral
CardHandlerJobTypePerform
ance];
GO
CREATE TABLE [TB_SalePackageCardGeneral
CardHandlerJobTypePerform
ance] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardGeneral
CardHandlerJobTypePerform
ance] PRIMARY KEY ([EntityID],[GeneralCardID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡通用
次卡经手人业绩
员工配置
IF OBJECT_ID(N'TB_SalePackageCardGeneral
CardHandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardGeneral
CardHandlerPerformance];
GO
CREATE TABLE [TB_SalePackageCardGeneral
CardHandlerPerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardGeneral
CardHandlerPerformance] PRIMARY KEY ([EntityID],[GeneralCardID],[PackageCardSaleHandlerID])
);
GO

-- 销售所有套餐卡
通用次卡经手人
佣金提成员工配
IF OBJECT_ID(N'TB_SalePackageCardGeneral
CardSchemeHandlerCommis
sion', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardGeneral
CardSchemeHandlerCommis
sion];
GO
CREATE TABLE [TB_SalePackageCardGeneral
CardSchemeHandlerCommis
sion] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardGeneral
CardSchemeHandlerCommis
sion] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID])
);
GO

-- 销售所有套餐卡
通用次卡经手人
职务佣金提成员
IF OBJECT_ID(N'TB_SalePackageCardGeneral
CardSchemeHandlerJobType
Commission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardGeneral
CardSchemeHandlerJobType
Commission];
GO
CREATE TABLE [TB_SalePackageCardGeneral
CardSchemeHandlerJobType
Commission] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardGeneral
CardSchemeHandlerJobType
Commission] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售所有套餐卡
通用次卡经手人
职务业绩员工配
IF OBJECT_ID(N'TB_SalePackageCardGeneral
CardSchemeHandlerJobType
Performance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardGeneral
CardSchemeHandlerJobType
Performance];
GO
CREATE TABLE [TB_SalePackageCardGeneral
CardSchemeHandlerJobType
Performance] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardGeneral
CardSchemeHandlerJobType
Performance] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售所有套餐卡
通用次卡经手人
业绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardGeneral
CardSchemeHandlerPerform
ance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardGeneral
CardSchemeHandlerPerform
ance];
GO
CREATE TABLE [TB_SalePackageCardGeneral
CardSchemeHandlerPerform
ance] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardGeneral
CardSchemeHandlerPerform
ance] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡经手
人佣金提成员工
IF OBJECT_ID(N'TB_SalePackageCardHandler
Commission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardHandler
Commission];
GO
CREATE TABLE [TB_SalePackageCardHandler
Commission] (
    [EntityID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardHandler
Commission] PRIMARY KEY ([EntityID],[PackageCardID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡经手
人职务佣金提成
员工配置
IF OBJECT_ID(N'TB_SalePackageCardHandlerJ
obTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardHandlerJ
obTypeCommission];
GO
CREATE TABLE [TB_SalePackageCardHandlerJ
obTypeCommission] (
    [EntityID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardHandlerJ
obTypeCommission] PRIMARY KEY ([EntityID],[PackageCardID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡产品
分类经手人职务
佣金提成员工配
IF OBJECT_ID(N'TB_SalePackageCardProduct
CategoryHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProduct
CategoryHandlerCommission];
GO
CREATE TABLE [TB_SalePackageCardProduct
CategoryHandlerCommission] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProduct
CategoryHandlerCommission] PRIMARY KEY ([EntityID],[ProductCategoryID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡产品
分类经手人职务
佣金提成员工配
IF OBJECT_ID(N'TB_SalePackageCardProduct
CategoryHandlerJobTypeCo
mmission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProduct
CategoryHandlerJobTypeCo
mmission];
GO
CREATE TABLE [TB_SalePackageCardProduct
CategoryHandlerJobTypeCo
mmission] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProduct
CategoryHandlerJobTypeCo
mmission] PRIMARY KEY ([EntityID],[ProductCategoryID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡产品
分类经手人职务
业绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardProduct
CategoryHandlerJobTypePerf
ormance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProduct
CategoryHandlerJobTypePerf
ormance];
GO
CREATE TABLE [TB_SalePackageCardProduct
CategoryHandlerJobTypePerf
ormance] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProduct
CategoryHandlerJobTypePerf
ormance] PRIMARY KEY ([EntityID],[ProductCategoryID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡产品
分类经手人业绩
员工配置
IF OBJECT_ID(N'TB_SalePackageCardProduct
CategoryHandlerPerformanc
e', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProduct
CategoryHandlerPerformanc
e];
GO
CREATE TABLE [TB_SalePackageCardProduct
CategoryHandlerPerformanc
e] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProduct
CategoryHandlerPerformanc
e] PRIMARY KEY ([EntityID],[ProductCategoryID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡产品
经手人佣金提成
员工配置
IF OBJECT_ID(N'TB_SalePackageCardProduct
HandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProduct
HandlerCommission];
GO
CREATE TABLE [TB_SalePackageCardProduct
HandlerCommission] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProduct
HandlerCommission] PRIMARY KEY ([EntityID],[ProductID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡产品
经手人职务佣金
提成员工配置
IF OBJECT_ID(N'TB_SalePackageCardProduct
HandlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProduct
HandlerJobTypeCommission];
GO
CREATE TABLE [TB_SalePackageCardProduct
HandlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProduct
HandlerJobTypeCommission] PRIMARY KEY ([EntityID],[ProductID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡产品
经手人职务业绩
员工配置
IF OBJECT_ID(N'TB_SalePackageCardProduct
HandlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProduct
HandlerJobTypePerformance];
GO
CREATE TABLE [TB_SalePackageCardProduct
HandlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProduct
HandlerJobTypePerformance] PRIMARY KEY ([EntityID],[ProductID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡产品
经手人业绩员工
IF OBJECT_ID(N'TB_SalePackageCardProduct
HandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProduct
HandlerPerformance];
GO
CREATE TABLE [TB_SalePackageCardProduct
HandlerPerformance] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProduct
HandlerPerformance] PRIMARY KEY ([EntityID],[ProductID],[PackageCardSaleHandlerID])
);
GO

-- 销售所有套餐卡
产品经手人佣金
提成员工配置
IF OBJECT_ID(N'TB_SalePackageCardProduct
SchemeHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProduct
SchemeHandlerCommission];
GO
CREATE TABLE [TB_SalePackageCardProduct
SchemeHandlerCommission] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProduct
SchemeHandlerCommission] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID])
);
GO

-- 销售所有套餐卡
产品经手人职务
佣金提成员工配
IF OBJECT_ID(N'TB_SalePackageCardProduct
SchemeHandlerJobTypeCom
mission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProduct
SchemeHandlerJobTypeCom
mission];
GO
CREATE TABLE [TB_SalePackageCardProduct
SchemeHandlerJobTypeCom
mission] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProduct
SchemeHandlerJobTypeCom
mission] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售所有套餐卡
产品经手人职务
业绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardProduct
SchemeHandlerJobTypePerfo
rmance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProduct
SchemeHandlerJobTypePerfo
rmance];
GO
CREATE TABLE [TB_SalePackageCardProduct
SchemeHandlerJobTypePerfo
rmance] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProduct
SchemeHandlerJobTypePerfo
rmance] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售所有套餐卡
产品经手人业绩
员工配置
IF OBJECT_ID(N'TB_SalePackageCardProduct
SchemeHandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProduct
SchemeHandlerPerformance];
GO
CREATE TABLE [TB_SalePackageCardProduct
SchemeHandlerPerformance] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProduct
SchemeHandlerPerformance] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID])
);
GO

-- 销售所有套餐卡
项目分类经手人
职务佣金提成员
IF OBJECT_ID(N'TB_SalePackageCardProjectC
ategoryHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProjectC
ategoryHandlerCommission];
GO
CREATE TABLE [TB_SalePackageCardProjectC
ategoryHandlerCommission] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProjectC
ategoryHandlerCommission] PRIMARY KEY ([EntityID],[ProjectCategoryID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡项目
分类经手人职务
佣金提成员工配
IF OBJECT_ID(N'TB_SalePackageCardProjectC
ategoryHandlerJobTypeCom
mission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProjectC
ategoryHandlerJobTypeCom
mission];
GO
CREATE TABLE [TB_SalePackageCardProjectC
ategoryHandlerJobTypeCom
mission] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProjectC
ategoryHandlerJobTypeCom
mission] PRIMARY KEY ([EntityID],[ProjectCategoryID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡项目
分类经手人职务
业绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardProjectC
ategoryHandlerJobTypePerfo
rmance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProjectC
ategoryHandlerJobTypePerfo
rmance];
GO
CREATE TABLE [TB_SalePackageCardProjectC
ategoryHandlerJobTypePerfo
rmance] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProjectC
ategoryHandlerJobTypePerfo
rmance] PRIMARY KEY ([EntityID],[ProjectCategoryID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡项目
分类经手人业绩
员工配置
IF OBJECT_ID(N'TB_SalePackageCardProjectC
ategoryHandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProjectC
ategoryHandlerPerformance];
GO
CREATE TABLE [TB_SalePackageCardProjectC
ategoryHandlerPerformance] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProjectC
ategoryHandlerPerformance] PRIMARY KEY ([EntityID],[ProjectCategoryID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡项目
经手人佣金提成
员工配置
IF OBJECT_ID(N'TB_SalePackageCardProjectH
andlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProjectH
andlerCommission];
GO
CREATE TABLE [TB_SalePackageCardProjectH
andlerCommission] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProjectH
andlerCommission] PRIMARY KEY ([EntityID],[ProjectID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡项目
经手人职务佣金
提成员工配置
IF OBJECT_ID(N'TB_SalePackageCardProjectH
andlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProjectH
andlerJobTypeCommission];
GO
CREATE TABLE [TB_SalePackageCardProjectH
andlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProjectH
andlerJobTypeCommission] PRIMARY KEY ([EntityID],[ProjectID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡项目
经手人职务业绩
员工配置
IF OBJECT_ID(N'TB_SalePackageCardProjectH
andlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProjectH
andlerJobTypePerformance];
GO
CREATE TABLE [TB_SalePackageCardProjectH
andlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProjectH
andlerJobTypePerformance] PRIMARY KEY ([EntityID],[ProjectID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡项目
经手人业绩员工
IF OBJECT_ID(N'TB_SalePackageCardProjectH
andlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProjectH
andlerPerformance];
GO
CREATE TABLE [TB_SalePackageCardProjectH
andlerPerformance] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProjectH
andlerPerformance] PRIMARY KEY ([EntityID],[ProjectID],[PackageCardSaleHandlerID])
);
GO

-- 销售所有套餐卡
项目经手人佣金
提成员工配置
IF OBJECT_ID(N'TB_SalePackageCardProjectS
chemeHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProjectS
chemeHandlerCommission];
GO
CREATE TABLE [TB_SalePackageCardProjectS
chemeHandlerCommission] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProjectS
chemeHandlerCommission] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID])
);
GO

-- 销售所有套餐卡
项目经手人职务
佣金提成员工配
IF OBJECT_ID(N'TB_SalePackageCardProjectS
chemeHandlerJobTypeCom
mission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProjectS
chemeHandlerJobTypeCom
mission];
GO
CREATE TABLE [TB_SalePackageCardProjectS
chemeHandlerJobTypeCom
mission] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProjectS
chemeHandlerJobTypeCom
mission] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售所有套餐卡
项目经手人职务
业绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardProjectS
chemeHandlerJobTypePerfor
mance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProjectS
chemeHandlerJobTypePerfor
mance];
GO
CREATE TABLE [TB_SalePackageCardProjectS
chemeHandlerJobTypePerfor
mance] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProjectS
chemeHandlerJobTypePerfor
mance] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售所有套餐卡
项目经手人业绩
员工配置
IF OBJECT_ID(N'TB_SalePackageCardProjectS
chemeHandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardProjectS
chemeHandlerPerformance];
GO
CREATE TABLE [TB_SalePackageCardProjectS
chemeHandlerPerformance] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardProjectS
chemeHandlerPerformance] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡储值
卡分类经手人职
务佣金提成员工
IF OBJECT_ID(N'TB_SalePackageCardSavingC
ardCategoryHandlerCommiss
ion', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardSavingC
ardCategoryHandlerCommiss
ion];
GO
CREATE TABLE [TB_SalePackageCardSavingC
ardCategoryHandlerCommiss
ion] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardSavingC
ardCategoryHandlerCommiss
ion] PRIMARY KEY ([EntityID],[SavingCardCategory
ID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡储值
卡分类经手人职
务佣金提成员工
IF OBJECT_ID(N'TB_SalePackageCardSavingC
ardCategoryHandlerJobType
Commission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardSavingC
ardCategoryHandlerJobType
Commission];
GO
CREATE TABLE [TB_SalePackageCardSavingC
ardCategoryHandlerJobType
Commission] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardSavingC
ardCategoryHandlerJobType
Commission] PRIMARY KEY ([EntityID],[SavingCardCategory
ID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡储值
卡分类经手人职
务业绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardSavingC
ardCategoryHandlerJobType
Performance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardSavingC
ardCategoryHandlerJobType
Performance];
GO
CREATE TABLE [TB_SalePackageCardSavingC
ardCategoryHandlerJobType
Performance] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardSavingC
ardCategoryHandlerJobType
Performance] PRIMARY KEY ([EntityID],[SavingCardCategory
ID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡储值
卡分类经手人业
绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardSavingC
ardCategoryHandlerPerform
ance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardSavingC
ardCategoryHandlerPerform
ance];
GO
CREATE TABLE [TB_SalePackageCardSavingC
ardCategoryHandlerPerform
ance] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardSavingC
ardCategoryHandlerPerform
ance] PRIMARY KEY ([EntityID],[SavingCardCategory
ID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡储值
卡经手人佣金提
成员工配置
IF OBJECT_ID(N'TB_SalePackageCardSavingC
ardHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardSavingC
ardHandlerCommission];
GO
CREATE TABLE [TB_SalePackageCardSavingC
ardHandlerCommission] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardSavingC
ardHandlerCommission] PRIMARY KEY ([EntityID],[SavingCardID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡储值
卡经手人职务佣
金提成员工配置
IF OBJECT_ID(N'TB_SalePackageCardSavingC
ardHandlerJobTypeCommissi
on', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardSavingC
ardHandlerJobTypeCommissi
on];
GO
CREATE TABLE [TB_SalePackageCardSavingC
ardHandlerJobTypeCommissi
on] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardSavingC
ardHandlerJobTypeCommissi
on] PRIMARY KEY ([EntityID],[SavingCardID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡储值
卡经手人职务业
绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardSavingC
ardHandlerJobTypePerforma
nce', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardSavingC
ardHandlerJobTypePerforma
nce];
GO
CREATE TABLE [TB_SalePackageCardSavingC
ardHandlerJobTypePerforma
nce] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardSavingC
ardHandlerJobTypePerforma
nce] PRIMARY KEY ([EntityID],[SavingCardID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡储值
卡经手人业绩员
工配置
IF OBJECT_ID(N'TB_SalePackageCardSavingC
ardHandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardSavingC
ardHandlerPerformance];
GO
CREATE TABLE [TB_SalePackageCardSavingC
ardHandlerPerformance] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardSavingC
ardHandlerPerformance] PRIMARY KEY ([EntityID],[SavingCardID],[PackageCardSaleHandlerID])
);
GO

-- 销售所有套餐卡
储值卡经手人佣
金提成员工配置
IF OBJECT_ID(N'TB_SalePackageCardSavingC
ardSchemeHandlerCommissi
on', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardSavingC
ardSchemeHandlerCommissi
on];
GO
CREATE TABLE [TB_SalePackageCardSavingC
ardSchemeHandlerCommissi
on] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardSavingC
ardSchemeHandlerCommissi
on] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID])
);
GO

-- 销售所有套餐卡
储值卡经手人职
务佣金提成员工
IF OBJECT_ID(N'TB_SalePackageCardSavingC
ardSchemeHandlerJobTypeC
ommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardSavingC
ardSchemeHandlerJobTypeC
ommission];
GO
CREATE TABLE [TB_SalePackageCardSavingC
ardSchemeHandlerJobTypeC
ommission] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardSavingC
ardSchemeHandlerJobTypeC
ommission] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售所有套餐卡
储值卡经手人职
务业绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardSavingC
ardSchemeHandlerJobTypeP
erformance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardSavingC
ardSchemeHandlerJobTypeP
erformance];
GO
CREATE TABLE [TB_SalePackageCardSavingC
ardSchemeHandlerJobTypeP
erformance] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardSavingC
ardSchemeHandlerJobTypeP
erformance] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售所有套餐卡
储值卡经手人业
绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardSavingC
ardSchemeHandlerPerforma
nce', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardSavingC
ardSchemeHandlerPerforma
nce];
GO
CREATE TABLE [TB_SalePackageCardSavingC
ardSchemeHandlerPerforma
nce] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardSavingC
ardSchemeHandlerPerforma
nce] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID])
);
GO

-- 销售所有套餐卡
经手人佣金提成
员工配置
IF OBJECT_ID(N'TB_SalePackageCardScheme
HandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardScheme
HandlerCommission];
GO
CREATE TABLE [TB_SalePackageCardScheme
HandlerCommission] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardScheme
HandlerCommission] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID])
);
GO

-- 销售所有套餐卡
经手人职务佣金
提成员工配置
IF OBJECT_ID(N'TB_SalePackageCardScheme
HandlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardScheme
HandlerJobTypeCommission];
GO
CREATE TABLE [TB_SalePackageCardScheme
HandlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardScheme
HandlerJobTypeCommission] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡时效
卡分类经手人职
务佣金提成员工
IF OBJECT_ID(N'TB_SalePackageCardTimeCar
dCategoryHandlerCommissio
n', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardTimeCar
dCategoryHandlerCommissio
n];
GO
CREATE TABLE [TB_SalePackageCardTimeCar
dCategoryHandlerCommissio
n] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardTimeCar
dCategoryHandlerCommissio
n] PRIMARY KEY ([EntityID],[TimeCardCategoryID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡时效
卡分类经手人职
务佣金提成员工
IF OBJECT_ID(N'TB_SalePackageCardTimeCar
dCategoryHandlerJobTypeCo
mmission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardTimeCar
dCategoryHandlerJobTypeCo
mmission];
GO
CREATE TABLE [TB_SalePackageCardTimeCar
dCategoryHandlerJobTypeCo
mmission] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardTimeCar
dCategoryHandlerJobTypeCo
mmission] PRIMARY KEY ([EntityID],[TimeCardCategoryID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡时效
卡分类经手人职
务业绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardTimeCar
dCategoryHandlerJobTypePe
rformance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardTimeCar
dCategoryHandlerJobTypePe
rformance];
GO
CREATE TABLE [TB_SalePackageCardTimeCar
dCategoryHandlerJobTypePe
rformance] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardTimeCar
dCategoryHandlerJobTypePe
rformance] PRIMARY KEY ([EntityID],[TimeCardCategoryID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡时效
卡分类经手人业
绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardTimeCar
dCategoryHandlerPerforman
ce', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardTimeCar
dCategoryHandlerPerforman
ce];
GO
CREATE TABLE [TB_SalePackageCardTimeCar
dCategoryHandlerPerforman
ce] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardTimeCar
dCategoryHandlerPerforman
ce] PRIMARY KEY ([EntityID],[TimeCardCategoryID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡时效
卡经手人佣金提
成员工配置
IF OBJECT_ID(N'TB_SalePackageCardTimeCar
dHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardTimeCar
dHandlerCommission];
GO
CREATE TABLE [TB_SalePackageCardTimeCar
dHandlerCommission] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardTimeCar
dHandlerCommission] PRIMARY KEY ([EntityID],[TimeCardID],[PackageCardSaleHandlerID])
);
GO

-- 销售套餐卡时效
卡经手人职务佣
金提成员工配置
IF OBJECT_ID(N'TB_SalePackageCardTimeCar
dHandlerJobTypeCommissio
n', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardTimeCar
dHandlerJobTypeCommissio
n];
GO
CREATE TABLE [TB_SalePackageCardTimeCar
dHandlerJobTypeCommissio
n] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardTimeCar
dHandlerJobTypeCommissio
n] PRIMARY KEY ([EntityID],[TimeCardID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡时效
卡经手人职务业
绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardTimeCar
dHandlerJobTypePerformanc
e', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardTimeCar
dHandlerJobTypePerformanc
e];
GO
CREATE TABLE [TB_SalePackageCardTimeCar
dHandlerJobTypePerformanc
e] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardTimeCar
dHandlerJobTypePerformanc
e] PRIMARY KEY ([EntityID],[TimeCardID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售套餐卡时效
卡经手人业绩员
工配置
IF OBJECT_ID(N'TB_SalePackageCardTimeCar
dHandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardTimeCar
dHandlerPerformance];
GO
CREATE TABLE [TB_SalePackageCardTimeCar
dHandlerPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardTimeCar
dHandlerPerformance] PRIMARY KEY ([EntityID],[TimeCardID],[PackageCardSaleHandlerID])
);
GO

-- 销售所有套餐卡
时效卡经手人佣
金提成员工配置
IF OBJECT_ID(N'TB_SalePackageCardTimeCar
dSchemeHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardTimeCar
dSchemeHandlerCommission];
GO
CREATE TABLE [TB_SalePackageCardTimeCar
dSchemeHandlerCommission] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardTimeCar
dSchemeHandlerCommission] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID])
);
GO

-- 销售所有套餐卡
时效卡分类经手
人职务佣金提成
员工配置
IF OBJECT_ID(N'TB_SalePackageCardTimeCar
dSchemeHandlerJobTypeCo
mmission', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardTimeCar
dSchemeHandlerJobTypeCo
mmission];
GO
CREATE TABLE [TB_SalePackageCardTimeCar
dSchemeHandlerJobTypeCo
mmission] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SalePackageCardTimeCar
dSchemeHandlerJobTypeCo
mmission] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售所有套餐卡
时效卡经手人职
务业绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardTimeCar
dSchemeHandlerJobTypePerf
ormance', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardTimeCar
dSchemeHandlerJobTypePerf
ormance];
GO
CREATE TABLE [TB_SalePackageCardTimeCar
dSchemeHandlerJobTypePerf
ormance] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardTimeCar
dSchemeHandlerJobTypePerf
ormance] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售所有套餐卡
时效卡经手人业
绩员工配置
IF OBJECT_ID(N'TB_SalePackageCardTimeCar
dSchemeHandlerPerformanc
e', N'U') IS NOT NULL DROP TABLE [TB_SalePackageCardTimeCar
dSchemeHandlerPerformanc
e];
GO
CREATE TABLE [TB_SalePackageCardTimeCar
dSchemeHandlerPerformanc
e] (
    [EntityID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SalePackageCardTimeCar
dSchemeHandlerPerformanc
e] PRIMARY KEY ([EntityID],[PackageCardSaleHandlerID])
);
GO

-- 销售产品类别佣
金提成员工配置
IF OBJECT_ID(N'TB_SaleProductCategoryCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleProductCategoryCommission];
GO
CREATE TABLE [TB_SaleProductCategoryCommission] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProductCategoryCommission] PRIMARY KEY ([EntityID],[ProductCategoryID])
);
GO

-- 销售产品类别业
绩门店配置
IF OBJECT_ID(N'TB_SaleProductCategoryEntit
yPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProductCategoryEntit
yPerformance];
GO
CREATE TABLE [TB_SaleProductCategoryEntit
yPerformance] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProductCategoryEntit
yPerformance] PRIMARY KEY ([EntityID],[ProductCategoryID])
);
GO

-- 销售产品类别经
手人佣金提成员
工配置
IF OBJECT_ID(N'TB_SaleProductCategoryHan
dlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleProductCategoryHan
dlerCommission];
GO
CREATE TABLE [TB_SaleProductCategoryHan
dlerCommission] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [ProductSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProductCategoryHan
dlerCommission] PRIMARY KEY ([EntityID],[ProductCategoryID],[ProductSaleHandlerID])
);
GO

-- 销售产品类别经
手人职务佣金提
成员工配置
IF OBJECT_ID(N'TB_SaleProductCategoryHan
dlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleProductCategoryHan
dlerJobTypeCommission];
GO
CREATE TABLE [TB_SaleProductCategoryHan
dlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [ProductSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProductCategoryHan
dlerJobTypeCommission] PRIMARY KEY ([EntityID],[ProductCategoryID],[ProductSaleHandlerID],[JobTypeID])
);
GO

-- 销售产品类别经
手人职务业绩员
工配置
IF OBJECT_ID(N'TB_SaleProductCategoryHan
dlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProductCategoryHan
dlerJobTypePerformance];
GO
CREATE TABLE [TB_SaleProductCategoryHan
dlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [ProductSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProductCategoryHan
dlerJobTypePerformance] PRIMARY KEY ([EntityID],[ProductCategoryID],[ProductSaleHandlerID],[JobTypeID])
);
GO

-- 销售产品类别经
手人业绩配置
IF OBJECT_ID(N'TB_SaleProductCategoryHan
dlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProductCategoryHan
dlerPerformance];
GO
CREATE TABLE [TB_SaleProductCategoryHan
dlerPerformance] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [ProductSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProductCategoryHan
dlerPerformance] PRIMARY KEY ([EntityID],[ProductCategoryID],[ProductSaleHandlerID])
);
GO

-- 销售产品类别业
绩员工配置
IF OBJECT_ID(N'TB_SaleProductCategoryPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProductCategoryPerformance];
GO
CREATE TABLE [TB_SaleProductCategoryPerformance] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProductCategoryPerformance] PRIMARY KEY ([EntityID],[ProductCategoryID])
);
GO

-- 销售产品佣金提
成员工配置
IF OBJECT_ID(N'TB_SaleProductCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleProductCommission];
GO
CREATE TABLE [TB_SaleProductCommission] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProductCommission] PRIMARY KEY ([EntityID],[ProductID])
);
GO

-- 销售产品佣金提
成员工配置方案
IF OBJECT_ID(N'TB_SaleProductCommissionScheme', N'U') IS NOT NULL DROP TABLE [TB_SaleProductCommissionScheme];
GO
CREATE TABLE [TB_SaleProductCommissionScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProductCommissionScheme] PRIMARY KEY ([EntityID])
);
GO

-- 销售产品业绩门店配置
IF OBJECT_ID(N'TB_SaleProductEntityPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProductEntityPerformance];
GO
CREATE TABLE [TB_SaleProductEntityPerformance] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProductEntityPerformance] PRIMARY KEY ([EntityID],[ProductID])
);
GO

-- 销售产品业绩门
店配置方案
IF OBJECT_ID(N'TB_SaleProductEntityPerform
anceScheme', N'U') IS NOT NULL DROP TABLE [TB_SaleProductEntityPerform
anceScheme];
GO
CREATE TABLE [TB_SaleProductEntityPerform
anceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProductEntityPerform
anceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 销售产品经手人
佣金提成员工配
IF OBJECT_ID(N'TB_SaleProductHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleProductHandlerCommission];
GO
CREATE TABLE [TB_SaleProductHandlerCommission] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [ProductSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProductHandlerCommission] PRIMARY KEY ([EntityID],[ProductID],[ProductSaleHandlerID])
);
GO

-- 销售产品经手人
职务佣金提成员
工配置
IF OBJECT_ID(N'TB_SaleProductHandlerJobTy
peCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleProductHandlerJobTy
peCommission];
GO
CREATE TABLE [TB_SaleProductHandlerJobTy
peCommission] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [ProductSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProductHandlerJobTy
peCommission] PRIMARY KEY ([EntityID],[ProductID],[ProductSaleHandlerID],[JobTypeID])
);
GO

-- 销售产品经手人
职务业绩员工配
IF OBJECT_ID(N'TB_SaleProductHandlerJobTy
pePerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProductHandlerJobTy
pePerformance];
GO
CREATE TABLE [TB_SaleProductHandlerJobTy
pePerformance] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [ProductSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProductHandlerJobTy
pePerformance] PRIMARY KEY ([EntityID],[ProductID],[ProductSaleHandlerID],[JobTypeID])
);
GO

-- 销售产品经手人
业绩员工配置
IF OBJECT_ID(N'TB_SaleProductHandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProductHandlerPerformance];
GO
CREATE TABLE [TB_SaleProductHandlerPerformance] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [ProductSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProductHandlerPerformance] PRIMARY KEY ([EntityID],[ProductID],[ProductSaleHandlerID])
);
GO

-- 销售产品业绩员工配置
IF OBJECT_ID(N'TB_SaleProductPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProductPerformance];
GO
CREATE TABLE [TB_SaleProductPerformance] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProductPerformance] PRIMARY KEY ([EntityID],[ProductID])
);
GO

-- 销售产品业绩员
工配置方案
IF OBJECT_ID(N'TB_SaleProductPerformanceScheme', N'U') IS NOT NULL DROP TABLE [TB_SaleProductPerformanceScheme];
GO
CREATE TABLE [TB_SaleProductPerformanceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProductPerformanceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 销售所有产品经
手人佣金提成员
工配置
IF OBJECT_ID(N'TB_SaleProductSchemeHandl
erCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleProductSchemeHandl
erCommission];
GO
CREATE TABLE [TB_SaleProductSchemeHandl
erCommission] (
    [EntityID] int NOT NULL,
    [ProductSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProductSchemeHandl
erCommission] PRIMARY KEY ([EntityID],[ProductSaleHandlerID])
);
GO

-- 销售所有产品经
手人职务佣金提
成员工配置
IF OBJECT_ID(N'TB_SaleProductSchemeHandl
erJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleProductSchemeHandl
erJobTypeCommission];
GO
CREATE TABLE [TB_SaleProductSchemeHandl
erJobTypeCommission] (
    [EntityID] int NOT NULL,
    [ProductSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProductSchemeHandl
erJobTypeCommission] PRIMARY KEY ([EntityID],[ProductSaleHandlerID],[JobTypeID])
);
GO

-- 销售产品所有经
手人职务业绩员
工配置
IF OBJECT_ID(N'TB_SaleProductSchemeHandl
erJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProductSchemeHandl
erJobTypePerformance];
GO
CREATE TABLE [TB_SaleProductSchemeHandl
erJobTypePerformance] (
    [EntityID] int NOT NULL,
    [ProductSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProductSchemeHandl
erJobTypePerformance] PRIMARY KEY ([EntityID],[ProductSaleHandlerID],[JobTypeID])
);
GO

-- 销售产品所有经
手人业绩员工配
IF OBJECT_ID(N'TB_SaleProductSchemeHandl
erPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProductSchemeHandl
erPerformance];
GO
CREATE TABLE [TB_SaleProductSchemeHandl
erPerformance] (
    [EntityID] int NOT NULL,
    [ProductSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProductSchemeHandl
erPerformance] PRIMARY KEY ([EntityID],[ProductSaleHandlerID])
);
GO

-- 销售项目类别佣
金提成员工配置
IF OBJECT_ID(N'TB_SaleProjectCategoryCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectCategoryCommission];
GO
CREATE TABLE [TB_SaleProjectCategoryCommission] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProjectCategoryCommission] PRIMARY KEY ([EntityID],[ProjectCategoryID])
);
GO

-- 销售项目类别业
绩门店配置
IF OBJECT_ID(N'TB_SaleProjectCategoryEntity
Performance', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectCategoryEntity
Performance];
GO
CREATE TABLE [TB_SaleProjectCategoryEntity
Performance] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProjectCategoryEntity
Performance] PRIMARY KEY ([EntityID],[ProjectCategoryID])
);
GO

-- 销售项目类别经
手人佣金提成员
工配置
IF OBJECT_ID(N'TB_SaleProjectCategoryHand
lerCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectCategoryHand
lerCommission];
GO
CREATE TABLE [TB_SaleProjectCategoryHand
lerCommission] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [ProjectSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProjectCategoryHand
lerCommission] PRIMARY KEY ([EntityID],[ProjectCategoryID],[ProjectSaleHandlerID])
);
GO

-- 销售项目类别经
手人职务佣金提
成员工配置
IF OBJECT_ID(N'TB_SaleProjectCategoryHand
lerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectCategoryHand
lerJobTypeCommission];
GO
CREATE TABLE [TB_SaleProjectCategoryHand
lerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [ProjectSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProjectCategoryHand
lerJobTypeCommission] PRIMARY KEY ([EntityID],[ProjectCategoryID],[ProjectSaleHandlerID],[JobTypeID])
);
GO

-- 销售项目类别经
手人职务业绩员
工配置
IF OBJECT_ID(N'TB_SaleProjectCategoryHand
lerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectCategoryHand
lerJobTypePerformance];
GO
CREATE TABLE [TB_SaleProjectCategoryHand
lerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [ProjectSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProjectCategoryHand
lerJobTypePerformance] PRIMARY KEY ([EntityID],[ProjectCategoryID],[ProjectSaleHandlerID],[JobTypeID])
);
GO

-- 销售项目类别经
手人业绩配置
IF OBJECT_ID(N'TB_SaleProjectCategoryHand
lerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectCategoryHand
lerPerformance];
GO
CREATE TABLE [TB_SaleProjectCategoryHand
lerPerformance] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [ProjectSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProjectCategoryHand
lerPerformance] PRIMARY KEY ([EntityID],[ProjectCategoryID],[ProjectSaleHandlerID])
);
GO

-- 销售项目类别业
绩员工配置
IF OBJECT_ID(N'TB_SaleProjectCategoryPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectCategoryPerformance];
GO
CREATE TABLE [TB_SaleProjectCategoryPerformance] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProjectCategoryPerformance] PRIMARY KEY ([EntityID],[ProjectCategoryID])
);
GO

-- 销售项目佣金提
成员工配置
IF OBJECT_ID(N'TB_SaleProjectCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectCommission];
GO
CREATE TABLE [TB_SaleProjectCommission] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProjectCommission] PRIMARY KEY ([EntityID],[ProjectID])
);
GO

-- 
IF OBJECT_ID(N'TB_SaleProjectCommissionScheme', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectCommissionScheme];
GO
CREATE TABLE [TB_SaleProjectCommissionScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProjectCommissionScheme] PRIMARY KEY ([EntityID])
);
GO

-- 销售项目业绩门店配置
IF OBJECT_ID(N'TB_SaleProjectEntityPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectEntityPerformance];
GO
CREATE TABLE [TB_SaleProjectEntityPerformance] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProjectEntityPerformance] PRIMARY KEY ([EntityID],[ProjectID])
);
GO

-- 销售项目业绩门
店配置方案
IF OBJECT_ID(N'TB_SaleProjectEntityPerforma
nceScheme', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectEntityPerforma
nceScheme];
GO
CREATE TABLE [TB_SaleProjectEntityPerforma
nceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProjectEntityPerforma
nceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 销售项目经手人
佣金提成员工配
IF OBJECT_ID(N'TB_SaleProjectHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectHandlerCommission];
GO
CREATE TABLE [TB_SaleProjectHandlerCommission] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [ProjectSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProjectHandlerCommission] PRIMARY KEY ([EntityID],[ProjectID],[ProjectSaleHandlerID])
);
GO

-- 销售项目经手人
职务佣金提成员
工配置
IF OBJECT_ID(N'TB_SaleProjectHandlerJobTy
peCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectHandlerJobTy
peCommission];
GO
CREATE TABLE [TB_SaleProjectHandlerJobTy
peCommission] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [ProjectSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProjectHandlerJobTy
peCommission] PRIMARY KEY ([EntityID],[ProjectID],[ProjectSaleHandlerID],[JobTypeID])
);
GO

-- 销售项目经手人
职务业绩员工配
IF OBJECT_ID(N'TB_SaleProjectHandlerJobTy
pePerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectHandlerJobTy
pePerformance];
GO
CREATE TABLE [TB_SaleProjectHandlerJobTy
pePerformance] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [ProjectSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProjectHandlerJobTy
pePerformance] PRIMARY KEY ([EntityID],[ProjectID],[ProjectSaleHandlerID],[JobTypeID])
);
GO

-- 销售项目经手人
业绩员工配置
IF OBJECT_ID(N'TB_SaleProjectHandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectHandlerPerformance];
GO
CREATE TABLE [TB_SaleProjectHandlerPerformance] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [ProjectSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProjectHandlerPerformance] PRIMARY KEY ([EntityID],[ProjectID],[ProjectSaleHandlerID])
);
GO

-- 销售项目业绩员工配置
IF OBJECT_ID(N'TB_SaleProjectPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectPerformance];
GO
CREATE TABLE [TB_SaleProjectPerformance] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProjectPerformance] PRIMARY KEY ([EntityID],[ProjectID])
);
GO

-- 销售项目业绩员
工配置方案
IF OBJECT_ID(N'TB_SaleProjectPerformanceScheme', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectPerformanceScheme];
GO
CREATE TABLE [TB_SaleProjectPerformanceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProjectPerformanceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 销售所有项目经
手人佣金业绩员
工配置
IF OBJECT_ID(N'TB_SaleProjectSchemeHandl
erCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectSchemeHandl
erCommission];
GO
CREATE TABLE [TB_SaleProjectSchemeHandl
erCommission] (
    [EntityID] int NOT NULL,
    [ProjectSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProjectSchemeHandl
erCommission] PRIMARY KEY ([EntityID],[ProjectSaleHandlerID])
);
GO

-- 销售所有项目经
手人职务佣金提
成员工配置
IF OBJECT_ID(N'TB_SaleProjectSchemeHandl
erJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectSchemeHandl
erJobTypeCommission];
GO
CREATE TABLE [TB_SaleProjectSchemeHandl
erJobTypeCommission] (
    [EntityID] int NOT NULL,
    [ProjectSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleProjectSchemeHandl
erJobTypeCommission] PRIMARY KEY ([EntityID],[ProjectSaleHandlerID],[JobTypeID])
);
GO

-- 销售项目所有经
手人职务业绩员
工配置
IF OBJECT_ID(N'TB_SaleProjectSchemeHandl
erJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectSchemeHandl
erJobTypePerformance];
GO
CREATE TABLE [TB_SaleProjectSchemeHandl
erJobTypePerformance] (
    [EntityID] int NOT NULL,
    [ProjectSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProjectSchemeHandl
erJobTypePerformance] PRIMARY KEY ([EntityID],[ProjectSaleHandlerID],[JobTypeID])
);
GO

-- 
IF OBJECT_ID(N'TB_SaleProjectSchemeHandl
erPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleProjectSchemeHandl
erPerformance];
GO
CREATE TABLE [TB_SaleProjectSchemeHandl
erPerformance] (
    [EntityID] int NOT NULL,
    [ProjectSaleHandlerI] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleProjectSchemeHandl
erPerformance] PRIMARY KEY ([EntityID],[ProjectSaleHandlerI])
);
GO

-- 销售储值卡类别
佣金提成员工配
IF OBJECT_ID(N'TB_SaleSavingCardCategoryC
ommission', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardCategoryC
ommission];
GO
CREATE TABLE [TB_SaleSavingCardCategoryC
ommission] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardCategoryC
ommission] PRIMARY KEY ([EntityID],[SavingCardCategory
ID])
);
GO

-- 销售储值卡类别
业绩门店配置
IF OBJECT_ID(N'TB_SaleSavingCardCategoryE
ntityPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardCategoryE
ntityPerformance];
GO
CREATE TABLE [TB_SaleSavingCardCategoryE
ntityPerformance] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardCategoryE
ntityPerformance] PRIMARY KEY ([EntityID],[SavingCardCategory
ID])
);
GO

-- 销售储值卡类别
经手人佣金提成
员工配置
IF OBJECT_ID(N'TB_SaleSavingCardCategory
HandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardCategory
HandlerCommission];
GO
CREATE TABLE [TB_SaleSavingCardCategory
HandlerCommission] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [SavingCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardCategory
HandlerCommission] PRIMARY KEY ([EntityID],[SavingCardCategory
ID],[SavingCardSaleHandlerID])
);
GO

-- 销售储值卡类别
经手人职务佣金
提成员工配置
IF OBJECT_ID(N'TB_SaleSavingCardCategory
HandlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardCategory
HandlerJobTypeCommission];
GO
CREATE TABLE [TB_SaleSavingCardCategory
HandlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [SavingCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardCategory
HandlerJobTypeCommission] PRIMARY KEY ([EntityID],[SavingCardCategory
ID],[SavingCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售储值卡类别
经手人职务业绩
IF OBJECT_ID(N'TB_SaleSavingCardCategory
HandlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardCategory
HandlerJobTypePerformance];
GO
CREATE TABLE [TB_SaleSavingCardCategory
HandlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [SavingCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardCategory
HandlerJobTypePerformance] PRIMARY KEY ([EntityID],[SavingCardCategory
ID],[SavingCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售储值卡类别
经手人业绩配置
IF OBJECT_ID(N'TB_SaleSavingCardCategory
HandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardCategory
HandlerPerformance];
GO
CREATE TABLE [TB_SaleSavingCardCategory
HandlerPerformance] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [SavingCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardCategory
HandlerPerformance] PRIMARY KEY ([EntityID],[SavingCardCategory
ID],[SavingCardSaleHandlerID])
);
GO

-- 销售储值卡类别
业绩员工配置
IF OBJECT_ID(N'TB_SaleSavingCardCategoryP
erformance', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardCategoryP
erformance];
GO
CREATE TABLE [TB_SaleSavingCardCategoryP
erformance] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardCategoryP
erformance] PRIMARY KEY ([EntityID],[SavingCardCategory
ID])
);
GO

-- 销售储值卡佣金
提成员工配置
IF OBJECT_ID(N'TB_SaleSavingCardCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardCommission];
GO
CREATE TABLE [TB_SaleSavingCardCommission] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardCommission] PRIMARY KEY ([EntityID],[SavingCardID])
);
GO

-- 销售储值卡佣金
提成员工配置方
IF OBJECT_ID(N'TB_SaleSavingCardCommissionScheme', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardCommissionScheme];
GO
CREATE TABLE [TB_SaleSavingCardCommissionScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardCommissionScheme] PRIMARY KEY ([EntityID])
);
GO

-- 销售储值卡业绩
门店配置
IF OBJECT_ID(N'TB_SaleSavingCardEntityPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardEntityPerformance];
GO
CREATE TABLE [TB_SaleSavingCardEntityPerformance] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardEntityPerformance] PRIMARY KEY ([EntityID],[SavingCardID])
);
GO

-- 销售储值卡业绩
门店配置方案
IF OBJECT_ID(N'TB_SaleSavingCardEntityPerf
ormanceScheme', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardEntityPerf
ormanceScheme];
GO
CREATE TABLE [TB_SaleSavingCardEntityPerf
ormanceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardEntityPerf
ormanceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 销售储值卡经手
人佣金提成员工
IF OBJECT_ID(N'TB_SaleSavingCardHandlerC
ommission', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardHandlerC
ommission];
GO
CREATE TABLE [TB_SaleSavingCardHandlerC
ommission] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [SavingCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardHandlerC
ommission] PRIMARY KEY ([EntityID],[SavingCardID],[SavingCardSaleHandlerID])
);
GO

-- 销售储值卡经手
人职务佣金提成
员工配置
IF OBJECT_ID(N'TB_SaleSavingCardHandlerJo
bTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardHandlerJo
bTypeCommission];
GO
CREATE TABLE [TB_SaleSavingCardHandlerJo
bTypeCommission] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [SavingCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardHandlerJo
bTypeCommission] PRIMARY KEY ([EntityID],[SavingCardID],[SavingCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售储值卡经手
人职务业绩员工
IF OBJECT_ID(N'TB_SaleSavingCardHandlerJo
bTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardHandlerJo
bTypePerformance];
GO
CREATE TABLE [TB_SaleSavingCardHandlerJo
bTypePerformance] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [SavingCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardHandlerJo
bTypePerformance] PRIMARY KEY ([EntityID],[SavingCardID],[SavingCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售储值卡经手
人业绩员工配置
IF OBJECT_ID(N'TB_SaleSavingCardHandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardHandlerPerformance];
GO
CREATE TABLE [TB_SaleSavingCardHandlerPerformance] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [SavingCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardHandlerPerformance] PRIMARY KEY ([EntityID],[SavingCardID],[SavingCardSaleHandlerID])
);
GO

-- 销售储值卡业绩
员工配置
IF OBJECT_ID(N'TB_SaleSavingCardPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardPerformance];
GO
CREATE TABLE [TB_SaleSavingCardPerformance] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardPerformance] PRIMARY KEY ([EntityID],[SavingCardID])
);
GO

-- 销售储值卡业绩
员工配置方案
IF OBJECT_ID(N'TB_SaleSavingCardPerformanceScheme', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardPerformanceScheme];
GO
CREATE TABLE [TB_SaleSavingCardPerformanceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardPerformanceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 销售所有储值卡
经手人佣金提成
员工配置
IF OBJECT_ID(N'TB_SaleSavingCardSchemeH
andlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardSchemeH
andlerCommission];
GO
CREATE TABLE [TB_SaleSavingCardSchemeH
andlerCommission] (
    [EntityID] int NOT NULL,
    [SavingCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardSchemeH
andlerCommission] PRIMARY KEY ([EntityID],[SavingCardSaleHandlerID])
);
GO

-- 销售所有储值卡
经手人职务佣金
提成员工配置
IF OBJECT_ID(N'TB_SaleSavingCardSchemeH
andlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardSchemeH
andlerJobTypeCommission];
GO
CREATE TABLE [TB_SaleSavingCardSchemeH
andlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [SavingCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardSchemeH
andlerJobTypeCommission] PRIMARY KEY ([EntityID],[SavingCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售储值卡所有
经手人职务业绩
员工配置
IF OBJECT_ID(N'TB_SaleSavingCardSchemeH
andlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardSchemeH
andlerJobTypePerformance];
GO
CREATE TABLE [TB_SaleSavingCardSchemeH
andlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [SavingCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardSchemeH
andlerJobTypePerformance] PRIMARY KEY ([EntityID],[SavingCardSaleHandlerID],[JobTypeID])
);
GO

-- 销售储值卡所有
经手人业绩员工
IF OBJECT_ID(N'TB_SaleSavingCardSchemeH
andlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleSavingCardSchemeH
andlerPerformance];
GO
CREATE TABLE [TB_SaleSavingCardSchemeH
andlerPerformance] (
    [EntityID] int NOT NULL,
    [SavingCardSaleHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleSavingCardSchemeH
andlerPerformance] PRIMARY KEY ([EntityID],[SavingCardSaleHandlerID])
);
GO

-- 销售时效卡类别
佣金提成员工配
IF OBJECT_ID(N'TB_SaleTimeCardCategoryCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardCategoryCommission];
GO
CREATE TABLE [TB_SaleTimeCardCategoryCommission] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardCategoryCommission] PRIMARY KEY ([EntityID],[TimeCardCategoryID])
);
GO

-- 销售时效卡类别
业绩门店配置
IF OBJECT_ID(N'TB_SaleTimeCardCategoryEnt
ityPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardCategoryEnt
ityPerformance];
GO
CREATE TABLE [TB_SaleTimeCardCategoryEnt
ityPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardCategoryEnt
ityPerformance] PRIMARY KEY ([EntityID],[TimeCardCategoryID])
);
GO

-- 销售时效卡类别
经手人佣金提成
员工配置
IF OBJECT_ID(N'TB_SaleTimeCardCategoryHa
ndlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardCategoryHa
ndlerCommission];
GO
CREATE TABLE [TB_SaleTimeCardCategoryHa
ndlerCommission] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [TimeCardSaleHandle
rID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardCategoryHa
ndlerCommission] PRIMARY KEY ([EntityID],[TimeCardCategoryID],[TimeCardSaleHandle
rID])
);
GO

-- 销售时效卡类别
经手人职务佣金
提成员工配置
IF OBJECT_ID(N'TB_SaleTimeCardCategoryHa
ndlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardCategoryHa
ndlerJobTypeCommission];
GO
CREATE TABLE [TB_SaleTimeCardCategoryHa
ndlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [TimeCardSaleHandle
rID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardCategoryHa
ndlerJobTypeCommission] PRIMARY KEY ([EntityID],[TimeCardCategoryID],[TimeCardSaleHandle
rID],[JobTypeID])
);
GO

-- 销售时效卡类别
经手人职务业绩
IF OBJECT_ID(N'TB_SaleTimeCardCategoryHa
ndlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardCategoryHa
ndlerJobTypePerformance];
GO
CREATE TABLE [TB_SaleTimeCardCategoryHa
ndlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [TimeCardSaleHandle
rID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardCategoryHa
ndlerJobTypePerformance] PRIMARY KEY ([EntityID],[TimeCardCategoryID],[TimeCardSaleHandle
rID],[JobTypeID])
);
GO

-- 销售时效卡类别
经手人业绩配置
IF OBJECT_ID(N'TB_SaleTimeCardCategoryHa
ndlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardCategoryHa
ndlerPerformance];
GO
CREATE TABLE [TB_SaleTimeCardCategoryHa
ndlerPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [TimeCardSaleHandle
rID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardCategoryHa
ndlerPerformance] PRIMARY KEY ([EntityID],[TimeCardCategoryID],[TimeCardSaleHandle
rID])
);
GO

-- 销售时效卡类别
业绩员工配置
IF OBJECT_ID(N'TB_SaleTimeCardCategoryPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardCategoryPerformance];
GO
CREATE TABLE [TB_SaleTimeCardCategoryPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardCategoryPerformance] PRIMARY KEY ([EntityID],[TimeCardCategoryID])
);
GO

-- 销售时效卡佣金
提成员工配置
IF OBJECT_ID(N'TB_SaleTimeCardCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardCommission];
GO
CREATE TABLE [TB_SaleTimeCardCommission] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardCommission] PRIMARY KEY ([EntityID],[TimeCardID])
);
GO

-- 销售时效卡佣金
提成员工配置方
IF OBJECT_ID(N'TB_SaleTimeCardCommission
Scheme', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardCommission
Scheme];
GO
CREATE TABLE [TB_SaleTimeCardCommission
Scheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardCommission
Scheme] PRIMARY KEY ([EntityID])
);
GO

-- 销售时效卡业绩
门店配置
IF OBJECT_ID(N'TB_SaleTimeCardEntityPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardEntityPerformance];
GO
CREATE TABLE [TB_SaleTimeCardEntityPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardEntityPerformance] PRIMARY KEY ([EntityID],[TimeCardID])
);
GO

-- 销售时效卡业绩
门店配置方案
IF OBJECT_ID(N'TB_SaleTimeCardEntityPerfor
manceScheme', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardEntityPerfor
manceScheme];
GO
CREATE TABLE [TB_SaleTimeCardEntityPerfor
manceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardEntityPerfor
manceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 销售时效卡经手
人佣金提成员工
IF OBJECT_ID(N'TB_SaleTimeCardHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardHandlerCommission];
GO
CREATE TABLE [TB_SaleTimeCardHandlerCommission] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [TimeCardSaleHandle
rID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardHandlerCommission] PRIMARY KEY ([EntityID],[TimeCardID],[TimeCardSaleHandle
rID])
);
GO

-- 销售时效卡经手
人职务佣金提成
员工配置
IF OBJECT_ID(N'TB_SaleTimeCardHandlerJob
TypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardHandlerJob
TypeCommission];
GO
CREATE TABLE [TB_SaleTimeCardHandlerJob
TypeCommission] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [TimeCardSaleHandle
rID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardHandlerJob
TypeCommission] PRIMARY KEY ([EntityID],[TimeCardID],[TimeCardSaleHandle
rID],[JobTypeID])
);
GO

-- 销售时效卡经手
人职务业绩员工
IF OBJECT_ID(N'TB_SaleTimeCardHandlerJob
TypePerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardHandlerJob
TypePerformance];
GO
CREATE TABLE [TB_SaleTimeCardHandlerJob
TypePerformance] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [TimeCardSaleHandle
rID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardHandlerJob
TypePerformance] PRIMARY KEY ([EntityID],[TimeCardID],[TimeCardSaleHandle
rID],[JobTypeID])
);
GO

-- 销售时效卡经手
人业绩员工配置
IF OBJECT_ID(N'TB_SaleTimeCardHandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardHandlerPerformance];
GO
CREATE TABLE [TB_SaleTimeCardHandlerPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [TimeCardSaleHandle
rID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardHandlerPerformance] PRIMARY KEY ([EntityID],[TimeCardID],[TimeCardSaleHandle
rID])
);
GO

-- 销售时效卡业绩
员工配置
IF OBJECT_ID(N'TB_SaleTimeCardPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardPerformance];
GO
CREATE TABLE [TB_SaleTimeCardPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardPerformance] PRIMARY KEY ([EntityID],[TimeCardID])
);
GO

-- 销售时效卡业绩
员工配置方案
IF OBJECT_ID(N'TB_SaleTimeCardPerformanceScheme', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardPerformanceScheme];
GO
CREATE TABLE [TB_SaleTimeCardPerformanceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardPerformanceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 销售所有时效卡
经手人佣金提成
员工配置
IF OBJECT_ID(N'TB_SaleTimeCardSchemeHan
dlerCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardSchemeHan
dlerCommission];
GO
CREATE TABLE [TB_SaleTimeCardSchemeHan
dlerCommission] (
    [EntityID] int NOT NULL,
    [TimeCardSaleHandle
rID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardSchemeHan
dlerCommission] PRIMARY KEY ([EntityID],[TimeCardSaleHandle
rID])
);
GO

-- 销售所有时效卡
经手人职务佣金
提成员工配置
IF OBJECT_ID(N'TB_SaleTimeCardSchemeHan
dlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardSchemeHan
dlerJobTypeCommission];
GO
CREATE TABLE [TB_SaleTimeCardSchemeHan
dlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [TimeCardSaleHandle
rID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardFixed] decimal(18,2) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    [SavingCardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardSchemeHan
dlerJobTypeCommission] PRIMARY KEY ([EntityID],[TimeCardSaleHandle
rID],[JobTypeID])
);
GO

-- 销售时效卡所有
经手人职务业绩
员工配置
IF OBJECT_ID(N'TB_SaleTimeCardSchemeHan
dlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardSchemeHan
dlerJobTypePerformance];
GO
CREATE TABLE [TB_SaleTimeCardSchemeHan
dlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [TimeCardSaleHandle
rID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardSchemeHan
dlerJobTypePerformance] PRIMARY KEY ([EntityID],[TimeCardSaleHandle
rID],[JobTypeID])
);
GO

-- 销售所有时效卡
经手人业绩员工
IF OBJECT_ID(N'TB_SaleTimeCardSchemeHan
dlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_SaleTimeCardSchemeHan
dlerPerformance];
GO
CREATE TABLE [TB_SaleTimeCardSchemeHan
dlerPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardSaleHandle
rID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [SavingCardRate] decimal(5,4) NULL,
    [SavingCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_SaleTimeCardSchemeHan
dlerPerformance] PRIMARY KEY ([EntityID],[TimeCardSaleHandle
rID])
);
GO

-- 储值卡管理
IF OBJECT_ID(N'TB_SavingCard', N'U') IS NOT NULL DROP TABLE [TB_SavingCard];
GO
CREATE TABLE [TB_SavingCard] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [NameFullPinYin] nvarchar(200) NULL,
    [NameAbbrPinYin] nvarchar(50) NULL,
    [Alias] nvarchar(50) NULL,
    [AliasFullPinYin] nvarchar(200) NULL,
    [AliasAbbrPinYin] nvarchar(200) NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [SaleStartDate] date NOT NULL,
    [SaleEndingDate] date NOT NULL,
    [ValidType] int NOT NULL,
    [ValidDay] int NULL,
    [IsAllowSell] bit NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [LargessPrice] decimal(18,2) NULL,
    [IsSettingLargess] bit NOT NULL,
    [IsAllowSaleDeduct] bit NOT NULL,
    [IsAllowConsumeDeduct] bit NOT NULL,
    [IsGoodsRange] bit NOT NULL,
    [IsLargessGoodsRange] bit NOT NULL,
    [IsUseRechargeRules] bit NOT NULL,
    [IsModifyPrice] bit NOT NULL,
    [IsModifyLargessPrice] bit NOT NULL,
    [Remark] nvarchar(200) NULL,
    [Memo] ntext NULL,
    CONSTRAINT [PK_TB_SavingCard] PRIMARY KEY ([ID])
);
GO

-- 储值卡账户
IF OBJECT_ID(N'TB_SavingCardAccount', N'U') IS NOT NULL DROP TABLE [TB_SavingCardAccount];
GO
CREATE TABLE [TB_SavingCardAccount] (
    [ID] int NOT NULL,
    [CustomerID] int NOT NULL,
    [EntityID] int NOT NULL,
    [BuyDate] datetime NOT NULL,
    [SavingCardID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [LargessPrice] decimal(18,2) NOT NULL,
    [Balance] decimal(18,2) NOT NULL,
    [LargessBalance] decimal(18,2) NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    [ValidType] int NOT NULL,
    [ValidDay] int NULL,
    [ValidDate] datetime NULL,
    [SaleBillSavingCardID] int NULL,
    [PackageCardAccountID] int NULL,
    [SaleBillPackageCard
SavingCardID] int NULL,
    [Channel] varchar(2) NOT NULL,
    [Active] bit NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TB_SavingCardAccount] PRIMARY KEY ([ID])
);
GO

-- 储值卡欠款平账
记录
IF OBJECT_ID(N'TB_SavingCardAccountArrear
AmountProcess', N'U') IS NOT NULL DROP TABLE [TB_SavingCardAccountArrear
AmountProcess];
GO
CREATE TABLE [TB_SavingCardAccountArrear
AmountProcess] (
    [ID] int NOT NULL,
    [SavingCardAccountI] int NOT NULL,
    [EntityID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [BeforeArrearAmount] decimal(18,2) NOT NULL,
    [AfterArrearAmount] decimal(18,2) NOT NULL,
    [PackageCardAccoun
tArrearAmountProce
ssID] int NULL,
    [CreatedBy] varchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_SavingCardAccountArrear
AmountProcess] PRIMARY KEY ([ID])
);
GO

-- 储值卡分类
IF OBJECT_ID(N'TB_SavingCardCategory', N'U') IS NOT NULL DROP TABLE [TB_SavingCardCategory];
GO
CREATE TABLE [TB_SavingCardCategory] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_SavingCardCategory] PRIMARY KEY ([ID])
);
GO

-- 储值卡消耗适用
门店
IF OBJECT_ID(N'TB_SavingCardConsumeEntity', N'U') IS NOT NULL DROP TABLE [TB_SavingCardConsumeEntity];
GO
CREATE TABLE [TB_SavingCardConsumeEntity] (
    [SavingCardID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_SavingCardConsumeEntity] PRIMARY KEY ([SavingCardID],[EntityID])
);
GO

-- 储值卡本金适用
范围-通用次卡
IF OBJECT_ID(N'TB_SavingCardGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_SavingCardGeneralCard];
GO
CREATE TABLE [TB_SavingCardGeneralCard] (
    [SavingCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [PriceType] int NOT NULL,
    [DiscountPrice] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SavingCardGeneralCard] PRIMARY KEY ([SavingCardID],[GeneralCardID],[IsLargess])
);
GO

-- 储值卡本金适用
范围-通用次卡
IF OBJECT_ID(N'TB_SavingCardGeneralCardCategory', N'U') IS NOT NULL DROP TABLE [TB_SavingCardGeneralCardCategory];
GO
CREATE TABLE [TB_SavingCardGeneralCardCategory] (
    [SavingCardID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [Discount] decimal(3,2) NOT NULL,
    CONSTRAINT [PK_TB_SavingCardGeneralCardCategory] PRIMARY KEY ([SavingCardID],[GeneralCardCategoryID],[IsLargess])
);
GO

-- 储值卡图片
IF OBJECT_ID(N'TB_SavingCardImage', N'U') IS NOT NULL DROP TABLE [TB_SavingCardImage];
GO
CREATE TABLE [TB_SavingCardImage] (
    [ID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [ImageURL] nvarchar(200) NOT NULL,
    [Sequence] int NOT NULL,
    CONSTRAINT [PK_TB_SavingCardImage] PRIMARY KEY ([ID])
);
GO

-- 储值卡本金适用
范围-套餐卡
IF OBJECT_ID(N'TB_SavingCardPackageCard', N'U') IS NOT NULL DROP TABLE [TB_SavingCardPackageCard];
GO
CREATE TABLE [TB_SavingCardPackageCard] (
    [SavingCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [PriceType] int NOT NULL,
    [DiscountPrice] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SavingCardPackageCard] PRIMARY KEY ([SavingCardID],[PackageCardID],[IsLargess])
);
GO

-- 储值卡本金适用
范围-套餐卡分
IF OBJECT_ID(N'TB_SavingCardPackageCardCategory', N'U') IS NOT NULL DROP TABLE [TB_SavingCardPackageCardCategory];
GO
CREATE TABLE [TB_SavingCardPackageCardCategory] (
    [SavingCardID] int NOT NULL,
    [PackageCardCategoryID] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [Discount] decimal(3,2) NOT NULL,
    CONSTRAINT [PK_TB_SavingCardPackageCardCategory] PRIMARY KEY ([SavingCardID],[PackageCardCategoryID],[IsLargess])
);
GO

-- 储值卡本金适用
范围-产品
IF OBJECT_ID(N'TB_SavingCardProduct', N'U') IS NOT NULL DROP TABLE [TB_SavingCardProduct];
GO
CREATE TABLE [TB_SavingCardProduct] (
    [SavingCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [PriceType] int NOT NULL,
    [DiscountPrice] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SavingCardProduct] PRIMARY KEY ([SavingCardID],[ProductID],[IsLargess])
);
GO

-- 储值卡本金适用
范围-产品分类
IF OBJECT_ID(N'TB_SavingCardProductCategory', N'U') IS NOT NULL DROP TABLE [TB_SavingCardProductCategory];
GO
CREATE TABLE [TB_SavingCardProductCategory] (
    [SavingCardID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [Discount] decimal(3,2) NOT NULL,
    CONSTRAINT [PK_TB_SavingCardProductCategory] PRIMARY KEY ([SavingCardID],[ProductCategoryID],[IsLargess])
);
GO

-- 储值卡本金适用
范围-项目
IF OBJECT_ID(N'TB_SavingCardProject', N'U') IS NOT NULL DROP TABLE [TB_SavingCardProject];
GO
CREATE TABLE [TB_SavingCardProject] (
    [SavingCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [PriceType] int NOT NULL,
    [DiscountPrice] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SavingCardProject] PRIMARY KEY ([SavingCardID],[ProjectID],[IsLargess])
);
GO

-- 储值卡本金适用
范围-项目分类
IF OBJECT_ID(N'TB_SavingCardProjectCategory', N'U') IS NOT NULL DROP TABLE [TB_SavingCardProjectCategory];
GO
CREATE TABLE [TB_SavingCardProjectCategory] (
    [SavingCardID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [Discount] decimal(3,2) NOT NULL,
    CONSTRAINT [PK_TB_SavingCardProjectCategory] PRIMARY KEY ([SavingCardID],[ProjectCategoryID],[IsLargess])
);
GO

-- 储值卡项目消耗
经手人管理
IF OBJECT_ID(N'TB_SavingCardProjectTreatHandler', N'U') IS NOT NULL DROP TABLE [TB_SavingCardProjectTreatHandler];
GO
CREATE TABLE [TB_SavingCardProjectTreatHandler] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_SavingCardProjectTreatHandler] PRIMARY KEY ([ID])
);
GO

-- 储值卡项目消耗
经手人适用职务
IF OBJECT_ID(N'TB_SavingCardProjectTreatH
andlerJobType', N'U') IS NOT NULL DROP TABLE [TB_SavingCardProjectTreatH
andlerJobType];
GO
CREATE TABLE [TB_SavingCardProjectTreatH
andlerJobType] (
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TB_SavingCardProjectTreatH
andlerJobType] PRIMARY KEY ([SavingCardProjectTr
eatHandlerID],[JobTypeID])
);
GO

-- 储值卡阶梯价格
设置
IF OBJECT_ID(N'TB_SavingCardRechargeRules', N'U') IS NOT NULL DROP TABLE [TB_SavingCardRechargeRules];
GO
CREATE TABLE [TB_SavingCardRechargeRules] (
    [SavingCardID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [LargessPrice] decimal(18,2) NOT NULL
);
GO

-- 储值卡销售适用
门店
IF OBJECT_ID(N'TB_SavingCardSaleEntity', N'U') IS NOT NULL DROP TABLE [TB_SavingCardSaleEntity];
GO
CREATE TABLE [TB_SavingCardSaleEntity] (
    [SavingCardID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_SavingCardSaleEntity] PRIMARY KEY ([SavingCardID],[EntityID])
);
GO

-- 储值卡销售经手
IF OBJECT_ID(N'TB_SavingCardSaleHandler', N'U') IS NOT NULL DROP TABLE [TB_SavingCardSaleHandler];
GO
CREATE TABLE [TB_SavingCardSaleHandler] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_SavingCardSaleHandler] PRIMARY KEY ([ID])
);
GO

-- 储值卡销售经手
人-适用职务
IF OBJECT_ID(N'TB_SavingCardSaleHandlerJobType', N'U') IS NOT NULL DROP TABLE [TB_SavingCardSaleHandlerJobType];
GO
CREATE TABLE [TB_SavingCardSaleHandlerJobType] (
    [SavingCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TB_SavingCardSaleHandlerJobType] PRIMARY KEY ([SavingCardSaleHandlerID],[JobTypeID])
);
GO

-- 储值卡本金适用
范围-时效卡卡
IF OBJECT_ID(N'TB_SavingCardTimeCard', N'U') IS NOT NULL DROP TABLE [TB_SavingCardTimeCard];
GO
CREATE TABLE [TB_SavingCardTimeCard] (
    [SavingCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [PriceType] int NOT NULL,
    [DiscountPrice] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_SavingCardTimeCard] PRIMARY KEY ([SavingCardID],[TimeCardID],[IsLargess])
);
GO

-- 储值卡本金适用
范围-项目分类
IF OBJECT_ID(N'TB_SavingCardTimeCardCategory', N'U') IS NOT NULL DROP TABLE [TB_SavingCardTimeCardCategory];
GO
CREATE TABLE [TB_SavingCardTimeCardCategory] (
    [SavingCardID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [Discount] decimal(3,2) NOT NULL,
    CONSTRAINT [PK_TB_SavingCardTimeCardCategory] PRIMARY KEY ([SavingCardID],[TimeCardCategoryID],[IsLargess])
);
GO

-- 服务人员
IF OBJECT_ID(N'TB_Servicer', N'U') IS NOT NULL DROP TABLE [TB_Servicer];
GO
CREATE TABLE [TB_Servicer] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [AddWhetherToShow] bit NOT NULL,
    [EntityRange] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_Servicer] PRIMARY KEY ([ID])
);
GO

-- 服务人员适用职
IF OBJECT_ID(N'TB_ServicerJobType', N'U') IS NOT NULL DROP TABLE [TB_ServicerJobType];
GO
CREATE TABLE [TB_ServicerJobType] (
    [ServicerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TB_ServicerJobType] PRIMARY KEY ([ServicerID],[JobTypeID])
);
GO

-- 标签
IF OBJECT_ID(N'TB_TagLibrary', N'U') IS NOT NULL DROP TABLE [TB_TagLibrary];
GO
CREATE TABLE [TB_TagLibrary] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TB_TagLibrary] PRIMARY KEY ([ID])
);
GO

-- 时效卡管理
IF OBJECT_ID(N'TB_TimeCard', N'U') IS NOT NULL DROP TABLE [TB_TimeCard];
GO
CREATE TABLE [TB_TimeCard] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [NameFullPinYin] nvarchar(200) NULL,
    [NameAbbrPinYin] nvarchar(50) NULL,
    [Alias] nvarchar(50) NULL,
    [AliasFullPinYin] nvarchar(200) NULL,
    [AliasAbbrPinYin] nvarchar(200) NULL,
    [TimeCardCategoryID] int NOT NULL,
    [ConsumeCycle] int NOT NULL,
    [CycleLimitAmount] int NOT NULL,
    [PerformanceAmount] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [SaleStartDate] date NOT NULL,
    [SaleEndingDate] date NOT NULL,
    [ValidType] int NOT NULL,
    [ValidDay] int NULL,
    [IsAllowSell] bit NOT NULL,
    [IsAllowLargess] bit NOT NULL,
    [Remark] nvarchar(200) NULL,
    [Memo] ntext NULL,
    CONSTRAINT [PK_TB_TimeCard] PRIMARY KEY ([ID])
);
GO

-- 时效卡账户
IF OBJECT_ID(N'TB_TimeCardAccount', N'U') IS NOT NULL DROP TABLE [TB_TimeCardAccount];
GO
CREATE TABLE [TB_TimeCardAccount] (
    [ID] int NOT NULL,
    [CustomerID] int NOT NULL,
    [EntityID] int NOT NULL,
    [BuyDate] datetime NOT NULL,
    [TimeCardID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [ArrearAmount] decimal(18,2) NOT NULL,
    [PerformanceTimes] int NOT NULL,
    [PerformanceBalance] int NOT NULL,
    [IsLargess] bit NOT NULL,
    [ValidType] int NOT NULL,
    [ValidDay] int NULL,
    [ValidDate] datetime NULL,
    [SaleBillTimeCardID] int NULL,
    [PackageCardAccountID] int NULL,
    [SaleBillPackageCard
TimeCardID] int NULL,
    [PayAmount] decimal(18,2) NOT NULL,
    [SavingCardDeductionAmount] decimal(18,2) NOT NULL,
    [SavingCardDeductio
nLargessAmount] decimal(18,2) NOT NULL,
    [PayPerformanceBala
nceAmount] decimal(18,2) NOT NULL,
    [CardPerformanceBal
anceAmount] decimal(18,2) NOT NULL,
    [CardLargessPerform
anceBalanceAmount] decimal(18,2) NOT NULL,
    [LargessPerformance
BalanceAmount] decimal(18,2) NOT NULL,
    [Channel] varchar(2) NOT NULL,
    [Active] bit NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TB_TimeCardAccount] PRIMARY KEY ([ID])
);
GO

-- 时效卡欠款平账
记录
IF OBJECT_ID(N'TB_TimeCardAccountArrearA
mountProcess', N'U') IS NOT NULL DROP TABLE [TB_TimeCardAccountArrearA
mountProcess];
GO
CREATE TABLE [TB_TimeCardAccountArrearA
mountProcess] (
    [ID] int NOT NULL,
    [TimeCardAccountID] int NOT NULL,
    [EntityID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [BeforeArrearAmount] decimal(18,2) NOT NULL,
    [AfterArrearAmount] decimal(18,2) NOT NULL,
    [PackageCardAccoun
tArrearAmountProce
ssID] int NULL,
    [CreatedBy] varchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_TimeCardAccountArrearA
mountProcess] PRIMARY KEY ([ID])
);
GO

-- 时效卡分类
IF OBJECT_ID(N'TB_TimeCardCategory', N'U') IS NOT NULL DROP TABLE [TB_TimeCardCategory];
GO
CREATE TABLE [TB_TimeCardCategory] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_TimeCardCategory] PRIMARY KEY ([ID])
);
GO

-- 时效卡消耗适用
门店
IF OBJECT_ID(N'TB_TimeCardConsumeEntity', N'U') IS NOT NULL DROP TABLE [TB_TimeCardConsumeEntity];
GO
CREATE TABLE [TB_TimeCardConsumeEntity] (
    [TimeCardID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_TimeCardConsumeEntity] PRIMARY KEY ([TimeCardID],[EntityID])
);
GO

-- 时效卡图片
IF OBJECT_ID(N'TB_TimeCardImage', N'U') IS NOT NULL DROP TABLE [TB_TimeCardImage];
GO
CREATE TABLE [TB_TimeCardImage] (
    [ID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ImageURL] nvarchar(200) NOT NULL,
    [Sequence] int NOT NULL,
    CONSTRAINT [PK_TB_TimeCardImage] PRIMARY KEY ([ID])
);
GO

-- 时效卡价格修改
适用门店
IF OBJECT_ID(N'TB_TimeCardModifyPriceEntity', N'U') IS NOT NULL DROP TABLE [TB_TimeCardModifyPriceEntity];
GO
CREATE TABLE [TB_TimeCardModifyPriceEntity] (
    [TimeCardID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_TimeCardModifyPriceEntity] PRIMARY KEY ([TimeCardID],[EntityID])
);
GO

-- 时效卡价格调整
IF OBJECT_ID(N'TB_TimeCardPriceAdjustment', N'U') IS NOT NULL DROP TABLE [TB_TimeCardPriceAdjustment];
GO
CREATE TABLE [TB_TimeCardPriceAdjustment] (
    [TimeCardID] int NOT NULL,
    [EntityID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TimeCardPriceAdjustment] PRIMARY KEY ([TimeCardID],[EntityID])
);
GO

-- 时效卡适用项目
IF OBJECT_ID(N'TB_TimeCardProject', N'U') IS NOT NULL DROP TABLE [TB_TimeCardProject];
GO
CREATE TABLE [TB_TimeCardProject] (
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    CONSTRAINT [PK_TB_TimeCardProject] PRIMARY KEY ([TimeCardID],[ProjectID])
);
GO

-- 时效卡销售适用
门店
IF OBJECT_ID(N'TB_TimeCardSaleEntity', N'U') IS NOT NULL DROP TABLE [TB_TimeCardSaleEntity];
GO
CREATE TABLE [TB_TimeCardSaleEntity] (
    [TimeCardID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TB_TimeCardSaleEntity] PRIMARY KEY ([TimeCardID],[EntityID])
);
GO

-- 时效卡销售经手
IF OBJECT_ID(N'TB_TimeCardSaleHandler', N'U') IS NOT NULL DROP TABLE [TB_TimeCardSaleHandler];
GO
CREATE TABLE [TB_TimeCardSaleHandler] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_TimeCardSaleHandler] PRIMARY KEY ([ID])
);
GO

-- 时效卡销售经手
人-适用职务
IF OBJECT_ID(N'TB_TimeCardSaleHandlerJob
Type', N'U') IS NOT NULL DROP TABLE [TB_TimeCardSaleHandlerJob
Type];
GO
CREATE TABLE [TB_TimeCardSaleHandlerJob
Type] (
    [TimeCardSaleHandle
rID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TB_TimeCardSaleHandlerJob
Type] PRIMARY KEY ([TimeCardSaleHandle
rID],[JobTypeID])
);
GO

-- 转账订单
IF OBJECT_ID(N'TB_TransferBill', N'U') IS NOT NULL DROP TABLE [TB_TransferBill];
GO
CREATE TABLE [TB_TransferBill] (
    [ID] varchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    [TransferOutCustomerID] int NOT NULL,
    [TransferInCustomerI] int NOT NULL,
    [CreatedBy] varchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [Remark] varchar(500) NULL,
    [Channel] varchar(50) NULL,
    [BillStatus] nvarchar(50) NULL,
    CONSTRAINT [PK_TB_TransferBill] PRIMARY KEY ([ID])
);
GO

-- 转账订单附件
IF OBJECT_ID(N'TB_TransferBillAttachment', N'U') IS NOT NULL DROP TABLE [TB_TransferBillAttachment];
GO
CREATE TABLE [TB_TransferBillAttachment] (
    [ID] int NOT NULL,
    [TransferBillID] nvarchar(50) NOT NULL,
    [AttachmentURL] nvarchar(200) NOT NULL,
    [AttachmentType] int NOT NULL,
    CONSTRAINT [PK_TB_TransferBillAttachment] PRIMARY KEY ([ID])
);
GO

-- 转账订单取消操作过程
IF OBJECT_ID(N'TB_TransferBillCancelProcess', N'U') IS NOT NULL DROP TABLE [TB_TransferBillCancelProcess];
GO
CREATE TABLE [TB_TransferBillCancelProcess] (
    [Bill ID] nvarchar(50) NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [Remark] nvarchar(500) NULL,
    CONSTRAINT [PK_TB_TransferBillCancelProcess] PRIMARY KEY ([Bill ID])
);
GO

-- 转账通用次卡账户明细
IF OBJECT_ID(N'TB_TransferBillGeneralCardAccount', N'U') IS NOT NULL DROP TABLE [TB_TransferBillGeneralCardAccount];
GO
CREATE TABLE [TB_TransferBillGeneralCardAccount] (
    [TransferBillID] varchar(50) NOT NULL,
    [TransferOutGeneral
CardAccountID] int NOT NULL,
    [TransferOutPackage
CardAccountID] int NULL,
    [TransferInGeneralCa
rdAccountID] int NOT NULL,
    [TransferInPackageCa
rdAccountID] int NULL,
    [GeneralCardID] int NOT NULL,
    [PackageCardID] int NULL,
    [Quantity] int NOT NULL,
    CONSTRAINT [PK_TB_TransferBillGeneralCardAccount] PRIMARY KEY ([TransferBillID],[TransferOutGeneral
CardAccountID],[GeneralCardID])
);
GO

-- 转账产品账户明
IF OBJECT_ID(N'TB_TransferBillProductAccou', N'U') IS NOT NULL DROP TABLE [TB_TransferBillProductAccou];
GO
CREATE TABLE [TB_TransferBillProductAccou] (
    [TransferBillID] varchar(50) NOT NULL,
    [TransferOutProduct
AccountID] int NOT NULL,
    [TransferOutPackage
CardAccountID] int NULL,
    [TransferInProductAccountID] int NOT NULL,
    [TransferInPackageCa
rdAccountID] int NULL,
    [ProductID] int NOT NULL,
    [PackageCardID] int NULL,
    [Quantity] int NOT NULL,
    CONSTRAINT [PK_TB_TransferBillProductAccou] PRIMARY KEY ([TransferBillID],[TransferOutProduct
AccountID],[ProductID])
);
GO

-- 转账项目账户明
IF OBJECT_ID(N'TB_TransferBillProjectAccoun', N'U') IS NOT NULL DROP TABLE [TB_TransferBillProjectAccoun];
GO
CREATE TABLE [TB_TransferBillProjectAccoun] (
    [TransferBillID] varchar(50) NOT NULL,
    [TransferOutProjectAccountID] int NOT NULL,
    [TransferOutPackage
CardAccountID] int NULL,
    [TransferInProjectAccountID] int NOT NULL,
    [TransferInPackageCa
rdAccountID] int NULL,
    [ProjectID] int NOT NULL,
    [PackageCardID] int NULL,
    [Quantity] int NOT NULL,
    CONSTRAINT [PK_TB_TransferBillProjectAccoun] PRIMARY KEY ([TransferBillID],[TransferOutProjectAccountID],[ProjectID])
);
GO

-- 转账储值卡账户
明细
IF OBJECT_ID(N'TB_TransferBillSavingCardAccount', N'U') IS NOT NULL DROP TABLE [TB_TransferBillSavingCardAccount];
GO
CREATE TABLE [TB_TransferBillSavingCardAccount] (
    [TransferBillID] varchar(50) NOT NULL,
    [TransferOutSavingC
ardAccountID] int NOT NULL,
    [TransferOutPackage
CardAccountID] int NULL,
    [TransferInSavingCar
dAccountID] int NOT NULL,
    [TransferInPackageCa
rdAccountID] int NULL,
    [SavingCardID] int NOT NULL,
    [PackageCardID] int NULL,
    [Amount] decimal(18,2) NOT NULL,
    [LargessAmount] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TransferBillSavingCardAccount] PRIMARY KEY ([TransferBillID],[TransferOutSavingC
ardAccountID],[SavingCardID])
);
GO

-- 转账签名
IF OBJECT_ID(N'TB_TransferBillSignature', N'U') IS NOT NULL DROP TABLE [TB_TransferBillSignature];
GO
CREATE TABLE [TB_TransferBillSignature] (
    [TransferBillID] nvarchar(50) NOT NULL,
    [ImageURL] nvarchar(200) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_TransferBillSignature] PRIMARY KEY ([TransferBillID])
);
GO

-- 转账时效卡账户
明细
IF OBJECT_ID(N'TB_TransferBillTimeCardAccount', N'U') IS NOT NULL DROP TABLE [TB_TransferBillTimeCardAccount];
GO
CREATE TABLE [TB_TransferBillTimeCardAccount] (
    [TransferBillID] varchar(50) NOT NULL,
    [TransferOutTimeCar
dAccountID] int NOT NULL,
    [TransferOutPackage
CardAccountID] int NULL,
    [TransferInTimeCard
AccountID] int NOT NULL,
    [TransferInPackageCa
rdAccountID] int NULL,
    [TimeCardID] int NOT NULL,
    [PackageCardID] int NULL,
    [Quantity] int NOT NULL,
    CONSTRAINT [PK_TB_TransferBillTimeCardAccount] PRIMARY KEY ([TransferBillID],[TransferOutTimeCar
dAccountID],[TimeCardID])
);
GO

-- 消耗订单管理
IF OBJECT_ID(N'TB_TreatBill', N'U') IS NOT NULL DROP TABLE [TB_TreatBill];
GO
CREATE TABLE [TB_TreatBill] (
    [ID] nvarchar(50) NOT NULL,
    [BillDate] datetime NOT NULL,
    [EntityID] int NOT NULL,
    [CustomerID] int NULL,
    [BillType] nvarchar(50) NOT NULL,
    [BillStatus] varchar(2) NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NOT NULL,
    [CardPreferentialAmount] decimal(18,2) NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [PayAmount] decimal(18,2) NOT NULL,
    [CardDeductionAmount] decimal(18,2) NOT NULL,
    [LargessCardDeducti
onAmount] decimal(18,2) NOT NULL,
    [Channel] nvarchar(50) NOT NULL,
    [Remark] nvarchar(1000) NULL,
    [CreatedOn] datetime NOT NULL,
    [IsFastBill] bit NULL,
    CONSTRAINT [PK_TB_TreatBill] PRIMARY KEY ([ID])
);
GO

-- 消耗订单附件
IF OBJECT_ID(N'TB_TreatBillAttachment', N'U') IS NOT NULL DROP TABLE [TB_TreatBillAttachment];
GO
CREATE TABLE [TB_TreatBillAttachment] (
    [ID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [AttachmentURL] nvarchar(200) NOT NULL,
    [AttachmentType] int NOT NULL,
    CONSTRAINT [PK_TB_TreatBillAttachment] PRIMARY KEY ([ID])
);
GO

-- 消耗订单取消操作过程
IF OBJECT_ID(N'TB_TreatBillCancelProcess', N'U') IS NOT NULL DROP TABLE [TB_TreatBillCancelProcess];
GO
CREATE TABLE [TB_TreatBillCancelProcess] (
    [Bill ID] nvarchar(50) NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [Remark] nvarchar(500) NULL,
    CONSTRAINT [PK_TB_TreatBillCancelProcess] PRIMARY KEY ([Bill ID])
);
GO

-- 消耗订单明细-
通用次卡
IF OBJECT_ID(N'TB_TreatBillGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_TreatBillGeneralCard];
GO
CREATE TABLE [TB_TreatBillGeneralCard] (
    [ID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [GeneralCardAccount
ID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [CardPreferentialAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [CardTreatTimes] int NOT NULL,
    [PayAmount] decimal(18,2) NOT NULL,
    [CardDeductionAmount] decimal(18,2) NOT NULL,
    [LargessCardDeducti
onAmount] decimal(18,2) NOT NULL,
    [IsLargess] bit NOT NULL,
    [PackageCardAccountID] int NULL,
    [PackageCardID] int NULL,
    CONSTRAINT [PK_TB_TreatBillGeneralCard] PRIMARY KEY ([ID])
);
GO

-- 消耗订单评论-
通用次卡
IF OBJECT_ID(N'TB_TreatBillGeneralCardComment', N'U') IS NOT NULL DROP TABLE [TB_TreatBillGeneralCardComment];
GO
CREATE TABLE [TB_TreatBillGeneralCardComment] (
    [TreatBillGeneralCard] int NOT NULL,
    [Grade] int NOT NULL,
    [Comment] nvarchar(400) NULL,
    [CreateOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_TreatBillGeneralCardComment] PRIMARY KEY ([TreatBillGeneralCard])
);
GO

-- 消耗订单经手人
-通用次卡
IF OBJECT_ID(N'TB_TreatBillHandlerGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_TreatBillHandlerGeneralCard];
GO
CREATE TABLE [TB_TreatBillHandlerGeneralCard] (
    [TreatBillGeneralCard
ID] int NOT NULL,
    [GeneralCardTreatHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [IsCalculatePassenger
Flow] bit NOT NULL,
    CONSTRAINT [PK_TB_TreatBillHandlerGeneralCard] PRIMARY KEY ([TreatBillGeneralCard
ID],[GeneralCardTreatHandlerID],[EmployeeID])
);
GO

-- 消耗订单经手人
-产品
IF OBJECT_ID(N'TB_TreatBillHandlerProduct', N'U') IS NOT NULL DROP TABLE [TB_TreatBillHandlerProduct];
GO
CREATE TABLE [TB_TreatBillHandlerProduct] (
    [TreatBillProductID] int NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [IsCalculatePassenger
Flow] bit NOT NULL,
    CONSTRAINT [PK_TB_TreatBillHandlerProduct] PRIMARY KEY ([TreatBillProductID],[ProductTreatHandler
ID],[EmployeeID])
);
GO

-- 消耗订单经手人
-项目
IF OBJECT_ID(N'TB_TreatBillHandlerProject', N'U') IS NOT NULL DROP TABLE [TB_TreatBillHandlerProject];
GO
CREATE TABLE [TB_TreatBillHandlerProject] (
    [TreatBillProjectID] int NOT NULL,
    [ProjectTreatHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [IsCalculatePassenger
Flow] bit NOT NULL,
    CONSTRAINT [PK_TB_TreatBillHandlerProject] PRIMARY KEY ([TreatBillProjectID],[ProjectTreatHandlerID],[EmployeeID])
);
GO

-- 消耗订单经手人
-储值卡
IF OBJECT_ID(N'TB_TreatBillHandlerSavingCard', N'U') IS NOT NULL DROP TABLE [TB_TreatBillHandlerSavingCard];
GO
CREATE TABLE [TB_TreatBillHandlerSavingCard] (
    [TreatBillSavingCardID] int NOT NULL,
    [SavingCardTreatHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [IsCalculatePassenger
Flow] bit NOT NULL,
    CONSTRAINT [PK_TB_TreatBillHandlerSavingCard] PRIMARY KEY ([TreatBillSavingCardID],[SavingCardTreatHandlerID],[EmployeeID])
);
GO

-- 消耗订单经手人
-时效卡
IF OBJECT_ID(N'TB_TreatBillHandlerTimeCard', N'U') IS NOT NULL DROP TABLE [TB_TreatBillHandlerTimeCard];
GO
CREATE TABLE [TB_TreatBillHandlerTimeCard] (
    [TreatBillTimeCardID] int NOT NULL,
    [TimeCardTreatHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [IsCalculatePassenger
Flow] bit NOT NULL,
    CONSTRAINT [PK_TB_TreatBillHandlerTimeCard] PRIMARY KEY ([TreatBillTimeCardID],[TimeCardTreatHandlerID],[EmployeeID])
);
GO

-- 挂单管理
IF OBJECT_ID(N'TB_TreatBillPending', N'U') IS NOT NULL DROP TABLE [TB_TreatBillPending];
GO
CREATE TABLE [TB_TreatBillPending] (
    [TreatBillID] nvarchar(50) NOT NULL,
    [Content] text NOT NULL,
    CONSTRAINT [PK_TB_TreatBillPending] PRIMARY KEY ([TreatBillID])
);
GO

-- 消耗订单明细-
产品
IF OBJECT_ID(N'TB_TreatBillProduct', N'U') IS NOT NULL DROP TABLE [TB_TreatBillProduct];
GO
CREATE TABLE [TB_TreatBillProduct] (
    [ID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [ProductAccountID] int NOT NULL,
    [ProductID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [CardPreferentialAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [PayAmount] decimal(18,2) NOT NULL,
    [CardDeductionAmount] decimal(18,2) NOT NULL,
    [LargessCardDeducti
onAmount] decimal(18,2) NOT NULL,
    [IsLargess] bit NOT NULL,
    [PackageCardAccountID] int NULL,
    [PackageCardID] int NULL,
    CONSTRAINT [PK_TB_TreatBillProduct] PRIMARY KEY ([ID])
);
GO

-- 消耗订单评论-
产品
IF OBJECT_ID(N'TB_TreatBillProductComment', N'U') IS NOT NULL DROP TABLE [TB_TreatBillProductComment];
GO
CREATE TABLE [TB_TreatBillProductComment] (
    [TreatBillProduct] int NOT NULL,
    [Grade] int NOT NULL,
    [Comment] nvarchar(400) NULL,
    [CreateOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_TreatBillProductComment] PRIMARY KEY ([TreatBillProduct])
);
GO

-- 
IF OBJECT_ID(N'TB_TreatBillProject', N'U') IS NOT NULL DROP TABLE [TB_TreatBillProject];
GO
CREATE TABLE [TB_TreatBillProject] (
    [ID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [ProjectAccountID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [CardPreferentialAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [PayAmount] decimal(18,2) NOT NULL,
    [CardDeductionAmount] decimal(18,2) NOT NULL,
    [LargessCardDeducti
onAmount] decimal(18,2) NOT NULL,
    [IsLargess] bit NOT NULL,
    [PackageCardAccountID] int NULL,
    [PackageCardID] int NULL,
    [TreatBillProject] int NOT NULL,
    [Grade] int NOT NULL,
    [Comment] nvarchar(400) NULL,
    [CreateOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_TreatBillProject] PRIMARY KEY ([ID],[TreatBillProject])
);
GO

-- 
IF OBJECT_ID(N'TB_TreatBillSavingCard', N'U') IS NOT NULL DROP TABLE [TB_TreatBillSavingCard];
GO
CREATE TABLE [TB_TreatBillSavingCard] (
    [ID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [SavingCardAccountI] int NOT NULL,
    [ProjectID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [PricePreferentialAmount] decimal(18,2) NOT NULL,
    [CardPreferentialAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [CardTreatAmount] decimal(18,2) NOT NULL,
    [LargessCardTreatAmount] decimal(18,2) NOT NULL,
    [PackageCardAccountID] int NULL,
    [PackageCardID] int NULL,
    CONSTRAINT [PK_TB_TreatBillSavingCard] PRIMARY KEY ([ID])
);
GO

-- 消耗订单评论-
储值卡
IF OBJECT_ID(N'TB_TreatBillSavingCardComment', N'U') IS NOT NULL DROP TABLE [TB_TreatBillSavingCardComment];
GO
CREATE TABLE [TB_TreatBillSavingCardComment] (
    [TreatBillSavingCard] int NOT NULL,
    [Grade] int NOT NULL,
    [Comment] nvarchar(400) NULL,
    [CreateOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_TreatBillSavingCardComment] PRIMARY KEY ([TreatBillSavingCard])
);
GO

-- 
IF OBJECT_ID(N'TB_TreatBillSignature', N'U') IS NOT NULL DROP TABLE [TB_TreatBillSignature];
GO
CREATE TABLE [TB_TreatBillSignature] (
    [TreatBillID] nvarchar(50) NOT NULL,
    [ImageURL] nvarchar(200) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_TreatBillSignature] PRIMARY KEY ([TreatBillID])
);
GO

-- 
IF OBJECT_ID(N'TB_TreatBillTimeCard', N'U') IS NOT NULL DROP TABLE [TB_TreatBillTimeCard];
GO
CREATE TABLE [TB_TreatBillTimeCard] (
    [ID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TimeCardAccountID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [CardPreferentialAmount] decimal(18,2) NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [PayAmount] decimal(18,2) NOT NULL,
    [CardDeductionAmount] decimal(18,2) NOT NULL,
    [LargessCardDeducti
onAmount] decimal(18,2) NOT NULL,
    [IsLargess] bit NOT NULL,
    [PackageCardAccountID] int NULL,
    [PackageCardID] int NULL,
    CONSTRAINT [PK_TB_TreatBillTimeCard] PRIMARY KEY ([ID])
);
GO

-- 消耗订单评论-
时效卡
IF OBJECT_ID(N'TB_TreatBillTimeCardComment', N'U') IS NOT NULL DROP TABLE [TB_TreatBillTimeCardComment];
GO
CREATE TABLE [TB_TreatBillTimeCardComment] (
    [TreatBillTimeCard] int NOT NULL,
    [Grade] int NOT NULL,
    [Comment] nvarchar(400) NULL,
    [CreateOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_TreatBillTimeCardComment] PRIMARY KEY ([TreatBillTimeCard])
);
GO

-- 消耗渠道市场咨
询人员业绩-通
用次卡
IF OBJECT_ID(N'TB_TreatChannelConsultantP
erformanceGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelConsultantP
erformanceGeneralCard];
GO
CREATE TABLE [TB_TreatChannelConsultantP
erformanceGeneralCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillGeneralCard
ID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelConsultantP
erformanceGeneralCard] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道市场咨
询人员业绩-套
餐卡通用次卡
IF OBJECT_ID(N'TB_TreatChannelConsultantP
erformancePackageCardGen
eralCard', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelConsultantP
erformancePackageCardGen
eralCard];
GO
CREATE TABLE [TB_TreatChannelConsultantP
erformancePackageCardGen
eralCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillGeneralCard
ID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelConsultantP
erformancePackageCardGen
eralCard] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道市场咨
询人员业绩-套
餐卡产品
IF OBJECT_ID(N'TB_TreatChannelConsultantP
erformancePackageCardProd
uct', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelConsultantP
erformancePackageCardProd
uct];
GO
CREATE TABLE [TB_TreatChannelConsultantP
erformancePackageCardProd
uct] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProductID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelConsultantP
erformancePackageCardProd
uct] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道市场咨
询人员业绩-套
餐卡项目
IF OBJECT_ID(N'TB_TreatChannelConsultantP
erformancePackageCardProj
ect', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelConsultantP
erformancePackageCardProj
ect];
GO
CREATE TABLE [TB_TreatChannelConsultantP
erformancePackageCardProj
ect] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProjectID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelConsultantP
erformancePackageCardProj
ect] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道市场咨
询人员业绩-套
餐卡储值卡
IF OBJECT_ID(N'TB_TreatChannelConsultantP
erformancePackageCardSavi
ngCard', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelConsultantP
erformancePackageCardSavi
ngCard];
GO
CREATE TABLE [TB_TreatChannelConsultantP
erformancePackageCardSavi
ngCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillSavingCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelConsultantP
erformancePackageCardSavi
ngCard] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道市场咨
询人员业绩-套
餐卡时效卡
IF OBJECT_ID(N'TB_TreatChannelConsultantP
erformancePackageCardTime
Card', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelConsultantP
erformancePackageCardTime
Card];
GO
CREATE TABLE [TB_TreatChannelConsultantP
erformancePackageCardTime
Card] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillTimeCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelConsultantP
erformancePackageCardTime
Card] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道市场咨
询人员业绩-产
IF OBJECT_ID(N'TB_TreatChannelConsultantP
erformanceProduct', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelConsultantP
erformanceProduct];
GO
CREATE TABLE [TB_TreatChannelConsultantP
erformanceProduct] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProductID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelConsultantP
erformanceProduct] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道市场咨
询人员业绩-项
IF OBJECT_ID(N'TB_TreatChannelConsultantP
erformanceProject', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelConsultantP
erformanceProject];
GO
CREATE TABLE [TB_TreatChannelConsultantP
erformanceProject] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProjectID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelConsultantP
erformanceProject] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道市场咨
询人员业绩-储
IF OBJECT_ID(N'TB_TreatChannelConsultantP
erformanceSavingCard', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelConsultantP
erformanceSavingCard];
GO
CREATE TABLE [TB_TreatChannelConsultantP
erformanceSavingCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillSavingCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelConsultantP
erformanceSavingCard] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道市场咨
询人员业绩-时
IF OBJECT_ID(N'TB_TreatChannelConsultantP
erformanceTimeCard', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelConsultantP
erformanceTimeCard];
GO
CREATE TABLE [TB_TreatChannelConsultantP
erformanceTimeCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillTimeCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelConsultantP
erformanceTimeCard] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道开发人
员人员业绩-通
用次卡
IF OBJECT_ID(N'TB_TreatChannelDeveloperP
erformanceGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelDeveloperP
erformanceGeneralCard];
GO
CREATE TABLE [TB_TreatChannelDeveloperP
erformanceGeneralCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillGeneralCard
ID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelDeveloperP
erformanceGeneralCard] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道市场开
发人员业绩-套
餐卡通用次卡
IF OBJECT_ID(N'TB_TreatChannelDeveloperP
erformancePackageCardGen
eralCard', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelDeveloperP
erformancePackageCardGen
eralCard];
GO
CREATE TABLE [TB_TreatChannelDeveloperP
erformancePackageCardGen
eralCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillGeneralCard
ID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelDeveloperP
erformancePackageCardGen
eralCard] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道开发人
员人员业绩-套
餐卡产品
IF OBJECT_ID(N'TB_TreatChannelDeveloperP
erformancePackageCardProd
uct', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelDeveloperP
erformancePackageCardProd
uct];
GO
CREATE TABLE [TB_TreatChannelDeveloperP
erformancePackageCardProd
uct] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProductID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelDeveloperP
erformancePackageCardProd
uct] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道市场开
发人员业绩-套
餐卡项目
IF OBJECT_ID(N'TB_TreatChannelDeveloperP
erformancePackageCardProj
ect', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelDeveloperP
erformancePackageCardProj
ect];
GO
CREATE TABLE [TB_TreatChannelDeveloperP
erformancePackageCardProj
ect] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProjectID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelDeveloperP
erformancePackageCardProj
ect] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道市场开
发人员业绩-套
餐卡储值卡
IF OBJECT_ID(N'TB_TreatChannelDeveloperP
erformancePackageCardSavi
ngCard', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelDeveloperP
erformancePackageCardSavi
ngCard];
GO
CREATE TABLE [TB_TreatChannelDeveloperP
erformancePackageCardSavi
ngCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillSavingCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelDeveloperP
erformancePackageCardSavi
ngCard] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道市场开
发人员业绩-套
餐卡时效卡
IF OBJECT_ID(N'TB_TreatChannelDeveloperP
erformancePackageCardTime
Card', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelDeveloperP
erformancePackageCardTime
Card];
GO
CREATE TABLE [TB_TreatChannelDeveloperP
erformancePackageCardTime
Card] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillTimeCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelDeveloperP
erformancePackageCardTime
Card] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道开发人
员人员业绩-产
IF OBJECT_ID(N'TB_TreatChannelDeveloperP
erformanceProduct', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelDeveloperP
erformanceProduct];
GO
CREATE TABLE [TB_TreatChannelDeveloperP
erformanceProduct] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProductID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelDeveloperP
erformanceProduct] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道开发人
员人员业绩-项
IF OBJECT_ID(N'TB_TreatChannelDeveloperP
erformanceProject', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelDeveloperP
erformanceProject];
GO
CREATE TABLE [TB_TreatChannelDeveloperP
erformanceProject] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProjectID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelDeveloperP
erformanceProject] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道开发人
员人员业绩-储
IF OBJECT_ID(N'TB_TreatChannelDeveloperP
erformanceSavingCard', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelDeveloperP
erformanceSavingCard];
GO
CREATE TABLE [TB_TreatChannelDeveloperP
erformanceSavingCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillSavingCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelDeveloperP
erformanceSavingCard] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道开发人
员人员业绩-时
IF OBJECT_ID(N'TB_TreatChannelDeveloperP
erformanceTimeCard', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelDeveloperP
erformanceTimeCard];
GO
CREATE TABLE [TB_TreatChannelDeveloperP
erformanceTimeCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillTimeCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelDeveloperP
erformanceTimeCard] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道业绩-
通用次卡
IF OBJECT_ID(N'TB_TreatChannelPerformanc
eGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelPerformanc
eGeneralCard];
GO
CREATE TABLE [TB_TreatChannelPerformanc
eGeneralCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillGeneralCard
ID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelPerformanc
eGeneralCard] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道业绩-
套餐卡通用次卡
IF OBJECT_ID(N'TB_TreatChannelPerformanc
ePackageCardGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelPerformanc
ePackageCardGeneralCard];
GO
CREATE TABLE [TB_TreatChannelPerformanc
ePackageCardGeneralCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillGeneralCard
ID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelPerformanc
ePackageCardGeneralCard] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道业绩-
套餐卡产品
IF OBJECT_ID(N'TB_TreatChannelPerformanc
ePackageCardProduct', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelPerformanc
ePackageCardProduct];
GO
CREATE TABLE [TB_TreatChannelPerformanc
ePackageCardProduct] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProductID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelPerformanc
ePackageCardProduct] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道业绩-
套餐卡项目
IF OBJECT_ID(N'TB_TreatChannelPerformanc
ePackageCardProject', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelPerformanc
ePackageCardProject];
GO
CREATE TABLE [TB_TreatChannelPerformanc
ePackageCardProject] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProjectID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelPerformanc
ePackageCardProject] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道业绩-
套餐卡储值卡
IF OBJECT_ID(N'TB_TreatChannelPerformanc
ePackageCardSavingCard', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelPerformanc
ePackageCardSavingCard];
GO
CREATE TABLE [TB_TreatChannelPerformanc
ePackageCardSavingCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillSavingCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelPerformanc
ePackageCardSavingCard] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道业绩-
套餐卡时效卡
IF OBJECT_ID(N'TB_TreatChannelPerformanc
ePackageCardTimeCard', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelPerformanc
ePackageCardTimeCard];
GO
CREATE TABLE [TB_TreatChannelPerformanc
ePackageCardTimeCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillTimeCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelPerformanc
ePackageCardTimeCard] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道业绩-
产品
IF OBJECT_ID(N'TB_TreatChannelPerformanceProduct', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelPerformanceProduct];
GO
CREATE TABLE [TB_TreatChannelPerformanceProduct] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProductID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelPerformanceProduct] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道业绩-
项目
IF OBJECT_ID(N'TB_TreatChannelPerformanceProject', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelPerformanceProject];
GO
CREATE TABLE [TB_TreatChannelPerformanceProject] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProjectID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelPerformanceProject] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道业绩-
储值卡
IF OBJECT_ID(N'TB_TreatChannelPerformanc
eSavingCard', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelPerformanc
eSavingCard];
GO
CREATE TABLE [TB_TreatChannelPerformanc
eSavingCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillSavingCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelPerformanc
eSavingCard] PRIMARY KEY ([ID])
);
GO

-- 消耗渠道业绩-
时效卡
IF OBJECT_ID(N'TB_TreatChannelPerformanc
eTimeCard', N'U') IS NOT NULL DROP TABLE [TB_TreatChannelPerformanc
eTimeCard];
GO
CREATE TABLE [TB_TreatChannelPerformanc
eTimeCard] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillTimeCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ChannelID] int NOT NULL,
    [IsChannelIntroducer] bit NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatChannelPerformanc
eTimeCard] PRIMARY KEY ([ID])
);
GO

-- 消耗员工业绩提
成-通用次卡
IF OBJECT_ID(N'TB_TreatEmployeePerforman
ceCommissionGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_TreatEmployeePerforman
ceCommissionGeneralCard];
GO
CREATE TABLE [TB_TreatEmployeePerforman
ceCommissionGeneralCard] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillGeneralCard
ID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [GeneralCardTreatHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardRateCommissio] decimal(18,2) NOT NULL,
    [CardFixedCommission] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [CardLargessRateCommission] decimal(18,2) NOT NULL,
    [CardLargessFixedCommission] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    [LargessRateCommission] decimal(18,2) NOT NULL,
    [LargessFixedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEmployeePerforman
ceCommissionGeneralCard] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillGeneralCard
ID],[GeneralCardID],[ProjectID],[GeneralCardTreatHandlerID],[EmployeeID])
);
GO

-- 消耗员工业绩提
成-套餐卡通用
次卡
IF OBJECT_ID(N'TB_TreatEmployeePerforman
ceCommissionPackageCardG
eneralCard', N'U') IS NOT NULL DROP TABLE [TB_TreatEmployeePerforman
ceCommissionPackageCardG
eneralCard];
GO
CREATE TABLE [TB_TreatEmployeePerforman
ceCommissionPackageCardG
eneralCard] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillGeneralCard
ID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [GeneralCardTreatHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardRateCommissio] decimal(18,2) NOT NULL,
    [CardFixedCommission] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [CardLargessRateCommission] decimal(18,2) NOT NULL,
    [CardLargessFixedCommission] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    [LargessRateCommission] decimal(18,2) NOT NULL,
    [LargessFixedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEmployeePerforman
ceCommissionPackageCardG
eneralCard] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillGeneralCard
ID],[PackageCardID],[GeneralCardID],[ProjectID],[GeneralCardTreatHandlerID],[EmployeeID])
);
GO

-- 消耗员工业绩提
成-套餐卡产品
IF OBJECT_ID(N'TB_TreatEmployeePerforman
ceCommissionPackageCardP
roduct', N'U') IS NOT NULL DROP TABLE [TB_TreatEmployeePerforman
ceCommissionPackageCardP
roduct];
GO
CREATE TABLE [TB_TreatEmployeePerforman
ceCommissionPackageCardP
roduct] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProductID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardRateCommissio] decimal(18,2) NOT NULL,
    [CardFixedCommission] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [CardLargessRateCommission] decimal(18,2) NOT NULL,
    [CardLargessFixedCommission] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    [LargessRateCommission] decimal(18,2) NOT NULL,
    [LargessFixedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEmployeePerforman
ceCommissionPackageCardP
roduct] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillProductID],[PackageCardID],[ProductID],[ProductTreatHandler
ID],[EmployeeID])
);
GO

-- 消耗员工业绩提
成-套餐卡项目
IF OBJECT_ID(N'TB_TreatEmployeePerforman
ceCommissionPackageCardP
roject', N'U') IS NOT NULL DROP TABLE [TB_TreatEmployeePerforman
ceCommissionPackageCardP
roject];
GO
CREATE TABLE [TB_TreatEmployeePerforman
ceCommissionPackageCardP
roject] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProjectID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ProjectTreatHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardRateCommissio] decimal(18,2) NOT NULL,
    [CardFixedCommission] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [CardLargessRateCommission] decimal(18,2) NOT NULL,
    [CardLargessFixedCommission] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    [LargessRateCommission] decimal(18,2) NOT NULL,
    [LargessFixedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEmployeePerforman
ceCommissionPackageCardP
roject] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillProjectID],[PackageCardID],[ProjectID],[ProjectTreatHandlerID],[EmployeeID])
);
GO

-- 消耗员工业绩提
成-套餐卡储值
卡
IF OBJECT_ID(N'TB_TreatEmployeePerforman
ceCommissionPackageCardS
avingCard', N'U') IS NOT NULL DROP TABLE [TB_TreatEmployeePerforman
ceCommissionPackageCardS
avingCard];
GO
CREATE TABLE [TB_TreatEmployeePerforman
ceCommissionPackageCardS
avingCard] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillSavingCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [SavingCardTreatHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardRateCommissio] decimal(18,2) NOT NULL,
    [CardFixedCommission] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [CardLargessRateCommission] decimal(18,2) NOT NULL,
    [CardLargessFixedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEmployeePerforman
ceCommissionPackageCardS
avingCard] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillSavingCardID],[PackageCardID],[SavingCardID],[ProjectID],[SavingCardTreatHandlerID],[EmployeeID])
);
GO

-- 消耗员工业绩提
成-套餐卡时效
卡
IF OBJECT_ID(N'TB_TreatEmployeePerforman
ceCommissionPackageCardTi
meCard', N'U') IS NOT NULL DROP TABLE [TB_TreatEmployeePerforman
ceCommissionPackageCardTi
meCard];
GO
CREATE TABLE [TB_TreatEmployeePerforman
ceCommissionPackageCardTi
meCard] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillTimeCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [TimeCardTreatHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardRateCommissio] decimal(18,2) NOT NULL,
    [CardFixedCommission] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [CardLargessRateCommission] decimal(18,2) NOT NULL,
    [CardLargessFixedCommission] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    [LargessRateCommission] decimal(18,2) NOT NULL,
    [LargessFixedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEmployeePerforman
ceCommissionPackageCardTi
meCard] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillTimeCardID],[PackageCardID],[TimeCardID],[ProjectID],[TimeCardTreatHandlerID],[EmployeeID])
);
GO

-- 消耗员工业绩提成-产品
IF OBJECT_ID(N'TB_TreatEmployeePerforman
ceCommissionProduct', N'U') IS NOT NULL DROP TABLE [TB_TreatEmployeePerforman
ceCommissionProduct];
GO
CREATE TABLE [TB_TreatEmployeePerforman
ceCommissionProduct] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProductID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardRateCommissio] decimal(18,2) NOT NULL,
    [CardFixedCommission] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [CardLargessRateCommission] decimal(18,2) NOT NULL,
    [CardLargessFixedCommission] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    [LargessRateCommission] decimal(18,2) NOT NULL,
    [LargessFixedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEmployeePerforman
ceCommissionProduct] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillProductID],[ProductID],[ProductTreatHandler
ID],[EmployeeID])
);
GO

-- 消耗员工业绩提成-项目
IF OBJECT_ID(N'TB_TreatEmployeePerforman
ceCommissionProject', N'U') IS NOT NULL DROP TABLE [TB_TreatEmployeePerforman
ceCommissionProject];
GO
CREATE TABLE [TB_TreatEmployeePerforman
ceCommissionProject] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProjectID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [ProjectTreatHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardRateCommissio] decimal(18,2) NOT NULL,
    [CardFixedCommission] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [CardLargessRateCommission] decimal(18,2) NOT NULL,
    [CardLargessFixedCommission] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    [LargessRateCommission] decimal(18,2) NOT NULL,
    [LargessFixedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEmployeePerforman
ceCommissionProject] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillProjectID],[ProjectID],[ProjectTreatHandlerID],[EmployeeID])
);
GO

-- 消耗员工业绩提
成-储值卡
IF OBJECT_ID(N'TB_TreatEmployeePerforman
ceCommissionSavingCard', N'U') IS NOT NULL DROP TABLE [TB_TreatEmployeePerforman
ceCommissionSavingCard];
GO
CREATE TABLE [TB_TreatEmployeePerforman
ceCommissionSavingCard] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillSavingCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [SavingCardTreatHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardRateCommissio] decimal(18,2) NOT NULL,
    [CardFixedCommission] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [CardLargessRateCommission] decimal(18,2) NOT NULL,
    [CardLargessFixedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEmployeePerforman
ceCommissionSavingCard] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillSavingCardID],[SavingCardID],[ProjectID],[SavingCardTreatHandlerID],[EmployeeID])
);
GO

-- 消耗员工业绩提
成-时效卡
IF OBJECT_ID(N'TB_TreatEmployeePerforman
ceCommissionTimeCard', N'U') IS NOT NULL DROP TABLE [TB_TreatEmployeePerforman
ceCommissionTimeCard];
GO
CREATE TABLE [TB_TreatEmployeePerforman
ceCommissionTimeCard] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillTimeCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [TimeCardTreatHandlerID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [PayRateCommission] decimal(18,2) NOT NULL,
    [PayFixedCommissio] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardRateCommissio] decimal(18,2) NOT NULL,
    [CardFixedCommission] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [CardLargessRateCommission] decimal(18,2) NOT NULL,
    [CardLargessFixedCommission] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    [LargessRateCommission] decimal(18,2) NOT NULL,
    [LargessFixedCommission] decimal(18,2) NOT NULL,
    [SpecialBenefitCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEmployeePerforman
ceCommissionTimeCard] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillTimeCardID],[TimeCardID],[ProjectID],[TimeCardTreatHandlerID],[EmployeeID])
);
GO

-- 消耗门店业绩-
通用次卡
IF OBJECT_ID(N'TB_TreatEntityPerformanceG
eneralCard', N'U') IS NOT NULL DROP TABLE [TB_TreatEntityPerformanceG
eneralCard];
GO
CREATE TABLE [TB_TreatEntityPerformanceG
eneralCard] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillGeneralCard
ID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEntityPerformanceG
eneralCard] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillGeneralCard
ID],[GeneralCardID],[ProjectID])
);
GO

-- 消耗门店业绩-
套餐卡通用次卡
IF OBJECT_ID(N'TB_TreatEntityPerformancePa
ckageCardGeneralCard', N'U') IS NOT NULL DROP TABLE [TB_TreatEntityPerformancePa
ckageCardGeneralCard];
GO
CREATE TABLE [TB_TreatEntityPerformancePa
ckageCardGeneralCard] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillGeneralCard
ID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEntityPerformancePa
ckageCardGeneralCard] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillGeneralCard
ID],[PackageCardID],[GeneralCardID],[ProjectID])
);
GO

-- 消耗门店业绩-
套餐卡产品
IF OBJECT_ID(N'TB_TreatEntityPerformancePa
ckageCardProduct', N'U') IS NOT NULL DROP TABLE [TB_TreatEntityPerformancePa
ckageCardProduct];
GO
CREATE TABLE [TB_TreatEntityPerformancePa
ckageCardProduct] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProductID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEntityPerformancePa
ckageCardProduct] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillProductID],[PackageCardID],[ProductID])
);
GO

-- 消耗门店业绩-
套餐卡项目
IF OBJECT_ID(N'TB_TreatEntityPerformancePa
ckageCardProject', N'U') IS NOT NULL DROP TABLE [TB_TreatEntityPerformancePa
ckageCardProject];
GO
CREATE TABLE [TB_TreatEntityPerformancePa
ckageCardProject] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProjectID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEntityPerformancePa
ckageCardProject] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillProjectID],[PackageCardID],[ProjectID])
);
GO

-- 消耗门店业绩-
套餐卡储值卡
IF OBJECT_ID(N'TB_TreatEntityPerformancePa
ckageCardSavingCard', N'U') IS NOT NULL DROP TABLE [TB_TreatEntityPerformancePa
ckageCardSavingCard];
GO
CREATE TABLE [TB_TreatEntityPerformancePa
ckageCardSavingCard] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillSavingCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEntityPerformancePa
ckageCardSavingCard] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillSavingCardID],[PackageCardID],[SavingCardID],[ProjectID])
);
GO

-- 消耗门店业绩-
套餐卡时效卡
IF OBJECT_ID(N'TB_TreatEntityPerformancePa
ckageCardTimeCard', N'U') IS NOT NULL DROP TABLE [TB_TreatEntityPerformancePa
ckageCardTimeCard];
GO
CREATE TABLE [TB_TreatEntityPerformancePa
ckageCardTimeCard] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillTimeCardID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEntityPerformancePa
ckageCardTimeCard] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillTimeCardID],[PackageCardID],[TimeCardID],[ProjectID])
);
GO

-- 消耗门店业绩-
产品
IF OBJECT_ID(N'TB_TreatEntityPerformanceProduct', N'U') IS NOT NULL DROP TABLE [TB_TreatEntityPerformanceProduct];
GO
CREATE TABLE [TB_TreatEntityPerformanceProduct] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProductID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BillDate
Scale] datetime
decimal NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEntityPerformanceProduct] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillProductID],[ProductID])
);
GO

-- 消耗门店业绩-
项目
IF OBJECT_ID(N'TB_TreatEntityPerformanceProject', N'U') IS NOT NULL DROP TABLE [TB_TreatEntityPerformanceProject];
GO
CREATE TABLE [TB_TreatEntityPerformanceProject] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillProjectID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEntityPerformanceProject] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillProjectID],[ProjectID])
);
GO

-- 消耗门店业绩-
储值卡
IF OBJECT_ID(N'TB_TreatEntityPerformanceSavingCard', N'U') IS NOT NULL DROP TABLE [TB_TreatEntityPerformanceSavingCard];
GO
CREATE TABLE [TB_TreatEntityPerformanceSavingCard] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillSavingCardID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEntityPerformanceSavingCard] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillSavingCardID],[SavingCardID],[ProjectID])
);
GO

-- 消耗门店业绩-
时效卡
IF OBJECT_ID(N'TB_TreatEntityPerformanceTimeCard', N'U') IS NOT NULL DROP TABLE [TB_TreatEntityPerformanceTimeCard];
GO
CREATE TABLE [TB_TreatEntityPerformanceTimeCard] (
    [EntityID] int NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [TreatBillTimeCardID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [Scale] decimal(5,4) NOT NULL,
    [PayPerformance] decimal(18,2) NOT NULL,
    [CardPerformance] decimal(18,2) NOT NULL,
    [CardLargessPerformance] decimal(18,2) NOT NULL,
    [LargessPerformance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TB_TreatEntityPerformanceTimeCard] PRIMARY KEY ([EntityID],[TreatBillID],[TreatBillTimeCardID],[TimeCardID],[ProjectID])
);
GO

-- 消耗通用次卡分
类佣金提成员工
IF OBJECT_ID(N'TB_TreatGeneralCardCategor
yCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardCategor
yCommission];
GO
CREATE TABLE [TB_TreatGeneralCardCategor
yCommission] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardCategor
yCommission] PRIMARY KEY ([EntityID],[GeneralCardCategoryID])
);
GO

-- 消耗通用次卡分
类业绩门店配置
IF OBJECT_ID(N'TB_TreatGeneralCardCategor
yEntityPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardCategor
yEntityPerformance];
GO
CREATE TABLE [TB_TreatGeneralCardCategor
yEntityPerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardCategor
yEntityPerformance] PRIMARY KEY ([EntityID],[GeneralCardCategoryID])
);
GO

-- 消耗通用次卡分
类经手人佣金提
成员工配置
IF OBJECT_ID(N'TB_TreatGeneralCardCategor
yHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardCategor
yHandlerCommission];
GO
CREATE TABLE [TB_TreatGeneralCardCategor
yHandlerCommission] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [GeneralCardProjectT
reatHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardCategor
yHandlerCommission] PRIMARY KEY ([EntityID],[GeneralCardCategoryID],[GeneralCardProjectT
reatHandlerID])
);
GO

-- 消耗通用次卡分
类经手人职务佣
金提成员工配置
IF OBJECT_ID(N'TB_TreatGeneralCardCategor
yHandlerJobTypeCommissio
n', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardCategor
yHandlerJobTypeCommissio
n];
GO
CREATE TABLE [TB_TreatGeneralCardCategor
yHandlerJobTypeCommissio
n] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [GeneralCardProjectT
reatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardCategor
yHandlerJobTypeCommissio
n] PRIMARY KEY ([EntityID],[GeneralCardCategoryID],[GeneralCardProjectT
reatHandlerID],[JobTypeID])
);
GO

-- 消耗通用次卡分
类经手人职务业
绩员工配置
IF OBJECT_ID(N'TB_TreatGeneralCardCategor
yHandlerJobTypePerformanc
e', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardCategor
yHandlerJobTypePerformanc
e];
GO
CREATE TABLE [TB_TreatGeneralCardCategor
yHandlerJobTypePerformanc
e] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [GeneralCardProjectT
reatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardCategor
yHandlerJobTypePerformanc
e] PRIMARY KEY ([EntityID],[GeneralCardCategoryID],[GeneralCardProjectT
reatHandlerID],[JobTypeID])
);
GO

-- 消耗通用次卡分
类经手人业绩员
工配置
IF OBJECT_ID(N'TB_TreatGeneralCardCategor
yHandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardCategor
yHandlerPerformance];
GO
CREATE TABLE [TB_TreatGeneralCardCategor
yHandlerPerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [GeneralCardProjectT
reatHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardCategor
yHandlerPerformance] PRIMARY KEY ([EntityID],[GeneralCardCategoryID],[GeneralCardProjectT
reatHandlerID])
);
GO

-- 消耗通用次卡分
类业绩员工配置
IF OBJECT_ID(N'TB_TreatGeneralCardCategor
yPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardCategor
yPerformance];
GO
CREATE TABLE [TB_TreatGeneralCardCategor
yPerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardCategor
yPerformance] PRIMARY KEY ([EntityID],[GeneralCardCategoryID])
);
GO

-- 消耗通用次卡佣
金提成员工配置
IF OBJECT_ID(N'TB_TreatGeneralCardCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardCommission];
GO
CREATE TABLE [TB_TreatGeneralCardCommission] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardCommission] PRIMARY KEY ([EntityID],[GeneralCardID])
);
GO

-- 消耗通用次卡业
绩门店配置
IF OBJECT_ID(N'TB_TreatGeneralCardEntityPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardEntityPerformance];
GO
CREATE TABLE [TB_TreatGeneralCardEntityPerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardEntityPerformance] PRIMARY KEY ([EntityID],[GeneralCardID])
);
GO

-- 消耗通用次卡业
绩门店配置方案
IF OBJECT_ID(N'TB_TreatGeneralCardEntityPe
rformanceScheme', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardEntityPe
rformanceScheme];
GO
CREATE TABLE [TB_TreatGeneralCardEntityPe
rformanceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardEntityPe
rformanceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 消耗通用次卡经
手人佣金提成员
工配置
IF OBJECT_ID(N'TB_TreatGeneralCardHandler
Commission', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardHandler
Commission];
GO
CREATE TABLE [TB_TreatGeneralCardHandler
Commission] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [GeneralCardProjectT
reatHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardHandler
Commission] PRIMARY KEY ([EntityID],[GeneralCardID],[GeneralCardProjectT
reatHandlerID])
);
GO

-- 消耗通用次卡经
手人职务佣金提
成员工配置
IF OBJECT_ID(N'TB_TreatGeneralCardHandler
JobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardHandler
JobTypeCommission];
GO
CREATE TABLE [TB_TreatGeneralCardHandler
JobTypeCommission] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [GeneralCardProjectT
reatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardHandler
JobTypeCommission] PRIMARY KEY ([EntityID],[GeneralCardID],[GeneralCardProjectT
reatHandlerID],[JobTypeID])
);
GO

-- 消耗通用次卡经
手人职务业绩员
工配置
IF OBJECT_ID(N'TB_TreatGeneralCardHandler
JobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardHandler
JobTypePerformance];
GO
CREATE TABLE [TB_TreatGeneralCardHandler
JobTypePerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [GeneralCardProjectT
reatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardHandler
JobTypePerformance] PRIMARY KEY ([EntityID],[GeneralCardID],[GeneralCardProjectT
reatHandlerID],[JobTypeID])
);
GO

-- 消耗通用次卡经
手人业绩员工配
IF OBJECT_ID(N'TB_TreatGeneralCardHandler
Performance', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardHandler
Performance];
GO
CREATE TABLE [TB_TreatGeneralCardHandler
Performance] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [GeneralCardProjectT
reatHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardHandler
Performance] PRIMARY KEY ([EntityID],[GeneralCardID],[GeneralCardProjectT
reatHandlerID])
);
GO

-- 消耗通用次卡业
绩员工配置
IF OBJECT_ID(N'TB_TreatGeneralCardPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardPerformance];
GO
CREATE TABLE [TB_TreatGeneralCardPerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardPerformance] PRIMARY KEY ([EntityID],[GeneralCardID])
);
GO

-- 消耗通用次卡业
绩员工配置方案
IF OBJECT_ID(N'TB_TreatGeneralCardPerform
anceScheme', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardPerform
anceScheme];
GO
CREATE TABLE [TB_TreatGeneralCardPerform
anceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardPerform
anceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 消耗通用次卡项
目佣金提成员工
IF OBJECT_ID(N'TB_TreatGeneralCardProjectC
ommission', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardProjectC
ommission];
GO
CREATE TABLE [TB_TreatGeneralCardProjectC
ommission] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardProjectC
ommission] PRIMARY KEY ([EntityID],[GeneralCardID],[ProjectID])
);
GO

-- 消耗通用次卡项
目佣金提成员工
配置方案
IF OBJECT_ID(N'TB_TreatGeneralCardProjectC
ommissionScheme', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardProjectC
ommissionScheme];
GO
CREATE TABLE [TB_TreatGeneralCardProjectC
ommissionScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardProjectC
ommissionScheme] PRIMARY KEY ([EntityID])
);
GO

-- 消耗通用次卡项
目业绩门店配置
IF OBJECT_ID(N'TB_TreatGeneralCardProjectE
ntityPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardProjectE
ntityPerformance];
GO
CREATE TABLE [TB_TreatGeneralCardProjectE
ntityPerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardProjectE
ntityPerformance] PRIMARY KEY ([EntityID],[GeneralCardID],[ProjectID])
);
GO

-- 消耗通用次卡项
目经手人佣金提
成员工配置
IF OBJECT_ID(N'TB_TreatGeneralCardProject
HandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardProject
HandlerCommission];
GO
CREATE TABLE [TB_TreatGeneralCardProject
HandlerCommission] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [GeneralCardProjectT
reatHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardProject
HandlerCommission] PRIMARY KEY ([EntityID],[GeneralCardID],[ProjectID],[GeneralCardProjectT
reatHandlerID])
);
GO

-- 消耗通用次卡项
目经手人职务佣
金提成员工配置
IF OBJECT_ID(N'TB_TreatGeneralCardProject
HandlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardProject
HandlerJobTypeCommission];
GO
CREATE TABLE [TB_TreatGeneralCardProject
HandlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [GeneralCardProjectT
reatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardProject
HandlerJobTypeCommission] PRIMARY KEY ([EntityID],[GeneralCardID],[ProjectID],[GeneralCardProjectT
reatHandlerID],[JobTypeID])
);
GO

-- 消耗通用次卡项
目经手人职务业
绩员工配置
IF OBJECT_ID(N'TB_TreatGeneralCardProject
HandlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardProject
HandlerJobTypePerformance];
GO
CREATE TABLE [TB_TreatGeneralCardProject
HandlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [GeneralCardProjectT
reatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardProject
HandlerJobTypePerformance] PRIMARY KEY ([EntityID],[GeneralCardID],[ProjectID],[GeneralCardProjectT
reatHandlerID],[JobTypeID])
);
GO

-- 消耗通用次卡项
目经手人业绩员
工配置
IF OBJECT_ID(N'TB_TreatGeneralCardProject
HandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardProject
HandlerPerformance];
GO
CREATE TABLE [TB_TreatGeneralCardProject
HandlerPerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [GeneralCardProjectT
reatHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardProject
HandlerPerformance] PRIMARY KEY ([EntityID],[GeneralCardID],[ProjectID],[GeneralCardProjectT
reatHandlerID])
);
GO

-- 消耗通用次卡项
目业绩员工配置
IF OBJECT_ID(N'TB_TreatGeneralCardProjectP
erformance', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardProjectP
erformance];
GO
CREATE TABLE [TB_TreatGeneralCardProjectP
erformance] (
    [EntityID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardProjectP
erformance] PRIMARY KEY ([EntityID],[GeneralCardID],[ProjectID])
);
GO

-- 消耗所有通用次
卡项目经手人佣
金提成员工配置
IF OBJECT_ID(N'TB_TreatGeneralCardProjectS
chemeHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardProjectS
chemeHandlerCommission];
GO
CREATE TABLE [TB_TreatGeneralCardProjectS
chemeHandlerCommission] (
    [EntityID] int NOT NULL,
    [GeneralCardProjectT
reatHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardProjectS
chemeHandlerCommission] PRIMARY KEY ([EntityID],[GeneralCardProjectT
reatHandlerID])
);
GO

-- 消耗所有通用次
卡项目经手人职
务佣金提成员工
IF OBJECT_ID(N'TB_TreatGeneralCardProjectS
chemeHandlerJobTypeCom
mission', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardProjectS
chemeHandlerJobTypeCom
mission];
GO
CREATE TABLE [TB_TreatGeneralCardProjectS
chemeHandlerJobTypeCom
mission] (
    [EntityID] int NOT NULL,
    [GeneralCardProjectT
reatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardProjectS
chemeHandlerJobTypeCom
mission] PRIMARY KEY ([EntityID],[GeneralCardProjectT
reatHandlerID],[JobTypeID])
);
GO

-- 消耗所有通用次
卡项目经手人职
务业绩员工配置
IF OBJECT_ID(N'TB_TreatGeneralCardScheme
HandlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardScheme
HandlerJobTypePerformance];
GO
CREATE TABLE [TB_TreatGeneralCardScheme
HandlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardProjectT
reatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardScheme
HandlerJobTypePerformance] PRIMARY KEY ([EntityID],[GeneralCardProjectT
reatHandlerID],[JobTypeID])
);
GO

-- 消耗所有通用次
卡项目经手人业
绩员工配置
IF OBJECT_ID(N'TB_TreatGeneralCardScheme
HandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatGeneralCardScheme
HandlerPerformance];
GO
CREATE TABLE [TB_TreatGeneralCardScheme
HandlerPerformance] (
    [EntityID] int NOT NULL,
    [GeneralCardProjectT
reatHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatGeneralCardScheme
HandlerPerformance] PRIMARY KEY ([EntityID],[GeneralCardProjectT
reatHandlerID])
);
GO

-- 消耗产品分类佣
金提成员工配置
IF OBJECT_ID(N'TB_TreatProductCategoryCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatProductCategoryCommission];
GO
CREATE TABLE [TB_TreatProductCategoryCommission] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProductCategoryCommission] PRIMARY KEY ([EntityID],[ProductCategoryID])
);
GO

-- 消耗产品分类业
绩门店配置
IF OBJECT_ID(N'TB_TreatProductCategoryEnti
tyPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProductCategoryEnti
tyPerformance];
GO
CREATE TABLE [TB_TreatProductCategoryEnti
tyPerformance] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProductCategoryEnti
tyPerformance] PRIMARY KEY ([EntityID],[ProductCategoryID])
);
GO

-- 消耗产品分类经
手人佣金提成员
工配置
IF OBJECT_ID(N'TB_TreatProductCategoryHa
ndlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatProductCategoryHa
ndlerCommission];
GO
CREATE TABLE [TB_TreatProductCategoryHa
ndlerCommission] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProductCategoryHa
ndlerCommission] PRIMARY KEY ([EntityID],[ProductCategoryID],[ProductTreatHandler
ID])
);
GO

-- 消耗产品分类经
手人职务佣金提
成员工配置
IF OBJECT_ID(N'TB_TreatProductCategoryHa
ndlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatProductCategoryHa
ndlerJobTypeCommission];
GO
CREATE TABLE [TB_TreatProductCategoryHa
ndlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProductCategoryHa
ndlerJobTypeCommission] PRIMARY KEY ([EntityID],[ProductCategoryID],[ProductTreatHandler
ID],[JobTypeID])
);
GO

-- 消耗产品分类经
手人职务业绩员
工配置
IF OBJECT_ID(N'TB_TreatProductCategoryHa
ndlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProductCategoryHa
ndlerJobTypePerformance];
GO
CREATE TABLE [TB_TreatProductCategoryHa
ndlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProductCategoryHa
ndlerJobTypePerformance] PRIMARY KEY ([EntityID],[ProductCategoryID],[ProductTreatHandler
ID],[JobTypeID])
);
GO

-- 消耗产品分类经
手人业绩员工配
IF OBJECT_ID(N'TB_TreatProductCategoryHa
ndlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProductCategoryHa
ndlerPerformance];
GO
CREATE TABLE [TB_TreatProductCategoryHa
ndlerPerformance] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProductCategoryHa
ndlerPerformance] PRIMARY KEY ([EntityID],[ProductCategoryID],[ProductTreatHandler
ID])
);
GO

-- 消耗产品分类业
绩员工配置
IF OBJECT_ID(N'TB_TreatProductCategoryPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProductCategoryPerformance];
GO
CREATE TABLE [TB_TreatProductCategoryPerformance] (
    [EntityID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProductCategoryPerformance] PRIMARY KEY ([EntityID],[ProductCategoryID])
);
GO

-- 消耗产品佣金提
成员工配置
IF OBJECT_ID(N'TB_TreatProductCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatProductCommission];
GO
CREATE TABLE [TB_TreatProductCommission] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProductCommission] PRIMARY KEY ([EntityID],[ProductID])
);
GO

-- 消耗产品佣金提
成员工配置方案
IF OBJECT_ID(N'TB_TreatProductCommission
Scheme', N'U') IS NOT NULL DROP TABLE [TB_TreatProductCommission
Scheme];
GO
CREATE TABLE [TB_TreatProductCommission
Scheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProductCommission
Scheme] PRIMARY KEY ([EntityID])
);
GO

-- 消耗产品业绩门店配置
IF OBJECT_ID(N'TB_TreatProductEntityPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProductEntityPerformance];
GO
CREATE TABLE [TB_TreatProductEntityPerformance] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProductEntityPerformance] PRIMARY KEY ([EntityID],[ProductID])
);
GO

-- 消耗产品业绩门
店配置方案
IF OBJECT_ID(N'TB_TreatProductEntityPerfor
manceScheme', N'U') IS NOT NULL DROP TABLE [TB_TreatProductEntityPerfor
manceScheme];
GO
CREATE TABLE [TB_TreatProductEntityPerfor
manceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProductEntityPerfor
manceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 消耗产品经手人
佣金提成员工配
IF OBJECT_ID(N'TB_TreatProductHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatProductHandlerCommission];
GO
CREATE TABLE [TB_TreatProductHandlerCommission] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProductHandlerCommission] PRIMARY KEY ([EntityID],[ProductID],[ProductTreatHandler
ID])
);
GO

-- 消耗产品经手人
职务佣金提成员
工配置
IF OBJECT_ID(N'TB_TreatProductHandlerJobT
ypeCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatProductHandlerJobT
ypeCommission];
GO
CREATE TABLE [TB_TreatProductHandlerJobT
ypeCommission] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProductHandlerJobT
ypeCommission] PRIMARY KEY ([EntityID],[ProductID],[ProductTreatHandler
ID],[JobTypeID])
);
GO

-- 消耗产品经手人
职务业绩员工配
IF OBJECT_ID(N'TB_TreatProductHandlerJobT
ypePerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProductHandlerJobT
ypePerformance];
GO
CREATE TABLE [TB_TreatProductHandlerJobT
ypePerformance] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProductHandlerJobT
ypePerformance] PRIMARY KEY ([EntityID],[ProductID],[ProductTreatHandler
ID],[JobTypeID])
);
GO

-- 消耗产品经手人
业绩员工配置
IF OBJECT_ID(N'TB_TreatProductHandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProductHandlerPerformance];
GO
CREATE TABLE [TB_TreatProductHandlerPerformance] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProductHandlerPerformance] PRIMARY KEY ([EntityID],[ProductID],[ProductTreatHandler
ID])
);
GO

-- 消耗产品业绩员工配置
IF OBJECT_ID(N'TB_TreatProductPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProductPerformance];
GO
CREATE TABLE [TB_TreatProductPerformance] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProductPerformance] PRIMARY KEY ([EntityID],[ProductID])
);
GO

-- 消耗产品业绩员
工配置方案
IF OBJECT_ID(N'TB_TreatProductPerformance
Scheme', N'U') IS NOT NULL DROP TABLE [TB_TreatProductPerformance
Scheme];
GO
CREATE TABLE [TB_TreatProductPerformance
Scheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProductPerformance
Scheme] PRIMARY KEY ([EntityID])
);
GO

-- 消耗所有产品经
手人佣金提成员
工配置
IF OBJECT_ID(N'TB_TreatProductSchemeHan
dlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatProductSchemeHan
dlerCommission];
GO
CREATE TABLE [TB_TreatProductSchemeHan
dlerCommission] (
    [EntityID] int NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProductSchemeHan
dlerCommission] PRIMARY KEY ([EntityID],[ProductTreatHandler
ID])
);
GO

-- 消耗所有产品经
手人职务佣金提
成员工配置
IF OBJECT_ID(N'TB_TreatProductSchemeHan
dlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatProductSchemeHan
dlerJobTypeCommission];
GO
CREATE TABLE [TB_TreatProductSchemeHan
dlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProductSchemeHan
dlerJobTypeCommission] PRIMARY KEY ([EntityID],[ProductTreatHandler
ID],[JobTypeID])
);
GO

-- 消耗所有产品经
手人职务业绩员
工配置
IF OBJECT_ID(N'TB_TreatProductSchemeHan
dlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProductSchemeHan
dlerJobTypePerformance];
GO
CREATE TABLE [TB_TreatProductSchemeHan
dlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProductSchemeHan
dlerJobTypePerformance] PRIMARY KEY ([EntityID],[ProductTreatHandler
ID],[JobTypeID])
);
GO

-- 消耗所有产品经
手人业绩员工配
IF OBJECT_ID(N'TB_TreatProductSchemeHan
dlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProductSchemeHan
dlerPerformance];
GO
CREATE TABLE [TB_TreatProductSchemeHan
dlerPerformance] (
    [EntityID] int NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProductSchemeHan
dlerPerformance] PRIMARY KEY ([EntityID],[ProductTreatHandler
ID])
);
GO

-- 消耗项目分类佣
金提成员工配置
IF OBJECT_ID(N'TB_TreatProjectCategoryCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectCategoryCommission];
GO
CREATE TABLE [TB_TreatProjectCategoryCommission] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProjectCategoryCommission] PRIMARY KEY ([EntityID],[ProjectCategoryID])
);
GO

-- 消耗项目分类业
绩门店配置
IF OBJECT_ID(N'TB_TreatProjectCategoryEntit
yPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectCategoryEntit
yPerformance];
GO
CREATE TABLE [TB_TreatProjectCategoryEntit
yPerformance] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProjectCategoryEntit
yPerformance] PRIMARY KEY ([EntityID],[ProjectCategoryID])
);
GO

-- 消耗项目分类经
手人佣金提成员
工配置
IF OBJECT_ID(N'TB_TreatProjectCategoryHan
dlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectCategoryHan
dlerCommission];
GO
CREATE TABLE [TB_TreatProjectCategoryHan
dlerCommission] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [ProjectTreatHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProjectCategoryHan
dlerCommission] PRIMARY KEY ([EntityID],[ProjectCategoryID],[ProjectTreatHandlerID])
);
GO

-- 消耗项目分类经
手人职务佣金提
成员工配置
IF OBJECT_ID(N'TB_TreatProjectCategoryHan
dlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectCategoryHan
dlerJobTypeCommission];
GO
CREATE TABLE [TB_TreatProjectCategoryHan
dlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [ProjectTreatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProjectCategoryHan
dlerJobTypeCommission] PRIMARY KEY ([EntityID],[ProjectCategoryID],[ProjectTreatHandlerID],[JobTypeID])
);
GO

-- 消耗项目分类经
手人职务业绩员
工配置
IF OBJECT_ID(N'TB_TreatProjectCategoryHan
dlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectCategoryHan
dlerJobTypePerformance];
GO
CREATE TABLE [TB_TreatProjectCategoryHan
dlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [ProjectTreatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProjectCategoryHan
dlerJobTypePerformance] PRIMARY KEY ([EntityID],[ProjectCategoryID],[ProjectTreatHandlerID],[JobTypeID])
);
GO

-- 消耗项目分类经
手人业绩员工配
IF OBJECT_ID(N'TB_TreatProjectCategoryHan
dlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectCategoryHan
dlerPerformance];
GO
CREATE TABLE [TB_TreatProjectCategoryHan
dlerPerformance] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [ProjectTreatHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProjectCategoryHan
dlerPerformance] PRIMARY KEY ([EntityID],[ProjectCategoryID],[ProjectTreatHandlerID])
);
GO

-- 消耗项目分类业
绩员工配置
IF OBJECT_ID(N'TB_TreatProjectCategoryPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectCategoryPerformance];
GO
CREATE TABLE [TB_TreatProjectCategoryPerformance] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProjectCategoryPerformance] PRIMARY KEY ([EntityID],[ProjectCategoryID])
);
GO

-- 消耗项目佣金提
成员工配置
IF OBJECT_ID(N'TB_TreatProjectCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectCommission];
GO
CREATE TABLE [TB_TreatProjectCommission] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProjectCommission] PRIMARY KEY ([EntityID],[ProjectID])
);
GO

-- 消耗项目佣金提
成员工配置方案
IF OBJECT_ID(N'TB_TreatProjectCommissionScheme', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectCommissionScheme];
GO
CREATE TABLE [TB_TreatProjectCommissionScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProjectCommissionScheme] PRIMARY KEY ([EntityID])
);
GO

-- 消耗项目业绩门店配置
IF OBJECT_ID(N'TB_TreatProjectEntityPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectEntityPerformance];
GO
CREATE TABLE [TB_TreatProjectEntityPerformance] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProjectEntityPerformance] PRIMARY KEY ([EntityID],[ProjectID])
);
GO

-- 消耗项目业绩门
店配置方案
IF OBJECT_ID(N'TB_TreatProjectEntityPerform
anceScheme', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectEntityPerform
anceScheme];
GO
CREATE TABLE [TB_TreatProjectEntityPerform
anceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProjectEntityPerform
anceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 消耗产品经手人
佣金提成员工配
IF OBJECT_ID(N'TB_TreatProjectHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectHandlerCommission];
GO
CREATE TABLE [TB_TreatProjectHandlerCommission] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [ProjectTreatHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProjectHandlerCommission] PRIMARY KEY ([EntityID],[ProjectID],[ProjectTreatHandlerID])
);
GO

-- 消耗项目经手人
职务佣金提成员
工配置
IF OBJECT_ID(N'TB_TreatProjectHandlerJobTy
peCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectHandlerJobTy
peCommission];
GO
CREATE TABLE [TB_TreatProjectHandlerJobTy
peCommission] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [ProjectTreatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProjectHandlerJobTy
peCommission] PRIMARY KEY ([EntityID],[ProjectID],[ProjectTreatHandlerID],[JobTypeID])
);
GO

-- 消耗项目经手人
职务业绩员工配
IF OBJECT_ID(N'TB_TreatProjectHandlerJobTy
pePerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectHandlerJobTy
pePerformance];
GO
CREATE TABLE [TB_TreatProjectHandlerJobTy
pePerformance] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [ProjectTreatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProjectHandlerJobTy
pePerformance] PRIMARY KEY ([EntityID],[ProjectID],[ProjectTreatHandlerID],[JobTypeID])
);
GO

-- 消耗项目经手人
业绩员工配置
IF OBJECT_ID(N'TB_TreatProjectHandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectHandlerPerformance];
GO
CREATE TABLE [TB_TreatProjectHandlerPerformance] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [ProjectTreatHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProjectHandlerPerformance] PRIMARY KEY ([EntityID],[ProjectID],[ProjectTreatHandlerID])
);
GO

-- 消耗项目业绩员工配置
IF OBJECT_ID(N'TB_TreatProjectPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectPerformance];
GO
CREATE TABLE [TB_TreatProjectPerformance] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProjectPerformance] PRIMARY KEY ([EntityID],[ProjectID])
);
GO

-- 消耗项目业绩员
工配置方案
IF OBJECT_ID(N'TB_TreatProjectPerformanceScheme', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectPerformanceScheme];
GO
CREATE TABLE [TB_TreatProjectPerformanceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProjectPerformanceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 消耗所有项目经
手人佣金提成员
工配置
IF OBJECT_ID(N'TB_TreatProjectSchemeHandl
erCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectSchemeHandl
erCommission];
GO
CREATE TABLE [TB_TreatProjectSchemeHandl
erCommission] (
    [EntityID] int NOT NULL,
    [ProjectTreatHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProjectSchemeHandl
erCommission] PRIMARY KEY ([EntityID],[ProjectTreatHandlerID])
);
GO

-- 消耗所有项目经
手人职务佣金提
成员工配置
IF OBJECT_ID(N'TB_TreatProjectSchemeHandl
erJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectSchemeHandl
erJobTypeCommission];
GO
CREATE TABLE [TB_TreatProjectSchemeHandl
erJobTypeCommission] (
    [EntityID] int NOT NULL,
    [ProjectTreatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatProjectSchemeHandl
erJobTypeCommission] PRIMARY KEY ([EntityID],[ProjectTreatHandlerID],[JobTypeID])
);
GO

-- 消耗所有项目经
手人职务业绩员
工配置
IF OBJECT_ID(N'TB_TreatProjectSchemeHandl
erJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectSchemeHandl
erJobTypePerformance];
GO
CREATE TABLE [TB_TreatProjectSchemeHandl
erJobTypePerformance] (
    [EntityID] int NOT NULL,
    [ProjectTreatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProjectSchemeHandl
erJobTypePerformance] PRIMARY KEY ([EntityID],[ProjectTreatHandlerID],[JobTypeID])
);
GO

-- 消耗所有项目经
手人业绩员工配
IF OBJECT_ID(N'TB_TreatProjectSchemeHandl
erPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatProjectSchemeHandl
erPerformance];
GO
CREATE TABLE [TB_TreatProjectSchemeHandl
erPerformance] (
    [EntityID] int NOT NULL,
    [ProjectTreatHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatProjectSchemeHandl
erPerformance] PRIMARY KEY ([EntityID],[ProjectTreatHandlerID])
);
GO

-- 消耗储值卡分类
佣金提成员工配
IF OBJECT_ID(N'TB_TreatSavingCardCategory
Commission', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardCategory
Commission];
GO
CREATE TABLE [TB_TreatSavingCardCategory
Commission] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardCategory
Commission] PRIMARY KEY ([EntityID],[SavingCardCategory
ID])
);
GO

-- 消耗储值卡分类
业绩门店配置
IF OBJECT_ID(N'TB_TreatSavingCardCategory
EntityPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardCategory
EntityPerformance];
GO
CREATE TABLE [TB_TreatSavingCardCategory
EntityPerformance] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardCategory
EntityPerformance] PRIMARY KEY ([EntityID],[SavingCardCategory
ID])
);
GO

-- 消耗储值卡分类
经手人佣金提成
员工配置
IF OBJECT_ID(N'TB_TreatSavingCardCategory
HandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardCategory
HandlerCommission];
GO
CREATE TABLE [TB_TreatSavingCardCategory
HandlerCommission] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardCategory
HandlerCommission] PRIMARY KEY ([EntityID],[SavingCardCategory
ID],[SavingCardProjectTr
eatHandlerID])
);
GO

-- 消耗储值卡分类
经手人职务佣金
提成员工配置
IF OBJECT_ID(N'TB_TreatSavingCardCategory
HandlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardCategory
HandlerJobTypeCommission];
GO
CREATE TABLE [TB_TreatSavingCardCategory
HandlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardCategory
HandlerJobTypeCommission] PRIMARY KEY ([EntityID],[SavingCardCategory
ID],[SavingCardProjectTr
eatHandlerID],[JobTypeID])
);
GO

-- 消耗储值卡分类
经手人职务业绩
员工配置
IF OBJECT_ID(N'TB_TreatSavingCardCategory
HandlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardCategory
HandlerJobTypePerformance];
GO
CREATE TABLE [TB_TreatSavingCardCategory
HandlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardCategory
HandlerJobTypePerformance] PRIMARY KEY ([EntityID],[SavingCardCategory
ID],[SavingCardProjectTr
eatHandlerID],[JobTypeID])
);
GO

-- 消耗储值卡分类
经手人业绩员工
IF OBJECT_ID(N'TB_TreatSavingCardCategory
HandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardCategory
HandlerPerformance];
GO
CREATE TABLE [TB_TreatSavingCardCategory
HandlerPerformance] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardCategory
HandlerPerformance] PRIMARY KEY ([EntityID],[SavingCardCategory
ID],[SavingCardProjectTr
eatHandlerID])
);
GO

-- 消耗储值卡分类
业绩员工配置
IF OBJECT_ID(N'TB_TreatSavingCardCategory
Performance', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardCategory
Performance];
GO
CREATE TABLE [TB_TreatSavingCardCategory
Performance] (
    [EntityID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardCategory
Performance] PRIMARY KEY ([EntityID],[SavingCardCategory
ID])
);
GO

-- 消耗时效卡佣金
提成员工配置
IF OBJECT_ID(N'TB_TreatSavingCardCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardCommission];
GO
CREATE TABLE [TB_TreatSavingCardCommission] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardCommission] PRIMARY KEY ([EntityID],[SavingCardID])
);
GO

-- 消耗储值卡佣金
提成员工配置方
IF OBJECT_ID(N'TB_TreatSavingCardCommiss
ionScheme', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardCommiss
ionScheme];
GO
CREATE TABLE [TB_TreatSavingCardCommiss
ionScheme] (
    [EntityID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardCommiss
ionScheme] PRIMARY KEY ([EntityID])
);
GO

-- 消耗储值卡业绩
门店配置
IF OBJECT_ID(N'TB_TreatSavingCardEntityPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardEntityPerformance];
GO
CREATE TABLE [TB_TreatSavingCardEntityPerformance] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardEntityPerformance] PRIMARY KEY ([EntityID],[SavingCardID])
);
GO

-- 消耗储值卡业绩
门店配置方案
IF OBJECT_ID(N'TB_TreatSavingCardEntityPerf
ormanceScheme', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardEntityPerf
ormanceScheme];
GO
CREATE TABLE [TB_TreatSavingCardEntityPerf
ormanceScheme] (
    [EntityID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardEntityPerf
ormanceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 消耗储值卡经手
人佣金提成员工
IF OBJECT_ID(N'TB_TreatSavingCardHandlerC
ommission', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardHandlerC
ommission];
GO
CREATE TABLE [TB_TreatSavingCardHandlerC
ommission] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardHandlerC
ommission] PRIMARY KEY ([EntityID],[SavingCardID],[SavingCardProjectTr
eatHandlerID])
);
GO

-- 消耗储值卡经手
人职务佣金提成
员工配置
IF OBJECT_ID(N'TB_TreatSavingCardHandlerJ
obTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardHandlerJ
obTypeCommission];
GO
CREATE TABLE [TB_TreatSavingCardHandlerJ
obTypeCommission] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardHandlerJ
obTypeCommission] PRIMARY KEY ([EntityID],[SavingCardID],[SavingCardProjectTr
eatHandlerID],[JobTypeID])
);
GO

-- 消耗储值卡经手
人职务业绩员工
IF OBJECT_ID(N'TB_TreatSavingCardHandlerJ
obTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardHandlerJ
obTypePerformance];
GO
CREATE TABLE [TB_TreatSavingCardHandlerJ
obTypePerformance] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardHandlerJ
obTypePerformance] PRIMARY KEY ([EntityID],[SavingCardID],[SavingCardProjectTr
eatHandlerID],[JobTypeID])
);
GO

-- 消耗储值卡经手
人业绩员工配置
IF OBJECT_ID(N'TB_TreatSavingCardHandlerP
erformance', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardHandlerP
erformance];
GO
CREATE TABLE [TB_TreatSavingCardHandlerP
erformance] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardHandlerP
erformance] PRIMARY KEY ([EntityID],[SavingCardID],[SavingCardProjectTr
eatHandlerID])
);
GO

-- 消耗储值卡业绩
员工配置
IF OBJECT_ID(N'TB_TreatSavingCardPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardPerformance];
GO
CREATE TABLE [TB_TreatSavingCardPerformance] (
    [EntityID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardPerformance] PRIMARY KEY ([EntityID],[SavingCardID])
);
GO

-- 消耗储值卡业绩
员工配置方案
IF OBJECT_ID(N'TB_TreatSavingCardPerforma
nceScheme', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardPerforma
nceScheme];
GO
CREATE TABLE [TB_TreatSavingCardPerforma
nceScheme] (
    [EntityID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardPerforma
nceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 消耗储值卡项目
分类佣金提成员
工配置
IF OBJECT_ID(N'TB_TreatSavingCardProjectCa
tegoryCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardProjectCa
tegoryCommission];
GO
CREATE TABLE [TB_TreatSavingCardProjectCa
tegoryCommission] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardProjectCa
tegoryCommission] PRIMARY KEY ([EntityID],[ProjectCategoryID])
);
GO

-- 消耗储值卡项目
分类经手人佣金
提成员工配置
IF OBJECT_ID(N'TB_TreatSavingCardProjectCa
tegoryHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardProjectCa
tegoryHandlerCommission];
GO
CREATE TABLE [TB_TreatSavingCardProjectCa
tegoryHandlerCommission] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardProjectCa
tegoryHandlerCommission] PRIMARY KEY ([EntityID],[ProjectCategoryID],[SavingCardProjectTr
eatHandlerID])
);
GO

-- 消耗储值卡项目
分类经手人职务
佣金提成员工配
IF OBJECT_ID(N'TB_TreatSavingCardProjectCa
tegoryHandlerJobTypeComm
ission', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardProjectCa
tegoryHandlerJobTypeComm
ission];
GO
CREATE TABLE [TB_TreatSavingCardProjectCa
tegoryHandlerJobTypeComm
ission] (
    [EntityID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardProjectCa
tegoryHandlerJobTypeComm
ission] PRIMARY KEY ([EntityID],[ProjectCategoryID],[SavingCardProjectTr
eatHandlerID],[JobTypeID])
);
GO

-- 消耗储值卡项目
佣金提成员工配
IF OBJECT_ID(N'TB_TreatSavingCardProjectC
ommission', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardProjectC
ommission];
GO
CREATE TABLE [TB_TreatSavingCardProjectC
ommission] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardProjectC
ommission] PRIMARY KEY ([EntityID],[ProjectID])
);
GO

-- 消耗储值卡项目
佣金提成员工配
置方案
IF OBJECT_ID(N'TB_TreatSavingCardProjectC
ommissionScheme', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardProjectC
ommissionScheme];
GO
CREATE TABLE [TB_TreatSavingCardProjectC
ommissionScheme] (
    [EntityID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardProjectC
ommissionScheme] PRIMARY KEY ([EntityID])
);
GO

-- 消耗储值卡项目
经手人佣金提成
员工配置
IF OBJECT_ID(N'TB_TreatSavingCardProjectH
andlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardProjectH
andlerCommission];
GO
CREATE TABLE [TB_TreatSavingCardProjectH
andlerCommission] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardProjectH
andlerCommission] PRIMARY KEY ([EntityID],[ProjectID],[SavingCardProjectTr
eatHandlerID])
);
GO

-- 消耗储值卡项目
经手人职务佣金
提成员工配置
IF OBJECT_ID(N'TB_TreatSavingCardProjectH
andlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardProjectH
andlerJobTypeCommission];
GO
CREATE TABLE [TB_TreatSavingCardProjectH
andlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardProjectH
andlerJobTypeCommission] PRIMARY KEY ([EntityID],[ProjectID],[SavingCardProjectTr
eatHandlerID],[JobTypeID])
);
GO

-- 消耗所有储值卡
项目经手人佣金
提成员工配置
IF OBJECT_ID(N'TB_TreatSavingCardProjectSc
hemeHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardProjectSc
hemeHandlerCommission];
GO
CREATE TABLE [TB_TreatSavingCardProjectSc
hemeHandlerCommission] (
    [EntityID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardProjectSc
hemeHandlerCommission] PRIMARY KEY ([EntityID],[SavingCardProjectTr
eatHandlerID])
);
GO

-- 消耗所有储值卡
项目经手人职务
佣金提成员工配
IF OBJECT_ID(N'TB_TreatSavingCardProjectSc
hemeHandlerJobTypeCommi
ssion', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardProjectSc
hemeHandlerJobTypeCommi
ssion];
GO
CREATE TABLE [TB_TreatSavingCardProjectSc
hemeHandlerJobTypeCommi
ssion] (
    [EntityID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardProjectSc
hemeHandlerJobTypeCommi
ssion] PRIMARY KEY ([EntityID],[SavingCardProjectTr
eatHandlerID],[JobTypeID])
);
GO

-- 消耗所有储值卡
项目经手人佣金
提成员工配置
IF OBJECT_ID(N'TB_TreatSavingCardSchemeH
andlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardSchemeH
andlerCommission];
GO
CREATE TABLE [TB_TreatSavingCardSchemeH
andlerCommission] (
    [EntityID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardSchemeH
andlerCommission] PRIMARY KEY ([EntityID],[SavingCardProjectTr
eatHandlerID])
);
GO

-- 消耗所有储值卡
项目经手人职务
佣金提成员工配
IF OBJECT_ID(N'TB_TreatSavingCardSchemeH
andlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardSchemeH
andlerJobTypeCommission];
GO
CREATE TABLE [TB_TreatSavingCardSchemeH
andlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardSchemeH
andlerJobTypeCommission] PRIMARY KEY ([EntityID],[SavingCardProjectTr
eatHandlerID],[JobTypeID])
);
GO

-- 消耗所有储值卡
项目经手人职务
业绩员工配置
IF OBJECT_ID(N'TB_TreatSavingCardSchemeH
andlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardSchemeH
andlerJobTypePerformance];
GO
CREATE TABLE [TB_TreatSavingCardSchemeH
andlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardSchemeH
andlerJobTypePerformance] PRIMARY KEY ([EntityID],[SavingCardProjectTr
eatHandlerID],[JobTypeID])
);
GO

-- 消耗所有储值卡
项目经手人业绩
员工配置
IF OBJECT_ID(N'TB_TreatSavingCardSchemeH
andlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatSavingCardSchemeH
andlerPerformance];
GO
CREATE TABLE [TB_TreatSavingCardSchemeH
andlerPerformance] (
    [EntityID] int NOT NULL,
    [SavingCardProjectTr
eatHandlerID] int NOT NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatSavingCardSchemeH
andlerPerformance] PRIMARY KEY ([EntityID],[SavingCardProjectTr
eatHandlerID])
);
GO

-- 消耗时效卡分类
佣金提成员工配
IF OBJECT_ID(N'TB_TreatTimeCardCategoryC
ommission', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardCategoryC
ommission];
GO
CREATE TABLE [TB_TreatTimeCardCategoryC
ommission] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardCategoryC
ommission] PRIMARY KEY ([EntityID],[TimeCardCategoryID])
);
GO

-- 消耗时效卡分类
业绩门店配置
IF OBJECT_ID(N'TB_TreatTimeCardCategoryE
ntityPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardCategoryE
ntityPerformance];
GO
CREATE TABLE [TB_TreatTimeCardCategoryE
ntityPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardCategoryE
ntityPerformance] PRIMARY KEY ([EntityID],[TimeCardCategoryID])
);
GO

-- 消耗时效卡分类
经手人佣金提成
员工配置
IF OBJECT_ID(N'TB_TreatTimeCardCategoryH
andlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardCategoryH
andlerCommission];
GO
CREATE TABLE [TB_TreatTimeCardCategoryH
andlerCommission] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [TimeCardProjectTrea
tHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardCategoryH
andlerCommission] PRIMARY KEY ([EntityID],[TimeCardCategoryID],[TimeCardProjectTrea
tHandlerID])
);
GO

-- 消耗时效卡分类
经手人职务佣金
提成员工配置
IF OBJECT_ID(N'TB_TreatTimeCardCategoryH
andlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardCategoryH
andlerJobTypeCommission];
GO
CREATE TABLE [TB_TreatTimeCardCategoryH
andlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [TimeCardProjectTrea
tHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardCategoryH
andlerJobTypeCommission] PRIMARY KEY ([EntityID],[TimeCardCategoryID],[TimeCardProjectTrea
tHandlerID],[JobTypeID])
);
GO

-- 消耗时效卡分类
经手人职务业绩
员工配置
IF OBJECT_ID(N'TB_TreatTimeCardCategoryH
andlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardCategoryH
andlerJobTypePerformance];
GO
CREATE TABLE [TB_TreatTimeCardCategoryH
andlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [TimeCardProjectTrea
tHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardCategoryH
andlerJobTypePerformance] PRIMARY KEY ([EntityID],[TimeCardCategoryID],[TimeCardProjectTrea
tHandlerID],[JobTypeID])
);
GO

-- 消耗时效卡分类
经手人业绩员工
IF OBJECT_ID(N'TB_TreatTimeCardCategoryH
andlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardCategoryH
andlerPerformance];
GO
CREATE TABLE [TB_TreatTimeCardCategoryH
andlerPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [TimeCardProjectTrea
tHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardCategoryH
andlerPerformance] PRIMARY KEY ([EntityID],[TimeCardCategoryID],[TimeCardProjectTrea
tHandlerID])
);
GO

-- 消耗时效卡分类
业绩员工配置
IF OBJECT_ID(N'TB_TreatTimeCardCategoryP
erformance', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardCategoryP
erformance];
GO
CREATE TABLE [TB_TreatTimeCardCategoryP
erformance] (
    [EntityID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardCategoryP
erformance] PRIMARY KEY ([EntityID],[TimeCardCategoryID])
);
GO

-- 消耗时效卡佣金
提成员工配置
IF OBJECT_ID(N'TB_TreatTimeCardCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardCommission];
GO
CREATE TABLE [TB_TreatTimeCardCommission] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardCommission] PRIMARY KEY ([EntityID],[TimeCardID])
);
GO

-- 消耗时效卡业绩
门店配置
IF OBJECT_ID(N'TB_TreatTimeCardEntityPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardEntityPerformance];
GO
CREATE TABLE [TB_TreatTimeCardEntityPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardEntityPerformance] PRIMARY KEY ([EntityID],[TimeCardID])
);
GO

-- 消耗时效卡业绩
门店配置方案
IF OBJECT_ID(N'TB_TreatTimeCardEntityPerfo
rmanceScheme', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardEntityPerfo
rmanceScheme];
GO
CREATE TABLE [TB_TreatTimeCardEntityPerfo
rmanceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardEntityPerfo
rmanceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 消耗时效卡经手
人佣金提成员工
IF OBJECT_ID(N'TB_TreatTimeCardHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardHandlerCommission];
GO
CREATE TABLE [TB_TreatTimeCardHandlerCommission] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [TimeCardProjectTrea
tHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardHandlerCommission] PRIMARY KEY ([EntityID],[TimeCardID],[TimeCardProjectTrea
tHandlerID])
);
GO

-- 消耗时效卡经手
人职务佣金提成
员工配置
IF OBJECT_ID(N'TB_TreatTimeCardHandlerJo
bTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardHandlerJo
bTypeCommission];
GO
CREATE TABLE [TB_TreatTimeCardHandlerJo
bTypeCommission] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [TimeCardProjectTrea
tHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardHandlerJo
bTypeCommission] PRIMARY KEY ([EntityID],[TimeCardID],[TimeCardProjectTrea
tHandlerID],[JobTypeID])
);
GO

-- 消耗时效卡经手
人职务业绩员工
IF OBJECT_ID(N'TB_TreatTimeCardHandlerJo
bTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardHandlerJo
bTypePerformance];
GO
CREATE TABLE [TB_TreatTimeCardHandlerJo
bTypePerformance] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [TimeCardProjectTrea
tHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardHandlerJo
bTypePerformance] PRIMARY KEY ([EntityID],[TimeCardID],[TimeCardProjectTrea
tHandlerID],[JobTypeID])
);
GO

-- 消耗时效经手人
业绩员工配置
IF OBJECT_ID(N'TB_TreatTimeCardHandlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardHandlerPerformance];
GO
CREATE TABLE [TB_TreatTimeCardHandlerPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [TimeCardProjectTrea
tHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardHandlerPerformance] PRIMARY KEY ([EntityID],[TimeCardID],[TimeCardProjectTrea
tHandlerID])
);
GO

-- 消耗时效卡业绩
员工配置
IF OBJECT_ID(N'TB_TreatTimeCardPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardPerformance];
GO
CREATE TABLE [TB_TreatTimeCardPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardPerformance] PRIMARY KEY ([EntityID],[TimeCardID])
);
GO

-- 消耗时效卡业绩
员工配置方案
IF OBJECT_ID(N'TB_TreatTimeCardPerformanceScheme', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardPerformanceScheme];
GO
CREATE TABLE [TB_TreatTimeCardPerformanceScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardPerformanceScheme] PRIMARY KEY ([EntityID])
);
GO

-- 消耗时效卡项目
佣金提成员工配
IF OBJECT_ID(N'TB_TreatTimeCardProjectCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardProjectCommission];
GO
CREATE TABLE [TB_TreatTimeCardProjectCommission] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardProjectCommission] PRIMARY KEY ([EntityID],[TimeCardID],[ProjectID])
);
GO

-- 消耗时效卡项目
佣金提成员工配
置方案
IF OBJECT_ID(N'TB_TreatTimeCardProjectCo
mmissionScheme', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardProjectCo
mmissionScheme];
GO
CREATE TABLE [TB_TreatTimeCardProjectCo
mmissionScheme] (
    [EntityID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardProjectCo
mmissionScheme] PRIMARY KEY ([EntityID])
);
GO

-- 消耗时效卡项目
业绩门店配置
IF OBJECT_ID(N'TB_TreatTimeCardProjectEnti
tyPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardProjectEnti
tyPerformance];
GO
CREATE TABLE [TB_TreatTimeCardProjectEnti
tyPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardProjectEnti
tyPerformance] PRIMARY KEY ([EntityID],[TimeCardID],[ProjectID])
);
GO

-- 消耗时效卡项目
经手人佣金提成
员工配置
IF OBJECT_ID(N'TB_TreatTimeCardProjectHan
dlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardProjectHan
dlerCommission];
GO
CREATE TABLE [TB_TreatTimeCardProjectHan
dlerCommission] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [TimeCardProjectTrea
tHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardProjectHan
dlerCommission] PRIMARY KEY ([EntityID],[TimeCardID],[ProjectID],[TimeCardProjectTrea
tHandlerID])
);
GO

-- 消耗时效卡项目
经手人职务佣金
提成员工配置
IF OBJECT_ID(N'TB_TreatTimeCardProjectHan
dlerJobTypeCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardProjectHan
dlerJobTypeCommission];
GO
CREATE TABLE [TB_TreatTimeCardProjectHan
dlerJobTypeCommission] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [TimeCardProjectTrea
tHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardProjectHan
dlerJobTypeCommission] PRIMARY KEY ([EntityID],[TimeCardID],[ProjectID],[TimeCardProjectTrea
tHandlerID],[JobTypeID])
);
GO

-- 消耗时效卡项目
经手人职务业绩
员工配置
IF OBJECT_ID(N'TB_TreatTimeCardProjectHan
dlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardProjectHan
dlerJobTypePerformance];
GO
CREATE TABLE [TB_TreatTimeCardProjectHan
dlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [TimeCardProjectTrea
tHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardProjectHan
dlerJobTypePerformance] PRIMARY KEY ([EntityID],[TimeCardID],[ProjectID],[TimeCardProjectTrea
tHandlerID],[JobTypeID])
);
GO

-- 消耗时效卡项目
经手人业绩员工
IF OBJECT_ID(N'TB_TreatTimeCardProjectHan
dlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardProjectHan
dlerPerformance];
GO
CREATE TABLE [TB_TreatTimeCardProjectHan
dlerPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [TimeCardProjectTrea
tHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardProjectHan
dlerPerformance] PRIMARY KEY ([EntityID],[TimeCardID],[ProjectID],[TimeCardProjectTrea
tHandlerID])
);
GO

-- 消耗时效卡项目
业绩员工配置
IF OBJECT_ID(N'TB_TreatTimeCardProjectPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardProjectPerformance];
GO
CREATE TABLE [TB_TreatTimeCardProjectPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardProjectPerformance] PRIMARY KEY ([EntityID],[TimeCardID],[ProjectID])
);
GO

-- 消耗所有时效卡
项目经手人佣金
提成员工配置
IF OBJECT_ID(N'TB_TreatTimeCardProjectSch
emeHandlerCommission', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardProjectSch
emeHandlerCommission];
GO
CREATE TABLE [TB_TreatTimeCardProjectSch
emeHandlerCommission] (
    [EntityID] int NOT NULL,
    [TimeCardProjectTrea
tHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardProjectSch
emeHandlerCommission] PRIMARY KEY ([EntityID],[TimeCardProjectTrea
tHandlerID])
);
GO

-- 消耗所有时效卡
项目经手人职务
佣金提成员工配
IF OBJECT_ID(N'TB_TreatTimeCardProjectSch
emeHandlerJobTypeCommis
sion', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardProjectSch
emeHandlerJobTypeCommis
sion];
GO
CREATE TABLE [TB_TreatTimeCardProjectSch
emeHandlerJobTypeCommis
sion] (
    [EntityID] int NOT NULL,
    [TimeCardProjectTrea
tHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [PayFixed] decimal(18,2) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardFixed] decimal(18,2) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [CardLargessFixed] decimal(18,2) NULL,
    [LargessRate] decimal(5,4) NULL,
    [LargessFixed] decimal(18,2) NULL,
    [SpecialBenefit] decimal(18,2) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardProjectSch
emeHandlerJobTypeCommis
sion] PRIMARY KEY ([EntityID],[TimeCardProjectTrea
tHandlerID],[JobTypeID])
);
GO

-- 消耗所有时效卡
项目经手人职务
业绩员工配置
IF OBJECT_ID(N'TB_TreatTimeCardSchemeHa
ndlerJobTypePerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardSchemeHa
ndlerJobTypePerformance];
GO
CREATE TABLE [TB_TreatTimeCardSchemeHa
ndlerJobTypePerformance] (
    [EntityID] int NOT NULL,
    [TimeCardProjectTrea
tHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardSchemeHa
ndlerJobTypePerformance] PRIMARY KEY ([EntityID],[TimeCardProjectTrea
tHandlerID],[JobTypeID])
);
GO

-- 消耗所有时效卡
项目经手人业绩
员工配置
IF OBJECT_ID(N'TB_TreatTimeCardSchemeHa
ndlerPerformance', N'U') IS NOT NULL DROP TABLE [TB_TreatTimeCardSchemeHa
ndlerPerformance];
GO
CREATE TABLE [TB_TreatTimeCardSchemeHa
ndlerPerformance] (
    [EntityID] int NOT NULL,
    [TimeCardProjectTrea
tHandlerID] int NOT NULL,
    [PayRate] decimal(5,4) NULL,
    [CardRate] decimal(5,4) NULL,
    [CardLargessRate] decimal(5,4) NULL,
    [LargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TB_TreatTimeCardSchemeHa
ndlerPerformance] PRIMARY KEY ([EntityID],[TimeCardProjectTrea
tHandlerID])
);
GO

-- 营销云预约订单
IF OBJECT_ID(N'TB_YingXiaoYunAppointment
Bill', N'U') IS NOT NULL DROP TABLE [TB_YingXiaoYunAppointment
Bill];
GO
CREATE TABLE [TB_YingXiaoYunAppointment
Bill] (
    [ID] nvarchar(50) NOT NULL,
    [YinXiaoYunID] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TB_YingXiaoYunAppointment
Bill] PRIMARY KEY ([ID])
);
GO

-- 营销云顾客
IF OBJECT_ID(N'TB_YingXiaoYunCustomer', N'U') IS NOT NULL DROP TABLE [TB_YingXiaoYunCustomer];
GO
CREATE TABLE [TB_YingXiaoYunCustomer] (
    [PhoneNumber] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TB_YingXiaoYunCustomer] PRIMARY KEY ([PhoneNumber])
);
GO

-- 营销云顾客标签
IF OBJECT_ID(N'TB_YingXiaoYunCustomerTa', N'U') IS NOT NULL DROP TABLE [TB_YingXiaoYunCustomerTa];
GO
CREATE TABLE [TB_YingXiaoYunCustomerTa] (
    [PhoneNumber] nvarchar(50) NOT NULL,
    [Label] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    CONSTRAINT [PK_TB_YingXiaoYunCustomerTa] PRIMARY KEY ([PhoneNumber],[Label])
);
GO

-- 营销云跟进记录
IF OBJECT_ID(N'TB_YingXiaoYunFollowUpRecord', N'U') IS NOT NULL DROP TABLE [TB_YingXiaoYunFollowUpRecord];
GO
CREATE TABLE [TB_YingXiaoYunFollowUpRecord] (
    [ID] nvarchar(50) NOT NULL,
    [PhoneNumber] nvarchar(50) NOT NULL,
    [Subject] nvarchar(50) NOT NULL,
    [FollowUpContent] text NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [FollowUpTime] datetime NOT NULL,
    [FollowUpBy] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TB_YingXiaoYunFollowUpRecord] PRIMARY KEY ([ID])
);
GO

-- 营销云跟进记录
附件
IF OBJECT_ID(N'TB_YingXiaoYunFollowUpRec
ordAttachment', N'U') IS NOT NULL DROP TABLE [TB_YingXiaoYunFollowUpRec
ordAttachment];
GO
CREATE TABLE [TB_YingXiaoYunFollowUpRec
ordAttachment] (
    [ID] int NOT NULL,
    [FollowUpRecordID] nvarchar(50) NOT NULL,
    [AttachmentURL] nvarchar(500) NOT NULL,
    CONSTRAINT [PK_TB_YingXiaoYunFollowUpRec
ordAttachment] PRIMARY KEY ([ID])
);
GO

-- 
IF OBJECT_ID(N'TB_YingXiaoYunTenant', N'U') IS NOT NULL DROP TABLE [TB_YingXiaoYunTenant];
GO
CREATE TABLE [TB_YingXiaoYunTenant] (
    [TenantID] nvarchar(50) NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TB_YingXiaoYunTenant] PRIMARY KEY ([TenantID])
);
GO

-- 库存调拨申请单
IF OBJECT_ID(N'TE_InventoryAllocationApply', N'U') IS NOT NULL DROP TABLE [TE_InventoryAllocationApply];
GO
CREATE TABLE [TE_InventoryAllocationApply] (
    [ID] nvarchar(50) NOT NULL,
    [BillStatus] nvarchar(2) NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [ApprovedBy] nvarchar(50) NULL,
    [ApprovedOn] datetime NULL,
    [Remark] nvarchar(200) NULL,
    [RejectReason] nvarchar(200) NULL,
    [InboundBillID] nvarchar(50) NULL,
    [InboundEntityID] int NOT NULL,
    [OutboundBillID] nvarchar(50) NULL,
    [OutboundEntityID] int NULL,
    CONSTRAINT [PK_TE_InventoryAllocationApply] PRIMARY KEY ([ID])
);
GO

-- 库存调拨申请单
明细
IF OBJECT_ID(N'TE_InventoryAllocationApply
Detail', N'U') IS NOT NULL DROP TABLE [TE_InventoryAllocationApply
Detail];
GO
CREATE TABLE [TE_InventoryAllocationApply
Detail] (
    [ID] int NOT NULL,
    [InventoryAllocationApplyID] nvarchar(50) NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [ApplyQuantity] int NOT NULL,
    [InboundQuantity] int NULL,
    [OutboundQuantity] int NULL,
    [MinimumUnitID] int NOT NULL,
    [ApplyMinimumUnit
Quantity] int NOT NULL,
    [InboundMinimumUnitQuantity] int NULL,
    [OutboundMinimum
UnitQuantity] int NULL,
    CONSTRAINT [PK_TE_InventoryAllocationApply
Detail] PRIMARY KEY ([ID])
);
GO

-- 库存调拨入库单
IF OBJECT_ID(N'TE_InventoryAllocationInbound', N'U') IS NOT NULL DROP TABLE [TE_InventoryAllocationInbound];
GO
CREATE TABLE [TE_InventoryAllocationInbound] (
    [ID] nvarchar(50) NOT NULL,
    [InDate] datetime NOT NULL,
    [EntityID] int NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TE_InventoryAllocationInbound] PRIMARY KEY ([ID])
);
GO

-- 库存调拨入库单
明细
IF OBJECT_ID(N'TE_InventoryAllocationInboundDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryAllocationInboundDetail];
GO
CREATE TABLE [TE_InventoryAllocationInboundDetail] (
    [ID] int NOT NULL,
    [InboundBillID] nvarchar(50) NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [Quantity] int NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryAllocationInboundDetail] PRIMARY KEY ([ID])
);
GO

-- 库存调拨出库单
IF OBJECT_ID(N'TE_InventoryAllocationOutbound', N'U') IS NOT NULL DROP TABLE [TE_InventoryAllocationOutbound];
GO
CREATE TABLE [TE_InventoryAllocationOutbound] (
    [ID] nvarchar(50) NOT NULL,
    [OutDate] datetime NOT NULL,
    [EntityID] int NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TE_InventoryAllocationOutbound] PRIMARY KEY ([ID])
);
GO

-- 库存调拨出库单
明细
IF OBJECT_ID(N'TE_InventoryAllocationOutboundDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryAllocationOutboundDetail];
GO
CREATE TABLE [TE_InventoryAllocationOutboundDetail] (
    [ID] int NOT NULL,
    [OutboundBillID] nvarchar(50) NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [Quantity] int NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryAllocationOutboundDetail] PRIMARY KEY ([ID])
);
GO

-- 门店要货单
IF OBJECT_ID(N'TE_InventoryApply', N'U') IS NOT NULL DROP TABLE [TE_InventoryApply];
GO
CREATE TABLE [TE_InventoryApply] (
    [ID] nvarchar(50) NOT NULL,
    [BillStatus] nvarchar(2) NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [SettlementWay] nvarchar(50) NULL,
    [ApprovedBy] nvarchar(50) NULL,
    [ApprovedOn] datetime NULL,
    [DelivererBy] nvarchar(50) NULL,
    [DelivererOn] datetime NULL,
    [InboundBy] nvarchar(50) NULL,
    [InboundOn] datetime NULL,
    [Remark] nvarchar(200) NULL,
    [ApprovalRemark] nvarchar(200) NULL,
    [RejectReason] nvarchar(200) NULL,
    [ApprovedTotalAmount] decimal(18,2) NULL,
    [InboundBillID] nvarchar(50) NULL,
    [InboundEntityID] int NOT NULL,
    [InboundTotalAmoun] decimal(18,2) NULL,
    [OutboundBillID] nvarchar(50) NULL,
    [OutboundEntityID] int NULL,
    [OutboundTotalAmount] decimal(18,2) NULL,
    CONSTRAINT [PK_TE_InventoryApply] PRIMARY KEY ([ID])
);
GO

-- 门店要货单明细
IF OBJECT_ID(N'TE_InventoryApplyDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryApplyDetail];
GO
CREATE TABLE [TE_InventoryApplyDetail] (
    [ID] int NOT NULL,
    [InventoryApplyID] nvarchar(50) NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [ApplyQuantity] int NOT NULL,
    [ApproveQuantity] int NULL,
    [ApprovedPrice] decimal(18,2) NULL,
    [ApprovedTotalAmount] decimal(18,2) NULL,
    [InboundQuantity] int NULL,
    [InboundPrice] decimal(18,2) NULL,
    [InboundTotalAmoun] decimal(18,2) NULL,
    [OutboundQuantity] int NULL,
    [OutboundPrice] decimal(18,2) NULL,
    [OutboundTotalAmount] decimal(18,2) NULL,
    [MinimumUnitID] int NOT NULL,
    [ApplyMinimumUnit
Quantity] int NULL,
    [ApproveMinimumU
nitQuantity] int NULL,
    [InboundMinimumUnitQuantity] int NULL,
    [OutboundMinimum
UnitQuantity] int NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TE_InventoryApplyDetail] PRIMARY KEY ([ID])
);
GO

-- 库存盘点
IF OBJECT_ID(N'TE_InventoryCheck', N'U') IS NOT NULL DROP TABLE [TE_InventoryCheck];
GO
CREATE TABLE [TE_InventoryCheck] (
    [ID] nvarchar(50) NOT NULL,
    [BillStatus] nvarchar(2) NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [Remark] nvarchar(200) NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryCheck] PRIMARY KEY ([ID])
);
GO

-- 库存盘点明细
IF OBJECT_ID(N'TE_InventoryCheckDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryCheckDetail];
GO
CREATE TABLE [TE_InventoryCheckDetail] (
    [ID] int NOT NULL,
    [InventoryCheckID] nvarchar(50) NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [StockQuantity] int NOT NULL,
    [BeforeStockQuantity] int NOT NULL,
    [Quantity] int NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TE_InventoryCheckDetail] PRIMARY KEY ([ID])
);
GO

-- 门店要货入库单
IF OBJECT_ID(N'TE_InventoryInbound', N'U') IS NOT NULL DROP TABLE [TE_InventoryInbound];
GO
CREATE TABLE [TE_InventoryInbound] (
    [ID] nvarchar(50) NOT NULL,
    [InDate] datetime NOT NULL,
    [EntityID] int NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TE_InventoryInbound] PRIMARY KEY ([ID])
);
GO

-- 门店要货入库单
明细
IF OBJECT_ID(N'TE_InventoryInboundDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryInboundDetail];
GO
CREATE TABLE [TE_InventoryInboundDetail] (
    [ID] int NOT NULL,
    [InboundBillID] nvarchar(50) NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [Quantity] int NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryInboundDetail] PRIMARY KEY ([ID])
);
GO

-- 门店要货出库单
IF OBJECT_ID(N'TE_InventoryOutbound', N'U') IS NOT NULL DROP TABLE [TE_InventoryOutbound];
GO
CREATE TABLE [TE_InventoryOutbound] (
    [ID] nvarchar(50) NOT NULL,
    [OutDate] datetime NOT NULL,
    [EntityID] int NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TE_InventoryOutbound] PRIMARY KEY ([ID])
);
GO

-- 门店要货出库单
明细
IF OBJECT_ID(N'TE_InventoryOutboundDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryOutboundDetail];
GO
CREATE TABLE [TE_InventoryOutboundDetail] (
    [ID] int NOT NULL,
    [OutboundBillID] nvarchar(50) NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [Quantity] int NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryOutboundDetail] PRIMARY KEY ([ID])
);
GO

-- 产品入库单
IF OBJECT_ID(N'TE_InventoryProductInbound', N'U') IS NOT NULL DROP TABLE [TE_InventoryProductInbound];
GO
CREATE TABLE [TE_InventoryProductInbound] (
    [ID] nvarchar(50) NOT NULL,
    [InDate] datetime NOT NULL,
    [InType] nvarchar(2) NOT NULL,
    [EntityID] int NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TE_InventoryProductInbound] PRIMARY KEY ([ID])
);
GO

-- 产品入库单明细
IF OBJECT_ID(N'TE_InventoryProductInbound
Detail', N'U') IS NOT NULL DROP TABLE [TE_InventoryProductInbound
Detail];
GO
CREATE TABLE [TE_InventoryProductInbound
Detail] (
    [ID] int NOT NULL,
    [InboundBillID] nvarchar(50) NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [Quantity] int NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryProductInbound
Detail] PRIMARY KEY ([ID])
);
GO

-- 产品出库单
IF OBJECT_ID(N'TE_InventoryProductOutbou', N'U') IS NOT NULL DROP TABLE [TE_InventoryProductOutbou];
GO
CREATE TABLE [TE_InventoryProductOutbou] (
    [ID] nvarchar(50) NOT NULL,
    [OutDate] datetime NOT NULL,
    [OutType] nvarchar(2) NOT NULL,
    [EntityID] int NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TE_InventoryProductOutbou] PRIMARY KEY ([ID])
);
GO

-- 产品出库单明细
IF OBJECT_ID(N'TE_InventoryProductOutboundDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryProductOutboundDetail];
GO
CREATE TABLE [TE_InventoryProductOutboundDetail] (
    [ID] int NOT NULL,
    [OutboundBillID] nvarchar(50) NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [Quantity] int NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryProductOutboundDetail] PRIMARY KEY ([ID])
);
GO

-- 门店退货单
IF OBJECT_ID(N'TE_InventoryRefund', N'U') IS NOT NULL DROP TABLE [TE_InventoryRefund];
GO
CREATE TABLE [TE_InventoryRefund] (
    [ID] nvarchar(50) NOT NULL,
    [BillStatus] nvarchar(2) NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [SettlementWay] nvarchar(50) NULL,
    [ApprovedBy] nvarchar(50) NULL,
    [ApprovedOn] datetime NULL,
    [RefundOutboundBy] nvarchar(50) NULL,
    [RefundOutboundOn] datetime NULL,
    [RefundInboundBy] nvarchar(50) NULL,
    [RefundInboundOn] datetime NULL,
    [Remark] nvarchar(200) NULL,
    [RejectReason] nvarchar(200) NULL,
    [ApprovedTotalAmount] decimal(18,2) NULL,
    [RefundOutboundBill
ID] nvarchar(50) NULL,
    [RefundOutboundEntityID] int NOT NULL,
    [RefundOutboundTotalAmount] decimal(18,2) NULL,
    [RefundInboundBillID] nvarchar(50) NULL,
    [RefundInboundEntityID] int NULL,
    [RefundInboundTotal
Amount] decimal(18,2) NULL,
    CONSTRAINT [PK_TE_InventoryRefund] PRIMARY KEY ([ID])
);
GO

-- 门店退货单明细
IF OBJECT_ID(N'TE_InventoryRefundDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryRefundDetail];
GO
CREATE TABLE [TE_InventoryRefundDetail] (
    [ID] int NOT NULL,
    [InventoryRefundID] nvarchar(50) NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [RefundQuantity] int NOT NULL,
    [ApproveQuantity] int NULL,
    [ApprovedPrice] decimal(18,2) NULL,
    [ApprovedTotalAmount] decimal(18,2) NULL,
    [RefundOutboundQuantity] int NULL,
    [RefundOutboundPrice] decimal(18,2) NULL,
    [RefundOutboundTotalAmount] decimal(18,2) NULL,
    [RefundInboundQuantity] int NULL,
    [RefundInboundPrice] decimal(18,2) NULL,
    [RefundInboundTotal
Amount] decimal(18,2) NULL,
    [MinimumUnitID] int NOT NULL,
    [RefundMinimumUnit
Quantity] int NULL,
    [ApproveMinimumU
nitQuantity] int NULL,
    [RefundOutboundMi
nimumUnitQuantity] int NULL,
    [RefundInboundMini
mumUnitQuantity] int NULL,
    CONSTRAINT [PK_TE_InventoryRefundDetail] PRIMARY KEY ([ID])
);
GO

-- 门店退货单入库
IF OBJECT_ID(N'TE_InventoryRefundInbound', N'U') IS NOT NULL DROP TABLE [TE_InventoryRefundInbound];
GO
CREATE TABLE [TE_InventoryRefundInbound] (
    [ID] nvarchar(50) NOT NULL,
    [InDate] datetime NOT NULL,
    [EntityID] int NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TE_InventoryRefundInbound] PRIMARY KEY ([ID])
);
GO

-- 门店退货单明细
IF OBJECT_ID(N'TE_InventoryRefundInbound
Detail', N'U') IS NOT NULL DROP TABLE [TE_InventoryRefundInbound
Detail];
GO
CREATE TABLE [TE_InventoryRefundInbound
Detail] (
    [ID] int NOT NULL,
    [RefundInboundBillID] nvarchar(50) NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [Quantity] int NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryRefundInbound
Detail] PRIMARY KEY ([ID])
);
GO

-- 门店退货单出库
IF OBJECT_ID(N'TE_InventoryRefundOutboun', N'U') IS NOT NULL DROP TABLE [TE_InventoryRefundOutboun];
GO
CREATE TABLE [TE_InventoryRefundOutboun] (
    [ID] nvarchar(50) NOT NULL,
    [OutDate] datetime NOT NULL,
    [EntityID] int NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TE_InventoryRefundOutboun] PRIMARY KEY ([ID])
);
GO

-- 门店退货单出库
明细
IF OBJECT_ID(N'TE_InventoryRefundOutboundDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryRefundOutboundDetail];
GO
CREATE TABLE [TE_InventoryRefundOutboundDetail] (
    [ID] int NOT NULL,
    [RefundOutboundBill
ID] nvarchar(50) NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [Quantity] int NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryRefundOutboundDetail] PRIMARY KEY ([ID])
);
GO

-- 取消通用次卡库
存入库明细
IF OBJECT_ID(N'TE_InventoryTreatCancelGen
eralCardInboundDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryTreatCancelGen
eralCardInboundDetail];
GO
CREATE TABLE [TE_InventoryTreatCancelGen
eralCardInboundDetail] (
    [ID] int NOT NULL,
    [InventoryTreatCance
lInboundID] nvarchar(50) NOT NULL,
    [TreatBillGeneralCard
ID] int NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [Quantity] int NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryTreatCancelGen
eralCardInboundDetail] PRIMARY KEY ([ID])
);
GO

-- 消耗取消库存入库
IF OBJECT_ID(N'TE_InventoryTreatCancelInbound', N'U') IS NOT NULL DROP TABLE [TE_InventoryTreatCancelInbound];
GO
CREATE TABLE [TE_InventoryTreatCancelInbound] (
    [ID] nvarchar(50) NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [InDate] datetime NOT NULL,
    [EntityID] int NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TE_InventoryTreatCancelInbound] PRIMARY KEY ([ID])
);
GO

-- 取消项目库存入库明细
IF OBJECT_ID(N'TE_InventoryTreatCancelProj
ectInboundDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryTreatCancelProj
ectInboundDetail];
GO
CREATE TABLE [TE_InventoryTreatCancelProj
ectInboundDetail] (
    [ID] int NOT NULL,
    [InventoryTreatCance
lInboundID] nvarchar(50) NOT NULL,
    [TreatBillProjectID] int NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [Quantity] int NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryTreatCancelProj
ectInboundDetail] PRIMARY KEY ([ID])
);
GO

-- 取消储值库存入库明细
IF OBJECT_ID(N'TE_InventoryTreatCancelSavi
ngCardInboundDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryTreatCancelSavi
ngCardInboundDetail];
GO
CREATE TABLE [TE_InventoryTreatCancelSavi
ngCardInboundDetail] (
    [ID] int NOT NULL,
    [InventoryTreatCance
lInboundID] nvarchar(50) NOT NULL,
    [TreatBillSavingCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [Quantity] int NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryTreatCancelSavi
ngCardInboundDetail] PRIMARY KEY ([ID])
);
GO

-- 取消时效卡库存
入库明细
IF OBJECT_ID(N'TE_InventoryTreatCancelTime
CardInboundDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryTreatCancelTime
CardInboundDetail];
GO
CREATE TABLE [TE_InventoryTreatCancelTime
CardInboundDetail] (
    [ID] int NOT NULL,
    [InventoryTreatCance
lInboundID] nvarchar(50) NOT NULL,
    [TreatBillTimeCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [Quantity] int NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryTreatCancelTime
CardInboundDetail] PRIMARY KEY ([ID])
);
GO

-- 取消通用次卡库
存入库明细
IF OBJECT_ID(N'TE_InventoryTreatGeneralCar
dOutboundDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryTreatGeneralCar
dOutboundDetail];
GO
CREATE TABLE [TE_InventoryTreatGeneralCar
dOutboundDetail] (
    [ID] int NOT NULL,
    [InventoryTreatOutboundID] nvarchar(50) NOT NULL,
    [TreatBillGeneralCard
ID] int NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [Quantity] int NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryTreatGeneralCar
dOutboundDetail] PRIMARY KEY ([ID])
);
GO

-- 消耗库存出库
IF OBJECT_ID(N'TE_InventoryTreatOutbound', N'U') IS NOT NULL DROP TABLE [TE_InventoryTreatOutbound];
GO
CREATE TABLE [TE_InventoryTreatOutbound] (
    [ID] nvarchar(50) NOT NULL,
    [TreatBillID] nvarchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    [OutDate] datetime NOT NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TE_InventoryTreatOutbound] PRIMARY KEY ([ID])
);
GO

-- 消耗项目库存出库
IF OBJECT_ID(N'TE_InventoryTreatProjectOut
boundDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryTreatProjectOut
boundDetail];
GO
CREATE TABLE [TE_InventoryTreatProjectOut
boundDetail] (
    [ID] int NOT NULL,
    [InventoryTreatOutboundID] nvarchar(50) NOT NULL,
    [TreatBillProjectID] int NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [Quantity] int NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryTreatProjectOut
boundDetail] PRIMARY KEY ([ID])
);
GO

-- 消耗储值卡库存
出库
IF OBJECT_ID(N'TE_InventoryTreatSavingCard
OutboundDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryTreatSavingCard
OutboundDetail];
GO
CREATE TABLE [TE_InventoryTreatSavingCard
OutboundDetail] (
    [ID] int NOT NULL,
    [InventoryTreatOutboundID] nvarchar(50) NOT NULL,
    [TreatBillSavingCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [Quantity] int NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryTreatSavingCard
OutboundDetail] PRIMARY KEY ([ID])
);
GO

-- 消耗时效卡库存
出库
IF OBJECT_ID(N'TE_InventoryTreatTimeCardO
utboundDetail', N'U') IS NOT NULL DROP TABLE [TE_InventoryTreatTimeCardO
utboundDetail];
GO
CREATE TABLE [TE_InventoryTreatTimeCardO
utboundDetail] (
    [ID] int NOT NULL,
    [InventoryTreatOutboundID] nvarchar(50) NOT NULL,
    [TreatBillTimeCardID] int NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [Quantity] int NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_InventoryTreatTimeCardO
utboundDetail] PRIMARY KEY ([ID])
);
GO

-- 收付款明细
IF OBJECT_ID(N'TE_PaymentBill', N'U') IS NOT NULL DROP TABLE [TE_PaymentBill];
GO
CREATE TABLE [TE_PaymentBill] (
    [ID] nvarchar(50) NOT NULL,
    [BillType] nvarchar(10) NOT NULL,
    [EntityID] int NOT NULL,
    [Balance] decimal(18,2) NOT NULL,
    [LargessBalance] decimal(18,2) NOT NULL,
    [PaymentWay] nvarchar(10) NOT NULL,
    [ReceiptNumber] nvarchar(50) NULL,
    [PaymentAccountName] nvarchar(50) NULL,
    [Remark] nvarchar(200) NULL,
    [SourceBillType] nvarchar(10) NULL,
    [SourceBillNo] nvarchar(50) NULL,
    [PaymentCategoryID] int NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NULL,
    CONSTRAINT [PK_TE_PaymentBill] PRIMARY KEY ([ID])
);
GO

-- 收付款类别
IF OBJECT_ID(N'TE_PaymentCategory', N'U') IS NOT NULL DROP TABLE [TE_PaymentCategory];
GO
CREATE TABLE [TE_PaymentCategory] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TE_PaymentCategory] PRIMARY KEY ([ID])
);
GO

-- 预付款管理
IF OBJECT_ID(N'TE_Prepay', N'U') IS NOT NULL DROP TABLE [TE_Prepay];
GO
CREATE TABLE [TE_Prepay] (
    [EntityID] int NOT NULL,
    [Balance] decimal(18,2) NOT NULL,
    [LargessBalance] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TE_Prepay] PRIMARY KEY ([EntityID])
);
GO

-- 产品资料
IF OBJECT_ID(N'TE_Product', N'U') IS NOT NULL DROP TABLE [TE_Product];
GO
CREATE TABLE [TE_Product] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [NameFullPinYin] nvarchar(200) NULL,
    [NameAbbrPinYin] nvarchar(50) NULL,
    [Alias] nvarchar(50) NULL,
    [AliasFullPinYin] nvarchar(200) NULL,
    [AliasAbbrPinYin] nvarchar(200) NULL,
    [PCategoryID] int NOT NULL,
    [Specification] nvarchar(100) NULL,
    [Active] bit NOT NULL,
    [ProductBrandID] int NULL,
    [Remark] nvarchar(200) NULL,
    [DeliveryPrice] decimal(18,2) NULL,
    CONSTRAINT [PK_TE_Product] PRIMARY KEY ([ID])
);
GO

-- 产品包装单位
IF OBJECT_ID(N'TE_ProductBarCode', N'U') IS NOT NULL DROP TABLE [TE_ProductBarCode];
GO
CREATE TABLE [TE_ProductBarCode] (
    [ID] int NOT NULL,
    [ProductID] int NOT NULL,
    [BarCode] nvarchar(50) NULL,
    [UnitID] int NOT NULL,
    [Amount] int NOT NULL,
    [IsMinimumUnit] bit NOT NULL,
    [IsDefautSendReceive] bit NOT NULL,
    CONSTRAINT [PK_TE_ProductBarCode] PRIMARY KEY ([ID])
);
GO

-- 产品品牌
IF OBJECT_ID(N'TE_ProductBrand', N'U') IS NOT NULL DROP TABLE [TE_ProductBrand];
GO
CREATE TABLE [TE_ProductBrand] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TE_ProductBrand] PRIMARY KEY ([ID])
);
GO

-- 产品分类
IF OBJECT_ID(N'TE_ProductCategory', N'U') IS NOT NULL DROP TABLE [TE_ProductCategory];
GO
CREATE TABLE [TE_ProductCategory] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    [ParentID] int NOT NULL,
    CONSTRAINT [PK_TE_ProductCategory] PRIMARY KEY ([ID])
);
GO

-- 产品分类配销价格
IF OBJECT_ID(N'TE_ProductCategoryDispatch
Price', N'U') IS NOT NULL DROP TABLE [TE_ProductCategoryDispatch
Price];
GO
CREATE TABLE [TE_ProductCategoryDispatch
Price] (
    [ProductDispatchPric
eSchemeID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [Discount] decimal(5,4) NULL,
    CONSTRAINT [PK_TE_ProductCategoryDispatch
Price] PRIMARY KEY ([ProductDispatchPric
eSchemeID],[ProductCategoryID])
);
GO

-- 产品配销价格
IF OBJECT_ID(N'TE_ProductDispatchPrice', N'U') IS NOT NULL DROP TABLE [TE_ProductDispatchPrice];
GO
CREATE TABLE [TE_ProductDispatchPrice] (
    [ProductDispatchPric
eSchemeID] int NOT NULL,
    [ProductID] int NOT NULL,
    [DispatchPrice] decimal(18,2) NULL,
    CONSTRAINT [PK_TE_ProductDispatchPrice] PRIMARY KEY ([ProductDispatchPric
eSchemeID],[ProductID])
);
GO

-- 配销价格方案
IF OBJECT_ID(N'TE_ProductDispatchPriceScheme', N'U') IS NOT NULL DROP TABLE [TE_ProductDispatchPriceScheme];
GO
CREATE TABLE [TE_ProductDispatchPriceScheme] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Discount] decimal(5,4) NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TE_ProductDispatchPriceScheme] PRIMARY KEY ([ID])
);
GO

-- 配销价格适用门店
IF OBJECT_ID(N'TE_ProductDispatchPriceSchemeEntity', N'U') IS NOT NULL DROP TABLE [TE_ProductDispatchPriceSchemeEntity];
GO
CREATE TABLE [TE_ProductDispatchPriceSchemeEntity] (
    [ProductDispatchPric
eSchemeID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TE_ProductDispatchPriceSchemeEntity] PRIMARY KEY ([ProductDispatchPric
eSchemeID],[EntityID])
);
GO

-- 采购退货订单
IF OBJECT_ID(N'TE_PurchaseRefund', N'U') IS NOT NULL DROP TABLE [TE_PurchaseRefund];
GO
CREATE TABLE [TE_PurchaseRefund] (
    [ID] nvarchar(50) NOT NULL,
    [OutDate] datetime NOT NULL,
    [EntityID] int NOT NULL,
    [SupplierID] int NULL,
    [Remark] nvarchar(200) NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TE_PurchaseRefund] PRIMARY KEY ([ID])
);
GO

-- 采购退货订单明
IF OBJECT_ID(N'TE_PurchaseRefundDetail', N'U') IS NOT NULL DROP TABLE [TE_PurchaseRefundDetail];
GO
CREATE TABLE [TE_PurchaseRefundDetail] (
    [ID] int NOT NULL,
    [PurchaseRefundID] nvarchar(50) NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [UnitPrice] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_PurchaseRefundDetail] PRIMARY KEY ([ID])
);
GO

-- 采购入库订单
IF OBJECT_ID(N'TE_PurchaseStorage', N'U') IS NOT NULL DROP TABLE [TE_PurchaseStorage];
GO
CREATE TABLE [TE_PurchaseStorage] (
    [ID] nvarchar(50) NOT NULL,
    [InDate] datetime NOT NULL,
    [EntityID] int NOT NULL,
    [SupplierID] int NULL,
    [Remark] nvarchar(200) NULL,
    [CreatedOn] datetime NOT NULL,
    [CreatedBy] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TE_PurchaseStorage] PRIMARY KEY ([ID])
);
GO

-- 采购入库明细
IF OBJECT_ID(N'TE_PurchaseStorageDetail', N'U') IS NOT NULL DROP TABLE [TE_PurchaseStorageDetail];
GO
CREATE TABLE [TE_PurchaseStorageDetail] (
    [ID] int NOT NULL,
    [PurchaseStorageID] nvarchar(50) NOT NULL,
    [ProductID] int NOT NULL,
    [UnitID] int NOT NULL,
    [UnitPrice] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [MinimumUnitID] int NOT NULL,
    [MinimumUnitQuantity] int NOT NULL,
    [StockQuantity] int NOT NULL,
    CONSTRAINT [PK_TE_PurchaseStorageDetail] PRIMARY KEY ([ID])
);
GO

-- 库存表
IF OBJECT_ID(N'TE_Stock', N'U') IS NOT NULL DROP TABLE [TE_Stock];
GO
CREATE TABLE [TE_Stock] (
    [EntityID] int NOT NULL,
    [ProductID] int NOT NULL,
    [Quantity] int NOT NULL,
    CONSTRAINT [PK_TE_Stock] PRIMARY KEY ([EntityID],[ProductID])
);
GO

-- 库存配置
IF OBJECT_ID(N'TE_StockConfig', N'U') IS NOT NULL DROP TABLE [TE_StockConfig];
GO
CREATE TABLE [TE_StockConfig] (
    [EntityID] int NOT NULL,
    [IsAllowNegativeOutbound] bit NOT NULL,
    CONSTRAINT [PK_TE_StockConfig] PRIMARY KEY ([EntityID])
);
GO

-- 供应商
IF OBJECT_ID(N'TE_Supplier', N'U') IS NOT NULL DROP TABLE [TE_Supplier];
GO
CREATE TABLE [TE_Supplier] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [ContactPersonName] nvarchar(50) NULL,
    [ContactPersonMobil] nvarchar(50) NULL,
    [SupplierTelePhone] nvarchar(50) NULL,
    [ProvinceCode] nvarchar(50) NULL,
    [CityCode] nvarchar(50) NULL,
    [AreaCode] nvarchar(50) NULL,
    [AddressDetail] nvarchar(100) NULL,
    [WeiXin] nvarchar(50) NULL,
    [Email] nvarchar(50) NULL,
    [Fax] nvarchar(50) NULL,
    [Remark] nvarchar(200) NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TE_Supplier] PRIMARY KEY ([ID])
);
GO

-- 包装单位
IF OBJECT_ID(N'TE_Unit', N'U') IS NOT NULL DROP TABLE [TE_Unit];
GO
CREATE TABLE [TE_Unit] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TE_Unit] PRIMARY KEY ([ID])
);
GO

-- 渠道提成方案配
IF OBJECT_ID(N'TK_ChannelCommission', N'U') IS NOT NULL DROP TABLE [TK_ChannelCommission];
GO
CREATE TABLE [TK_ChannelCommission] (
    [ID] int NOT NULL,
    [ChannelCommission
SchemeID] int NOT NULL,
    [BeginPerformance] int NOT NULL,
    [EndPerformance] int NOT NULL,
    [Rate] decimal(5,4) NOT NULL,
    [Fixed] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TK_ChannelCommission] PRIMARY KEY ([ID])
);
GO

-- 渠道提成方案适用渠道
IF OBJECT_ID(N'TK_ChannelCommissionRange', N'U') IS NOT NULL DROP TABLE [TK_ChannelCommissionRange];
GO
CREATE TABLE [TK_ChannelCommissionRange] (
    [ChannelCommission
SchemeID] int NOT NULL,
    [ChannelID] int NOT NULL,
    CONSTRAINT [PK_TK_ChannelCommissionRange] PRIMARY KEY ([ChannelCommission
SchemeID],[ChannelID])
);
GO

-- 渠道提成方案
IF OBJECT_ID(N'TK_ChannelCommissionScheme', N'U') IS NOT NULL DROP TABLE [TK_ChannelCommissionScheme];
GO
CREATE TABLE [TK_ChannelCommissionScheme] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [ChannelPerformance
SchemeID] int NOT NULL,
    [Calculation] nvarchar(50) NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TK_ChannelCommissionScheme] PRIMARY KEY ([ID])
);
GO

-- 市场提成方案配置
IF OBJECT_ID(N'TK_ChannelEmployeeCommission', N'U') IS NOT NULL DROP TABLE [TK_ChannelEmployeeCommission];
GO
CREATE TABLE [TK_ChannelEmployeeCommission] (
    [ID] int NOT NULL,
    [ChannelEmployeeCo
mmissionSchemeID] int NOT NULL,
    [BeginPerformance] int NOT NULL,
    [EndPerformance] int NOT NULL,
    [Rate] decimal(5,4) NOT NULL,
    [Fixed] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TK_ChannelEmployeeCommission] PRIMARY KEY ([ID])
);
GO

-- 市场提成方案适用职务
IF OBJECT_ID(N'TK_ChannelEmployeeCommi
ssionJobType', N'U') IS NOT NULL DROP TABLE [TK_ChannelEmployeeCommi
ssionJobType];
GO
CREATE TABLE [TK_ChannelEmployeeCommi
ssionJobType] (
    [ChannelEmployeeCo
mmissionSchemeID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TK_ChannelEmployeeCommi
ssionJobType] PRIMARY KEY ([ChannelEmployeeCo
mmissionSchemeID],[JobTypeID])
);
GO

-- 市场提成方案
IF OBJECT_ID(N'TK_ChannelEmployeeCommi
ssionScheme', N'U') IS NOT NULL DROP TABLE [TK_ChannelEmployeeCommi
ssionScheme];
GO
CREATE TABLE [TK_ChannelEmployeeCommi
ssionScheme] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [Calculation] nvarchar(50) NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TK_ChannelEmployeeCommi
ssionScheme] PRIMARY KEY ([ID])
);
GO

-- 市场业绩取值方案
IF OBJECT_ID(N'TK_ChannelEmployeePerfor
manceScheme', N'U') IS NOT NULL DROP TABLE [TK_ChannelEmployeePerfor
manceScheme];
GO
CREATE TABLE [TK_ChannelEmployeePerfor
manceScheme] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Active] bit NOT NULL,
    [IsCalculateChannelDeveloper] bit NOT NULL,
    [IsCalculateChannelConsultant] bit NOT NULL,
    CONSTRAINT [PK_TK_ChannelEmployeePerfor
manceScheme] PRIMARY KEY ([ID])
);
GO

-- 市场业绩结算单据
IF OBJECT_ID(N'TK_ChannelEmployeeSalary', N'U') IS NOT NULL DROP TABLE [TK_ChannelEmployeeSalary];
GO
CREATE TABLE [TK_ChannelEmployeeSalary] (
    [ChannelEmployeeSal
arySettlementInterva
lID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [ChannelEmployeePe
rformanceCommissi] decimal(18,2) NOT NULL,
    [ChannelEmployeeTe
amPerformanceCom
mission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TK_ChannelEmployeeSalary] PRIMARY KEY ([ChannelEmployeeSal
arySettlementInterva
lID],[EmployeeID])
);
GO

-- 市场业绩提成结算明细
IF OBJECT_ID(N'TK_ChannelEmployeeSalaryC
ommissionSchemeDetail', N'U') IS NOT NULL DROP TABLE [TK_ChannelEmployeeSalaryC
ommissionSchemeDetail];
GO
CREATE TABLE [TK_ChannelEmployeeSalaryC
ommissionSchemeDetail] (
    [EmployeeID] nvarchar(50) NOT NULL,
    [ChannelEmployeeSal
arySettlementInterva
lID] int NOT NULL,
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [ChannelEmployeeCo
mmissionSchemeID] int NOT NULL,
    [Performance] decimal(18,2) NOT NULL,
    [Commission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TK_ChannelEmployeeSalaryC
ommissionSchemeDetail] PRIMARY KEY ([EmployeeID],[ChannelEmployeeSal
arySettlementInterva
lID],[ChannelEmployeePe
rformanceSchemeID],[ChannelEmployeeCo
mmissionSchemeID])
);
GO

-- 市场业绩提成结
算周期设置
IF OBJECT_ID(N'TK_ChannelEmployeeSalaryS
ettlementInterval', N'U') IS NOT NULL DROP TABLE [TK_ChannelEmployeeSalaryS
ettlementInterval];
GO
CREATE TABLE [TK_ChannelEmployeeSalaryS
ettlementInterval] (
    [ID] int NOT NULL,
    [SettlementMonth] nvarchar(20) NOT NULL,
    [StartDate] date NOT NULL,
    [EndDate] date NOT NULL,
    CONSTRAINT [PK_TK_ChannelEmployeeSalaryS
ettlementInterval] PRIMARY KEY ([ID])
);
GO

-- 市场团队提成方案配置
IF OBJECT_ID(N'TK_ChannelEmployeeTeamC
ommission', N'U') IS NOT NULL DROP TABLE [TK_ChannelEmployeeTeamC
ommission];
GO
CREATE TABLE [TK_ChannelEmployeeTeamC
ommission] (
    [ID] int NOT NULL,
    [ChannelEmployeeTe
amCommissionSche
meID] int NOT NULL,
    [BeginPerformance] int NOT NULL,
    [EndPerformance] int NOT NULL,
    [Rate] decimal(5,4) NOT NULL,
    [Fixed] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TK_ChannelEmployeeTeamC
ommission] PRIMARY KEY ([ID])
);
GO

-- 市场团队提成方
案提成员工
IF OBJECT_ID(N'TK_ChannelEmployeeTeamC
ommissionEmployee', N'U') IS NOT NULL DROP TABLE [TK_ChannelEmployeeTeamC
ommissionEmployee];
GO
CREATE TABLE [TK_ChannelEmployeeTeamC
ommissionEmployee] (
    [ID] int NOT NULL,
    [ChannelEmployeeTe
amCommissionSche
meID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TK_ChannelEmployeeTeamC
ommissionEmployee] PRIMARY KEY ([ID])
);
GO

-- 市场团队提成方案
IF OBJECT_ID(N'TK_ChannelEmployeeTeamC
ommissionScheme', N'U') IS NOT NULL DROP TABLE [TK_ChannelEmployeeTeamC
ommissionScheme];
GO
CREATE TABLE [TK_ChannelEmployeeTeamC
ommissionScheme] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [Calculation] nvarchar(50) NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TK_ChannelEmployeeTeamC
ommissionScheme] PRIMARY KEY ([ID])
);
GO

-- 市场团队提成方
案团队员工
IF OBJECT_ID(N'TK_ChannelEmployeeTeamEmployee', N'U') IS NOT NULL DROP TABLE [TK_ChannelEmployeeTeamEmployee];
GO
CREATE TABLE [TK_ChannelEmployeeTeamEmployee] (
    [ID] int NOT NULL,
    [ChannelEmployeeTe
amCommissionSche
meID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TK_ChannelEmployeeTeamEmployee] PRIMARY KEY ([ID])
);
GO

-- 市场团队业绩提
成结算明细
IF OBJECT_ID(N'TK_ChannelEmployeeTeamSa
laryCommissionSchemeDetail', N'U') IS NOT NULL DROP TABLE [TK_ChannelEmployeeTeamSa
laryCommissionSchemeDetail];
GO
CREATE TABLE [TK_ChannelEmployeeTeamSa
laryCommissionSchemeDetail] (
    [EmployeeID] nvarchar(50) NOT NULL,
    [ChannelEmployeeSal
arySettlementInterva
lID] int NOT NULL,
    [ChannelEmployeeTe
amCommissionSche
meID] int NOT NULL,
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [Performance] decimal(18,2) NOT NULL,
    [Commission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TK_ChannelEmployeeTeamSa
laryCommissionSchemeDetail] PRIMARY KEY ([EmployeeID],[ChannelEmployeeSal
arySettlementInterva
lID],[ChannelEmployeeTe
amCommissionSche
meID])
);
GO

-- 渠道业绩取值方案
IF OBJECT_ID(N'TK_ChannelPerformanceScheme', N'U') IS NOT NULL DROP TABLE [TK_ChannelPerformanceScheme];
GO
CREATE TABLE [TK_ChannelPerformanceScheme] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Active] bit NOT NULL,
    [IsCalculateChannel] bit NOT NULL,
    [IsCalculateIntroduce
r] bit NOT NULL,
    CONSTRAINT [PK_TK_ChannelPerformanceScheme] PRIMARY KEY ([ID])
);
GO

-- 渠道业绩提成结算
IF OBJECT_ID(N'TK_ChannelSalary', N'U') IS NOT NULL DROP TABLE [TK_ChannelSalary];
GO
CREATE TABLE [TK_ChannelSalary] (
    [ChannelSalarySettle
mentIntervalID] int NOT NULL,
    [ChannelID] int NOT NULL,
    [ChannelPerformance
Commission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TK_ChannelSalary] PRIMARY KEY ([ChannelSalarySettle
mentIntervalID],[ChannelID])
);
GO

-- 渠道业绩提成结算明细
IF OBJECT_ID(N'TK_ChannelSalaryCommissio
nSchemeDetail', N'U') IS NOT NULL DROP TABLE [TK_ChannelSalaryCommissio
nSchemeDetail];
GO
CREATE TABLE [TK_ChannelSalaryCommissio
nSchemeDetail] (
    [ChannelID] int NOT NULL,
    [ChannelSalarySettle
mentIntervalID] int NOT NULL,
    [ChannelPerformance
SchemeID] int NOT NULL,
    [ChannelCommission
SchemeID] int NOT NULL,
    [Performance] decimal(18,2) NOT NULL,
    [Commission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TK_ChannelSalaryCommissio
nSchemeDetail] PRIMARY KEY ([ChannelID],[ChannelSalarySettle
mentIntervalID],[ChannelPerformance
SchemeID],[ChannelCommission
SchemeID])
);
GO

-- 渠道业绩结算周期设置
IF OBJECT_ID(N'TK_ChannelSalarySettlementInterval', N'U') IS NOT NULL DROP TABLE [TK_ChannelSalarySettlementInterval];
GO
CREATE TABLE [TK_ChannelSalarySettlementInterval] (
    [ID] int NOT NULL,
    [SettlementMonth] nvarchar(20) NOT NULL,
    [StartDate] date NOT NULL,
    [EndDate] date NOT NULL,
    CONSTRAINT [PK_TK_ChannelSalarySettlementInterval] PRIMARY KEY ([ID])
);
GO

-- 员工管理
IF OBJECT_ID(N'TK_Employee', N'U') IS NOT NULL DROP TABLE [TK_Employee];
GO
CREATE TABLE [TK_Employee] (
    [ID] nvarchar(50) NOT NULL,
    [Name] nvarchar(20) NOT NULL,
    [Alias] nvarchar(50) NULL,
    [PhoneNumber] nvarchar(20) NOT NULL,
    [JobID] int NOT NULL,
    [Password] varchar(32) NOT NULL,
    [State] bit NOT NULL,
    [Gender] varchar(1) NULL,
    [IDNumber] nvarchar(50) NULL,
    [Birthdate] date NULL,
    [Address] nvarchar(100) NULL,
    [EntryDate] date NULL,
    [TrialExpiryDate] date NULL,
    [ContractStartDate] date NULL,
    [ContractEndDate] date NULL,
    [SocialSecurityPaymentDate] date NULL,
    [Remark] nvarchar(200) NULL,
    [Avatar] nvarchar(500) NULL,
    CONSTRAINT [PK_TK_Employee] PRIMARY KEY ([ID])
);
GO

-- 员工业绩提成方案配置
IF OBJECT_ID(N'TK_EmployeeCommission', N'U') IS NOT NULL DROP TABLE [TK_EmployeeCommission];
GO
CREATE TABLE [TK_EmployeeCommission] (
    [ID] int NOT NULL,
    [EmployeeCommissio
nSchemeID] int NOT NULL,
    [BeginPerformance] int NOT NULL,
    [EndPerformance] int NOT NULL,
    [Rate] decimal(5,4) NOT NULL,
    [Fixed] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TK_EmployeeCommission] PRIMARY KEY ([ID])
);
GO

-- 员工业绩提成方
案适用门店
IF OBJECT_ID(N'TK_EmployeeCommissionEntity', N'U') IS NOT NULL DROP TABLE [TK_EmployeeCommissionEntity];
GO
CREATE TABLE [TK_EmployeeCommissionEntity] (
    [EmployeeCommissio
nSchemeID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TK_EmployeeCommissionEntity] PRIMARY KEY ([EmployeeCommissio
nSchemeID],[EntityID])
);
GO

-- 员工业绩提成方
案通用次卡销售
经手人对应职务
IF OBJECT_ID(N'TK_EmployeeCommissionGe
neralCardSaleHandlerJobTyp
e', N'U') IS NOT NULL DROP TABLE [TK_EmployeeCommissionGe
neralCardSaleHandlerJobTyp
e];
GO
CREATE TABLE [TK_EmployeeCommissionGe
neralCardSaleHandlerJobTyp
e] (
    [EmployeeCommissio
nSchemeID] int NOT NULL,
    [GeneralCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TK_EmployeeCommissionGe
neralCardSaleHandlerJobTyp
e] PRIMARY KEY ([EmployeeCommissio
nSchemeID],[GeneralCardSaleHandlerID],[JobTypeID])
);
GO

-- 员工业绩提成方
案套餐卡销售经
手人对应职务
IF OBJECT_ID(N'TK_EmployeeCommissionPac
kageCardSaleHandlerJobTyp
e', N'U') IS NOT NULL DROP TABLE [TK_EmployeeCommissionPac
kageCardSaleHandlerJobTyp
e];
GO
CREATE TABLE [TK_EmployeeCommissionPac
kageCardSaleHandlerJobTyp
e] (
    [EmployeeCommissio
nSchemeID] int NOT NULL,
    [PackageCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TK_EmployeeCommissionPac
kageCardSaleHandlerJobTyp
e] PRIMARY KEY ([EmployeeCommissio
nSchemeID],[PackageCardSaleHandlerID],[JobTypeID])
);
GO

-- 员工业绩提成方
案产品销售经手
人对应职务
IF OBJECT_ID(N'TK_EmployeeCommissionPro
ductSaleHandlerJobType', N'U') IS NOT NULL DROP TABLE [TK_EmployeeCommissionPro
ductSaleHandlerJobType];
GO
CREATE TABLE [TK_EmployeeCommissionPro
ductSaleHandlerJobType] (
    [EmployeeCommissio
nSchemeID] int NOT NULL,
    [ProductSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TK_EmployeeCommissionPro
ductSaleHandlerJobType] PRIMARY KEY ([EmployeeCommissio
nSchemeID],[ProductSaleHandlerID],[JobTypeID])
);
GO

-- 员工业绩提成方
案产品消耗经手
人对应职务
IF OBJECT_ID(N'TK_EmployeeCommissionPro
ductTreatHandlerJobType', N'U') IS NOT NULL DROP TABLE [TK_EmployeeCommissionPro
ductTreatHandlerJobType];
GO
CREATE TABLE [TK_EmployeeCommissionPro
ductTreatHandlerJobType] (
    [EmployeeCommissio
nSchemeID] int NOT NULL,
    [ProductTreatHandler
ID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TK_EmployeeCommissionPro
ductTreatHandlerJobType] PRIMARY KEY ([EmployeeCommissio
nSchemeID],[ProductTreatHandler
ID],[JobTypeID])
);
GO

-- 员工业绩提成方
案项目销售经手
人对应职务
IF OBJECT_ID(N'TK_EmployeeCommissionProj
ectSaleHandlerJobType', N'U') IS NOT NULL DROP TABLE [TK_EmployeeCommissionProj
ectSaleHandlerJobType];
GO
CREATE TABLE [TK_EmployeeCommissionProj
ectSaleHandlerJobType] (
    [EmployeeCommissio
nSchemeID] int NOT NULL,
    [ProjectSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TK_EmployeeCommissionProj
ectSaleHandlerJobType] PRIMARY KEY ([EmployeeCommissio
nSchemeID],[ProjectSaleHandlerID],[JobTypeID])
);
GO

-- 员工业绩提成方
案项目消耗经手
人对应职务
IF OBJECT_ID(N'TK_EmployeeCommissionProj
ectTreatHandlerJobType', N'U') IS NOT NULL DROP TABLE [TK_EmployeeCommissionProj
ectTreatHandlerJobType];
GO
CREATE TABLE [TK_EmployeeCommissionProj
ectTreatHandlerJobType] (
    [EmployeeCommissio
nSchemeID] int NOT NULL,
    [ProjectTreatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TK_EmployeeCommissionProj
ectTreatHandlerJobType] PRIMARY KEY ([EmployeeCommissio
nSchemeID],[ProjectTreatHandlerID],[JobTypeID])
);
GO

-- 员工业绩提成方
案储值卡销售经
手人对应职务
IF OBJECT_ID(N'TK_EmployeeCommissionSav
ingCardSaleHandlerJobType', N'U') IS NOT NULL DROP TABLE [TK_EmployeeCommissionSav
ingCardSaleHandlerJobType];
GO
CREATE TABLE [TK_EmployeeCommissionSav
ingCardSaleHandlerJobType] (
    [EmployeeCommissio
nSchemeID] int NOT NULL,
    [SavingCardSaleHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TK_EmployeeCommissionSav
ingCardSaleHandlerJobType] PRIMARY KEY ([EmployeeCommissio
nSchemeID],[SavingCardSaleHandlerID],[JobTypeID])
);
GO

-- 员工业绩提成方
案储值卡消耗经
手人对应职务
IF OBJECT_ID(N'TK_EmployeeCommissionSav
ingCardTreatHandlerJobType', N'U') IS NOT NULL DROP TABLE [TK_EmployeeCommissionSav
ingCardTreatHandlerJobType];
GO
CREATE TABLE [TK_EmployeeCommissionSav
ingCardTreatHandlerJobType] (
    [EmployeeCommissio
nSchemeID] int NOT NULL,
    [SavingCardTreatHandlerID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TK_EmployeeCommissionSav
ingCardTreatHandlerJobType] PRIMARY KEY ([EmployeeCommissio
nSchemeID],[SavingCardTreatHandlerID],[JobTypeID])
);
GO

-- 员工业绩提成方案
IF OBJECT_ID(N'TK_EmployeeCommissionScheme', N'U') IS NOT NULL DROP TABLE [TK_EmployeeCommissionScheme];
GO
CREATE TABLE [TK_EmployeeCommissionScheme] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [PerformanceEvaluati
onSchemeID] int NOT NULL,
    [PerformanceEvaluationRange] nvarchar(50) NOT NULL,
    [PerformanceCalculat
ionSchemeID] int NOT NULL,
    [PerformanceCalculationRange] nvarchar(50) NOT NULL,
    [Calculation] nvarchar(50) NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TK_EmployeeCommissionScheme] PRIMARY KEY ([ID])
);
GO

-- 员工业绩提成方
案时效卡销售经
手人对应职务
IF OBJECT_ID(N'TK_EmployeeCommissionTim
eCardSaleHandlerJobType', N'U') IS NOT NULL DROP TABLE [TK_EmployeeCommissionTim
eCardSaleHandlerJobType];
GO
CREATE TABLE [TK_EmployeeCommissionTim
eCardSaleHandlerJobType] (
    [EmployeeCommissio
nSchemeID] int NOT NULL,
    [TimeCardSaleHandle
rID] int NOT NULL,
    [JobTypeID] int NOT NULL,
    CONSTRAINT [PK_TK_EmployeeCommissionTim
eCardSaleHandlerJobType] PRIMARY KEY ([EmployeeCommissio
nSchemeID],[TimeCardSaleHandle
rID],[JobTypeID])
);
GO

-- 员工所属门店
IF OBJECT_ID(N'TK_EmployeeEntity', N'U') IS NOT NULL DROP TABLE [TK_EmployeeEntity];
GO
CREATE TABLE [TK_EmployeeEntity] (
    [EmployeeID] nvarchar(50) NOT NULL,
    [EntityID] int NOT NULL,
    [IsPrimaryEntity] bit NOT NULL,
    CONSTRAINT [PK_TK_EmployeeEntity] PRIMARY KEY ([EmployeeID],[EntityID])
);
GO

-- 门店管理
IF OBJECT_ID(N'TK_Entity', N'U') IS NOT NULL DROP TABLE [TK_Entity];
GO
CREATE TABLE [TK_Entity] (
    [ID] int NOT NULL,
    [EntityName] nvarchar(50) NOT NULL,
    [ParentID] int NOT NULL,
    [IsStore] bit NOT NULL,
    [IsWarehouse] bit NOT NULL,
    [Sequence] int NULL,
    [ProvinceCode] nvarchar(50) NULL,
    [CityCode] nvarchar(50) NULL,
    [AreaCode] nvarchar(50) NULL,
    [AddressDetail] nvarchar(200) NULL,
    [Longitude] decimal(13,10) NULL,
    [Latitude] decimal(13,10) NULL,
    [Active] bit NULL,
    [Remark] nvarchar(200) NULL,
    CONSTRAINT [PK_TK_Entity] PRIMARY KEY ([ID])
);
GO

-- 门店提成方案配
IF OBJECT_ID(N'TK_EntityCommission', N'U') IS NOT NULL DROP TABLE [TK_EntityCommission];
GO
CREATE TABLE [TK_EntityCommission] (
    [ID] int NOT NULL,
    [EntityCommissionSchemeID] int NOT NULL,
    [BeginPerformance] int NOT NULL,
    [EndPerformance] int NOT NULL,
    [Rate] decimal(5,4) NOT NULL,
    [Fixed] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TK_EntityCommission] PRIMARY KEY ([ID])
);
GO

-- 门店提成方案适用员工
IF OBJECT_ID(N'TK_EntityCommissionEmployee', N'U') IS NOT NULL DROP TABLE [TK_EntityCommissionEmployee];
GO
CREATE TABLE [TK_EntityCommissionEmployee] (
    [ID] int NOT NULL,
    [CommissionSchemeID] int NOT NULL,
    [EmployeeID] nvarchar(50) NULL,
    CONSTRAINT [PK_TK_EntityCommissionEmployee] PRIMARY KEY ([ID])
);
GO

-- 门店提成方案适
用员工业绩门店
IF OBJECT_ID(N'TK_EntityCommissionEmployeeEntity', N'U') IS NOT NULL DROP TABLE [TK_EntityCommissionEmployeeEntity];
GO
CREATE TABLE [TK_EntityCommissionEmployeeEntity] (
    [EntityCommissionEmployeeID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TK_EntityCommissionEmployeeEntity] PRIMARY KEY ([EntityCommissionEmployeeID],[EntityID])
);
GO

-- 门店提成方案
IF OBJECT_ID(N'TK_EntityCommissionScheme', N'U') IS NOT NULL DROP TABLE [TK_EntityCommissionScheme];
GO
CREATE TABLE [TK_EntityCommissionScheme] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [PerformanceEvaluati
onSchemeID] int NOT NULL,
    [PerformanceCalculat
ionSchemeID] int NOT NULL,
    [Calculation] nvarchar(50) NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TK_EntityCommissionScheme] PRIMARY KEY ([ID])
);
GO

-- 职务管理
IF OBJECT_ID(N'TK_JobType', N'U') IS NOT NULL DROP TABLE [TK_JobType];
GO
CREATE TABLE [TK_JobType] (
    [ID] int NOT NULL,
    [JobName] nvarchar(50) NOT NULL,
    [JobDescription] nvarchar(200) NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TK_JobType] PRIMARY KEY ([ID])
);
GO

-- 员工业绩取值方
IF OBJECT_ID(N'TK_PerformanceScheme', N'U') IS NOT NULL DROP TABLE [TK_PerformanceScheme];
GO
CREATE TABLE [TK_PerformanceScheme] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [IsSeparateSalePacka
geCardPerformance] bit NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TK_PerformanceScheme] PRIMARY KEY ([ID])
);
GO

-- 员工业绩提成结算
IF OBJECT_ID(N'TK_Salary', N'U') IS NOT NULL DROP TABLE [TK_Salary];
GO
CREATE TABLE [TK_Salary] (
    [SalarySettlementIntervalID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    [EmployeePerforman
ceCommission] decimal(18,2) NOT NULL,
    [TeamPerformanceC
ommission] decimal(18,2) NOT NULL,
    [EntityPerformanceC
ommission] decimal(18,2) NOT NULL,
    [SaleCommission] decimal(18,2) NOT NULL,
    [TreatCommission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TK_Salary] PRIMARY KEY ([SalarySettlementIntervalID],[EmployeeID])
);
GO

-- 个人业绩提成明细
IF OBJECT_ID(N'TK_SalaryEmployeeCommissi
onSchemeDetail', N'U') IS NOT NULL DROP TABLE [TK_SalaryEmployeeCommissi
onSchemeDetail];
GO
CREATE TABLE [TK_SalaryEmployeeCommissi
onSchemeDetail] (
    [EmployeeID] nvarchar(50) NOT NULL,
    [SalarySettlementIntervalID] int NOT NULL,
    [EmployeeCommissio
nSchemeID] int NOT NULL,
    [PerformanceEvaluati
onSchemeID] int NOT NULL,
    [PerformanceEvaluationRange] nvarchar(50) NOT NULL,
    [EvaluationPerformance] decimal(18,2) NOT NULL,
    [PerformanceCalculat
ionSchemeID] int NOT NULL,
    [PerformanceCalculationRange] nvarchar(50) NOT NULL,
    [CalculationPerformance] decimal(18,2) NOT NULL,
    [Commission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TK_SalaryEmployeeCommissi
onSchemeDetail] PRIMARY KEY ([EmployeeID],[SalarySettlementIntervalID],[EmployeeCommissio
nSchemeID])
);
GO

-- 门店业绩提成明细
IF OBJECT_ID(N'TK_SalaryEntityCommissionSc
hemeDetail', N'U') IS NOT NULL DROP TABLE [TK_SalaryEntityCommissionSc
hemeDetail];
GO
CREATE TABLE [TK_SalaryEntityCommissionSc
hemeDetail] (
    [EmployeeID] nvarchar(50) NOT NULL,
    [SalarySettlementIntervalID] int NOT NULL,
    [EntityCommissionSchemeID] int NOT NULL,
    [PerformanceEvaluati
onSchemeID] int NOT NULL,
    [PerformanceCalculat
ionSchemeID] int NOT NULL,
    [EvaluationPerformance] decimal(18,2) NOT NULL,
    [CalculationPerformance] decimal(18,2) NOT NULL,
    [Commission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TK_SalaryEntityCommissionSc
hemeDetail] PRIMARY KEY ([EmployeeID],[SalarySettlementIntervalID],[EntityCommissionSchemeID])
);
GO

-- 员工业绩提成结
算周期设置
IF OBJECT_ID(N'TK_SalarySettlementInterval', N'U') IS NOT NULL DROP TABLE [TK_SalarySettlementInterval];
GO
CREATE TABLE [TK_SalarySettlementInterval] (
    [ID] int NOT NULL,
    [SettlementMonth] nvarchar(20) NOT NULL,
    [StartDate] date NOT NULL,
    [EndDate] date NOT NULL,
    CONSTRAINT [PK_TK_SalarySettlementInterval] PRIMARY KEY ([ID])
);
GO

-- 团队业绩提成明细
IF OBJECT_ID(N'TK_SalaryTeamCommissionSc
hemeDetail', N'U') IS NOT NULL DROP TABLE [TK_SalaryTeamCommissionSc
hemeDetail];
GO
CREATE TABLE [TK_SalaryTeamCommissionSc
hemeDetail] (
    [EmployeeID] nvarchar(50) NOT NULL,
    [SalarySettlementIntervalID] int NOT NULL,
    [TeamCommissionSchemeID] int NOT NULL,
    [PerformanceEvaluati
onSchemeID] int NOT NULL,
    [PerformanceCalculat
ionSchemeID] int NOT NULL,
    [EvaluationPerformance] decimal(18,2) NOT NULL,
    [CalculationPerformance] decimal(18,2) NOT NULL,
    [Commission] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TK_SalaryTeamCommissionSc
hemeDetail] PRIMARY KEY ([EmployeeID],[SalarySettlementIntervalID],[TeamCommissionSchemeID])
);
GO

-- 市场销售通用次
卡分类业绩取值
IF OBJECT_ID(N'TK_SaleChannelEmployeeGe
neralCardCategoryPerforman', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelEmployeeGe
neralCardCategoryPerforman];
GO
CREATE TABLE [TK_SaleChannelEmployeeGe
neralCardCategoryPerforman] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelEmployeeGe
neralCardCategoryPerforman] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[GeneralCardCategoryID])
);
GO

-- 市场销售通用次
卡业绩取值配置
IF OBJECT_ID(N'TK_SaleChannelEmployeeGe
neralCardPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelEmployeeGe
neralCardPerformance];
GO
CREATE TABLE [TK_SaleChannelEmployeeGe
neralCardPerformance] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelEmployeeGe
neralCardPerformance] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[GeneralCardID])
);
GO

-- 市场销售产品分
类业绩取值配置
IF OBJECT_ID(N'TK_SaleChannelEmployeePro
ductCategoryPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelEmployeePro
ductCategoryPerformance];
GO
CREATE TABLE [TK_SaleChannelEmployeePro
ductCategoryPerformance] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelEmployeePro
ductCategoryPerformance] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[ProductCategoryID])
);
GO

-- 市场销售产品业
绩取值配置
IF OBJECT_ID(N'TK_SaleChannelEmployeePro
ductPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelEmployeePro
ductPerformance];
GO
CREATE TABLE [TK_SaleChannelEmployeePro
ductPerformance] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelEmployeePro
ductPerformance] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[ProductID])
);
GO

-- 市场销售项目分
类业绩取值配置
IF OBJECT_ID(N'TK_SaleChannelEmployeePro
jectCategoryPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelEmployeePro
jectCategoryPerformance];
GO
CREATE TABLE [TK_SaleChannelEmployeePro
jectCategoryPerformance] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelEmployeePro
jectCategoryPerformance] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[ProjectCategoryID])
);
GO

-- 市场销售项目业
绩取值配置
IF OBJECT_ID(N'TK_SaleChannelEmployeePro
jectPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelEmployeePro
jectPerformance];
GO
CREATE TABLE [TK_SaleChannelEmployeePro
jectPerformance] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelEmployeePro
jectPerformance] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[ProjectID])
);
GO

-- 市场销售储值卡
分类业绩取值配
IF OBJECT_ID(N'TK_SaleChannelEmployeeSav
ingCardCategoryPerformanc', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelEmployeeSav
ingCardCategoryPerformanc];
GO
CREATE TABLE [TK_SaleChannelEmployeeSav
ingCardCategoryPerformanc] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelEmployeeSav
ingCardCategoryPerformanc] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[SavingCardCategory
ID])
);
GO

-- 市场销售储值卡
业绩取值配置
IF OBJECT_ID(N'TK_SaleChannelEmployeeSav
ingCardPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelEmployeeSav
ingCardPerformance];
GO
CREATE TABLE [TK_SaleChannelEmployeeSav
ingCardPerformance] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelEmployeeSav
ingCardPerformance] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[SavingCardID])
);
GO

-- 市场销售时效卡
分类业绩取值配
IF OBJECT_ID(N'TK_SaleChannelEmployeeTim
eCardCategoryPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelEmployeeTim
eCardCategoryPerformance];
GO
CREATE TABLE [TK_SaleChannelEmployeeTim
eCardCategoryPerformance] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelEmployeeTim
eCardCategoryPerformance] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[TimeCardCategoryID])
);
GO

-- 市场销售时效卡
业绩取值配置
IF OBJECT_ID(N'TK_SaleChannelEmployeeTim
eCardPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelEmployeeTim
eCardPerformance];
GO
CREATE TABLE [TK_SaleChannelEmployeeTim
eCardPerformance] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelEmployeeTim
eCardPerformance] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[TimeCardID])
);
GO

-- 渠道销售通用次
卡分类业绩取值
IF OBJECT_ID(N'TK_SaleChannelGeneralCard
CategoryPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelGeneralCard
CategoryPerformance];
GO
CREATE TABLE [TK_SaleChannelGeneralCard
CategoryPerformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelGeneralCard
CategoryPerformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[GeneralCardCategoryID])
);
GO

-- 渠道销售通用次
卡业绩取值配置
IF OBJECT_ID(N'TK_SaleChannelGeneralCard
Performance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelGeneralCard
Performance];
GO
CREATE TABLE [TK_SaleChannelGeneralCard
Performance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelGeneralCard
Performance] PRIMARY KEY ([ChannelPerformance
SchemeID],[GeneralCardID])
);
GO

-- 渠道销售产品分
类业绩取值配置
IF OBJECT_ID(N'TK_SaleChannelProductCateg
oryPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelProductCateg
oryPerformance];
GO
CREATE TABLE [TK_SaleChannelProductCateg
oryPerformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelProductCateg
oryPerformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[ProductCategoryID])
);
GO

-- 渠道销售产品业
绩取值配置
IF OBJECT_ID(N'TK_SaleChannelProductPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelProductPerformance];
GO
CREATE TABLE [TK_SaleChannelProductPerformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelProductPerformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[ProductID])
);
GO

-- 渠道销售项目分
类业绩取值配置
IF OBJECT_ID(N'TK_SaleChannelProjectCateg
oryPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelProjectCateg
oryPerformance];
GO
CREATE TABLE [TK_SaleChannelProjectCateg
oryPerformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelProjectCateg
oryPerformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[ProjectCategoryID])
);
GO

-- 渠道销售项目业
绩取值配置
IF OBJECT_ID(N'TK_SaleChannelProjectPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelProjectPerformance];
GO
CREATE TABLE [TK_SaleChannelProjectPerformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelProjectPerformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[ProjectID])
);
GO

-- 渠道销售储值卡
分类业绩取值配
IF OBJECT_ID(N'TK_SaleChannelSavingCardC
ategoryPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelSavingCardC
ategoryPerformance];
GO
CREATE TABLE [TK_SaleChannelSavingCardC
ategoryPerformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelSavingCardC
ategoryPerformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[SavingCardCategory
ID])
);
GO

-- 渠道销售储值卡
业绩取值配置
IF OBJECT_ID(N'TK_SaleChannelSavingCardP
erformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelSavingCardP
erformance];
GO
CREATE TABLE [TK_SaleChannelSavingCardP
erformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelSavingCardP
erformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[SavingCardID])
);
GO

-- 渠道销售时效卡
分类业绩取值配
IF OBJECT_ID(N'TK_SaleChannelTimeCardCat
egoryPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelTimeCardCat
egoryPerformance];
GO
CREATE TABLE [TK_SaleChannelTimeCardCat
egoryPerformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelTimeCardCat
egoryPerformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[TimeCardCategoryID])
);
GO

-- 渠道销售时效卡
业绩取值配置
IF OBJECT_ID(N'TK_SaleChannelTimeCardPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleChannelTimeCardPerformance];
GO
CREATE TABLE [TK_SaleChannelTimeCardPerformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleChannelTimeCardPerformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[TimeCardID])
);
GO

-- 销售通用次卡分
类业绩取值员工
IF OBJECT_ID(N'TK_SaleGeneralCardCategory
Performance', N'U') IS NOT NULL DROP TABLE [TK_SaleGeneralCardCategory
Performance];
GO
CREATE TABLE [TK_SaleGeneralCardCategory
Performance] (
    [PerformanceScheme
ID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleGeneralCardCategory
Performance] PRIMARY KEY ([PerformanceScheme
ID],[GeneralCardCategoryID])
);
GO

-- 销售通用次卡业
绩取值员工配置
IF OBJECT_ID(N'TK_SaleGeneralCardPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleGeneralCardPerformance];
GO
CREATE TABLE [TK_SaleGeneralCardPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleGeneralCardPerformance] PRIMARY KEY ([PerformanceScheme
ID],[GeneralCardID])
);
GO

-- 
IF OBJECT_ID(N'TK_SalePackageCardCategor
yPerformance', N'U') IS NOT NULL DROP TABLE [TK_SalePackageCardCategor
yPerformance];
GO
CREATE TABLE [TK_SalePackageCardCategor
yPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [PackageCardCategoryID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SalePackageCardCategor
yPerformance] PRIMARY KEY ([PerformanceScheme
ID],[PackageCardCategoryID])
);
GO

-- 
IF OBJECT_ID(N'TK_SalePackageCardPerformance', N'U') IS NOT NULL DROP TABLE [TK_SalePackageCardPerformance];
GO
CREATE TABLE [TK_SalePackageCardPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [PackageCardID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SalePackageCardPerformance] PRIMARY KEY ([PerformanceScheme
ID],[PackageCardID])
);
GO

-- 销售产品分类业
绩取值员工配置
IF OBJECT_ID(N'TK_SaleProductCategoryPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleProductCategoryPerformance];
GO
CREATE TABLE [TK_SaleProductCategoryPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleProductCategoryPerformance] PRIMARY KEY ([PerformanceScheme
ID],[ProductCategoryID])
);
GO

-- 销售产品业绩取
值员工配置
IF OBJECT_ID(N'TK_SaleProductPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleProductPerformance];
GO
CREATE TABLE [TK_SaleProductPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleProductPerformance] PRIMARY KEY ([PerformanceScheme
ID],[ProductID])
);
GO

-- 销售项目分类业
绩取值员工配置
IF OBJECT_ID(N'TK_SaleProjectCategoryPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleProjectCategoryPerformance];
GO
CREATE TABLE [TK_SaleProjectCategoryPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleProjectCategoryPerformance] PRIMARY KEY ([PerformanceScheme
ID],[ProjectCategoryID])
);
GO

-- 销售项目业绩取
值员工配置
IF OBJECT_ID(N'TK_SaleProjectPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleProjectPerformance];
GO
CREATE TABLE [TK_SaleProjectPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleProjectPerformance] PRIMARY KEY ([PerformanceScheme
ID],[ProjectID])
);
GO

-- 销售储值卡分类
业绩取值员工配
IF OBJECT_ID(N'TK_SaleSavingCardCategoryP
erformance', N'U') IS NOT NULL DROP TABLE [TK_SaleSavingCardCategoryP
erformance];
GO
CREATE TABLE [TK_SaleSavingCardCategoryP
erformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleSavingCardCategoryP
erformance] PRIMARY KEY ([PerformanceScheme
ID],[SavingCardCategory
ID])
);
GO

-- 销售储值卡业绩
取值员工配置
IF OBJECT_ID(N'TK_SaleSavingCardPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleSavingCardPerformance];
GO
CREATE TABLE [TK_SaleSavingCardPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleSavingCardPerformance] PRIMARY KEY ([PerformanceScheme
ID],[SavingCardID])
);
GO

-- 销售时效卡分类
业绩取值员工配
IF OBJECT_ID(N'TK_SaleTimeCardCategoryPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleTimeCardCategoryPerformance];
GO
CREATE TABLE [TK_SaleTimeCardCategoryPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleTimeCardCategoryPerformance] PRIMARY KEY ([PerformanceScheme
ID],[TimeCardCategoryID])
);
GO

-- 销售时效卡业绩
取值员工配置
IF OBJECT_ID(N'TK_SaleTimeCardPerformance', N'U') IS NOT NULL DROP TABLE [TK_SaleTimeCardPerformance];
GO
CREATE TABLE [TK_SaleTimeCardPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PayPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerformanceRate] decimal(5,4) NULL,
    [SavingCardPerforma
nceLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_SaleTimeCardPerformance] PRIMARY KEY ([PerformanceScheme
ID],[TimeCardID])
);
GO

-- 团队提成方案配
IF OBJECT_ID(N'TK_TeamCommission', N'U') IS NOT NULL DROP TABLE [TK_TeamCommission];
GO
CREATE TABLE [TK_TeamCommission] (
    [ID] int NOT NULL,
    [TeamCommissionSchemeID] int NOT NULL,
    [BeginPerformance] int NOT NULL,
    [EndPerformance] int NOT NULL,
    [Rate] decimal(5,4) NOT NULL,
    [Fixed] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_TK_TeamCommission] PRIMARY KEY ([ID])
);
GO

-- 团队提成方案配
置提成员工
IF OBJECT_ID(N'TK_TeamCommissionEmployee', N'U') IS NOT NULL DROP TABLE [TK_TeamCommissionEmployee];
GO
CREATE TABLE [TK_TeamCommissionEmployee] (
    [ID] int NOT NULL,
    [TeamCommissionSchemeID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TK_TeamCommissionEmployee] PRIMARY KEY ([ID])
);
GO

-- 团队提成方案
IF OBJECT_ID(N'TK_TeamCommissionScheme', N'U') IS NOT NULL DROP TABLE [TK_TeamCommissionScheme];
GO
CREATE TABLE [TK_TeamCommissionScheme] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [PerformanceEvaluati
onSchemeID] int NOT NULL,
    [PerformanceCalculat
ionSchemeID] int NOT NULL,
    [Calculation] nvarchar(50) NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TK_TeamCommissionScheme] PRIMARY KEY ([ID])
);
GO

-- 团队提成方案配
置团队员工
IF OBJECT_ID(N'TK_TeamEmployee', N'U') IS NOT NULL DROP TABLE [TK_TeamEmployee];
GO
CREATE TABLE [TK_TeamEmployee] (
    [ID] int NOT NULL,
    [TeamCommissionSchemeID] int NOT NULL,
    [EmployeeID] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TK_TeamEmployee] PRIMARY KEY ([ID])
);
GO

-- 市场消耗通用次
卡分类业绩取值
IF OBJECT_ID(N'TK_TreatChannelEmployeeGe
neralCardCategoryPerforman', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelEmployeeGe
neralCardCategoryPerforman];
GO
CREATE TABLE [TK_TreatChannelEmployeeGe
neralCardCategoryPerforman] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelEmployeeGe
neralCardCategoryPerforman] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[GeneralCardCategoryID])
);
GO

-- 市场消耗通用次
卡业绩取值配置
IF OBJECT_ID(N'TK_TreatChannelEmployeeGe
neralCardPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelEmployeeGe
neralCardPerformance];
GO
CREATE TABLE [TK_TreatChannelEmployeeGe
neralCardPerformance] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelEmployeeGe
neralCardPerformance] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[GeneralCardID])
);
GO

-- 市场消耗产品分
类业绩取值配置
IF OBJECT_ID(N'TK_TreatChannelEmployeePr
oductCategoryPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelEmployeePr
oductCategoryPerformance];
GO
CREATE TABLE [TK_TreatChannelEmployeePr
oductCategoryPerformance] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelEmployeePr
oductCategoryPerformance] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[ProductCategoryID])
);
GO

-- 市场消耗产品业
绩取值配置
IF OBJECT_ID(N'TK_TreatChannelEmployeePr
oductPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelEmployeePr
oductPerformance];
GO
CREATE TABLE [TK_TreatChannelEmployeePr
oductPerformance] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelEmployeePr
oductPerformance] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[ProductID])
);
GO

-- 市场消耗项目分
类业绩取值配置
IF OBJECT_ID(N'TK_TreatChannelEmployeePr
ojectCategoryPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelEmployeePr
ojectCategoryPerformance];
GO
CREATE TABLE [TK_TreatChannelEmployeePr
ojectCategoryPerformance] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelEmployeePr
ojectCategoryPerformance] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[ProjectCategoryID])
);
GO

-- 市场消耗项目业
绩取值配置
IF OBJECT_ID(N'TK_TreatChannelEmployeePr
ojectPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelEmployeePr
ojectPerformance];
GO
CREATE TABLE [TK_TreatChannelEmployeePr
ojectPerformance] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelEmployeePr
ojectPerformance] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[ProjectID])
);
GO

-- 市场消耗储值卡
分类业绩取值配
IF OBJECT_ID(N'TK_TreatChannelEmployeeSa
vingCardCategoryPerforman', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelEmployeeSa
vingCardCategoryPerforman];
GO
CREATE TABLE [TK_TreatChannelEmployeeSa
vingCardCategoryPerforman] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelEmployeeSa
vingCardCategoryPerforman] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[SavingCardCategory
ID])
);
GO

-- 市场消耗储值卡
业绩取值配置
IF OBJECT_ID(N'TK_TreatChannelEmployeeSa
vingCardPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelEmployeeSa
vingCardPerformance];
GO
CREATE TABLE [TK_TreatChannelEmployeeSa
vingCardPerformance] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelEmployeeSa
vingCardPerformance] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[SavingCardID])
);
GO

-- 市场消耗时效卡
分类业绩取值配
IF OBJECT_ID(N'TK_TreatChannelEmployeeTi
meCardCategoryPerformanc', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelEmployeeTi
meCardCategoryPerformanc];
GO
CREATE TABLE [TK_TreatChannelEmployeeTi
meCardCategoryPerformanc] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelEmployeeTi
meCardCategoryPerformanc] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[TimeCardCategoryID])
);
GO

-- 市场消耗时效卡
业绩取值配置
IF OBJECT_ID(N'TK_TreatChannelEmployeeTi
meCardPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelEmployeeTi
meCardPerformance];
GO
CREATE TABLE [TK_TreatChannelEmployeeTi
meCardPerformance] (
    [ChannelEmployeePe
rformanceSchemeID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelEmployeeTi
meCardPerformance] PRIMARY KEY ([ChannelEmployeePe
rformanceSchemeID],[TimeCardID])
);
GO

-- 渠道消耗通用次
卡分类业绩取值
IF OBJECT_ID(N'TK_TreatChannelGeneralCard
CategoryPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelGeneralCard
CategoryPerformance];
GO
CREATE TABLE [TK_TreatChannelGeneralCard
CategoryPerformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelGeneralCard
CategoryPerformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[GeneralCardCategoryID])
);
GO

-- 渠道消耗通用次
卡业绩取值配置
IF OBJECT_ID(N'TK_TreatChannelGeneralCard
Performance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelGeneralCard
Performance];
GO
CREATE TABLE [TK_TreatChannelGeneralCard
Performance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelGeneralCard
Performance] PRIMARY KEY ([ChannelPerformance
SchemeID],[GeneralCardID])
);
GO

-- 渠道消耗产品分
类业绩取值配置
IF OBJECT_ID(N'TK_TreatChannelProductCate
goryPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelProductCate
goryPerformance];
GO
CREATE TABLE [TK_TreatChannelProductCate
goryPerformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelProductCate
goryPerformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[ProductCategoryID])
);
GO

-- 渠道消耗产品业
绩取值配置
IF OBJECT_ID(N'TK_TreatChannelProductPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelProductPerformance];
GO
CREATE TABLE [TK_TreatChannelProductPerformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelProductPerformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[ProductID])
);
GO

-- 渠道消耗项目分
类业绩取值配置
IF OBJECT_ID(N'TK_TreatChannelProjectCate
goryPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelProjectCate
goryPerformance];
GO
CREATE TABLE [TK_TreatChannelProjectCate
goryPerformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelProjectCate
goryPerformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[ProjectCategoryID])
);
GO

-- 渠道消耗项目业
绩取值配置
IF OBJECT_ID(N'TK_TreatChannelProjectPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelProjectPerformance];
GO
CREATE TABLE [TK_TreatChannelProjectPerformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelProjectPerformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[ProjectID])
);
GO

-- 渠道消耗储值卡
分类业绩取值配
IF OBJECT_ID(N'TK_TreatChannelSavingCard
CategoryPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelSavingCard
CategoryPerformance];
GO
CREATE TABLE [TK_TreatChannelSavingCard
CategoryPerformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelSavingCard
CategoryPerformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[SavingCardCategory
ID])
);
GO

-- 渠道消耗储值卡
业绩取值配置
IF OBJECT_ID(N'TK_TreatChannelSavingCardP
erformance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelSavingCardP
erformance];
GO
CREATE TABLE [TK_TreatChannelSavingCardP
erformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelSavingCardP
erformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[SavingCardID])
);
GO

-- 渠道消耗时效卡
分类业绩取值配
IF OBJECT_ID(N'TK_TreatChannelTimeCardCa
tegoryPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelTimeCardCa
tegoryPerformance];
GO
CREATE TABLE [TK_TreatChannelTimeCardCa
tegoryPerformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelTimeCardCa
tegoryPerformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[TimeCardCategoryID])
);
GO

-- 渠道消耗时效卡
业绩取值配置
IF OBJECT_ID(N'TK_TreatChannelTimeCardPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatChannelTimeCardPerformance];
GO
CREATE TABLE [TK_TreatChannelTimeCardPerformance] (
    [ChannelPerformance
SchemeID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatChannelTimeCardPerformance] PRIMARY KEY ([ChannelPerformance
SchemeID],[TimeCardID])
);
GO

-- 消耗通用次卡分
类业绩取值员工
IF OBJECT_ID(N'TK_TreatGeneralCardCategor
yPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatGeneralCardCategor
yPerformance];
GO
CREATE TABLE [TK_TreatGeneralCardCategor
yPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [GeneralCardCategoryID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatGeneralCardCategor
yPerformance] PRIMARY KEY ([PerformanceScheme
ID],[GeneralCardCategoryID])
);
GO

-- 消耗通用次卡业
绩取值员工配置
IF OBJECT_ID(N'TK_TreatGeneralCardPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatGeneralCardPerformance];
GO
CREATE TABLE [TK_TreatGeneralCardPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [GeneralCardID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatGeneralCardPerformance] PRIMARY KEY ([PerformanceScheme
ID],[GeneralCardID])
);
GO

-- 消耗产品分类业
绩取值员工配置
IF OBJECT_ID(N'TK_TreatProductCategoryPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatProductCategoryPerformance];
GO
CREATE TABLE [TK_TreatProductCategoryPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [ProductCategoryID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatProductCategoryPerformance] PRIMARY KEY ([PerformanceScheme
ID],[ProductCategoryID])
);
GO

-- 
IF OBJECT_ID(N'TK_TreatProductPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatProductPerformance];
GO
CREATE TABLE [TK_TreatProductPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [ProductID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatProductPerformance] PRIMARY KEY ([PerformanceScheme
ID],[ProductID])
);
GO

-- 消耗项目分类业
绩取值员工配置
IF OBJECT_ID(N'TK_TreatProjectCategoryPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatProjectCategoryPerformance];
GO
CREATE TABLE [TK_TreatProjectCategoryPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [ProjectCategoryID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatProjectCategoryPerformance] PRIMARY KEY ([PerformanceScheme
ID],[ProjectCategoryID])
);
GO

-- 消耗项目业绩取
值员工配置
IF OBJECT_ID(N'TK_TreatProjectPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatProjectPerformance];
GO
CREATE TABLE [TK_TreatProjectPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [ProjectID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatProjectPerformance] PRIMARY KEY ([PerformanceScheme
ID],[ProjectID])
);
GO

-- 消耗储值卡分类
业绩取值员工配
IF OBJECT_ID(N'TK_TreatSavingCardCategory
Performance', N'U') IS NOT NULL DROP TABLE [TK_TreatSavingCardCategory
Performance];
GO
CREATE TABLE [TK_TreatSavingCardCategory
Performance] (
    [PerformanceScheme
ID] int NOT NULL,
    [SavingCardCategory
ID] int NOT NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatSavingCardCategory
Performance] PRIMARY KEY ([PerformanceScheme
ID],[SavingCardCategory
ID])
);
GO

-- 消耗储值卡业绩
取值员工配置
IF OBJECT_ID(N'TK_TreatSavingCardPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatSavingCardPerformance];
GO
CREATE TABLE [TK_TreatSavingCardPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [SavingCardID] int NOT NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatSavingCardPerformance] PRIMARY KEY ([PerformanceScheme
ID],[SavingCardID])
);
GO

-- 消耗时效卡分类
业绩取值员工配
IF OBJECT_ID(N'TK_TreatTimeCardCategoryP
erformance', N'U') IS NOT NULL DROP TABLE [TK_TreatTimeCardCategoryP
erformance];
GO
CREATE TABLE [TK_TreatTimeCardCategoryP
erformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [TimeCardCategoryID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatTimeCardCategoryP
erformance] PRIMARY KEY ([PerformanceScheme
ID],[TimeCardCategoryID])
);
GO

-- 消耗时效卡业绩
取值员工配置
IF OBJECT_ID(N'TK_TreatTimeCardPerformance', N'U') IS NOT NULL DROP TABLE [TK_TreatTimeCardPerformance];
GO
CREATE TABLE [TK_TreatTimeCardPerformance] (
    [PerformanceScheme
ID] int NOT NULL,
    [TimeCardID] int NOT NULL,
    [PerformancePayRate] decimal(5,4) NULL,
    [PerformanceCardRat] decimal(5,4) NULL,
    [PerformanceCardLargessRate] decimal(5,4) NULL,
    [PerformanceLargess
Rate] decimal(5,4) NULL,
    CONSTRAINT [PK_TK_TreatTimeCardPerformance] PRIMARY KEY ([PerformanceScheme
ID],[TimeCardID])
);
GO

-- 商城预约项目配
IF OBJECT_ID(N'TM_AppointmentProject', N'U') IS NOT NULL DROP TABLE [TM_AppointmentProject];
GO
CREATE TABLE [TM_AppointmentProject] (
    [ProjectID] int NOT NULL,
    CONSTRAINT [PK_TM_AppointmentProject] PRIMARY KEY ([ProjectID])
);
GO

-- 商城预约角色配
IF OBJECT_ID(N'TM_AppointmentServicer', N'U') IS NOT NULL DROP TABLE [TM_AppointmentServicer];
GO
CREATE TABLE [TM_AppointmentServicer] (
    [EntityID] int NOT NULL,
    [AppointmentService
rID] int NOT NULL,
    CONSTRAINT [PK_TM_AppointmentServicer] PRIMARY KEY ([EntityID],[AppointmentService
rID])
);
GO

-- 购物车
IF OBJECT_ID(N'TM_Cart', N'U') IS NOT NULL DROP TABLE [TM_Cart];
GO
CREATE TABLE [TM_Cart] (
    [ID] int NOT NULL,
    [CustomerID] int NOT NULL,
    [EntityID] int NOT NULL,
    [GoodsType] nvarchar(50) NOT NULL,
    [GoodsID] int NOT NULL,
    [Quantity] int NOT NULL,
    CONSTRAINT [PK_TM_Cart] PRIMARY KEY ([ID])
);
GO

-- 组件
IF OBJECT_ID(N'TM_Components', N'U') IS NOT NULL DROP TABLE [TM_Components];
GO
CREATE TABLE [TM_Components] (
    [Code] nvarchar(50) NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Icon] nvarchar(50) NOT NULL,
    [Type] nvarchar(50) NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TM_Components] PRIMARY KEY ([Code])
);
GO

-- 商城顾客管理
IF OBJECT_ID(N'TM_Customer', N'U') IS NOT NULL DROP TABLE [TM_Customer];
GO
CREATE TABLE [TM_Customer] (
    [OpenID] nvarchar(100) NOT NULL,
    [Name] nvarchar(50) NULL,
    [Gender] varchar(1) NULL,
    [PhoneNumber] nvarchar(50) NULL,
    [CreatedOn] datetime NULL,
    [Avatar] nvarchar(500) NULL,
    [UnionID] nvarchar(40) NULL,
    CONSTRAINT [PK_TM_Customer] PRIMARY KEY ([OpenID])
);
GO

-- 店铺信息
IF OBJECT_ID(N'TM_Entity', N'U') IS NOT NULL DROP TABLE [TM_Entity];
GO
CREATE TABLE [TM_Entity] (
    [EntityID] int NOT NULL,
    [EntityLogoURL] nvarchar(256) NULL,
    [ServiceTelephoneNumber] nvarchar(50) NULL,
    [BusinessStartTime] time NULL,
    [BusinessEndTime] time NULL,
    [Description] nvarchar(200) NULL,
    CONSTRAINT [PK_TM_Entity] PRIMARY KEY ([EntityID])
);
GO

-- 营业时间
IF OBJECT_ID(N'TM_EntityBusinessDate', N'U') IS NOT NULL DROP TABLE [TM_EntityBusinessDate];
GO
CREATE TABLE [TM_EntityBusinessDate] (
    [EntityID] int NOT NULL,
    [Data] int NOT NULL,
    CONSTRAINT [PK_TM_EntityBusinessDate] PRIMARY KEY ([EntityID],[Data])
);
GO

-- 
IF OBJECT_ID(N'TM_EntityPhoto', N'U') IS NOT NULL DROP TABLE [TM_EntityPhoto];
GO
CREATE TABLE [TM_EntityPhoto] (
    [ID] int NOT NULL,
    [EntityID] int NOT NULL,
    [PhotoURL] nvarchar(256) NOT NULL,
    [Sequence] int NOT NULL,
    CONSTRAINT [PK_TM_EntityPhoto] PRIMARY KEY ([ID])
);
GO

-- 商品管理
IF OBJECT_ID(N'TM_Goods', N'U') IS NOT NULL DROP TABLE [TM_Goods];
GO
CREATE TABLE [TM_Goods] (
    [ID] int NOT NULL,
    [GoodsType] nvarchar(50) NOT NULL,
    [GoodsID] int NOT NULL,
    [CategoryID] int NOT NULL,
    [Sequence] int NOT NULL,
    CONSTRAINT [PK_TM_Goods] PRIMARY KEY ([ID])
);
GO

-- 商品分类
IF OBJECT_ID(N'TM_GoodsCategory', N'U') IS NOT NULL DROP TABLE [TM_GoodsCategory];
GO
CREATE TABLE [TM_GoodsCategory] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [ParentID] int NOT NULL,
    [Sequence] int NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_TM_GoodsCategory] PRIMARY KEY ([ID])
);
GO

-- 拼团
IF OBJECT_ID(N'TM_Groupon', N'U') IS NOT NULL DROP TABLE [TM_Groupon];
GO
CREATE TABLE [TM_Groupon] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [BeginDateTime] datetime NOT NULL,
    [EndDateTime] datetime NOT NULL,
    [GroupTimeOutDay] int NOT NULL,
    [GroupTimeOutHour] int NOT NULL,
    [GroupTimeOutMinuter] int NOT NULL,
    [GroupLimit] bit NOT NULL,
    [Quota] int NOT NULL,
    [GoodsType] nvarchar(50) NOT NULL,
    [GoodsID] int NOT NULL,
    [ActivityStock] int NOT NULL,
    [JoinGroup] bit NOT NULL,
    [GroupDynamic] bit NOT NULL,
    [ShareText] nvarchar(200) NOT NULL,
    CONSTRAINT [PK_TM_Groupon] PRIMARY KEY ([ID])
);
GO

-- 拼团订单
IF OBJECT_ID(N'TM_GrouponBill', N'U') IS NOT NULL DROP TABLE [TM_GrouponBill];
GO
CREATE TABLE [TM_GrouponBill] (
    [ID] nvarchar(50) NOT NULL,
    [GrouponPriceID] int NOT NULL,
    [BillDate] datetime NOT NULL,
    [BillStatus] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TM_GrouponBill] PRIMARY KEY ([ID])
);
GO

-- 拼团订单详情
IF OBJECT_ID(N'TM_GrouponBillDetail', N'U') IS NOT NULL DROP TABLE [TM_GrouponBillDetail];
GO
CREATE TABLE [TM_GrouponBillDetail] (
    [GrouponBillID] nvarchar(50) NOT NULL,
    [SaleBillID] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TM_GrouponBillDetail] PRIMARY KEY ([GrouponBillID],[SaleBillID])
);
GO

-- 拼团适用门店
IF OBJECT_ID(N'TM_GrouponEntity', N'U') IS NOT NULL DROP TABLE [TM_GrouponEntity];
GO
CREATE TABLE [TM_GrouponEntity] (
    [GrouponID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TM_GrouponEntity] PRIMARY KEY ([GrouponID],[EntityID])
);
GO

-- 拼团价格设置
IF OBJECT_ID(N'TM_GrouponPrice', N'U') IS NOT NULL DROP TABLE [TM_GrouponPrice];
GO
CREATE TABLE [TM_GrouponPrice] (
    [ID] int NOT NULL,
    [GrouponID] int NOT NULL,
    [PeopleNum] int NOT NULL,
    [GroupPrice] decimal(18,2) NOT NULL,
    [DriverPrice] decimal(18,2) NULL,
    CONSTRAINT [PK_TM_GrouponPrice] PRIMARY KEY ([ID])
);
GO

-- 商城首页
IF OBJECT_ID(N'TM_HomeConfig', N'U') IS NOT NULL DROP TABLE [TM_HomeConfig];
GO
CREATE TABLE [TM_HomeConfig] (
    [ComponentsCode] nvarchar(50) NOT NULL,
    [ComponentsPropert] ntext NOT NULL,
    [Sequence] int NOT NULL
);
GO

-- 个人中心
IF OBJECT_ID(N'TM_PersonalCenterConfig', N'U') IS NOT NULL DROP TABLE [TM_PersonalCenterConfig];
GO
CREATE TABLE [TM_PersonalCenterConfig] (
    [ShowSaleBill] bit NOT NULL,
    [HideOfflineSaleBill] bit NOT NULL,
    [ShowTreatBill] bit NOT NULL,
    [ShowAppointmentBi] bit NOT NULL,
    [ShowProductAccoun] bit NOT NULL,
    [ShowProjectAccount] bit NOT NULL,
    [ShowGeneralCardAccount] bit NOT NULL,
    [ShowTimeCardAccount] bit NOT NULL,
    [ShowSavingCardAccount] bit NOT NULL,
    [ShowPackageCardAccount] bit NOT NULL
);
GO

-- 秒杀管理
IF OBJECT_ID(N'TM_Seckill', N'U') IS NOT NULL DROP TABLE [TM_Seckill];
GO
CREATE TABLE [TM_Seckill] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [BeginDateTime] datetime NOT NULL,
    [EndDateTime] datetime NOT NULL,
    [Quota] int NOT NULL,
    [GoodsType] nvarchar(50) NOT NULL,
    [GoodsID] int NOT NULL,
    [SeckillPrice] decimal(18,2) NOT NULL,
    [ActivityStock] int NOT NULL,
    [PayTimeOutMinuter] int NOT NULL,
    CONSTRAINT [PK_TM_Seckill] PRIMARY KEY ([ID])
);
GO

-- 秒杀订单
IF OBJECT_ID(N'TM_SeckillBill', N'U') IS NOT NULL DROP TABLE [TM_SeckillBill];
GO
CREATE TABLE [TM_SeckillBill] (
    [SeckillID] int NOT NULL,
    [SaleBillID] nchar(50) NOT NULL,
    CONSTRAINT [PK_TM_SeckillBill] PRIMARY KEY ([SeckillID],[SaleBillID])
);
GO

-- 秒杀适用门店
IF OBJECT_ID(N'TM_SeckillEntity', N'U') IS NOT NULL DROP TABLE [TM_SeckillEntity];
GO
CREATE TABLE [TM_SeckillEntity] (
    [SeckillID] int NOT NULL,
    [EntityID] int NOT NULL,
    CONSTRAINT [PK_TM_SeckillEntity] PRIMARY KEY ([SeckillID],[EntityID])
);
GO

-- 地区
IF OBJECT_ID(N'TS_Area', N'U') IS NOT NULL DROP TABLE [TS_Area];
GO
CREATE TABLE [TS_Area] (
    [Code] nvarchar(50) NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [CityCode] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TS_Area] PRIMARY KEY ([Code])
);
GO

-- 自动编号
IF OBJECT_ID(N'TS_AutoNumber', N'U') IS NOT NULL DROP TABLE [TS_AutoNumber];
GO
CREATE TABLE [TS_AutoNumber] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Prefix] nvarchar(50) NULL,
    [IsYear] bit NOT NULL,
    [IsMonth] bit NOT NULL,
    [IsDay] bit NOT NULL,
    [Length] int NOT NULL,
    [CurrentNum] varchar(8) NULL,
    [CurrentNumber] int NULL,
    CONSTRAINT [PK_TS_AutoNumber] PRIMARY KEY ([ID])
);
GO

-- 品牌登录页
IF OBJECT_ID(N'TS_BrandLoginPage', N'U') IS NOT NULL DROP TABLE [TS_BrandLoginPage];
GO
CREATE TABLE [TS_BrandLoginPage] (
    [ID] int NOT NULL,
    [BrandLogo] nvarchar(200) NOT NULL,
    [BrandLogoIcon] nvarchar(200) NOT NULL,
    [BrandImage] nvarchar(200) NOT NULL,
    [FrontColor] nvarchar(50) NOT NULL,
    [BackgroundColor] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TS_BrandLoginPage] PRIMARY KEY ([ID])
);
GO

-- 城市
IF OBJECT_ID(N'TS_City', N'U') IS NOT NULL DROP TABLE [TS_City];
GO
CREATE TABLE [TS_City] (
    [Code] nvarchar(50) NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [ProvinceCode] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TS_City] PRIMARY KEY ([Code])
);
GO

-- 打印模板
IF OBJECT_ID(N'TS_PrintTemplate', N'U') IS NOT NULL DROP TABLE [TS_PrintTemplate];
GO
CREATE TABLE [TS_PrintTemplate] (
    [ID] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [TemplateType] nvarchar(50) NOT NULL,
    [Template] ntext NOT NULL,
    [Sequence] int NOT NULL,
    CONSTRAINT [PK_TS_PrintTemplate] PRIMARY KEY ([ID])
);
GO

-- 省份
IF OBJECT_ID(N'TS_Province', N'U') IS NOT NULL DROP TABLE [TS_Province];
GO
CREATE TABLE [TS_Province] (
    [Code] nvarchar(50) NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    CONSTRAINT [PK_TS_Province] PRIMARY KEY ([Code])
);
GO
