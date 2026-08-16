--
-- PostgreSQL database dump
--


-- Dumped from database version 16.15 (Debian 16.15-1.pgdg12+2)
-- Dumped by pg_dump version 16.15 (Debian 16.15-1.pgdg12+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


--
-- Name: ActionType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ActionType" AS ENUM (
    'code',
    'noCode'
);


--
-- Name: ContactAttributeType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ContactAttributeType" AS ENUM (
    'default',
    'custom'
);


--
-- Name: DataMigrationStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."DataMigrationStatus" AS ENUM (
    'pending',
    'applied',
    'failed'
);


--
-- Name: DisplayStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."DisplayStatus" AS ENUM (
    'seen',
    'responded'
);


--
-- Name: EnvironmentType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."EnvironmentType" AS ENUM (
    'production',
    'development'
);


--
-- Name: IdentityProvider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."IdentityProvider" AS ENUM (
    'email',
    'github',
    'google',
    'azuread',
    'openid',
    'saml'
);


--
-- Name: InsightCategory; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."InsightCategory" AS ENUM (
    'featureRequest',
    'complaint',
    'praise',
    'other'
);


--
-- Name: IntegrationType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."IntegrationType" AS ENUM (
    'googleSheets',
    'airtable',
    'notion',
    'slack'
);


--
-- Name: Intention; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."Intention" AS ENUM (
    'survey_user_segments',
    'survey_at_specific_point_in_user_journey',
    'enrich_customer_profiles',
    'collect_all_user_feedback_on_one_platform',
    'other'
);


--
-- Name: MembershipRole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."MembershipRole" AS ENUM (
    'owner',
    'admin',
    'editor',
    'developer',
    'viewer'
);


--
-- Name: Objective; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."Objective" AS ENUM (
    'increase_conversion',
    'improve_user_retention',
    'increase_user_adoption',
    'sharpen_marketing_messaging',
    'support_sales',
    'other'
);


--
-- Name: OrganizationRole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."OrganizationRole" AS ENUM (
    'owner',
    'manager',
    'member',
    'billing'
);


--
-- Name: PipelineTriggers; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."PipelineTriggers" AS ENUM (
    'responseCreated',
    'responseUpdated',
    'responseFinished'
);


--
-- Name: ProjectTeamPermission; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ProjectTeamPermission" AS ENUM (
    'read',
    'readWrite',
    'manage'
);


--
-- Name: Role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."Role" AS ENUM (
    'project_manager',
    'engineer',
    'founder',
    'marketing_specialist',
    'other'
);


--
-- Name: Sentiment; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."Sentiment" AS ENUM (
    'positive',
    'negative',
    'neutral'
);


--
-- Name: SurveyAttributeFilterCondition; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."SurveyAttributeFilterCondition" AS ENUM (
    'equals',
    'notEquals'
);


--
-- Name: SurveyStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."SurveyStatus" AS ENUM (
    'draft',
    'inProgress',
    'paused',
    'completed',
    'scheduled'
);


--
-- Name: SurveyType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."SurveyType" AS ENUM (
    'link',
    'web',
    'website',
    'app'
);


--
-- Name: TeamUserRole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."TeamUserRole" AS ENUM (
    'admin',
    'contributor'
);


--
-- Name: WebhookSource; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WebhookSource" AS ENUM (
    'user',
    'zapier',
    'make',
    'n8n',
    'activepieces'
);


--
-- Name: WidgetPlacement; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WidgetPlacement" AS ENUM (
    'bottomLeft',
    'bottomRight',
    'topLeft',
    'topRight',
    'center'
);


--
-- Name: displayOptions; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."displayOptions" AS ENUM (
    'displayOnce',
    'displayMultiple',
    'respondMultiple',
    'displaySome'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Account; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Account" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    "userId" text NOT NULL,
    type text NOT NULL,
    provider text NOT NULL,
    "providerAccountId" text NOT NULL,
    access_token text,
    refresh_token text,
    expires_at integer,
    token_type text,
    scope text,
    id_token text,
    session_state text,
    ext_expires_in integer
);


--
-- Name: ActionClass; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ActionClass" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    name text NOT NULL,
    description text,
    type public."ActionType" NOT NULL,
    "noCodeConfig" jsonb,
    "environmentId" text NOT NULL,
    key text
);


