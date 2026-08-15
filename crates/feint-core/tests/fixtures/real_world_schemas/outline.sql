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
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: enum_document_insights_period; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_document_insights_period AS ENUM (
    'day',
    'week'
);


--
-- Name: enum_file_operations_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_file_operations_state AS ENUM (
    'creating',
    'uploading',
    'complete',
    'error',
    'expired'
);


--
-- Name: enum_file_operations_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_file_operations_type AS ENUM (
    'import',
    'export'
);


--
-- Name: enum_group_users_permission; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_group_users_permission AS ENUM (
    'admin',
    'member'
);


--
-- Name: enum_relationships_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_relationships_type AS ENUM (
    'backlink',
    'similar'
);


--
-- Name: enum_search_queries_source; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_search_queries_source AS ENUM (
    'slack',
    'app',
    'api',
    'oauth',
    'mcp'
);


--
-- Name: enum_users_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_users_role AS ENUM (
    'admin',
    'member',
    'viewer',
    'guest'
);


--
-- Name: atlases_search_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.atlases_search_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new."searchVector" :=
    setweight(to_tsvector('english', coalesce(new.name, '')),'A') ||
    setweight(to_tsvector('english', coalesce(new.description, '')), 'C');
  return new;
end
$$;


--
-- Name: documents_search_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.documents_search_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    begin
      new."searchVector" :=
        setweight(to_tsvector('english', coalesce(new.title, '')),'A') ||
        setweight(to_tsvector('english', coalesce(array_to_string(new."previousTitles", ' , '),'')),'C') ||
        setweight(to_tsvector('english', substring(coalesce(new.text, ''), 1, 1000000)), 'D');
      return new;
    end
    $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: SequelizeMeta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SequelizeMeta" (
    name character varying(255) NOT NULL
);


--
-- Name: access_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.access_requests (
    id uuid NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    "respondedAt" timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "documentId" uuid NOT NULL,
    "userId" uuid NOT NULL,
    "teamId" uuid NOT NULL,
    "responderId" uuid
);


--
-- Name: apiKeys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."apiKeys" (
    id uuid NOT NULL,
    name character varying,
    secret character varying(255),
    "userId" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "deletedAt" timestamp with time zone,
    "expiresAt" timestamp with time zone,
    "lastActiveAt" timestamp with time zone,
    hash character varying(255),
    last4 character varying(4),
    scope character varying(255)[]
);


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attachments (
    id uuid NOT NULL,
    "teamId" uuid NOT NULL,
    "userId" uuid NOT NULL,
    "documentId" uuid,
    key character varying(4096) NOT NULL,
    "contentType" character varying(255) NOT NULL,
    size bigint NOT NULL,
    acl character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "lastAccessedAt" timestamp with time zone,
    "expiresAt" timestamp with time zone
);


--
-- Name: authentication_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authentication_providers (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    "providerId" character varying(255) NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    "teamId" uuid NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    settings jsonb
);


--
-- Name: authentications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authentications (
    id uuid NOT NULL,
    "userId" uuid,
    "teamId" uuid,
    service character varying(255) NOT NULL,
    token bytea,
    scopes character varying(255)[],
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "refreshToken" bytea,
    "expiresAt" timestamp with time zone,
    "clientId" character varying(255),
    "clientSecret" bytea
);


--
-- Name: relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.relationships (
    id uuid NOT NULL,
    "userId" uuid NOT NULL,
    "documentId" uuid NOT NULL,
    "reverseDocumentId" uuid NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    type public.enum_relationships_type DEFAULT 'backlink'::public.enum_relationships_type NOT NULL
);


--
-- Name: backlinks; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.backlinks AS
 SELECT id,
    "userId",
    "documentId",
    "reverseDocumentId",
    "createdAt",
    "updatedAt"
   FROM public.relationships
  WHERE (type = 'backlink'::public.enum_relationships_type);


--
-- Name: group_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_permissions (
    "collectionId" uuid,
    "groupId" uuid NOT NULL,
    "createdById" uuid NOT NULL,
    permission character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "deletedAt" timestamp with time zone,
    "documentId" uuid,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "sourceId" uuid
);


--
-- Name: collection_groups; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.collection_groups AS
 SELECT "collectionId",
    "groupId",
    "createdById",
    permission,
    "createdAt",
    "updatedAt",
    "deletedAt",
    "documentId"
   FROM public.group_permissions;


--
-- Name: user_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_permissions (
    "collectionId" uuid,
    "userId" uuid NOT NULL,
    permission character varying(255) DEFAULT 'read_write'::character varying NOT NULL,
    "createdById" uuid NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "documentId" uuid,
    index character varying(255),
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "sourceId" uuid
);


--
-- Name: collection_users; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.collection_users AS
 SELECT "collectionId",
    "userId",
    permission,
    "createdById",
    "createdAt",
    "updatedAt",
    "documentId"
   FROM public.user_permissions;


--
-- Name: collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collections (
    id uuid NOT NULL,
    name character varying,
    description character varying,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "teamId" uuid NOT NULL,
    "searchVector" tsvector,
    "createdById" uuid,
    "deletedAt" timestamp with time zone,
    "urlId" character varying(255),
    "documentStructure" jsonb,
    color text,
    "maintainerApprovalRequired" boolean DEFAULT false NOT NULL,
    icon text,
    sort jsonb,
    sharing boolean DEFAULT true NOT NULL,
    index text,
    permission character varying(255) DEFAULT NULL::character varying,
    state bytea,
    "importId" uuid,
    content jsonb,
    "archivedAt" timestamp with time zone,
    "archivedById" uuid,
    "apiImportId" uuid,
    commenting boolean,
    "sourceMetadata" jsonb,
    "templateManagement" character varying(255) DEFAULT 'admin'::character varying NOT NULL
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id uuid NOT NULL,
    data jsonb NOT NULL,
    "documentId" uuid NOT NULL,
    "parentCommentId" uuid,
    "createdById" uuid NOT NULL,
    "resolvedAt" timestamp with time zone,
    "resolvedById" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "deletedAt" timestamp with time zone,
    reactions jsonb
);


