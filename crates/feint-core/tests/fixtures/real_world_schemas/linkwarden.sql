--
-- PostgreSQL database dump
--


-- Dumped from database version 16.15 (Debian 16.15-1.pgdg13+2)
-- Dumped by pg_dump version 16.15 (Debian 16.15-1.pgdg13+2)

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
-- Name: AiTaggingMethod; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."AiTaggingMethod" AS ENUM (
    'DISABLED',
    'GENERATE',
    'PREDEFINED',
    'EXISTING'
);


--
-- Name: AppMigrationStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."AppMigrationStatus" AS ENUM (
    'APPLIED',
    'PENDING',
    'FAILED'
);


--
-- Name: DashboardSectionType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."DashboardSectionType" AS ENUM (
    'STATS',
    'RECENT_LINKS',
    'PINNED_LINKS',
    'COLLECTION'
);


--
-- Name: LinksRouteTo; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."LinksRouteTo" AS ENUM (
    'ORIGINAL',
    'PDF',
    'READABLE',
    'MONOLITH',
    'SCREENSHOT',
    'DETAILS'
);


--
-- Name: SubscriptionProvider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."SubscriptionProvider" AS ENUM (
    'STRIPE',
    'APPLE',
    'GOOGLE'
);


--
-- Name: Theme; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."Theme" AS ENUM (
    'dark',
    'light',
    'auto'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: AccessToken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AccessToken" (
    id integer NOT NULL,
    name text NOT NULL,
    "userId" integer NOT NULL,
    token text NOT NULL,
    revoked boolean DEFAULT false NOT NULL,
    expires timestamp(3) without time zone NOT NULL,
    "lastUsedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "isSession" boolean DEFAULT false NOT NULL
);


--
-- Name: AccessToken_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."AccessToken_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: AccessToken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."AccessToken_id_seq" OWNED BY public."AccessToken".id;


--
-- Name: Account; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Account" (
    id text NOT NULL,
    "userId" integer NOT NULL,
    type text NOT NULL,
    provider text NOT NULL,
    "providerAccountId" text NOT NULL,
    refresh_token text,
    access_token text,
    expires_at integer,
    token_type text,
    scope text,
    id_token text,
    session_state text
);


--
-- Name: AppMigration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AppMigration" (
    id integer NOT NULL,
    name text NOT NULL,
    status public."AppMigrationStatus" NOT NULL,
    "finishedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: AppMigration_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."AppMigration_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: AppMigration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."AppMigration_id_seq" OWNED BY public."AppMigration".id;


--
-- Name: Collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Collection" (
    id integer NOT NULL,
    name text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    color text DEFAULT '#0ea5e9'::text NOT NULL,
    "isPublic" boolean DEFAULT false NOT NULL,
    "ownerId" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "parentId" integer,
    icon text,
    "iconWeight" text,
    "createdById" integer
);


--
-- Name: Collection_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Collection_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Collection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Collection_id_seq" OWNED BY public."Collection".id;


--
-- Name: DashboardSection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DashboardSection" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "collectionId" integer,
    type public."DashboardSectionType" NOT NULL,
    "order" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: DashboardSection_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."DashboardSection_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: DashboardSection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."DashboardSection_id_seq" OWNED BY public."DashboardSection".id;


--
-- Name: Highlight; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Highlight" (
    id integer NOT NULL,
    color text NOT NULL,
    comment text,
    "linkId" integer NOT NULL,
    "userId" integer NOT NULL,
    "startOffset" integer NOT NULL,
    "endOffset" integer NOT NULL,
    text text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Highlight_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Highlight_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Highlight_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Highlight_id_seq" OWNED BY public."Highlight".id;


--
-- Name: Link; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Link" (
    id integer NOT NULL,
    name text DEFAULT ''::text NOT NULL,
    url text,
    description text DEFAULT ''::text NOT NULL,
    "collectionId" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    pdf text,
    image text,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    readable text,
    "lastPreserved" timestamp(3) without time zone,
    "textContent" text,
    type text DEFAULT 'url'::text NOT NULL,
    preview text,
    "importDate" timestamp(3) without time zone,
    monolith text,
    color text,
    icon text,
    "iconWeight" text,
    "createdById" integer,
    "aiTagged" boolean DEFAULT false NOT NULL,
    "indexVersion" integer,
    "clientSide" boolean DEFAULT false NOT NULL,
    "metaDescription" text
);


--
-- Name: Link_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Link_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Link_id_seq" OWNED BY public."Link".id;