--
-- Name: ApiKey; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ApiKey" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "lastUsedAt" timestamp(3) without time zone,
    label text,
    "hashedKey" text NOT NULL,
    "environmentId" text NOT NULL
);


--
-- Name: Contact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Contact" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    "environmentId" text NOT NULL,
    "userId" text
);


--
-- Name: ContactAttribute; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ContactAttribute" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    "attributeKeyId" text NOT NULL,
    "contactId" text NOT NULL,
    value text NOT NULL
);


--
-- Name: ContactAttributeKey; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ContactAttributeKey" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    name text,
    description text,
    "environmentId" text NOT NULL,
    type public."ContactAttributeType" DEFAULT 'custom'::public."ContactAttributeType" NOT NULL,
    key text NOT NULL,
    "isUnique" boolean DEFAULT false NOT NULL
);


--
-- Name: DataMigration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DataMigration" (
    id text NOT NULL,
    started_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    finished_at timestamp(3) without time zone,
    status public."DataMigrationStatus" NOT NULL,
    name text NOT NULL
);


--
-- Name: Display; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Display" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    "surveyId" text NOT NULL,
    "contactId" text,
    status public."DisplayStatus",
    "responseId" text
);


--
-- Name: Document; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Document" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    "environmentId" text NOT NULL,
    "surveyId" text,
    "responseId" text,
    "questionId" text,
    sentiment public."Sentiment" NOT NULL,
    "isSpam" boolean NOT NULL,
    text text NOT NULL,
    vector public.vector(512)
);


--
-- Name: DocumentInsight; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DocumentInsight" (
    "documentId" text NOT NULL,
    "insightId" text NOT NULL
);


--
-- Name: Environment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Environment" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    type public."EnvironmentType" NOT NULL,
    "projectId" text NOT NULL,
    "widgetSetupCompleted" boolean DEFAULT false NOT NULL,
    "appSetupCompleted" boolean DEFAULT false NOT NULL
);


--
-- Name: Insight; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Insight" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    "environmentId" text NOT NULL,
    category public."InsightCategory" NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    vector public.vector(512)
);


--
-- Name: Integration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Integration" (
    id text NOT NULL,
    type public."IntegrationType" NOT NULL,
    "environmentId" text NOT NULL,
    config jsonb NOT NULL
);


--
-- Name: Invite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Invite" (
    id text NOT NULL,
    email text NOT NULL,
    name text,
    "organizationId" text NOT NULL,
    "creatorId" text NOT NULL,
    "acceptorId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "deprecatedRole" public."MembershipRole",
    role public."OrganizationRole" DEFAULT 'member'::public."OrganizationRole" NOT NULL,
    "teamIds" text[] DEFAULT ARRAY[]::text[]
);


--
-- Name: Language; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Language" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    code text NOT NULL,
    alias text,
    "projectId" text NOT NULL
);


--
-- Name: Membership; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Membership" (
    "organizationId" text NOT NULL,
    "userId" text NOT NULL,
    accepted boolean DEFAULT false NOT NULL,
    "deprecatedRole" public."MembershipRole",
    role public."OrganizationRole" DEFAULT 'member'::public."OrganizationRole" NOT NULL
);


--
-- Name: Organization; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Organization" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    name text NOT NULL,
    billing jsonb NOT NULL,
    "isAIEnabled" boolean DEFAULT false NOT NULL,
    whitelabel jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: Project; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Project" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    name text NOT NULL,
    "organizationId" text NOT NULL,
    "brandColor" text,
    "recontactDays" integer DEFAULT 7 NOT NULL,
    "linkSurveyBranding" boolean DEFAULT true NOT NULL,
    "clickOutsideClose" boolean DEFAULT true NOT NULL,
    "darkOverlay" boolean DEFAULT false NOT NULL,
    placement public."WidgetPlacement" DEFAULT 'bottomRight'::public."WidgetPlacement" NOT NULL,
    "highlightBorderColor" text,
    "inAppSurveyBranding" boolean DEFAULT true NOT NULL,
    styling jsonb DEFAULT '{"allowStyleOverwrite": true}'::jsonb NOT NULL,
    logo jsonb,
    config jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: ProjectTeam; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ProjectTeam" (
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    "projectId" text NOT NULL,
    "teamId" text NOT NULL,
    permission public."ProjectTeamPermission" DEFAULT 'read'::public."ProjectTeamPermission" NOT NULL
);