--
-- Name: document_insights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_insights (
    id uuid NOT NULL,
    "documentId" uuid NOT NULL,
    "teamId" uuid NOT NULL,
    date date NOT NULL,
    "viewCount" integer DEFAULT 0 NOT NULL,
    "viewerCount" integer DEFAULT 0 NOT NULL,
    "commentCount" integer DEFAULT 0 NOT NULL,
    "reactionCount" integer DEFAULT 0 NOT NULL,
    "revisionCount" integer DEFAULT 0 NOT NULL,
    "editorCount" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    period public.enum_document_insights_period DEFAULT 'day'::public.enum_document_insights_period NOT NULL
);


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
    id uuid NOT NULL,
    "urlId" character varying NOT NULL,
    title character varying NOT NULL,
    text text,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "collectionId" uuid,
    "teamId" uuid,
    "parentDocumentId" uuid,
    "lastModifiedById" uuid NOT NULL,
    "revisionCount" integer DEFAULT 0,
    "searchVector" tsvector,
    "deletedAt" timestamp with time zone,
    "createdById" uuid,
    "collaboratorIds" uuid[],
    "publishedAt" timestamp with time zone,
    "pinnedById" uuid,
    "archivedAt" timestamp with time zone,
    "isWelcome" boolean DEFAULT false NOT NULL,
    "editorVersion" character varying(255),
    version smallint,
    template boolean DEFAULT false NOT NULL,
    "templateId" uuid,
    "previousTitles" character varying(255)[],
    state bytea,
    "fullWidth" boolean DEFAULT false NOT NULL,
    "importId" uuid,
    "insightsEnabled" boolean DEFAULT true NOT NULL,
    "sourceMetadata" jsonb,
    content jsonb,
    summary text,
    icon character varying(255),
    color character varying(255),
    "apiImportId" uuid,
    language character varying(2),
    "popularityScore" double precision DEFAULT '0'::double precision NOT NULL
);


--
-- Name: emojis; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emojis (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    "attachmentId" uuid NOT NULL,
    "teamId" uuid NOT NULL,
    "createdById" uuid NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    data jsonb,
    "userId" uuid,
    "collectionId" uuid,
    "teamId" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "documentId" uuid,
    "actorId" uuid,
    "modelId" uuid,
    ip character varying(255),
    changes jsonb,
    "authType" character varying(255)
);


--
-- Name: external_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_groups (
    id uuid NOT NULL,
    "externalId" character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    "groupId" uuid,
    "authenticationProviderId" uuid NOT NULL,
    "teamId" uuid NOT NULL,
    "lastSyncedAt" timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: file_operations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_operations (
    id uuid NOT NULL,
    state public.enum_file_operations_state NOT NULL,
    type public.enum_file_operations_type NOT NULL,
    key character varying(255),
    url character varying(255),
    size bigint NOT NULL,
    "userId" uuid NOT NULL,
    "collectionId" uuid,
    "teamId" uuid NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    error character varying(255),
    format character varying(255) DEFAULT 'outline-markdown'::character varying NOT NULL,
    "includeAttachments" boolean DEFAULT true NOT NULL,
    "deletedAt" timestamp with time zone,
    options jsonb,
    "documentId" uuid
);


--
-- Name: group_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_users (
    "userId" uuid NOT NULL,
    "groupId" uuid NOT NULL,
    "createdById" uuid NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    permission public.enum_group_users_permission DEFAULT 'member'::public.enum_group_users_permission NOT NULL
);


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    "teamId" uuid NOT NULL,
    "createdById" uuid NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "deletedAt" timestamp with time zone,
    "externalId" character varying(255),
    "disableMentions" boolean DEFAULT false NOT NULL,
    description text
);


--
-- Name: import_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.import_tasks (
    id uuid NOT NULL,
    state character varying(255) NOT NULL,
    input jsonb NOT NULL,
    output jsonb,
    "importId" uuid NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    error character varying(255),
    phase character varying(255) DEFAULT 'page'::character varying NOT NULL
);


--
-- Name: imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.imports (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    service character varying(255) NOT NULL,
    state character varying(255) NOT NULL,
    input jsonb NOT NULL,
    "documentCount" integer DEFAULT 0 NOT NULL,
    "integrationId" uuid,
    "createdById" uuid NOT NULL,
    "teamId" uuid NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "deletedAt" timestamp with time zone,
    error character varying(255),
    scratch jsonb
);


--
-- Name: integrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations (
    id uuid NOT NULL,
    type character varying(255),
    "userId" uuid,
    "teamId" uuid NOT NULL,
    service character varying(255) NOT NULL,
    "collectionId" uuid,
    "authenticationId" uuid,
    events character varying(255)[],
    settings jsonb,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "deletedAt" timestamp with time zone,
    "issueSources" jsonb
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id uuid NOT NULL,
    "actorId" uuid,
    "userId" uuid NOT NULL,
    event character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "viewedAt" timestamp with time zone,
    "emailedAt" timestamp with time zone,
    "teamId" uuid NOT NULL,
    "documentId" uuid,
    "commentId" uuid,
    "revisionId" uuid,
    "collectionId" uuid,
    "archivedAt" timestamp with time zone,
    "membershipId" uuid,
    data json,
    "groupId" uuid,
    "accessRequestId" uuid
);


--
-- Name: oauth_authentications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_authentications (
    id uuid NOT NULL,
    "accessTokenHash" character varying(255) NOT NULL,
    "accessTokenExpiresAt" timestamp with time zone NOT NULL,
    "refreshTokenHash" character varying(255) NOT NULL,
    "refreshTokenExpiresAt" timestamp with time zone NOT NULL,
    "lastActiveAt" timestamp with time zone,
    scope character varying(255)[] NOT NULL,
    "oauthClientId" uuid NOT NULL,
    "userId" uuid NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "deletedAt" timestamp with time zone,
    "grantId" uuid
);


--
-- Name: oauth_authorization_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_authorization_codes (
    id uuid NOT NULL,
    "authorizationCodeHash" character varying(255) NOT NULL,
    "codeChallenge" character varying(255),
    "codeChallengeMethod" character varying(255),
    scope character varying(255)[] NOT NULL,
    "oauthClientId" uuid NOT NULL,
    "userId" uuid NOT NULL,
    "redirectUri" character varying(1024) NOT NULL,
    "expiresAt" timestamp with time zone NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "grantId" uuid
);