--
-- Name: PasswordResetToken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PasswordResetToken" (
    identifier text NOT NULL,
    token text NOT NULL,
    expires timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: RssSubscription; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RssSubscription" (
    id integer NOT NULL,
    url text NOT NULL,
    name text NOT NULL,
    "lastBuildDate" timestamp(3) without time zone,
    "collectionId" integer NOT NULL,
    "ownerId" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: RssSubscription_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."RssSubscription_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: RssSubscription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."RssSubscription_id_seq" OWNED BY public."RssSubscription".id;


--
-- Name: Subscription; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Subscription" (
    id integer NOT NULL,
    active boolean NOT NULL,
    "stripeSubscriptionId" text,
    "currentPeriodStart" timestamp(3) without time zone NOT NULL,
    "currentPeriodEnd" timestamp(3) without time zone NOT NULL,
    "userId" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    provider public."SubscriptionProvider" NOT NULL,
    "storeOriginalTransactionId" text,
    "storeProductId" text,
    "googlePurchaseToken" text,
    "storeMetadata" jsonb
);


--
-- Name: Subscription_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Subscription_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Subscription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Subscription_id_seq" OWNED BY public."Subscription".id;


--
-- Name: Tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Tag" (
    id integer NOT NULL,
    name text NOT NULL,
    "ownerId" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "archiveAsMonolith" boolean,
    "archiveAsPDF" boolean,
    "archiveAsReadable" boolean,
    "archiveAsScreenshot" boolean,
    "archiveAsWaybackMachine" boolean,
    "aiTag" boolean,
    "aiGenerated" boolean DEFAULT false NOT NULL
);


--
-- Name: Tag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Tag_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Tag_id_seq" OWNED BY public."Tag".id;


--
-- Name: User; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."User" (
    id integer NOT NULL,
    name text,
    username text,
    email text,
    "emailVerified" timestamp(3) without time zone,
    password text,
    "isPrivate" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "archiveAsPDF" boolean DEFAULT true NOT NULL,
    "archiveAsScreenshot" boolean DEFAULT true NOT NULL,
    "archiveAsWaybackMachine" boolean DEFAULT false NOT NULL,
    image text,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "linksRouteTo" public."LinksRouteTo" DEFAULT 'ORIGINAL'::public."LinksRouteTo" NOT NULL,
    "collectionOrder" integer[] DEFAULT ARRAY[]::integer[],
    "preventDuplicateLinks" boolean DEFAULT false NOT NULL,
    "unverifiedNewEmail" text,
    locale text DEFAULT 'en'::text NOT NULL,
    "archiveAsMonolith" boolean DEFAULT true NOT NULL,
    "parentSubscriptionId" integer,
    "referredBy" text,
    "aiPredefinedTags" text[] DEFAULT ARRAY[]::text[],
    "aiTaggingMethod" public."AiTaggingMethod" DEFAULT 'DISABLED'::public."AiTaggingMethod" NOT NULL,
    "aiTagExistingLinks" boolean DEFAULT false NOT NULL,
    "archiveAsReadable" boolean DEFAULT true NOT NULL,
    "readableFontFamily" text DEFAULT 'sans-serif'::text,
    "readableFontSize" text DEFAULT '20px'::text,
    "readableLineHeight" text DEFAULT '1.8'::text,
    "readableLineWidth" text DEFAULT 'normal'::text,
    theme public."Theme" DEFAULT 'dark'::public."Theme" NOT NULL,
    "lastPickedAt" timestamp(3) without time zone,
    "acceptPromotionalEmails" boolean DEFAULT false NOT NULL,
    "trialEndEmailSent" boolean DEFAULT false NOT NULL,
    uuid uuid NOT NULL
);


--
-- Name: User_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."User_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: User_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."User_id_seq" OWNED BY public."User".id;