--
-- Name: Response; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Response" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    finished boolean DEFAULT false NOT NULL,
    "surveyId" text NOT NULL,
    "contactId" text,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    meta jsonb DEFAULT '{}'::jsonb NOT NULL,
    "contactAttributes" jsonb,
    "singleUseId" text,
    ttc jsonb DEFAULT '{}'::jsonb NOT NULL,
    language text,
    variables jsonb DEFAULT '{}'::jsonb NOT NULL,
    "displayId" text,
    "endingId" text
);


--
-- Name: ResponseNote; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ResponseNote" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    "responseId" text NOT NULL,
    "userId" text NOT NULL,
    text text NOT NULL,
    "isEdited" boolean DEFAULT false NOT NULL,
    "isResolved" boolean DEFAULT false NOT NULL
);


--
-- Name: Segment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Segment" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    title text NOT NULL,
    description text,
    "isPrivate" boolean DEFAULT true NOT NULL,
    filters jsonb DEFAULT '[]'::jsonb NOT NULL,
    "environmentId" text NOT NULL
);


--
-- Name: ShortUrl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ShortUrl" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    url text NOT NULL
);


--
-- Name: Survey; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Survey" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    name text NOT NULL,
    "environmentId" text NOT NULL,
    status public."SurveyStatus" DEFAULT 'draft'::public."SurveyStatus" NOT NULL,
    questions jsonb DEFAULT '[]'::jsonb NOT NULL,
    "displayOption" public."displayOptions" DEFAULT 'displayOnce'::public."displayOptions" NOT NULL,
    "recontactDays" integer,
    "thankYouCard" jsonb,
    type public."SurveyType" DEFAULT 'web'::public."SurveyType" NOT NULL,
    "autoClose" integer,
    delay integer DEFAULT 0 NOT NULL,
    "autoComplete" integer,
    "redirectUrl" text,
    "closeOnDate" timestamp(3) without time zone,
    "surveyClosedMessage" jsonb,
    "verifyEmail" jsonb,
    "singleUse" jsonb DEFAULT '{"enabled": false, "isEncrypted": true}'::jsonb,
    "projectOverwrites" jsonb,
    "hiddenFields" jsonb DEFAULT '{"enabled": false}'::jsonb NOT NULL,
    pin text,
    "welcomeCard" jsonb DEFAULT '{"enabled": false}'::jsonb NOT NULL,
    styling jsonb,
    "resultShareKey" text,
    "displayPercentage" numeric(65,30),
    "createdBy" text,
    "segmentId" text,
    "inlineTriggers" jsonb,
    "runOnDate" timestamp(3) without time zone,
    "displayLimit" integer,
    "showLanguageSwitch" boolean,
    "isVerifyEmailEnabled" boolean DEFAULT false NOT NULL,
    endings jsonb[] DEFAULT ARRAY[]::jsonb[],
    variables jsonb DEFAULT '[]'::jsonb NOT NULL,
    "isSingleResponsePerEmailEnabled" boolean DEFAULT false NOT NULL,
    "isBackButtonHidden" boolean DEFAULT false NOT NULL
);


--
-- Name: SurveyAttributeFilter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SurveyAttributeFilter" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    "attributeKeyId" text NOT NULL,
    "surveyId" text NOT NULL,
    condition public."SurveyAttributeFilterCondition" NOT NULL,
    value text NOT NULL
);


--
-- Name: SurveyFollowUp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SurveyFollowUp" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    "surveyId" text NOT NULL,
    name text NOT NULL,
    trigger jsonb NOT NULL,
    action jsonb NOT NULL
);


--
-- Name: SurveyLanguage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SurveyLanguage" (
    "languageId" text NOT NULL,
    "surveyId" text NOT NULL,
    "default" boolean DEFAULT false NOT NULL,
    enabled boolean DEFAULT true NOT NULL
);


--
-- Name: SurveyTrigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SurveyTrigger" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    "surveyId" text NOT NULL,
    "actionClassId" text NOT NULL
);


--
-- Name: Tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Tag" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    name text NOT NULL,
    "environmentId" text NOT NULL
);


--
-- Name: TagsOnResponses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TagsOnResponses" (
    "responseId" text NOT NULL,
    "tagId" text NOT NULL
);


--
-- Name: Team; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Team" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    name text NOT NULL,
    "organizationId" text NOT NULL
);


--
-- Name: TeamUser; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TeamUser" (
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    "teamId" text NOT NULL,
    "userId" text NOT NULL,
    role public."TeamUserRole" NOT NULL
);