--
-- Name: oauth_clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_clients (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    "developerName" character varying(255),
    "developerUrl" character varying(1024),
    "avatarUrl" character varying(1024),
    "clientId" character varying(255) NOT NULL,
    "clientSecret" bytea NOT NULL,
    published boolean DEFAULT false NOT NULL,
    "teamId" uuid NOT NULL,
    "createdById" uuid,
    "redirectUris" character varying(1024)[] DEFAULT (ARRAY[]::character varying[])::character varying(1024)[] NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "deletedAt" timestamp with time zone,
    "clientType" character varying(255) DEFAULT 'confidential'::character varying NOT NULL,
    "lastActiveAt" timestamp with time zone,
    "registrationAccessTokenHash" character varying(255)
);


--
-- Name: pins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pins (
    id uuid NOT NULL,
    "documentId" uuid NOT NULL,
    "collectionId" uuid,
    "teamId" uuid NOT NULL,
    "createdById" uuid NOT NULL,
    index character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: reactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reactions (
    id uuid NOT NULL,
    emoji character varying(255) NOT NULL,
    "userId" uuid NOT NULL,
    "commentId" uuid NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: revisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.revisions (
    id uuid NOT NULL,
    title character varying NOT NULL,
    text text,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "userId" uuid NOT NULL,
    "documentId" uuid NOT NULL,
    "editorVersion" character varying(255),
    version smallint,
    content jsonb,
    icon character varying(255),
    color character varying(255),
    name character varying(255),
    "deletedAt" timestamp with time zone,
    "collaboratorIds" uuid[] DEFAULT ARRAY[]::uuid[] NOT NULL
);


--
-- Name: search_queries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.search_queries (
    id uuid NOT NULL,
    "userId" uuid,
    "teamId" uuid,
    source public.enum_search_queries_source NOT NULL,
    query character varying(255) NOT NULL,
    results integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "shareId" uuid,
    score integer,
    answer text,
    duration integer
);


--
-- Name: share_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.share_subscriptions (
    id uuid NOT NULL,
    "shareId" uuid NOT NULL,
    email character varying(255) NOT NULL,
    "emailFingerprint" character varying(255) NOT NULL,
    secret character varying(64) NOT NULL,
    "ipAddress" character varying(45),
    "confirmedAt" timestamp with time zone,
    "unsubscribedAt" timestamp with time zone,
    "lastNotifiedAt" timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "documentId" uuid NOT NULL
);


--
-- Name: shares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shares (
    id uuid NOT NULL,
    "userId" uuid NOT NULL,
    "teamId" uuid NOT NULL,
    "documentId" uuid,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "revokedAt" timestamp with time zone,
    "revokedById" uuid,
    published boolean DEFAULT false NOT NULL,
    "lastAccessedAt" timestamp with time zone,
    "includeChildDocuments" boolean DEFAULT false NOT NULL,
    views integer DEFAULT 0,
    "urlId" character varying(255),
    domain character varying(255),
    "allowIndexing" boolean DEFAULT true NOT NULL,
    "showLastUpdated" boolean DEFAULT false NOT NULL,
    "collectionId" uuid,
    "showTOC" boolean DEFAULT false NOT NULL,
    "allowSubscriptions" boolean DEFAULT true NOT NULL,
    title character varying(255),
    "iconUrl" character varying(4096)
);


--
-- Name: stars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stars (
    id uuid NOT NULL,
    "documentId" uuid,
    "userId" uuid NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    index character varying(255),
    "collectionId" uuid
);


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id uuid NOT NULL,
    "userId" uuid NOT NULL,
    "documentId" uuid,
    event character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "deletedAt" timestamp with time zone,
    "collectionId" uuid
);


--
-- Name: team_domains; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_domains (
    id uuid NOT NULL,
    "teamId" uuid NOT NULL,
    "createdById" uuid NOT NULL,
    name character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "avatarUrl" character varying(4096),
    "deletedAt" timestamp with time zone,
    sharing boolean DEFAULT true NOT NULL,
    subdomain character varying(255),
    "documentEmbeds" boolean DEFAULT true NOT NULL,
    "guestSignin" boolean DEFAULT false NOT NULL,
    domain character varying(255),
    "signupQueryParams" jsonb,
    "defaultUserRole" character varying(255) DEFAULT 'member'::character varying NOT NULL,
    "defaultCollectionId" uuid,
    "memberCollectionCreate" boolean DEFAULT true NOT NULL,
    "inviteRequired" boolean DEFAULT false NOT NULL,
    preferences jsonb,
    "suspendedAt" timestamp with time zone,
    "lastActiveAt" timestamp with time zone,
    "memberTeamCreate" boolean DEFAULT true NOT NULL,
    "approximateTotalAttachmentsSize" bigint DEFAULT 0,
    "previousSubdomains" character varying(255)[],
    description text,
    "passkeysEnabled" boolean DEFAULT false NOT NULL,
    flags jsonb,
    "guidanceMCP" text
);


--
-- Name: user_authentications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_authentications (
    id uuid NOT NULL,
    "userId" uuid NOT NULL,
    "authenticationProviderId" uuid NOT NULL,
    "accessToken" bytea,
    "refreshToken" bytea,
    scopes character varying(255)[],
    "providerId" character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "expiresAt" timestamp with time zone,
    "lastValidatedAt" timestamp with time zone
);


--
-- Name: user_passkeys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_passkeys (
    id uuid NOT NULL,
    name text NOT NULL,
    "userAgent" text,
    "credentialId" text NOT NULL,
    "credentialPublicKey" bytea NOT NULL,
    aaguid text,
    counter bigint DEFAULT 0 NOT NULL,
    transports character varying(255)[],
    "lastActiveAt" timestamp with time zone,
    "userId" uuid NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email character varying(255) DEFAULT NULL::character varying,
    name character varying NOT NULL,
    "jwtSecret" bytea,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "teamId" uuid,
    "avatarUrl" character varying(4096),
    "suspendedById" uuid,
    "suspendedAt" timestamp with time zone,
    "lastActiveAt" timestamp with time zone,
    "lastActiveIp" character varying(255),
    "lastSignedInAt" timestamp with time zone,
    "lastSignedInIp" character varying(255),
    "deletedAt" timestamp with time zone,
    "lastSigninEmailSentAt" timestamp with time zone,
    language character varying(255),
    flags jsonb,
    "invitedById" uuid,
    preferences jsonb,
    "notificationSettings" jsonb DEFAULT '{}'::jsonb NOT NULL,
    role public.enum_users_role NOT NULL,
    timezone character varying(255)
);


--
-- Name: views; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.views (
    id uuid NOT NULL,
    "documentId" uuid NOT NULL,
    "userId" uuid NOT NULL,
    count integer DEFAULT 1 NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "lastEditingAt" timestamp with time zone
);


--
-- Name: webhook_deliveries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhook_deliveries (
    id uuid NOT NULL,
    "webhookSubscriptionId" uuid NOT NULL,
    status character varying(255) NOT NULL,
    "statusCode" integer,
    "requestBody" jsonb,
    "requestHeaders" jsonb,
    "responseBody" text,
    "responseHeaders" jsonb,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: webhook_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhook_subscriptions (
    id uuid NOT NULL,
    "teamId" uuid NOT NULL,
    "createdById" uuid NOT NULL,
    url character varying(1024) NOT NULL,
    enabled boolean NOT NULL,
    name character varying(255) NOT NULL,
    events character varying(255)[] NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "deletedAt" timestamp with time zone,
    secret bytea
);


--
-- Name: SequelizeMeta SequelizeMeta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SequelizeMeta"
    ADD CONSTRAINT "SequelizeMeta_pkey" PRIMARY KEY (name);


--
-- Name: access_requests access_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_requests
    ADD CONSTRAINT access_requests_pkey PRIMARY KEY (id);


--
-- Name: apiKeys apiKeys_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."apiKeys"
    ADD CONSTRAINT "apiKeys_hash_key" UNIQUE (hash);


--
-- Name: apiKeys apiKeys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."apiKeys"
    ADD CONSTRAINT "apiKeys_pkey" PRIMARY KEY (id);


--
-- Name: apiKeys apiKeys_secret_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."apiKeys"
    ADD CONSTRAINT "apiKeys_secret_key" UNIQUE (secret);


--
-- Name: collections atlases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT atlases_pkey PRIMARY KEY (id);


--
-- Name: collections atlases_urlId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT "atlases_urlId_key" UNIQUE ("urlId");


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: authentication_providers authentication_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentication_providers
    ADD CONSTRAINT authentication_providers_pkey PRIMARY KEY (id);


--
-- Name: authentication_providers authentication_providers_providerId_teamId_uk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentication_providers
    ADD CONSTRAINT "authentication_providers_providerId_teamId_uk" UNIQUE ("providerId", "teamId");


--
-- Name: authentications authentications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: relationships backlinks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationships
    ADD CONSTRAINT backlinks_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: document_insights document_insights_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_insights
    ADD CONSTRAINT document_insights_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: documents documents_urlId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_urlId_key" UNIQUE ("urlId");


--
-- Name: emojis emojis_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emojis
    ADD CONSTRAINT emojis_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: external_groups external_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_groups
    ADD CONSTRAINT external_groups_pkey PRIMARY KEY (id);


--
-- Name: file_operations file_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_operations
    ADD CONSTRAINT file_operations_pkey PRIMARY KEY (id);


--
-- Name: group_permissions group_permissions_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_permissions
    ADD CONSTRAINT group_permissions_id_pk PRIMARY KEY (id);


--
-- Name: group_users group_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_users
    ADD CONSTRAINT group_users_pkey PRIMARY KEY ("groupId", "userId");


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: import_tasks import_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_tasks
    ADD CONSTRAINT import_tasks_pkey PRIMARY KEY (id);


--
-- Name: imports imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT imports_pkey PRIMARY KEY (id);


--
-- Name: integrations integrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations
    ADD CONSTRAINT integrations_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oauth_authentications oauth_authentications_accessTokenHash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_authentications
    ADD CONSTRAINT "oauth_authentications_accessTokenHash_key" UNIQUE ("accessTokenHash");


--
-- Name: oauth_authentications oauth_authentications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_authentications
    ADD CONSTRAINT oauth_authentications_pkey PRIMARY KEY (id);


--
-- Name: oauth_authentications oauth_authentications_refreshTokenHash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_authentications
    ADD CONSTRAINT "oauth_authentications_refreshTokenHash_key" UNIQUE ("refreshTokenHash");


--
-- Name: oauth_authorization_codes oauth_authorization_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_authorization_codes
    ADD CONSTRAINT oauth_authorization_codes_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_clientId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_clients
    ADD CONSTRAINT "oauth_clients_clientId_key" UNIQUE ("clientId");


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_registrationAccessTokenHash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_clients
    ADD CONSTRAINT "oauth_clients_registrationAccessTokenHash_key" UNIQUE ("registrationAccessTokenHash");


--
-- Name: pins pins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pins
    ADD CONSTRAINT pins_pkey PRIMARY KEY (id);


--
-- Name: reactions reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT reactions_pkey PRIMARY KEY (id);


--
-- Name: revisions revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.revisions
    ADD CONSTRAINT revisions_pkey PRIMARY KEY (id);


--
-- Name: search_queries search_queries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_queries
    ADD CONSTRAINT search_queries_pkey PRIMARY KEY (id);


--
-- Name: share_subscriptions share_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.share_subscriptions
    ADD CONSTRAINT share_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: shares shares_domain_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_domain_key UNIQUE (domain);


--
-- Name: shares shares_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: stars stars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stars
    ADD CONSTRAINT stars_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: team_domains team_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_domains
    ADD CONSTRAINT team_domains_pkey PRIMARY KEY (id);


--
-- Name: teams teams_domain_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_domain_key UNIQUE (domain);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: teams teams_subdomain_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_subdomain_key UNIQUE (subdomain);


--
-- Name: user_authentications user_authentications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_authentications
    ADD CONSTRAINT user_authentications_pkey PRIMARY KEY (id);


--
-- Name: user_authentications user_authentications_providerId_userId_uk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_authentications
    ADD CONSTRAINT "user_authentications_providerId_userId_uk" UNIQUE ("providerId", "userId");


--
-- Name: user_passkeys user_passkeys_credentialId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_passkeys
    ADD CONSTRAINT "user_passkeys_credentialId_key" UNIQUE ("credentialId");


--
-- Name: user_passkeys user_passkeys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_passkeys
    ADD CONSTRAINT user_passkeys_pkey PRIMARY KEY (id);


--
-- Name: user_permissions user_permissions_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT user_permissions_id_pk PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: views views_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.views
    ADD CONSTRAINT views_pkey PRIMARY KEY (id);


--
-- Name: webhook_deliveries webhook_deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_deliveries
    ADD CONSTRAINT webhook_deliveries_pkey PRIMARY KEY (id);


--
-- Name: webhook_subscriptions webhook_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_subscriptions
    ADD CONSTRAINT webhook_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: access_requests_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX access_requests_document_id ON public.access_requests USING btree ("documentId");


--
-- Name: access_requests_document_id_user_id_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX access_requests_document_id_user_id_pending ON public.access_requests USING btree ("documentId", "userId") WHERE ((status)::text = 'pending'::text);


--
-- Name: access_requests_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX access_requests_team_id ON public.access_requests USING btree ("teamId");


--
-- Name: access_requests_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX access_requests_user_id ON public.access_requests USING btree ("userId");


--
-- Name: api_keys_user_id_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX api_keys_user_id_deleted_at ON public."apiKeys" USING btree ("userId", "deletedAt");


--
-- Name: attachments_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attachments_created_at ON public.attachments USING btree ("createdAt");


--
-- Name: attachments_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attachments_document_id ON public.attachments USING btree ("documentId");


--
-- Name: attachments_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attachments_expires_at ON public.attachments USING btree ("expiresAt");


--
-- Name: attachments_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attachments_team_id ON public.attachments USING btree ("teamId");


--
-- Name: authentication_providers_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX authentication_providers_provider_id ON public.authentication_providers USING btree ("providerId");


--
-- Name: authentications_team_id_service; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX authentications_team_id_service ON public.authentications USING btree ("teamId", service);


--
-- Name: backlinks_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX backlinks_document_id ON public.relationships USING btree ("documentId");


--
-- Name: backlinks_reverse_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX backlinks_reverse_document_id ON public.relationships USING btree ("reverseDocumentId");


--
-- Name: collections_api_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX collections_api_import_id ON public.collections USING btree ("apiImportId");


--
-- Name: collections_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX collections_archived_at ON public.collections USING btree ("archivedAt");


--
-- Name: collections_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX collections_import_id ON public.collections USING btree ("importId");


--
-- Name: collections_team_id_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX collections_team_id_deleted_at ON public.collections USING btree ("teamId", "deletedAt");


--
-- Name: comments_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_created_at ON public.comments USING btree ("createdAt");


--
-- Name: comments_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_document_id ON public.comments USING btree ("documentId");


--
-- Name: document_insights_document_id_date_period; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX document_insights_document_id_date_period ON public.document_insights USING btree ("documentId", date, period);


--
-- Name: document_insights_team_id_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX document_insights_team_id_date ON public.document_insights USING btree ("teamId", date);


--
-- Name: documents_api_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX documents_api_import_id ON public.documents USING btree ("apiImportId");


--
-- Name: documents_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX documents_archived_at ON public.documents USING btree ("archivedAt");


--
-- Name: documents_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX documents_collection_id ON public.documents USING btree ("collectionId");


--
-- Name: documents_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX documents_import_id ON public.documents USING btree ("importId");


--
-- Name: documents_parent_document_id_atlas_id_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX documents_parent_document_id_atlas_id_deleted_at ON public.documents USING btree ("parentDocumentId", "collectionId", "deletedAt");


--
-- Name: documents_published_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX documents_published_at ON public.documents USING btree ("publishedAt");


--
-- Name: documents_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX documents_team_id ON public.documents USING btree ("teamId", "deletedAt");


--
-- Name: documents_title_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX documents_title_idx ON public.documents USING gin (title public.gin_trgm_ops);


--
-- Name: documents_tsv_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX documents_tsv_idx ON public.documents USING gin ("searchVector");


--
-- Name: documents_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX documents_updated_at ON public.documents USING btree ("updatedAt");


--
-- Name: documents_url_id_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX documents_url_id_deleted_at ON public.documents USING btree ("urlId", "deletedAt");


--
-- Name: emojis_attachment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX emojis_attachment_id ON public.emojis USING btree ("attachmentId");


--
-- Name: emojis_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX emojis_created_by_id ON public.emojis USING btree ("createdById");


--
-- Name: emojis_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX emojis_team_id ON public.emojis USING btree ("teamId");


--
-- Name: emojis_team_id_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX emojis_team_id_name ON public.emojis USING btree ("teamId", name);


--
-- Name: events_actor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_actor_id ON public.events USING btree ("actorId");


--
-- Name: events_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_created_at ON public.events USING btree ("createdAt");


--
-- Name: events_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_document_id ON public.events USING btree ("documentId");


--
-- Name: events_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_name ON public.events USING btree (name);


--
-- Name: events_team_id_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_team_id_collection_id ON public.events USING btree ("teamId", "collectionId");


--
-- Name: external_groups_authentication_provider_id_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX external_groups_authentication_provider_id_external_id ON public.external_groups USING btree ("authenticationProviderId", "externalId");


--
-- Name: file_operations_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_operations_document_id ON public.file_operations USING btree ("documentId");


--
-- Name: file_operations_type_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_operations_type_state ON public.file_operations USING btree (type, state);


--
-- Name: group_permissions_collection_id_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX group_permissions_collection_id_group_id ON public.group_permissions USING btree ("collectionId", "groupId");


--
-- Name: group_permissions_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX group_permissions_deleted_at ON public.group_permissions USING btree ("deletedAt");


--
-- Name: group_permissions_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX group_permissions_document_id ON public.group_permissions USING btree ("documentId");


--
-- Name: group_permissions_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX group_permissions_group_id ON public.group_permissions USING btree ("groupId");


--
-- Name: group_permissions_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX group_permissions_source_id ON public.group_permissions USING btree ("sourceId");


--
-- Name: group_users_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX group_users_user_id ON public.group_users USING btree ("userId");


--
-- Name: groups_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX groups_external_id ON public.groups USING btree ("externalId");


--
-- Name: groups_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX groups_team_id ON public.groups USING btree ("teamId");


--
-- Name: import_tasks_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX import_tasks_import_id ON public.import_tasks USING btree ("importId");


--
-- Name: import_tasks_state_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX import_tasks_state_import_id ON public.import_tasks USING btree (state, "importId");


--
-- Name: imports_service_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX imports_service_team_id ON public.imports USING btree (service, "teamId");


--
-- Name: imports_state_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX imports_state_team_id ON public.imports USING btree (state, "teamId");


--
-- Name: integrations_service_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_service_type ON public.integrations USING btree (service, type);


--
-- Name: integrations_service_type_createdAt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "integrations_service_type_createdAt" ON public.integrations USING btree (service, type, "createdAt");


--
-- Name: integrations_settings_slack_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_settings_slack_gin ON public.integrations USING gin (((settings -> 'slack'::text))) WHERE (((service)::text = 'slack'::text) AND ((type)::text = 'linkedAccount'::text));


--
-- Name: integrations_team_id_type_service; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX integrations_team_id_type_service ON public.integrations USING btree ("teamId", type, service);


--
-- Name: notifications_access_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifications_access_request_id ON public.notifications USING btree ("accessRequestId");


--
-- Name: notifications_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifications_created_at ON public.notifications USING btree ("createdAt");


--
-- Name: notifications_document_id_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifications_document_id_user_id ON public.notifications USING btree ("documentId", "userId");


--
-- Name: notifications_emailed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifications_emailed_at ON public.notifications USING btree ("emailedAt");


--
-- Name: notifications_event; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifications_event ON public.notifications USING btree (event);


--
-- Name: notifications_team_id_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifications_team_id_user_id ON public.notifications USING btree ("teamId", "userId");


--
-- Name: oauth_authentications_grant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth_authentications_grant_id ON public.oauth_authentications USING btree ("grantId");


--
-- Name: oauth_authorization_codes_grant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth_authorization_codes_grant_id ON public.oauth_authorization_codes USING btree ("grantId");


--
-- Name: oauth_clients_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth_clients_team_id ON public.oauth_clients USING btree ("teamId");


--
-- Name: pins_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pins_collection_id ON public.pins USING btree ("collectionId");


--
-- Name: pins_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pins_team_id ON public.pins USING btree ("teamId");


--
-- Name: reactions_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX reactions_comment_id ON public.reactions USING btree ("commentId");


--
-- Name: reactions_emoji_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX reactions_emoji_user_id ON public.reactions USING btree (emoji, "userId");


--
-- Name: relationships_document_id_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX relationships_document_id_type ON public.relationships USING btree ("documentId", type);


--
-- Name: revisions_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX revisions_created_at ON public.revisions USING btree ("createdAt");


--
-- Name: revisions_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX revisions_document_id ON public.revisions USING btree ("documentId");


--
-- Name: search_queries_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX search_queries_team_id ON public.search_queries USING btree ("teamId");


--
-- Name: search_queries_user_id_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX search_queries_user_id_created_at ON public.search_queries USING btree ("userId", "createdAt");


--
-- Name: share_subscriptions_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX share_subscriptions_document_id ON public.share_subscriptions USING btree ("documentId");


--
-- Name: share_subscriptions_ip_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX share_subscriptions_ip_address ON public.share_subscriptions USING btree ("ipAddress");


--
-- Name: share_subscriptions_share_id_confirmed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX share_subscriptions_share_id_confirmed_at ON public.share_subscriptions USING btree ("shareId", "confirmedAt") WHERE ("unsubscribedAt" IS NULL);


--
-- Name: share_subscriptions_share_id_document_id_email_fingerprint; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX share_subscriptions_share_id_document_id_email_fingerprint ON public.share_subscriptions USING btree ("shareId", "documentId", "emailFingerprint");


--
-- Name: shares_urlId_teamId_not_revoked_uk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "shares_urlId_teamId_not_revoked_uk" ON public.shares USING btree ("urlId", "teamId") WHERE ("revokedAt" IS NULL);


--
-- Name: stars_document_id_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stars_document_id_user_id ON public.stars USING btree ("documentId", "userId");


--
-- Name: stars_user_id_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stars_user_id_document_id ON public.stars USING btree ("userId", "documentId");


--
-- Name: subscriptions_event_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscriptions_event_collection_id ON public.subscriptions USING btree (event, "collectionId") WHERE ("deletedAt" IS NULL);


--
-- Name: subscriptions_event_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscriptions_event_document_id ON public.subscriptions USING btree (event, "documentId") WHERE ("deletedAt" IS NULL);


--
-- Name: subscriptions_user_id_collection_id_event; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX subscriptions_user_id_collection_id_event ON public.subscriptions USING btree ("userId", "collectionId", event);


--
-- Name: subscriptions_user_id_document_id_event; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX subscriptions_user_id_document_id_event ON public.subscriptions USING btree ("userId", "documentId", event);


--
-- Name: team_domains_team_id_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX team_domains_team_id_name ON public.team_domains USING btree ("teamId", name);


--
-- Name: teams_previous_subdomains; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX teams_previous_subdomains ON public.teams USING gin ("previousSubdomains");


--
-- Name: teams_subdomain; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX teams_subdomain ON public.teams USING btree (subdomain);


--
-- Name: user_authentications_providerId_createdAt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "user_authentications_providerId_createdAt" ON public.user_authentications USING btree ("providerId", "createdAt");


--
-- Name: user_authentications_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_authentications_user_id ON public.user_authentications USING btree ("userId");


--
-- Name: user_passkeys_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_passkeys_user_id ON public.user_passkeys USING btree ("userId");


--
-- Name: user_permissions_collection_id_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_permissions_collection_id_user_id ON public.user_permissions USING btree ("collectionId", "userId");


--
-- Name: user_permissions_document_id_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_permissions_document_id_user_id ON public.user_permissions USING btree ("documentId", "userId");


--
-- Name: user_permissions_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_permissions_source_id ON public.user_permissions USING btree ("sourceId");


--
-- Name: user_permissions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_permissions_user_id ON public.user_permissions USING btree ("userId");


--
-- Name: users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_email ON public.users USING btree (email);


--
-- Name: users_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_team_id ON public.users USING btree ("teamId");


--
-- Name: views_document_id_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX views_document_id_user_id ON public.views USING btree ("documentId", "userId");


--
-- Name: views_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX views_updated_at ON public.views USING btree ("updatedAt");


--
-- Name: views_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX views_user_id ON public.views USING btree ("userId");


--
-- Name: webhook_deliveries_createdAt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "webhook_deliveries_createdAt" ON public.webhook_deliveries USING btree ("createdAt");


--
-- Name: webhook_deliveries_webhook_subscription_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX webhook_deliveries_webhook_subscription_id ON public.webhook_deliveries USING btree ("webhookSubscriptionId");


--
-- Name: webhook_subscriptions_team_id_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX webhook_subscriptions_team_id_enabled ON public.webhook_subscriptions USING btree ("teamId", enabled);


--
-- Name: collections atlases_tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER atlases_tsvectorupdate BEFORE INSERT OR UPDATE ON public.collections FOR EACH ROW EXECUTE FUNCTION public.atlases_search_trigger();


--
-- Name: documents documents_tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER documents_tsvectorupdate BEFORE INSERT OR UPDATE ON public.documents FOR EACH ROW EXECUTE FUNCTION public.documents_search_trigger();


--
-- Name: access_requests access_requests_documentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_requests
    ADD CONSTRAINT "access_requests_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES public.documents(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: access_requests access_requests_responderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_requests
    ADD CONSTRAINT "access_requests_responderId_fkey" FOREIGN KEY ("responderId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: access_requests access_requests_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_requests
    ADD CONSTRAINT "access_requests_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: access_requests access_requests_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_requests
    ADD CONSTRAINT "access_requests_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: attachments attachments_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT "attachments_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id);


--
-- Name: attachments attachments_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT "attachments_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- Name: authentication_providers authentication_providers_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentication_providers
    ADD CONSTRAINT "authentication_providers_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id);


--
-- Name: authentications authentications_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentications
    ADD CONSTRAINT "authentications_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id);


--
-- Name: authentications authentications_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authentications
    ADD CONSTRAINT "authentications_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- Name: relationships backlinks_documentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationships
    ADD CONSTRAINT "backlinks_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: relationships backlinks_reverseDocumentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationships
    ADD CONSTRAINT "backlinks_reverseDocumentId_fkey" FOREIGN KEY ("reverseDocumentId") REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: relationships backlinks_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationships
    ADD CONSTRAINT "backlinks_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- Name: collections collections_apiImportId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT "collections_apiImportId_fkey" FOREIGN KEY ("apiImportId") REFERENCES public.imports(id);


--
-- Name: collections collections_archivedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT "collections_archivedById_fkey" FOREIGN KEY ("archivedById") REFERENCES public.users(id);


--
-- Name: collections collections_importId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT "collections_importId_fkey" FOREIGN KEY ("importId") REFERENCES public.file_operations(id);


--
-- Name: comments comments_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: comments comments_documentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: comments comments_parentCommentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments_parentCommentId_fkey" FOREIGN KEY ("parentCommentId") REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: comments comments_resolvedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments_resolvedById_fkey" FOREIGN KEY ("resolvedById") REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: document_insights document_insights_documentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_insights
    ADD CONSTRAINT "document_insights_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: document_insights document_insights_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_insights
    ADD CONSTRAINT "document_insights_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: documents documents_apiImportId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_apiImportId_fkey" FOREIGN KEY ("apiImportId") REFERENCES public.imports(id);


--
-- Name: documents documents_atlasId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_atlasId_fkey" FOREIGN KEY ("collectionId") REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: documents documents_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id);


--
-- Name: documents documents_importId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_importId_fkey" FOREIGN KEY ("importId") REFERENCES public.file_operations(id);


--
-- Name: documents documents_lastModifiedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_lastModifiedById_fkey" FOREIGN KEY ("lastModifiedById") REFERENCES public.users(id);


--
-- Name: documents documents_parentDocumentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_parentDocumentId_fkey" FOREIGN KEY ("parentDocumentId") REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: documents documents_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: emojis emojis_attachmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emojis
    ADD CONSTRAINT "emojis_attachmentId_fkey" FOREIGN KEY ("attachmentId") REFERENCES public.attachments(id) ON DELETE CASCADE;


--
-- Name: emojis emojis_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emojis
    ADD CONSTRAINT "emojis_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: emojis emojis_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emojis
    ADD CONSTRAINT "emojis_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: events events_actorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT "events_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES public.users(id);


--
-- Name: events events_collectionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT "events_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES public.collections(id);


--
-- Name: events events_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT "events_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id);


--
-- Name: events events_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT "events_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- Name: external_groups external_groups_authenticationProviderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_groups
    ADD CONSTRAINT "external_groups_authenticationProviderId_fkey" FOREIGN KEY ("authenticationProviderId") REFERENCES public.authentication_providers(id) ON DELETE CASCADE;


--
-- Name: external_groups external_groups_groupId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_groups
    ADD CONSTRAINT "external_groups_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES public.groups(id) ON DELETE SET NULL;


--
-- Name: external_groups external_groups_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_groups
    ADD CONSTRAINT "external_groups_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: file_operations file_operations_collectionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_operations
    ADD CONSTRAINT "file_operations_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: file_operations file_operations_documentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_operations
    ADD CONSTRAINT "file_operations_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: file_operations file_operations_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_operations
    ADD CONSTRAINT "file_operations_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: file_operations file_operations_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_operations
    ADD CONSTRAINT "file_operations_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- Name: group_permissions group_permissions_collectionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_permissions
    ADD CONSTRAINT "group_permissions_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES public.collections(id) ON DELETE SET NULL;


--
-- Name: group_permissions group_permissions_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_permissions
    ADD CONSTRAINT "group_permissions_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: group_permissions group_permissions_documentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_permissions
    ADD CONSTRAINT "group_permissions_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: group_permissions group_permissions_groupId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_permissions
    ADD CONSTRAINT "group_permissions_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: group_permissions group_permissions_sourceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_permissions
    ADD CONSTRAINT "group_permissions_sourceId_fkey" FOREIGN KEY ("sourceId") REFERENCES public.group_permissions(id) ON DELETE CASCADE;


--
-- Name: group_users group_users_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_users
    ADD CONSTRAINT "group_users_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id);


--
-- Name: group_users group_users_groupId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_users
    ADD CONSTRAINT "group_users_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: group_users group_users_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_users
    ADD CONSTRAINT "group_users_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: groups groups_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT "groups_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id);


--
-- Name: groups groups_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT "groups_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id);


--
-- Name: import_tasks import_tasks_importId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_tasks
    ADD CONSTRAINT "import_tasks_importId_fkey" FOREIGN KEY ("importId") REFERENCES public.imports(id) ON DELETE CASCADE;


--
-- Name: imports imports_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT "imports_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id);


--
-- Name: imports imports_integrationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT "imports_integrationId_fkey" FOREIGN KEY ("integrationId") REFERENCES public.integrations(id);


--
-- Name: imports imports_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT "imports_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id);


--
-- Name: integrations integrations_authenticationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations
    ADD CONSTRAINT "integrations_authenticationId_fkey" FOREIGN KEY ("authenticationId") REFERENCES public.authentications(id) ON DELETE CASCADE;


--
-- Name: integrations integrations_collectionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations
    ADD CONSTRAINT "integrations_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: integrations integrations_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations
    ADD CONSTRAINT "integrations_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: integrations integrations_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations
    ADD CONSTRAINT "integrations_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- Name: notifications notifications_accessRequestId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_accessRequestId_fkey" FOREIGN KEY ("accessRequestId") REFERENCES public.access_requests(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: notifications notifications_actorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: notifications notifications_collectionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_commentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_commentId_fkey" FOREIGN KEY ("commentId") REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_documentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_groupId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_revisionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_revisionId_fkey" FOREIGN KEY ("revisionId") REFERENCES public.revisions(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authentications oauth_authentications_oauthClientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_authentications
    ADD CONSTRAINT "oauth_authentications_oauthClientId_fkey" FOREIGN KEY ("oauthClientId") REFERENCES public.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authentications oauth_authentications_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_authentications
    ADD CONSTRAINT "oauth_authentications_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authorization_codes oauth_authorization_codes_oauthClientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_authorization_codes
    ADD CONSTRAINT "oauth_authorization_codes_oauthClientId_fkey" FOREIGN KEY ("oauthClientId") REFERENCES public.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorization_codes oauth_authorization_codes_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_authorization_codes
    ADD CONSTRAINT "oauth_authorization_codes_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: oauth_clients oauth_clients_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_clients
    ADD CONSTRAINT "oauth_clients_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id);


--
-- Name: oauth_clients oauth_clients_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_clients
    ADD CONSTRAINT "oauth_clients_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: pins pins_collectionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pins
    ADD CONSTRAINT "pins_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: pins pins_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pins
    ADD CONSTRAINT "pins_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id);


--
-- Name: pins pins_documentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pins
    ADD CONSTRAINT "pins_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: pins pins_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pins
    ADD CONSTRAINT "pins_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: reactions reactions_commentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT "reactions_commentId_fkey" FOREIGN KEY ("commentId") REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: reactions reactions_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT "reactions_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: revisions revisions_documentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.revisions
    ADD CONSTRAINT "revisions_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: revisions revisions_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.revisions
    ADD CONSTRAINT "revisions_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- Name: search_queries search_queries_shareId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_queries
    ADD CONSTRAINT "search_queries_shareId_fkey" FOREIGN KEY ("shareId") REFERENCES public.shares(id) ON DELETE SET NULL;


--
-- Name: search_queries search_queries_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_queries
    ADD CONSTRAINT "search_queries_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id);


--
-- Name: search_queries search_queries_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_queries
    ADD CONSTRAINT "search_queries_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- Name: share_subscriptions share_subscriptions_documentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.share_subscriptions
    ADD CONSTRAINT "share_subscriptions_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: share_subscriptions share_subscriptions_shareId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.share_subscriptions
    ADD CONSTRAINT "share_subscriptions_shareId_fkey" FOREIGN KEY ("shareId") REFERENCES public.shares(id) ON DELETE CASCADE;


--
-- Name: shares shares_collectionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT "shares_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: shares shares_documentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT "shares_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: shares shares_revokedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT "shares_revokedById_fkey" FOREIGN KEY ("revokedById") REFERENCES public.users(id);


--
-- Name: shares shares_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT "shares_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id);


--
-- Name: shares shares_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT "shares_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- Name: stars stars_collectionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stars
    ADD CONSTRAINT "stars_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: stars stars_documentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stars
    ADD CONSTRAINT "stars_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: stars stars_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stars
    ADD CONSTRAINT "stars_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_collectionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT "subscriptions_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_documentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT "subscriptions_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT "subscriptions_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: team_domains team_domains_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_domains
    ADD CONSTRAINT "team_domains_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: team_domains team_domains_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_domains
    ADD CONSTRAINT "team_domains_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: user_authentications user_authentications_authenticationProviderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_authentications
    ADD CONSTRAINT "user_authentications_authenticationProviderId_fkey" FOREIGN KEY ("authenticationProviderId") REFERENCES public.authentication_providers(id) ON DELETE CASCADE;


--
-- Name: user_authentications user_authentications_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_authentications
    ADD CONSTRAINT "user_authentications_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_passkeys user_passkeys_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_passkeys
    ADD CONSTRAINT "user_passkeys_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_permissions user_permissions_collectionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT "user_permissions_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES public.collections(id) ON DELETE SET NULL;


--
-- Name: user_permissions user_permissions_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT "user_permissions_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_permissions user_permissions_documentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT "user_permissions_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: user_permissions user_permissions_sourceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT "user_permissions_sourceId_fkey" FOREIGN KEY ("sourceId") REFERENCES public.user_permissions(id) ON DELETE CASCADE;


--
-- Name: user_permissions user_permissions_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT "user_permissions_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_invitedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "users_invitedById_fkey" FOREIGN KEY ("invitedById") REFERENCES public.users(id);


--
-- Name: users users_suspendedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "users_suspendedById_fkey" FOREIGN KEY ("suspendedById") REFERENCES public.users(id);


--
-- Name: users users_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "users_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: webhook_deliveries webhook_deliveries_webhookSubscriptionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_deliveries
    ADD CONSTRAINT "webhook_deliveries_webhookSubscriptionId_fkey" FOREIGN KEY ("webhookSubscriptionId") REFERENCES public.webhook_subscriptions(id) ON DELETE CASCADE;


--
-- Name: webhook_subscriptions webhook_subscriptions_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_subscriptions
    ADD CONSTRAINT "webhook_subscriptions_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: webhook_subscriptions webhook_subscriptions_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_subscriptions
    ADD CONSTRAINT "webhook_subscriptions_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