--
-- Name: UsersAndCollections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UsersAndCollections" (
    "userId" integer NOT NULL,
    "collectionId" integer NOT NULL,
    "canCreate" boolean NOT NULL,
    "canUpdate" boolean NOT NULL,
    "canDelete" boolean NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: VerificationToken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."VerificationToken" (
    identifier text NOT NULL,
    token text NOT NULL,
    expires timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: WhitelistedUser; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WhitelistedUser" (
    id integer NOT NULL,
    username text DEFAULT ''::text NOT NULL,
    "userId" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: WhitelistedUser_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."WhitelistedUser_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: WhitelistedUser_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."WhitelistedUser_id_seq" OWNED BY public."WhitelistedUser".id;


--
-- Name: _LinkToTag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."_LinkToTag" (
    "A" integer NOT NULL,
    "B" integer NOT NULL
);


--
-- Name: _PinnedLinks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."_PinnedLinks" (
    "A" integer NOT NULL,
    "B" integer NOT NULL
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
-- Name: AccessToken id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AccessToken" ALTER COLUMN id SET DEFAULT nextval('public."AccessToken_id_seq"'::regclass);


--
-- Name: AppMigration id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AppMigration" ALTER COLUMN id SET DEFAULT nextval('public."AppMigration_id_seq"'::regclass);


--
-- Name: Collection id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Collection" ALTER COLUMN id SET DEFAULT nextval('public."Collection_id_seq"'::regclass);


--
-- Name: DashboardSection id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DashboardSection" ALTER COLUMN id SET DEFAULT nextval('public."DashboardSection_id_seq"'::regclass);


--
-- Name: Highlight id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Highlight" ALTER COLUMN id SET DEFAULT nextval('public."Highlight_id_seq"'::regclass);


--
-- Name: Link id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Link" ALTER COLUMN id SET DEFAULT nextval('public."Link_id_seq"'::regclass);


--
-- Name: RssSubscription id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RssSubscription" ALTER COLUMN id SET DEFAULT nextval('public."RssSubscription_id_seq"'::regclass);


--
-- Name: Subscription id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Subscription" ALTER COLUMN id SET DEFAULT nextval('public."Subscription_id_seq"'::regclass);


--
-- Name: Tag id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Tag" ALTER COLUMN id SET DEFAULT nextval('public."Tag_id_seq"'::regclass);


--
-- Name: User id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User" ALTER COLUMN id SET DEFAULT nextval('public."User_id_seq"'::regclass);


--
-- Name: WhitelistedUser id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WhitelistedUser" ALTER COLUMN id SET DEFAULT nextval('public."WhitelistedUser_id_seq"'::regclass);


--
-- Name: AccessToken AccessToken_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AccessToken"
    ADD CONSTRAINT "AccessToken_pkey" PRIMARY KEY (id);


--
-- Name: Account Account_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Account"
    ADD CONSTRAINT "Account_pkey" PRIMARY KEY (id);


--
-- Name: AppMigration AppMigration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AppMigration"
    ADD CONSTRAINT "AppMigration_pkey" PRIMARY KEY (id);


--
-- Name: Collection Collection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Collection"
    ADD CONSTRAINT "Collection_pkey" PRIMARY KEY (id);


--
-- Name: DashboardSection DashboardSection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DashboardSection"
    ADD CONSTRAINT "DashboardSection_pkey" PRIMARY KEY (id);


--
-- Name: Highlight Highlight_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Highlight"
    ADD CONSTRAINT "Highlight_pkey" PRIMARY KEY (id);


--
-- Name: Link Link_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Link"
    ADD CONSTRAINT "Link_pkey" PRIMARY KEY (id);


--
-- Name: RssSubscription RssSubscription_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RssSubscription"
    ADD CONSTRAINT "RssSubscription_pkey" PRIMARY KEY (id);


--
-- Name: Subscription Subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Subscription"
    ADD CONSTRAINT "Subscription_pkey" PRIMARY KEY (id);


--
-- Name: Tag Tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Tag"
    ADD CONSTRAINT "Tag_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: UsersAndCollections UsersAndCollections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UsersAndCollections"
    ADD CONSTRAINT "UsersAndCollections_pkey" PRIMARY KEY ("userId", "collectionId");


--
-- Name: WhitelistedUser WhitelistedUser_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WhitelistedUser"
    ADD CONSTRAINT "WhitelistedUser_pkey" PRIMARY KEY (id);


--
-- Name: _LinkToTag _LinkToTag_AB_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_LinkToTag"
    ADD CONSTRAINT "_LinkToTag_AB_pkey" PRIMARY KEY ("A", "B");


--
-- Name: _PinnedLinks _PinnedLinks_AB_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_PinnedLinks"
    ADD CONSTRAINT "_PinnedLinks_AB_pkey" PRIMARY KEY ("A", "B");


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: AccessToken_token_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AccessToken_token_key" ON public."AccessToken" USING btree (token);


--
-- Name: Account_provider_providerAccountId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Account_provider_providerAccountId_key" ON public."Account" USING btree (provider, "providerAccountId");


--
-- Name: AppMigration_name_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AppMigration_name_key" ON public."AppMigration" USING btree (name);


--
-- Name: Collection_ownerId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Collection_ownerId_idx" ON public."Collection" USING btree ("ownerId");


--
-- Name: DashboardSection_userId_collectionId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DashboardSection_userId_collectionId_key" ON public."DashboardSection" USING btree ("userId", "collectionId");


--
-- Name: Link_collectionId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Link_collectionId_idx" ON public."Link" USING btree ("collectionId");


--
-- Name: PasswordResetToken_token_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PasswordResetToken_token_key" ON public."PasswordResetToken" USING btree (token);


--
-- Name: Subscription_googlePurchaseToken_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Subscription_googlePurchaseToken_key" ON public."Subscription" USING btree ("googlePurchaseToken");


--
-- Name: Subscription_storeOriginalTransactionId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Subscription_storeOriginalTransactionId_key" ON public."Subscription" USING btree ("storeOriginalTransactionId");


--
-- Name: Subscription_stripeSubscriptionId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Subscription_stripeSubscriptionId_key" ON public."Subscription" USING btree ("stripeSubscriptionId");


--
-- Name: Subscription_userId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Subscription_userId_key" ON public."Subscription" USING btree ("userId");


--
-- Name: Tag_name_ownerId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Tag_name_ownerId_key" ON public."Tag" USING btree (name, "ownerId");


--
-- Name: Tag_ownerId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Tag_ownerId_idx" ON public."Tag" USING btree ("ownerId");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: User_username_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_username_key" ON public."User" USING btree (username);


--
-- Name: User_uuid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_uuid_key" ON public."User" USING btree (uuid);


--
-- Name: UsersAndCollections_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UsersAndCollections_userId_idx" ON public."UsersAndCollections" USING btree ("userId");


--
-- Name: VerificationToken_identifier_token_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "VerificationToken_identifier_token_key" ON public."VerificationToken" USING btree (identifier, token);


--
-- Name: VerificationToken_token_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "VerificationToken_token_key" ON public."VerificationToken" USING btree (token);


--
-- Name: _LinkToTag_B_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "_LinkToTag_B_index" ON public."_LinkToTag" USING btree ("B");


--
-- Name: _PinnedLinks_B_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "_PinnedLinks_B_index" ON public."_PinnedLinks" USING btree ("B");


--
-- Name: AccessToken AccessToken_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AccessToken"
    ADD CONSTRAINT "AccessToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Account Account_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Account"
    ADD CONSTRAINT "Account_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Collection Collection_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Collection"
    ADD CONSTRAINT "Collection_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Collection Collection_ownerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Collection"
    ADD CONSTRAINT "Collection_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Collection Collection_parentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Collection"
    ADD CONSTRAINT "Collection_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES public."Collection"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DashboardSection DashboardSection_collectionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DashboardSection"
    ADD CONSTRAINT "DashboardSection_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES public."Collection"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DashboardSection DashboardSection_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DashboardSection"
    ADD CONSTRAINT "DashboardSection_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Highlight Highlight_linkId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Highlight"
    ADD CONSTRAINT "Highlight_linkId_fkey" FOREIGN KEY ("linkId") REFERENCES public."Link"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Highlight Highlight_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Highlight"
    ADD CONSTRAINT "Highlight_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Link Link_collectionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Link"
    ADD CONSTRAINT "Link_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES public."Collection"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Link Link_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Link"
    ADD CONSTRAINT "Link_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RssSubscription RssSubscription_collectionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RssSubscription"
    ADD CONSTRAINT "RssSubscription_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES public."Collection"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Subscription Subscription_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Subscription"
    ADD CONSTRAINT "Subscription_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Tag Tag_ownerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Tag"
    ADD CONSTRAINT "Tag_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: User User_parentSubscriptionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_parentSubscriptionId_fkey" FOREIGN KEY ("parentSubscriptionId") REFERENCES public."Subscription"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: UsersAndCollections UsersAndCollections_collectionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UsersAndCollections"
    ADD CONSTRAINT "UsersAndCollections_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES public."Collection"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UsersAndCollections UsersAndCollections_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UsersAndCollections"
    ADD CONSTRAINT "UsersAndCollections_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WhitelistedUser WhitelistedUser_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WhitelistedUser"
    ADD CONSTRAINT "WhitelistedUser_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _LinkToTag _LinkToTag_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_LinkToTag"
    ADD CONSTRAINT "_LinkToTag_A_fkey" FOREIGN KEY ("A") REFERENCES public."Link"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _LinkToTag _LinkToTag_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_LinkToTag"
    ADD CONSTRAINT "_LinkToTag_B_fkey" FOREIGN KEY ("B") REFERENCES public."Tag"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _PinnedLinks _PinnedLinks_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_PinnedLinks"
    ADD CONSTRAINT "_PinnedLinks_A_fkey" FOREIGN KEY ("A") REFERENCES public."Link"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _PinnedLinks _PinnedLinks_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_PinnedLinks"
    ADD CONSTRAINT "_PinnedLinks_B_fkey" FOREIGN KEY ("B") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