--
-- Name: User; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."User" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    email_verified timestamp(3) without time zone,
    password text,
    "identityProvider" public."IdentityProvider" DEFAULT 'email'::public."IdentityProvider" NOT NULL,
    "identityProviderAccountId" text,
    "groupId" text,
    objective public."Objective",
    role public."Role",
    "notificationSettings" jsonb DEFAULT '{}'::jsonb NOT NULL,
    "backupCodes" text,
    "twoFactorEnabled" boolean DEFAULT false NOT NULL,
    "twoFactorSecret" text,
    "imageUrl" text,
    locale text DEFAULT 'en-US'::text NOT NULL
);


--
-- Name: Webhook; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Webhook" (
    id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    url text NOT NULL,
    "environmentId" text NOT NULL,
    triggers public."PipelineTriggers"[],
    "surveyIds" text[],
    name text,
    source public."WebhookSource" DEFAULT 'user'::public."WebhookSource" NOT NULL
);


--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


--
-- Name: Account Account_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Account"
    ADD CONSTRAINT "Account_pkey" PRIMARY KEY (id);


--
-- Name: ActionClass ActionClass_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ActionClass"
    ADD CONSTRAINT "ActionClass_pkey" PRIMARY KEY (id);


--
-- Name: ApiKey ApiKey_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ApiKey"
    ADD CONSTRAINT "ApiKey_pkey" PRIMARY KEY (id);


--
-- Name: ContactAttributeKey ContactAttributeKey_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ContactAttributeKey"
    ADD CONSTRAINT "ContactAttributeKey_pkey" PRIMARY KEY (id);


--
-- Name: ContactAttribute ContactAttribute_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ContactAttribute"
    ADD CONSTRAINT "ContactAttribute_pkey" PRIMARY KEY (id);


--
-- Name: Contact Contact_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Contact"
    ADD CONSTRAINT "Contact_pkey" PRIMARY KEY (id);


--
-- Name: DataMigration DataMigration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DataMigration"
    ADD CONSTRAINT "DataMigration_pkey" PRIMARY KEY (id);


--
-- Name: Display Display_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Display"
    ADD CONSTRAINT "Display_pkey" PRIMARY KEY (id);


--
-- Name: DocumentInsight DocumentInsight_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DocumentInsight"
    ADD CONSTRAINT "DocumentInsight_pkey" PRIMARY KEY ("documentId", "insightId");


--
-- Name: Document Document_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Document"
    ADD CONSTRAINT "Document_pkey" PRIMARY KEY (id);


--
-- Name: Environment Environment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Environment"
    ADD CONSTRAINT "Environment_pkey" PRIMARY KEY (id);


--
-- Name: Insight Insight_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Insight"
    ADD CONSTRAINT "Insight_pkey" PRIMARY KEY (id);


--
-- Name: Integration Integration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Integration"
    ADD CONSTRAINT "Integration_pkey" PRIMARY KEY (id);


--
-- Name: Invite Invite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Invite"
    ADD CONSTRAINT "Invite_pkey" PRIMARY KEY (id);


--
-- Name: Language Language_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Language"
    ADD CONSTRAINT "Language_pkey" PRIMARY KEY (id);


--
-- Name: Membership Membership_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Membership"
    ADD CONSTRAINT "Membership_pkey" PRIMARY KEY ("userId", "organizationId");


--
-- Name: Organization Organization_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Organization"
    ADD CONSTRAINT "Organization_pkey" PRIMARY KEY (id);


--
-- Name: ProjectTeam ProjectTeam_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ProjectTeam"
    ADD CONSTRAINT "ProjectTeam_pkey" PRIMARY KEY ("projectId", "teamId");


--
-- Name: Project Project_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Project"
    ADD CONSTRAINT "Project_pkey" PRIMARY KEY (id);


--
-- Name: ResponseNote ResponseNote_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ResponseNote"
    ADD CONSTRAINT "ResponseNote_pkey" PRIMARY KEY (id);


--
-- Name: Response Response_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Response"
    ADD CONSTRAINT "Response_pkey" PRIMARY KEY (id);


--
-- Name: Segment Segment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Segment"
    ADD CONSTRAINT "Segment_pkey" PRIMARY KEY (id);


--
-- Name: ShortUrl ShortUrl_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ShortUrl"
    ADD CONSTRAINT "ShortUrl_pkey" PRIMARY KEY (id);


--
-- Name: SurveyAttributeFilter SurveyAttributeFilter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SurveyAttributeFilter"
    ADD CONSTRAINT "SurveyAttributeFilter_pkey" PRIMARY KEY (id);


--
-- Name: SurveyFollowUp SurveyFollowUp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SurveyFollowUp"
    ADD CONSTRAINT "SurveyFollowUp_pkey" PRIMARY KEY (id);


--
-- Name: SurveyLanguage SurveyLanguage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SurveyLanguage"
    ADD CONSTRAINT "SurveyLanguage_pkey" PRIMARY KEY ("languageId", "surveyId");


--
-- Name: SurveyTrigger SurveyTrigger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SurveyTrigger"
    ADD CONSTRAINT "SurveyTrigger_pkey" PRIMARY KEY (id);


--
-- Name: Survey Survey_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Survey"
    ADD CONSTRAINT "Survey_pkey" PRIMARY KEY (id);


--
-- Name: Tag Tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Tag"
    ADD CONSTRAINT "Tag_pkey" PRIMARY KEY (id);


--
-- Name: TagsOnResponses TagsOnResponses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TagsOnResponses"
    ADD CONSTRAINT "TagsOnResponses_pkey" PRIMARY KEY ("responseId", "tagId");


--
-- Name: TeamUser TeamUser_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TeamUser"
    ADD CONSTRAINT "TeamUser_pkey" PRIMARY KEY ("teamId", "userId");


--
-- Name: Team Team_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Team"
    ADD CONSTRAINT "Team_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: Webhook Webhook_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Webhook"
    ADD CONSTRAINT "Webhook_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: Account_provider_providerAccountId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Account_provider_providerAccountId_key" ON public."Account" USING btree (provider, "providerAccountId");


--
-- Name: Account_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Account_userId_idx" ON public."Account" USING btree ("userId");


--
-- Name: ActionClass_environmentId_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ActionClass_environmentId_created_at_idx" ON public."ActionClass" USING btree ("environmentId", created_at);


--
-- Name: ActionClass_key_environmentId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ActionClass_key_environmentId_key" ON public."ActionClass" USING btree (key, "environmentId");


--
-- Name: ActionClass_name_environmentId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ActionClass_name_environmentId_key" ON public."ActionClass" USING btree (name, "environmentId");


--
-- Name: ApiKey_environmentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ApiKey_environmentId_idx" ON public."ApiKey" USING btree ("environmentId");


--
-- Name: ApiKey_hashedKey_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ApiKey_hashedKey_key" ON public."ApiKey" USING btree ("hashedKey");


--
-- Name: ApiKey_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ApiKey_id_key" ON public."ApiKey" USING btree (id);


--
-- Name: ContactAttributeKey_environmentId_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ContactAttributeKey_environmentId_created_at_idx" ON public."ContactAttributeKey" USING btree ("environmentId", created_at);


--
-- Name: ContactAttributeKey_key_environmentId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ContactAttributeKey_key_environmentId_key" ON public."ContactAttributeKey" USING btree (key, "environmentId");


--
-- Name: ContactAttribute_attributeKeyId_value_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ContactAttribute_attributeKeyId_value_idx" ON public."ContactAttribute" USING btree ("attributeKeyId", value);


--
-- Name: ContactAttribute_contactId_attributeKeyId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ContactAttribute_contactId_attributeKeyId_key" ON public."ContactAttribute" USING btree ("contactId", "attributeKeyId");


--
-- Name: Contact_environmentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Contact_environmentId_idx" ON public."Contact" USING btree ("environmentId");


--
-- Name: DataMigration_name_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DataMigration_name_key" ON public."DataMigration" USING btree (name);


--
-- Name: Display_contactId_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Display_contactId_created_at_idx" ON public."Display" USING btree ("contactId", created_at);


--
-- Name: Display_responseId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Display_responseId_key" ON public."Display" USING btree ("responseId");


--
-- Name: Display_surveyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Display_surveyId_idx" ON public."Display" USING btree ("surveyId");


--
-- Name: DocumentInsight_insightId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DocumentInsight_insightId_idx" ON public."DocumentInsight" USING btree ("insightId");


--
-- Name: Document_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Document_created_at_idx" ON public."Document" USING btree (created_at);


--
-- Name: Document_responseId_questionId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Document_responseId_questionId_key" ON public."Document" USING btree ("responseId", "questionId");


--
-- Name: Environment_projectId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Environment_projectId_idx" ON public."Environment" USING btree ("projectId");


--
-- Name: Integration_environmentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Integration_environmentId_idx" ON public."Integration" USING btree ("environmentId");


--
-- Name: Integration_type_environmentId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Integration_type_environmentId_key" ON public."Integration" USING btree (type, "environmentId");


--
-- Name: Invite_email_organizationId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Invite_email_organizationId_idx" ON public."Invite" USING btree (email, "organizationId");


--
-- Name: Invite_organizationId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Invite_organizationId_idx" ON public."Invite" USING btree ("organizationId");


--
-- Name: Language_projectId_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Language_projectId_code_key" ON public."Language" USING btree ("projectId", code);


--
-- Name: Membership_organizationId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Membership_organizationId_idx" ON public."Membership" USING btree ("organizationId");


--
-- Name: Membership_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Membership_userId_idx" ON public."Membership" USING btree ("userId");


--
-- Name: ProjectTeam_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ProjectTeam_teamId_idx" ON public."ProjectTeam" USING btree ("teamId");


--
-- Name: Project_organizationId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Project_organizationId_idx" ON public."Project" USING btree ("organizationId");


--
-- Name: Project_organizationId_name_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Project_organizationId_name_key" ON public."Project" USING btree ("organizationId", name);


--
-- Name: ResponseNote_responseId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ResponseNote_responseId_idx" ON public."ResponseNote" USING btree ("responseId");


--
-- Name: Response_contactId_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Response_contactId_created_at_idx" ON public."Response" USING btree ("contactId", created_at);


--
-- Name: Response_displayId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Response_displayId_key" ON public."Response" USING btree ("displayId");


--
-- Name: Response_surveyId_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Response_surveyId_created_at_idx" ON public."Response" USING btree ("surveyId", created_at);


--
-- Name: Response_surveyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Response_surveyId_idx" ON public."Response" USING btree ("surveyId");


--
-- Name: Response_surveyId_singleUseId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Response_surveyId_singleUseId_key" ON public."Response" USING btree ("surveyId", "singleUseId");


--
-- Name: Segment_environmentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Segment_environmentId_idx" ON public."Segment" USING btree ("environmentId");


--
-- Name: Segment_environmentId_title_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Segment_environmentId_title_key" ON public."Segment" USING btree ("environmentId", title);


--
-- Name: ShortUrl_url_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ShortUrl_url_key" ON public."ShortUrl" USING btree (url);


--
-- Name: SurveyAttributeFilter_attributeKeyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SurveyAttributeFilter_attributeKeyId_idx" ON public."SurveyAttributeFilter" USING btree ("attributeKeyId");


--
-- Name: SurveyAttributeFilter_surveyId_attributeKeyId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SurveyAttributeFilter_surveyId_attributeKeyId_key" ON public."SurveyAttributeFilter" USING btree ("surveyId", "attributeKeyId");


--
-- Name: SurveyAttributeFilter_surveyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SurveyAttributeFilter_surveyId_idx" ON public."SurveyAttributeFilter" USING btree ("surveyId");


--
-- Name: SurveyLanguage_languageId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SurveyLanguage_languageId_idx" ON public."SurveyLanguage" USING btree ("languageId");


--
-- Name: SurveyLanguage_surveyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SurveyLanguage_surveyId_idx" ON public."SurveyLanguage" USING btree ("surveyId");


--
-- Name: SurveyTrigger_surveyId_actionClassId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SurveyTrigger_surveyId_actionClassId_key" ON public."SurveyTrigger" USING btree ("surveyId", "actionClassId");


--
-- Name: SurveyTrigger_surveyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SurveyTrigger_surveyId_idx" ON public."SurveyTrigger" USING btree ("surveyId");


--
-- Name: Survey_environmentId_updated_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Survey_environmentId_updated_at_idx" ON public."Survey" USING btree ("environmentId", updated_at);


--
-- Name: Survey_resultShareKey_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Survey_resultShareKey_key" ON public."Survey" USING btree ("resultShareKey");


--
-- Name: Survey_segmentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Survey_segmentId_idx" ON public."Survey" USING btree ("segmentId");


--
-- Name: Tag_environmentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Tag_environmentId_idx" ON public."Tag" USING btree ("environmentId");


--
-- Name: Tag_environmentId_name_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Tag_environmentId_name_key" ON public."Tag" USING btree ("environmentId", name);


--
-- Name: TagsOnResponses_responseId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TagsOnResponses_responseId_idx" ON public."TagsOnResponses" USING btree ("responseId");


--
-- Name: TeamUser_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TeamUser_userId_idx" ON public."TeamUser" USING btree ("userId");


--
-- Name: Team_organizationId_name_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Team_organizationId_name_key" ON public."Team" USING btree ("organizationId", name);


--
-- Name: User_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "User_email_idx" ON public."User" USING btree (email);


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: Webhook_environmentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Webhook_environmentId_idx" ON public."Webhook" USING btree ("environmentId");


--
-- Name: Account Account_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Account"
    ADD CONSTRAINT "Account_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ActionClass ActionClass_environmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ActionClass"
    ADD CONSTRAINT "ActionClass_environmentId_fkey" FOREIGN KEY ("environmentId") REFERENCES public."Environment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ApiKey ApiKey_environmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ApiKey"
    ADD CONSTRAINT "ApiKey_environmentId_fkey" FOREIGN KEY ("environmentId") REFERENCES public."Environment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ContactAttributeKey ContactAttributeKey_environmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ContactAttributeKey"
    ADD CONSTRAINT "ContactAttributeKey_environmentId_fkey" FOREIGN KEY ("environmentId") REFERENCES public."Environment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ContactAttribute ContactAttribute_attributeKeyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ContactAttribute"
    ADD CONSTRAINT "ContactAttribute_attributeKeyId_fkey" FOREIGN KEY ("attributeKeyId") REFERENCES public."ContactAttributeKey"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ContactAttribute ContactAttribute_contactId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ContactAttribute"
    ADD CONSTRAINT "ContactAttribute_contactId_fkey" FOREIGN KEY ("contactId") REFERENCES public."Contact"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Contact Contact_environmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Contact"
    ADD CONSTRAINT "Contact_environmentId_fkey" FOREIGN KEY ("environmentId") REFERENCES public."Environment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Display Display_contactId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Display"
    ADD CONSTRAINT "Display_contactId_fkey" FOREIGN KEY ("contactId") REFERENCES public."Contact"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Display Display_surveyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Display"
    ADD CONSTRAINT "Display_surveyId_fkey" FOREIGN KEY ("surveyId") REFERENCES public."Survey"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DocumentInsight DocumentInsight_documentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DocumentInsight"
    ADD CONSTRAINT "DocumentInsight_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES public."Document"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DocumentInsight DocumentInsight_insightId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DocumentInsight"
    ADD CONSTRAINT "DocumentInsight_insightId_fkey" FOREIGN KEY ("insightId") REFERENCES public."Insight"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Document Document_environmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Document"
    ADD CONSTRAINT "Document_environmentId_fkey" FOREIGN KEY ("environmentId") REFERENCES public."Environment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Document Document_responseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Document"
    ADD CONSTRAINT "Document_responseId_fkey" FOREIGN KEY ("responseId") REFERENCES public."Response"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Document Document_surveyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Document"
    ADD CONSTRAINT "Document_surveyId_fkey" FOREIGN KEY ("surveyId") REFERENCES public."Survey"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Environment Environment_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Environment"
    ADD CONSTRAINT "Environment_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public."Project"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Insight Insight_environmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Insight"
    ADD CONSTRAINT "Insight_environmentId_fkey" FOREIGN KEY ("environmentId") REFERENCES public."Environment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Integration Integration_environmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Integration"
    ADD CONSTRAINT "Integration_environmentId_fkey" FOREIGN KEY ("environmentId") REFERENCES public."Environment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Invite Invite_acceptorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Invite"
    ADD CONSTRAINT "Invite_acceptorId_fkey" FOREIGN KEY ("acceptorId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Invite Invite_creatorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Invite"
    ADD CONSTRAINT "Invite_creatorId_fkey" FOREIGN KEY ("creatorId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Invite Invite_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Invite"
    ADD CONSTRAINT "Invite_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Organization"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Language Language_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Language"
    ADD CONSTRAINT "Language_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public."Project"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Membership Membership_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Membership"
    ADD CONSTRAINT "Membership_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Organization"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Membership Membership_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Membership"
    ADD CONSTRAINT "Membership_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ProjectTeam ProjectTeam_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ProjectTeam"
    ADD CONSTRAINT "ProjectTeam_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public."Project"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ProjectTeam ProjectTeam_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ProjectTeam"
    ADD CONSTRAINT "ProjectTeam_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Project Project_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Project"
    ADD CONSTRAINT "Project_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Organization"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ResponseNote ResponseNote_responseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ResponseNote"
    ADD CONSTRAINT "ResponseNote_responseId_fkey" FOREIGN KEY ("responseId") REFERENCES public."Response"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ResponseNote ResponseNote_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ResponseNote"
    ADD CONSTRAINT "ResponseNote_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Response Response_contactId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Response"
    ADD CONSTRAINT "Response_contactId_fkey" FOREIGN KEY ("contactId") REFERENCES public."Contact"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Response Response_displayId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Response"
    ADD CONSTRAINT "Response_displayId_fkey" FOREIGN KEY ("displayId") REFERENCES public."Display"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Response Response_surveyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Response"
    ADD CONSTRAINT "Response_surveyId_fkey" FOREIGN KEY ("surveyId") REFERENCES public."Survey"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Segment Segment_environmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Segment"
    ADD CONSTRAINT "Segment_environmentId_fkey" FOREIGN KEY ("environmentId") REFERENCES public."Environment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SurveyAttributeFilter SurveyAttributeFilter_attributeKeyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SurveyAttributeFilter"
    ADD CONSTRAINT "SurveyAttributeFilter_attributeKeyId_fkey" FOREIGN KEY ("attributeKeyId") REFERENCES public."ContactAttributeKey"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SurveyAttributeFilter SurveyAttributeFilter_surveyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SurveyAttributeFilter"
    ADD CONSTRAINT "SurveyAttributeFilter_surveyId_fkey" FOREIGN KEY ("surveyId") REFERENCES public."Survey"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SurveyFollowUp SurveyFollowUp_surveyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SurveyFollowUp"
    ADD CONSTRAINT "SurveyFollowUp_surveyId_fkey" FOREIGN KEY ("surveyId") REFERENCES public."Survey"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SurveyLanguage SurveyLanguage_languageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SurveyLanguage"
    ADD CONSTRAINT "SurveyLanguage_languageId_fkey" FOREIGN KEY ("languageId") REFERENCES public."Language"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SurveyLanguage SurveyLanguage_surveyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SurveyLanguage"
    ADD CONSTRAINT "SurveyLanguage_surveyId_fkey" FOREIGN KEY ("surveyId") REFERENCES public."Survey"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SurveyTrigger SurveyTrigger_actionClassId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SurveyTrigger"
    ADD CONSTRAINT "SurveyTrigger_actionClassId_fkey" FOREIGN KEY ("actionClassId") REFERENCES public."ActionClass"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SurveyTrigger SurveyTrigger_surveyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SurveyTrigger"
    ADD CONSTRAINT "SurveyTrigger_surveyId_fkey" FOREIGN KEY ("surveyId") REFERENCES public."Survey"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Survey Survey_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Survey"
    ADD CONSTRAINT "Survey_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Survey Survey_environmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Survey"
    ADD CONSTRAINT "Survey_environmentId_fkey" FOREIGN KEY ("environmentId") REFERENCES public."Environment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Survey Survey_segmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Survey"
    ADD CONSTRAINT "Survey_segmentId_fkey" FOREIGN KEY ("segmentId") REFERENCES public."Segment"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Tag Tag_environmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Tag"
    ADD CONSTRAINT "Tag_environmentId_fkey" FOREIGN KEY ("environmentId") REFERENCES public."Environment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TagsOnResponses TagsOnResponses_responseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TagsOnResponses"
    ADD CONSTRAINT "TagsOnResponses_responseId_fkey" FOREIGN KEY ("responseId") REFERENCES public."Response"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TagsOnResponses TagsOnResponses_tagId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TagsOnResponses"
    ADD CONSTRAINT "TagsOnResponses_tagId_fkey" FOREIGN KEY ("tagId") REFERENCES public."Tag"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TeamUser TeamUser_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TeamUser"
    ADD CONSTRAINT "TeamUser_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TeamUser TeamUser_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TeamUser"
    ADD CONSTRAINT "TeamUser_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Team Team_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Team"
    ADD CONSTRAINT "Team_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Organization"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Webhook Webhook_environmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Webhook"
    ADD CONSTRAINT "Webhook_environmentId_fkey" FOREIGN KEY ("environmentId") REFERENCES public."Environment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


