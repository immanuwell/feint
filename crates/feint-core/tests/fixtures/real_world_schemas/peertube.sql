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
-- Name: enum_accountVideoRate_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_accountVideoRate_type" AS ENUM (
    'like',
    'dislike'
);


--
-- Name: enum_actorFollow_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_actorFollow_state" AS ENUM (
    'pending',
    'accepted',
    'rejected'
);


--
-- Name: enum_actor_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.enum_actor_type AS ENUM (
    'Group',
    'Person',
    'Application',
    'Organization',
    'Service'
);


--
-- Name: enum_user_nsfwPolicy; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."enum_user_nsfwPolicy" AS ENUM (
    'do_not_list',
    'warn',
    'blur',
    'display'
);


--
-- Name: immutable_unaccent(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.immutable_unaccent(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
SELECT public.unaccent('public.unaccent', $1::text)
$_$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: abuse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.abuse (
    id integer NOT NULL,
    reason character varying(3000) DEFAULT NULL::character varying NOT NULL,
    state integer NOT NULL,
    "moderationComment" character varying(3000) DEFAULT NULL::character varying,
    "predefinedReasons" integer[],
    "processedAt" timestamp with time zone,
    "reporterAccountId" integer,
    "flaggedAccountId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: abuseMessage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."abuseMessage" (
    id integer NOT NULL,
    message text NOT NULL,
    "byModerator" boolean NOT NULL,
    "accountId" integer,
    "abuseId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: abuseMessage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."abuseMessage_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: abuseMessage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."abuseMessage_id_seq" OWNED BY public."abuseMessage".id;


--
-- Name: abuse_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.abuse_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: abuse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.abuse_id_seq OWNED BY public.abuse.id;


--
-- Name: account; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(1000) DEFAULT NULL::character varying,
    "actorId" integer,
    "userId" integer,
    "applicationId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: accountAutomaticTagPolicy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."accountAutomaticTagPolicy" (
    id integer NOT NULL,
    policy integer,
    "accountId" integer NOT NULL,
    "automaticTagId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: accountAutomaticTagPolicy_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."accountAutomaticTagPolicy_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accountAutomaticTagPolicy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."accountAutomaticTagPolicy_id_seq" OWNED BY public."accountAutomaticTagPolicy".id;


--
-- Name: accountBlocklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."accountBlocklist" (
    id integer NOT NULL,
    "accountId" integer NOT NULL,
    "targetAccountId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: accountBlocklist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."accountBlocklist_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accountBlocklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."accountBlocklist_id_seq" OWNED BY public."accountBlocklist".id;


--
-- Name: accountVideoRate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."accountVideoRate" (
    id integer NOT NULL,
    type public."enum_accountVideoRate_type" NOT NULL,
    url character varying(2000) NOT NULL,
    "videoId" integer NOT NULL,
    "accountId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: accountVideoRate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."accountVideoRate_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accountVideoRate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."accountVideoRate_id_seq" OWNED BY public."accountVideoRate".id;


--
-- Name: account_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_id_seq OWNED BY public.account.id;


--
-- Name: actor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.actor (
    id integer NOT NULL,
    type public.enum_actor_type NOT NULL,
    "preferredUsername" character varying(255) NOT NULL,
    url character varying(2000) NOT NULL,
    "publicKey" character varying(5000),
    "privateKey" character varying(5000),
    "followersCount" integer NOT NULL,
    "followingCount" integer NOT NULL,
    "inboxUrl" character varying(2000) NOT NULL,
    "outboxUrl" character varying(2000),
    "sharedInboxUrl" character varying(2000),
    "followersUrl" character varying(2000),
    "followingUrl" character varying(2000),
    "remoteCreatedAt" timestamp with time zone,
    "serverId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: actorCustomPage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."actorCustomPage" (
    id integer NOT NULL,
    content text,
    type character varying(255) NOT NULL,
    "actorId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: actorCustomPage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."actorCustomPage_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actorCustomPage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."actorCustomPage_id_seq" OWNED BY public."actorCustomPage".id;


--
-- Name: actorFollow; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."actorFollow" (
    id integer NOT NULL,
    state public."enum_actorFollow_state" NOT NULL,
    score integer DEFAULT 1000 NOT NULL,
    url character varying(2000),
    "actorId" integer NOT NULL,
    "targetActorId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: actorFollow_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."actorFollow_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actorFollow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."actorFollow_id_seq" OWNED BY public."actorFollow".id;


--
-- Name: actorImage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."actorImage" (
    id integer NOT NULL,
    filename character varying(255) NOT NULL,
    height integer,
    width integer,
    "fileUrl" character varying(255),
    "onDisk" boolean NOT NULL,
    type integer NOT NULL,
    "actorId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: actorImage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."actorImage_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actorImage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."actorImage_id_seq" OWNED BY public."actorImage".id;


--
-- Name: actor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.actor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.actor_id_seq OWNED BY public.actor.id;


--
-- Name: application; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application (
    id integer NOT NULL,
    "migrationVersion" integer DEFAULT 0 NOT NULL,
    "latestPeerTubeVersion" character varying(255),
    "nodeVersion" character varying(255) NOT NULL,
    "nodeABIVersion" integer NOT NULL
);


--
-- Name: application_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.application_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: application_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.application_id_seq OWNED BY public.application.id;


--
-- Name: automaticTag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."automaticTag" (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


--
-- Name: automaticTag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."automaticTag_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: automaticTag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."automaticTag_id_seq" OWNED BY public."automaticTag".id;


--
-- Name: commentAbuse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."commentAbuse" (
    id integer NOT NULL,
    "abuseId" integer NOT NULL,
    "videoCommentId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: commentAbuse_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."commentAbuse_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commentAbuse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."commentAbuse_id_seq" OWNED BY public."commentAbuse".id;


--
-- Name: commentAutomaticTag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."commentAutomaticTag" (
    "commentId" integer NOT NULL,
    "automaticTagId" integer NOT NULL,
    "accountId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: localVideoViewer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."localVideoViewer" (
    id integer NOT NULL,
    "startDate" timestamp with time zone NOT NULL,
    "endDate" timestamp with time zone NOT NULL,
    "watchTime" integer NOT NULL,
    client character varying(255),
    device character varying(255),
    "operatingSystem" character varying(255),
    country character varying(255),
    "subdivisionName" character varying(255),
    uuid uuid NOT NULL,
    url character varying(255) NOT NULL,
    "videoId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL
);


--
-- Name: localVideoViewerWatchSection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."localVideoViewerWatchSection" (
    id integer NOT NULL,
    "watchStart" integer NOT NULL,
    "watchEnd" integer NOT NULL,
    "localVideoViewerId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL
);


--
-- Name: localVideoViewerWatchSection_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."localVideoViewerWatchSection_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: localVideoViewerWatchSection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."localVideoViewerWatchSection_id_seq" OWNED BY public."localVideoViewerWatchSection".id;


--
-- Name: localVideoViewer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."localVideoViewer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: localVideoViewer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."localVideoViewer_id_seq" OWNED BY public."localVideoViewer".id;


--
-- Name: oAuthClient; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."oAuthClient" (
    id integer NOT NULL,
    "clientId" character varying(255) NOT NULL,
    "clientSecret" character varying(255) NOT NULL,
    grants character varying(255)[],
    "redirectUris" character varying(255)[],
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: oAuthClient_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."oAuthClient_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oAuthClient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."oAuthClient_id_seq" OWNED BY public."oAuthClient".id;


--
-- Name: oAuthToken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."oAuthToken" (
    id integer NOT NULL,
    "accessToken" character varying(255) NOT NULL,
    "accessTokenExpiresAt" timestamp with time zone NOT NULL,
    "refreshToken" character varying(255) NOT NULL,
    "refreshTokenExpiresAt" timestamp with time zone NOT NULL,
    "authName" character varying(255),
    "loginDevice" character varying(255),
    "loginIP" character varying(255),
    "loginDate" timestamp with time zone,
    "lastActivityDevice" character varying(255),
    "lastActivityIP" character varying(255),
    "lastActivityDate" timestamp with time zone,
    "userId" integer NOT NULL,
    "oAuthClientId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: oAuthToken_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."oAuthToken_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oAuthToken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."oAuthToken_id_seq" OWNED BY public."oAuthToken".id;


--
-- Name: plugin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plugin (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    type integer NOT NULL,
    version character varying(255) NOT NULL,
    "latestVersion" character varying(255),
    enabled boolean NOT NULL,
    uninstalled boolean NOT NULL,
    "peertubeEngine" character varying(255) NOT NULL,
    description character varying(255),
    homepage character varying(255) NOT NULL,
    settings jsonb,
    storage jsonb,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: plugin_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plugin_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plugin_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plugin_id_seq OWNED BY public.plugin.id;


--
-- Name: runner; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.runner (
    id integer NOT NULL,
    "runnerToken" character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(1000),
    "lastContact" timestamp with time zone NOT NULL,
    ip character varying(255) NOT NULL,
    version character varying(255),
    "runnerRegistrationTokenId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: runnerJob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."runnerJob" (
    id integer NOT NULL,
    uuid uuid NOT NULL,
    type character varying(255) NOT NULL,
    payload jsonb NOT NULL,
    "privatePayload" jsonb NOT NULL,
    state integer NOT NULL,
    failures integer DEFAULT 0 NOT NULL,
    error character varying(5000),
    priority integer NOT NULL,
    "processingJobToken" character varying(255),
    progress integer,
    "startedAt" timestamp with time zone,
    "finishedAt" timestamp with time zone,
    "dependsOnRunnerJobId" integer,
    "runnerId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: runnerJob_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."runnerJob_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: runnerJob_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."runnerJob_id_seq" OWNED BY public."runnerJob".id;


--
-- Name: runnerRegistrationToken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."runnerRegistrationToken" (
    id integer NOT NULL,
    "registrationToken" character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: runnerRegistrationToken_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."runnerRegistrationToken_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: runnerRegistrationToken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."runnerRegistrationToken_id_seq" OWNED BY public."runnerRegistrationToken".id;


--
-- Name: runner_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.runner_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: runner_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.runner_id_seq OWNED BY public.runner.id;


--
-- Name: scheduleVideoUpdate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."scheduleVideoUpdate" (
    id integer NOT NULL,
    "updateAt" timestamp with time zone NOT NULL,
    privacy integer,
    "videoId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: scheduleVideoUpdate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."scheduleVideoUpdate_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scheduleVideoUpdate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."scheduleVideoUpdate_id_seq" OWNED BY public."scheduleVideoUpdate".id;


--
-- Name: server; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.server (
    id integer NOT NULL,
    host character varying(255) NOT NULL,
    "redundancyAllowed" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: serverBlocklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."serverBlocklist" (
    id integer NOT NULL,
    "accountId" integer NOT NULL,
    "targetServerId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: serverBlocklist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."serverBlocklist_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: serverBlocklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."serverBlocklist_id_seq" OWNED BY public."serverBlocklist".id;


--
-- Name: server_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.server_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: server_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.server_id_seq OWNED BY public.server.id;


--
-- Name: storyboard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.storyboard (
    id integer NOT NULL,
    filename character varying(255) NOT NULL,
    "totalHeight" integer NOT NULL,
    "totalWidth" integer NOT NULL,
    "spriteHeight" integer NOT NULL,
    "spriteWidth" integer NOT NULL,
    "spriteDuration" integer NOT NULL,
    "fileUrl" character varying(2000),
    "videoId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: storyboard_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.storyboard_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: storyboard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.storyboard_id_seq OWNED BY public.storyboard.id;


--
-- Name: tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


--
-- Name: tag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_id_seq OWNED BY public.tag.id;


--
-- Name: thumbnail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thumbnail (
    id integer NOT NULL,
    filename character varying(255) NOT NULL,
    height integer,
    width integer,
    type integer NOT NULL,
    "fileUrl" character varying(2000),
    "automaticallyGenerated" boolean,
    "onDisk" boolean NOT NULL,
    "videoId" integer,
    "videoPlaylistId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: thumbnail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thumbnail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thumbnail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thumbnail_id_seq OWNED BY public.thumbnail.id;


--
-- Name: tracker; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tracker (
    id integer NOT NULL,
    url character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: tracker_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tracker_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tracker_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tracker_id_seq OWNED BY public.tracker.id;


--
-- Name: uploadImage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."uploadImage" (
    id integer NOT NULL,
    filename character varying(255) NOT NULL,
    height integer,
    width integer,
    "fileUrl" character varying(255),
    type integer NOT NULL,
    "actorId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: uploadImage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."uploadImage_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploadImage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."uploadImage_id_seq" OWNED BY public."uploadImage".id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    password character varying(255),
    username character varying(255) NOT NULL,
    email character varying(400) NOT NULL,
    "pendingEmail" character varying(400),
    "emailVerified" boolean,
    "nsfwPolicy" public."enum_user_nsfwPolicy" NOT NULL,
    "nsfwFlagsDisplayed" integer DEFAULT 0 NOT NULL,
    "nsfwFlagsHidden" integer DEFAULT 0 NOT NULL,
    "nsfwFlagsBlurred" integer DEFAULT 0 NOT NULL,
    "nsfwFlagsWarned" integer DEFAULT 0 NOT NULL,
    "p2pEnabled" boolean NOT NULL,
    "videosHistoryEnabled" boolean DEFAULT true NOT NULL,
    "autoPlayVideo" boolean DEFAULT true NOT NULL,
    "autoPlayNextVideo" boolean DEFAULT false NOT NULL,
    "autoPlayNextVideoPlaylist" boolean DEFAULT true NOT NULL,
    language character varying(255),
    "videoLanguages" character varying(255)[] DEFAULT NULL::character varying[],
    "adminFlags" integer DEFAULT 0 NOT NULL,
    blocked boolean DEFAULT false NOT NULL,
    "blockedReason" character varying(255) DEFAULT NULL::character varying,
    role integer NOT NULL,
    "videoQuota" bigint NOT NULL,
    "videoQuotaDaily" bigint NOT NULL,
    theme character varying(255) DEFAULT 'instance-default'::character varying NOT NULL,
    "noInstanceConfigWarningModal" boolean DEFAULT false NOT NULL,
    "noWelcomeModal" boolean DEFAULT false NOT NULL,
    "noAccountSetupWarningModal" boolean DEFAULT false NOT NULL,
    "pluginAuth" character varying(255) DEFAULT NULL::character varying,
    "feedToken" uuid NOT NULL,
    "lastLoginDate" timestamp with time zone,
    "emailPublic" boolean DEFAULT false NOT NULL,
    "otpSecret" character varying(255) DEFAULT NULL::character varying,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: userExport; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."userExport" (
    id integer NOT NULL,
    filename character varying(255),
    "withVideoFiles" boolean NOT NULL,
    state integer NOT NULL,
    error text,
    size bigint,
    storage integer NOT NULL,
    "fileUrl" character varying(255),
    "userId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: userExport_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."userExport_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: userExport_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."userExport_id_seq" OWNED BY public."userExport".id;


--
-- Name: userImport; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."userImport" (
    id integer NOT NULL,
    filename character varying(255),
    state integer NOT NULL,
    error text,
    "resultSummary" jsonb,
    "userId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: userImport_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."userImport_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: userImport_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."userImport_id_seq" OWNED BY public."userImport".id;


--
-- Name: userNotification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."userNotification" (
    id integer NOT NULL,
    type integer NOT NULL,
    read boolean DEFAULT false NOT NULL,
    "userId" integer NOT NULL,
    "videoId" integer,
    "commentId" integer,
    "abuseId" integer,
    "videoBlacklistId" integer,
    "videoImportId" integer,
    "accountId" integer,
    "actorFollowId" integer,
    "pluginId" integer,
    "applicationId" integer,
    "userRegistrationId" integer,
    "videoCaptionId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: userNotificationSetting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."userNotificationSetting" (
    id integer NOT NULL,
    "newVideoFromSubscription" integer NOT NULL,
    "newCommentOnMyVideo" integer NOT NULL,
    "abuseAsModerator" integer NOT NULL,
    "videoAutoBlacklistAsModerator" integer NOT NULL,
    "blacklistOnMyVideo" integer NOT NULL,
    "myVideoPublished" integer NOT NULL,
    "myVideoImportFinished" integer NOT NULL,
    "newUserRegistration" integer NOT NULL,
    "newInstanceFollower" integer NOT NULL,
    "autoInstanceFollowing" integer NOT NULL,
    "newFollow" integer NOT NULL,
    "commentMention" integer NOT NULL,
    "abuseStateChange" integer NOT NULL,
    "abuseNewMessage" integer NOT NULL,
    "newPeerTubeVersion" integer NOT NULL,
    "newPluginVersion" integer NOT NULL,
    "myVideoStudioEditionFinished" integer NOT NULL,
    "myVideoTranscriptionGenerated" integer NOT NULL,
    "userId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: userNotificationSetting_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."userNotificationSetting_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: userNotificationSetting_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."userNotificationSetting_id_seq" OWNED BY public."userNotificationSetting".id;


--
-- Name: userNotification_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."userNotification_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: userNotification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."userNotification_id_seq" OWNED BY public."userNotification".id;


--
-- Name: userRegistration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."userRegistration" (
    id integer NOT NULL,
    state integer NOT NULL,
    "registrationReason" text NOT NULL,
    "moderationResponse" text,
    password character varying(255),
    username character varying(255) NOT NULL,
    email character varying(400) NOT NULL,
    "emailVerified" boolean,
    "accountDisplayName" character varying(255),
    "channelHandle" character varying(255),
    "channelDisplayName" character varying(255),
    "processedAt" timestamp with time zone,
    "userId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: userRegistration_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."userRegistration_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: userRegistration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."userRegistration_id_seq" OWNED BY public."userRegistration".id;


--
-- Name: userVideoHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."userVideoHistory" (
    id integer NOT NULL,
    "currentTime" integer NOT NULL,
    "videoId" integer NOT NULL,
    "userId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: userVideoHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."userVideoHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: userVideoHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."userVideoHistory_id_seq" OWNED BY public."userVideoHistory".id;


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: video; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.video (
    id integer NOT NULL,
    uuid uuid NOT NULL,
    name character varying(255) NOT NULL,
    category integer,
    licence integer,
    language character varying(10) DEFAULT NULL::character varying,
    privacy integer NOT NULL,
    nsfw boolean NOT NULL,
    "nsfwFlags" integer DEFAULT 0 NOT NULL,
    "nsfwSummary" character varying(255) DEFAULT NULL::character varying,
    description character varying(10000) DEFAULT NULL::character varying,
    support character varying(1000) DEFAULT NULL::character varying,
    duration integer NOT NULL,
    views integer DEFAULT 0 NOT NULL,
    likes integer DEFAULT 0 NOT NULL,
    dislikes integer DEFAULT 0 NOT NULL,
    comments integer DEFAULT 0 NOT NULL,
    remote boolean NOT NULL,
    "isLive" boolean DEFAULT false NOT NULL,
    url character varying(2000) NOT NULL,
    "commentsPolicy" integer NOT NULL,
    "downloadEnabled" boolean NOT NULL,
    "waitTranscoding" boolean NOT NULL,
    state integer NOT NULL,
    "aspectRatio" double precision,
    "inputFileUpdatedAt" timestamp with time zone,
    "publishedAt" timestamp with time zone NOT NULL,
    "originallyPublishedAt" timestamp with time zone,
    "channelId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoAbuse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoAbuse" (
    id integer NOT NULL,
    "startAt" integer,
    "endAt" integer,
    "deletedVideo" jsonb,
    "abuseId" integer NOT NULL,
    "videoId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoAbuse_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoAbuse_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoAbuse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoAbuse_id_seq" OWNED BY public."videoAbuse".id;


--
-- Name: videoAutomaticTag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoAutomaticTag" (
    "videoId" integer NOT NULL,
    "automaticTagId" integer NOT NULL,
    "accountId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoBlacklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoBlacklist" (
    id integer NOT NULL,
    reason character varying(300),
    unfederated boolean NOT NULL,
    type integer NOT NULL,
    "videoId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoBlacklist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoBlacklist_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoBlacklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoBlacklist_id_seq" OWNED BY public."videoBlacklist".id;


--
-- Name: videoCaption; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoCaption" (
    id integer NOT NULL,
    language character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    "m3u8Filename" character varying(255),
    storage integer DEFAULT 0 NOT NULL,
    "fileUrl" character varying(2000),
    "m3u8Url" character varying(255),
    "automaticallyGenerated" boolean NOT NULL,
    "videoId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoCaption_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoCaption_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoCaption_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoCaption_id_seq" OWNED BY public."videoCaption".id;


--
-- Name: videoChangeOwnership; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoChangeOwnership" (
    id integer NOT NULL,
    status character varying(255) NOT NULL,
    "initiatorAccountId" integer NOT NULL,
    "nextOwnerAccountId" integer NOT NULL,
    "videoId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoChangeOwnership_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoChangeOwnership_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoChangeOwnership_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoChangeOwnership_id_seq" OWNED BY public."videoChangeOwnership".id;


--
-- Name: videoChannel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoChannel" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(1000) DEFAULT NULL::character varying,
    support character varying(1000) DEFAULT NULL::character varying,
    "actorId" integer,
    "accountId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoChannelSync; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoChannelSync" (
    id integer NOT NULL,
    "externalChannelUrl" character varying(2000) DEFAULT NULL::character varying NOT NULL,
    state integer DEFAULT 1 NOT NULL,
    "lastSyncAt" timestamp with time zone,
    "videoChannelId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoChannelSync_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoChannelSync_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoChannelSync_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoChannelSync_id_seq" OWNED BY public."videoChannelSync".id;


--
-- Name: videoChannel_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoChannel_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoChannel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoChannel_id_seq" OWNED BY public."videoChannel".id;


--
-- Name: videoChapter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoChapter" (
    id integer NOT NULL,
    timecode integer NOT NULL,
    title character varying(255) NOT NULL,
    "videoId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoChapter_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoChapter_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoChapter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoChapter_id_seq" OWNED BY public."videoChapter".id;


--
-- Name: videoComment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoComment" (
    id integer NOT NULL,
    "deletedAt" timestamp with time zone,
    url character varying(2000) NOT NULL,
    text text NOT NULL,
    "heldForReview" boolean NOT NULL,
    "replyApproval" character varying(255),
    "originCommentId" integer,
    "inReplyToCommentId" integer,
    "videoId" integer NOT NULL,
    "accountId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoComment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoComment_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoComment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoComment_id_seq" OWNED BY public."videoComment".id;


--
-- Name: videoFile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoFile" (
    id integer NOT NULL,
    resolution integer NOT NULL,
    width integer,
    height integer,
    size bigint NOT NULL,
    extname character varying(255) NOT NULL,
    "infoHash" character varying(255),
    fps integer DEFAULT '-1'::integer NOT NULL,
    "formatFlags" integer NOT NULL,
    streams integer NOT NULL,
    metadata jsonb,
    "metadataUrl" character varying(255),
    "fileUrl" character varying(255),
    filename character varying(255),
    "torrentUrl" character varying(255),
    "torrentFilename" character varying(255),
    "videoId" integer,
    storage integer DEFAULT 0 NOT NULL,
    "videoStreamingPlaylistId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoFile_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoFile_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoFile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoFile_id_seq" OWNED BY public."videoFile".id;


--
-- Name: videoImport; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoImport" (
    id integer NOT NULL,
    "targetUrl" character varying(2000) DEFAULT NULL::character varying,
    "magnetUri" character varying(2000) DEFAULT NULL::character varying,
    "torrentName" character varying(255) DEFAULT NULL::character varying,
    state integer NOT NULL,
    error text,
    "userId" integer,
    "videoId" integer,
    "videoChannelSyncId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoImport_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoImport_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoImport_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoImport_id_seq" OWNED BY public."videoImport".id;


--
-- Name: videoJobInfo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoJobInfo" (
    id integer NOT NULL,
    "pendingMove" integer DEFAULT 0 NOT NULL,
    "pendingTranscode" integer DEFAULT 0 NOT NULL,
    "pendingTranscription" integer DEFAULT 0 NOT NULL,
    "videoId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoJobInfo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoJobInfo_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoJobInfo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoJobInfo_id_seq" OWNED BY public."videoJobInfo".id;


--
-- Name: videoLive; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoLive" (
    id integer NOT NULL,
    "streamKey" character varying(255),
    "saveReplay" boolean NOT NULL,
    "permanentLive" boolean NOT NULL,
    "latencyMode" integer NOT NULL,
    "videoId" integer NOT NULL,
    "replaySettingId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoLiveReplaySetting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoLiveReplaySetting" (
    id integer NOT NULL,
    privacy integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoLiveReplaySetting_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoLiveReplaySetting_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoLiveReplaySetting_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoLiveReplaySetting_id_seq" OWNED BY public."videoLiveReplaySetting".id;


--
-- Name: videoLiveSchedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoLiveSchedule" (
    id integer NOT NULL,
    "startAt" timestamp with time zone NOT NULL,
    "liveVideoId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoLiveSchedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoLiveSchedule_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoLiveSchedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoLiveSchedule_id_seq" OWNED BY public."videoLiveSchedule".id;


--
-- Name: videoLiveSession; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoLiveSession" (
    id integer NOT NULL,
    "startDate" timestamp with time zone NOT NULL,
    "endDate" timestamp with time zone,
    error integer,
    "saveReplay" boolean NOT NULL,
    "endingProcessed" boolean NOT NULL,
    "replayVideoId" integer,
    "liveVideoId" integer,
    "replaySettingId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoLiveSession_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoLiveSession_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoLiveSession_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoLiveSession_id_seq" OWNED BY public."videoLiveSession".id;


--
-- Name: videoLive_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoLive_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoLive_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoLive_id_seq" OWNED BY public."videoLive".id;


--
-- Name: videoPassword; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoPassword" (
    id integer NOT NULL,
    password character varying(255) NOT NULL,
    "videoId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoPassword_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoPassword_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoPassword_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoPassword_id_seq" OWNED BY public."videoPassword".id;


--
-- Name: videoPlaylist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoPlaylist" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(1000),
    privacy integer NOT NULL,
    url character varying(2000) NOT NULL,
    uuid uuid NOT NULL,
    type integer DEFAULT 1 NOT NULL,
    "videoChannelPosition" integer,
    "ownerAccountId" integer NOT NULL,
    "videoChannelId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoPlaylistElement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoPlaylistElement" (
    id integer NOT NULL,
    url character varying(2000),
    "position" integer DEFAULT 1 NOT NULL,
    "startTimestamp" integer,
    "stopTimestamp" integer,
    "videoPlaylistId" integer NOT NULL,
    "videoId" integer,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoPlaylistElement_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoPlaylistElement_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoPlaylistElement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoPlaylistElement_id_seq" OWNED BY public."videoPlaylistElement".id;


--
-- Name: videoPlaylist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoPlaylist_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoPlaylist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoPlaylist_id_seq" OWNED BY public."videoPlaylist".id;


--
-- Name: videoRedundancy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoRedundancy" (
    id integer NOT NULL,
    "expiresOn" timestamp with time zone,
    "fileUrl" character varying(2000) NOT NULL,
    url character varying(2000) NOT NULL,
    strategy character varying(255),
    "videoStreamingPlaylistId" integer NOT NULL,
    "actorId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoRedundancy_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoRedundancy_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoRedundancy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoRedundancy_id_seq" OWNED BY public."videoRedundancy".id;


--
-- Name: videoShare; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoShare" (
    id integer NOT NULL,
    url character varying(2000) NOT NULL,
    "actorId" integer NOT NULL,
    "videoId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoShare_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoShare_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoShare_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoShare_id_seq" OWNED BY public."videoShare".id;


--
-- Name: videoSource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoSource" (
    id integer NOT NULL,
    "inputFilename" character varying(255) NOT NULL,
    "keptOriginalFilename" character varying(255),
    resolution integer,
    width integer,
    height integer,
    fps integer,
    size bigint,
    metadata jsonb,
    storage integer,
    "fileUrl" character varying(255),
    "videoId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoSource_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoSource_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoSource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoSource_id_seq" OWNED BY public."videoSource".id;


--
-- Name: videoStreamingPlaylist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoStreamingPlaylist" (
    id integer NOT NULL,
    type integer NOT NULL,
    "playlistFilename" character varying(255) NOT NULL,
    "playlistUrl" character varying(2000),
    "p2pMediaLoaderInfohashes" character varying(255)[] NOT NULL,
    "p2pMediaLoaderPeerVersion" integer NOT NULL,
    "segmentsSha256Filename" character varying(255),
    "segmentsSha256Url" character varying(255),
    "videoId" integer NOT NULL,
    storage integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoStreamingPlaylist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoStreamingPlaylist_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoStreamingPlaylist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoStreamingPlaylist_id_seq" OWNED BY public."videoStreamingPlaylist".id;


--
-- Name: videoTag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoTag" (
    "videoId" integer NOT NULL,
    "tagId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoTracker; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoTracker" (
    "videoId" integer NOT NULL,
    "trackerId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: videoView; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."videoView" (
    id integer NOT NULL,
    "startDate" timestamp with time zone NOT NULL,
    "endDate" timestamp with time zone NOT NULL,
    views integer NOT NULL,
    "videoId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL
);


--
-- Name: videoView_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."videoView_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videoView_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."videoView_id_seq" OWNED BY public."videoView".id;


--
-- Name: video_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.video_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: video_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.video_id_seq OWNED BY public.video.id;


--
-- Name: watchedWordsList; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."watchedWordsList" (
    id integer NOT NULL,
    "listName" character varying(255) NOT NULL,
    words character varying(255)[] NOT NULL,
    "accountId" integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- Name: watchedWordsList_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."watchedWordsList_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: watchedWordsList_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."watchedWordsList_id_seq" OWNED BY public."watchedWordsList".id;


--
-- Name: abuse id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.abuse ALTER COLUMN id SET DEFAULT nextval('public.abuse_id_seq'::regclass);


--
-- Name: abuseMessage id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."abuseMessage" ALTER COLUMN id SET DEFAULT nextval('public."abuseMessage_id_seq"'::regclass);


--
-- Name: account id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account ALTER COLUMN id SET DEFAULT nextval('public.account_id_seq'::regclass);


--
-- Name: accountAutomaticTagPolicy id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."accountAutomaticTagPolicy" ALTER COLUMN id SET DEFAULT nextval('public."accountAutomaticTagPolicy_id_seq"'::regclass);


--
-- Name: accountBlocklist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."accountBlocklist" ALTER COLUMN id SET DEFAULT nextval('public."accountBlocklist_id_seq"'::regclass);


--
-- Name: accountVideoRate id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."accountVideoRate" ALTER COLUMN id SET DEFAULT nextval('public."accountVideoRate_id_seq"'::regclass);


--
-- Name: actor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actor ALTER COLUMN id SET DEFAULT nextval('public.actor_id_seq'::regclass);


--
-- Name: actorCustomPage id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."actorCustomPage" ALTER COLUMN id SET DEFAULT nextval('public."actorCustomPage_id_seq"'::regclass);


--
-- Name: actorFollow id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."actorFollow" ALTER COLUMN id SET DEFAULT nextval('public."actorFollow_id_seq"'::regclass);


--
-- Name: actorImage id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."actorImage" ALTER COLUMN id SET DEFAULT nextval('public."actorImage_id_seq"'::regclass);


--
-- Name: application id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application ALTER COLUMN id SET DEFAULT nextval('public.application_id_seq'::regclass);


--
-- Name: automaticTag id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."automaticTag" ALTER COLUMN id SET DEFAULT nextval('public."automaticTag_id_seq"'::regclass);


--
-- Name: commentAbuse id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."commentAbuse" ALTER COLUMN id SET DEFAULT nextval('public."commentAbuse_id_seq"'::regclass);


--
-- Name: localVideoViewer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."localVideoViewer" ALTER COLUMN id SET DEFAULT nextval('public."localVideoViewer_id_seq"'::regclass);


--
-- Name: localVideoViewerWatchSection id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."localVideoViewerWatchSection" ALTER COLUMN id SET DEFAULT nextval('public."localVideoViewerWatchSection_id_seq"'::regclass);


--
-- Name: oAuthClient id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."oAuthClient" ALTER COLUMN id SET DEFAULT nextval('public."oAuthClient_id_seq"'::regclass);


--
-- Name: oAuthToken id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."oAuthToken" ALTER COLUMN id SET DEFAULT nextval('public."oAuthToken_id_seq"'::regclass);


--
-- Name: plugin id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plugin ALTER COLUMN id SET DEFAULT nextval('public.plugin_id_seq'::regclass);


--
-- Name: runner id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.runner ALTER COLUMN id SET DEFAULT nextval('public.runner_id_seq'::regclass);


--
-- Name: runnerJob id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."runnerJob" ALTER COLUMN id SET DEFAULT nextval('public."runnerJob_id_seq"'::regclass);


--
-- Name: runnerRegistrationToken id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."runnerRegistrationToken" ALTER COLUMN id SET DEFAULT nextval('public."runnerRegistrationToken_id_seq"'::regclass);


--
-- Name: scheduleVideoUpdate id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."scheduleVideoUpdate" ALTER COLUMN id SET DEFAULT nextval('public."scheduleVideoUpdate_id_seq"'::regclass);


--
-- Name: server id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.server ALTER COLUMN id SET DEFAULT nextval('public.server_id_seq'::regclass);


--
-- Name: serverBlocklist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."serverBlocklist" ALTER COLUMN id SET DEFAULT nextval('public."serverBlocklist_id_seq"'::regclass);


--
-- Name: storyboard id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storyboard ALTER COLUMN id SET DEFAULT nextval('public.storyboard_id_seq'::regclass);


--
-- Name: tag id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag ALTER COLUMN id SET DEFAULT nextval('public.tag_id_seq'::regclass);


--
-- Name: thumbnail id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thumbnail ALTER COLUMN id SET DEFAULT nextval('public.thumbnail_id_seq'::regclass);


--
-- Name: tracker id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracker ALTER COLUMN id SET DEFAULT nextval('public.tracker_id_seq'::regclass);


--
-- Name: uploadImage id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."uploadImage" ALTER COLUMN id SET DEFAULT nextval('public."uploadImage_id_seq"'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Name: userExport id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userExport" ALTER COLUMN id SET DEFAULT nextval('public."userExport_id_seq"'::regclass);


--
-- Name: userImport id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userImport" ALTER COLUMN id SET DEFAULT nextval('public."userImport_id_seq"'::regclass);


--
-- Name: userNotification id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotification" ALTER COLUMN id SET DEFAULT nextval('public."userNotification_id_seq"'::regclass);


--
-- Name: userNotificationSetting id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotificationSetting" ALTER COLUMN id SET DEFAULT nextval('public."userNotificationSetting_id_seq"'::regclass);


--
-- Name: userRegistration id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userRegistration" ALTER COLUMN id SET DEFAULT nextval('public."userRegistration_id_seq"'::regclass);


--
-- Name: userVideoHistory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userVideoHistory" ALTER COLUMN id SET DEFAULT nextval('public."userVideoHistory_id_seq"'::regclass);


--
-- Name: video id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.video ALTER COLUMN id SET DEFAULT nextval('public.video_id_seq'::regclass);


--
-- Name: videoAbuse id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoAbuse" ALTER COLUMN id SET DEFAULT nextval('public."videoAbuse_id_seq"'::regclass);


--
-- Name: videoBlacklist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoBlacklist" ALTER COLUMN id SET DEFAULT nextval('public."videoBlacklist_id_seq"'::regclass);


--
-- Name: videoCaption id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoCaption" ALTER COLUMN id SET DEFAULT nextval('public."videoCaption_id_seq"'::regclass);


--
-- Name: videoChangeOwnership id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoChangeOwnership" ALTER COLUMN id SET DEFAULT nextval('public."videoChangeOwnership_id_seq"'::regclass);


--
-- Name: videoChannel id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoChannel" ALTER COLUMN id SET DEFAULT nextval('public."videoChannel_id_seq"'::regclass);


--
-- Name: videoChannelSync id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoChannelSync" ALTER COLUMN id SET DEFAULT nextval('public."videoChannelSync_id_seq"'::regclass);


--
-- Name: videoChapter id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoChapter" ALTER COLUMN id SET DEFAULT nextval('public."videoChapter_id_seq"'::regclass);


--
-- Name: videoComment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoComment" ALTER COLUMN id SET DEFAULT nextval('public."videoComment_id_seq"'::regclass);


--
-- Name: videoFile id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoFile" ALTER COLUMN id SET DEFAULT nextval('public."videoFile_id_seq"'::regclass);


--
-- Name: videoImport id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoImport" ALTER COLUMN id SET DEFAULT nextval('public."videoImport_id_seq"'::regclass);


--
-- Name: videoJobInfo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoJobInfo" ALTER COLUMN id SET DEFAULT nextval('public."videoJobInfo_id_seq"'::regclass);


--
-- Name: videoLive id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoLive" ALTER COLUMN id SET DEFAULT nextval('public."videoLive_id_seq"'::regclass);


--
-- Name: videoLiveReplaySetting id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoLiveReplaySetting" ALTER COLUMN id SET DEFAULT nextval('public."videoLiveReplaySetting_id_seq"'::regclass);


--
-- Name: videoLiveSchedule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoLiveSchedule" ALTER COLUMN id SET DEFAULT nextval('public."videoLiveSchedule_id_seq"'::regclass);


--
-- Name: videoLiveSession id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoLiveSession" ALTER COLUMN id SET DEFAULT nextval('public."videoLiveSession_id_seq"'::regclass);


--
-- Name: videoPassword id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoPassword" ALTER COLUMN id SET DEFAULT nextval('public."videoPassword_id_seq"'::regclass);


--
-- Name: videoPlaylist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoPlaylist" ALTER COLUMN id SET DEFAULT nextval('public."videoPlaylist_id_seq"'::regclass);


--
-- Name: videoPlaylistElement id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoPlaylistElement" ALTER COLUMN id SET DEFAULT nextval('public."videoPlaylistElement_id_seq"'::regclass);


--
-- Name: videoRedundancy id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoRedundancy" ALTER COLUMN id SET DEFAULT nextval('public."videoRedundancy_id_seq"'::regclass);


--
-- Name: videoShare id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoShare" ALTER COLUMN id SET DEFAULT nextval('public."videoShare_id_seq"'::regclass);


--
-- Name: videoSource id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoSource" ALTER COLUMN id SET DEFAULT nextval('public."videoSource_id_seq"'::regclass);


--
-- Name: videoStreamingPlaylist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoStreamingPlaylist" ALTER COLUMN id SET DEFAULT nextval('public."videoStreamingPlaylist_id_seq"'::regclass);


--
-- Name: videoView id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoView" ALTER COLUMN id SET DEFAULT nextval('public."videoView_id_seq"'::regclass);


--
-- Name: watchedWordsList id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."watchedWordsList" ALTER COLUMN id SET DEFAULT nextval('public."watchedWordsList_id_seq"'::regclass);


--
-- Name: abuseMessage abuseMessage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."abuseMessage"
    ADD CONSTRAINT "abuseMessage_pkey" PRIMARY KEY (id);


--
-- Name: abuse abuse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.abuse
    ADD CONSTRAINT abuse_pkey PRIMARY KEY (id);


--
-- Name: accountAutomaticTagPolicy accountAutomaticTagPolicy_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."accountAutomaticTagPolicy"
    ADD CONSTRAINT "accountAutomaticTagPolicy_pkey" PRIMARY KEY (id);


--
-- Name: accountBlocklist accountBlocklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."accountBlocklist"
    ADD CONSTRAINT "accountBlocklist_pkey" PRIMARY KEY (id);


--
-- Name: accountVideoRate accountVideoRate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."accountVideoRate"
    ADD CONSTRAINT "accountVideoRate_pkey" PRIMARY KEY (id);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: actorCustomPage actorCustomPage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."actorCustomPage"
    ADD CONSTRAINT "actorCustomPage_pkey" PRIMARY KEY (id);


--
-- Name: actorFollow actorFollow_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."actorFollow"
    ADD CONSTRAINT "actorFollow_pkey" PRIMARY KEY (id);


--
-- Name: actorImage actorImage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."actorImage"
    ADD CONSTRAINT "actorImage_pkey" PRIMARY KEY (id);


--
-- Name: actor actor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actor
    ADD CONSTRAINT actor_pkey PRIMARY KEY (id);


--
-- Name: application application_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application
    ADD CONSTRAINT application_pkey PRIMARY KEY (id);


--
-- Name: automaticTag automaticTag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."automaticTag"
    ADD CONSTRAINT "automaticTag_pkey" PRIMARY KEY (id);


--
-- Name: commentAbuse commentAbuse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."commentAbuse"
    ADD CONSTRAINT "commentAbuse_pkey" PRIMARY KEY (id);


--
-- Name: commentAutomaticTag commentAutomaticTag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."commentAutomaticTag"
    ADD CONSTRAINT "commentAutomaticTag_pkey" PRIMARY KEY ("commentId", "automaticTagId", "accountId");


--
-- Name: localVideoViewerWatchSection localVideoViewerWatchSection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."localVideoViewerWatchSection"
    ADD CONSTRAINT "localVideoViewerWatchSection_pkey" PRIMARY KEY (id);


--
-- Name: localVideoViewer localVideoViewer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."localVideoViewer"
    ADD CONSTRAINT "localVideoViewer_pkey" PRIMARY KEY (id);


--
-- Name: oAuthClient oAuthClient_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."oAuthClient"
    ADD CONSTRAINT "oAuthClient_pkey" PRIMARY KEY (id);


--
-- Name: oAuthToken oAuthToken_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."oAuthToken"
    ADD CONSTRAINT "oAuthToken_pkey" PRIMARY KEY (id);


--
-- Name: plugin plugin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plugin
    ADD CONSTRAINT plugin_pkey PRIMARY KEY (id);


--
-- Name: runnerJob runnerJob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."runnerJob"
    ADD CONSTRAINT "runnerJob_pkey" PRIMARY KEY (id);


--
-- Name: runnerRegistrationToken runnerRegistrationToken_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."runnerRegistrationToken"
    ADD CONSTRAINT "runnerRegistrationToken_pkey" PRIMARY KEY (id);


--
-- Name: runner runner_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.runner
    ADD CONSTRAINT runner_pkey PRIMARY KEY (id);


--
-- Name: scheduleVideoUpdate scheduleVideoUpdate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."scheduleVideoUpdate"
    ADD CONSTRAINT "scheduleVideoUpdate_pkey" PRIMARY KEY (id);


--
-- Name: serverBlocklist serverBlocklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."serverBlocklist"
    ADD CONSTRAINT "serverBlocklist_pkey" PRIMARY KEY (id);


--
-- Name: server server_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.server
    ADD CONSTRAINT server_pkey PRIMARY KEY (id);


--
-- Name: storyboard storyboard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storyboard
    ADD CONSTRAINT storyboard_pkey PRIMARY KEY (id);


--
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- Name: thumbnail thumbnail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thumbnail
    ADD CONSTRAINT thumbnail_pkey PRIMARY KEY (id);


--
-- Name: tracker tracker_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracker
    ADD CONSTRAINT tracker_pkey PRIMARY KEY (id);


--
-- Name: uploadImage uploadImage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."uploadImage"
    ADD CONSTRAINT "uploadImage_pkey" PRIMARY KEY (id);


--
-- Name: userExport userExport_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userExport"
    ADD CONSTRAINT "userExport_pkey" PRIMARY KEY (id);


--
-- Name: userImport userImport_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userImport"
    ADD CONSTRAINT "userImport_pkey" PRIMARY KEY (id);


--
-- Name: userNotificationSetting userNotificationSetting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotificationSetting"
    ADD CONSTRAINT "userNotificationSetting_pkey" PRIMARY KEY (id);


--
-- Name: userNotification userNotification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotification"
    ADD CONSTRAINT "userNotification_pkey" PRIMARY KEY (id);


--
-- Name: userRegistration userRegistration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userRegistration"
    ADD CONSTRAINT "userRegistration_pkey" PRIMARY KEY (id);


--
-- Name: userVideoHistory userVideoHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userVideoHistory"
    ADD CONSTRAINT "userVideoHistory_pkey" PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: videoAbuse videoAbuse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoAbuse"
    ADD CONSTRAINT "videoAbuse_pkey" PRIMARY KEY (id);


--
-- Name: videoAutomaticTag videoAutomaticTag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoAutomaticTag"
    ADD CONSTRAINT "videoAutomaticTag_pkey" PRIMARY KEY ("videoId", "automaticTagId", "accountId");


--
-- Name: videoBlacklist videoBlacklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoBlacklist"
    ADD CONSTRAINT "videoBlacklist_pkey" PRIMARY KEY (id);


--
-- Name: videoCaption videoCaption_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoCaption"
    ADD CONSTRAINT "videoCaption_pkey" PRIMARY KEY (id);


--
-- Name: videoChangeOwnership videoChangeOwnership_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoChangeOwnership"
    ADD CONSTRAINT "videoChangeOwnership_pkey" PRIMARY KEY (id);


--
-- Name: videoChannelSync videoChannelSync_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoChannelSync"
    ADD CONSTRAINT "videoChannelSync_pkey" PRIMARY KEY (id);


--
-- Name: videoChannel videoChannel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoChannel"
    ADD CONSTRAINT "videoChannel_pkey" PRIMARY KEY (id);


--
-- Name: videoChapter videoChapter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoChapter"
    ADD CONSTRAINT "videoChapter_pkey" PRIMARY KEY (id);


--
-- Name: videoComment videoComment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoComment"
    ADD CONSTRAINT "videoComment_pkey" PRIMARY KEY (id);


--
-- Name: videoFile videoFile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoFile"
    ADD CONSTRAINT "videoFile_pkey" PRIMARY KEY (id);


--
-- Name: videoImport videoImport_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoImport"
    ADD CONSTRAINT "videoImport_pkey" PRIMARY KEY (id);


--
-- Name: videoJobInfo videoJobInfo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoJobInfo"
    ADD CONSTRAINT "videoJobInfo_pkey" PRIMARY KEY (id);


--
-- Name: videoJobInfo videoJobInfo_videoId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoJobInfo"
    ADD CONSTRAINT "videoJobInfo_videoId_key" UNIQUE ("videoId");


--
-- Name: videoLiveReplaySetting videoLiveReplaySetting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoLiveReplaySetting"
    ADD CONSTRAINT "videoLiveReplaySetting_pkey" PRIMARY KEY (id);


--
-- Name: videoLiveSchedule videoLiveSchedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoLiveSchedule"
    ADD CONSTRAINT "videoLiveSchedule_pkey" PRIMARY KEY (id);


--
-- Name: videoLiveSession videoLiveSession_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoLiveSession"
    ADD CONSTRAINT "videoLiveSession_pkey" PRIMARY KEY (id);


--
-- Name: videoLive videoLive_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoLive"
    ADD CONSTRAINT "videoLive_pkey" PRIMARY KEY (id);


--
-- Name: videoPassword videoPassword_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoPassword"
    ADD CONSTRAINT "videoPassword_pkey" PRIMARY KEY (id);


--
-- Name: videoPlaylistElement videoPlaylistElement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoPlaylistElement"
    ADD CONSTRAINT "videoPlaylistElement_pkey" PRIMARY KEY (id);


--
-- Name: videoPlaylist videoPlaylist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoPlaylist"
    ADD CONSTRAINT "videoPlaylist_pkey" PRIMARY KEY (id);


--
-- Name: videoRedundancy videoRedundancy_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoRedundancy"
    ADD CONSTRAINT "videoRedundancy_pkey" PRIMARY KEY (id);


--
-- Name: videoShare videoShare_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoShare"
    ADD CONSTRAINT "videoShare_pkey" PRIMARY KEY (id);


--
-- Name: videoSource videoSource_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoSource"
    ADD CONSTRAINT "videoSource_pkey" PRIMARY KEY (id);


--
-- Name: videoStreamingPlaylist videoStreamingPlaylist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoStreamingPlaylist"
    ADD CONSTRAINT "videoStreamingPlaylist_pkey" PRIMARY KEY (id);


--
-- Name: videoTag videoTag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoTag"
    ADD CONSTRAINT "videoTag_pkey" PRIMARY KEY ("videoId", "tagId");


--
-- Name: videoTracker videoTracker_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoTracker"
    ADD CONSTRAINT "videoTracker_pkey" PRIMARY KEY ("videoId", "trackerId");


--
-- Name: videoView videoView_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoView"
    ADD CONSTRAINT "videoView_pkey" PRIMARY KEY (id);


--
-- Name: video video_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.video
    ADD CONSTRAINT video_pkey PRIMARY KEY (id);


--
-- Name: watchedWordsList watchedWordsList_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."watchedWordsList"
    ADD CONSTRAINT "watchedWordsList_pkey" PRIMARY KEY (id);


--
-- Name: abuse_flagged_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX abuse_flagged_account_id ON public.abuse USING btree ("flaggedAccountId");


--
-- Name: abuse_message_abuse_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX abuse_message_abuse_id ON public."abuseMessage" USING btree ("abuseId");


--
-- Name: abuse_message_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX abuse_message_account_id ON public."abuseMessage" USING btree ("accountId");


--
-- Name: abuse_reporter_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX abuse_reporter_account_id ON public.abuse USING btree ("reporterAccountId");


--
-- Name: account_actor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX account_actor_id ON public.account USING btree ("actorId");


--
-- Name: account_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX account_application_id ON public.account USING btree ("applicationId");


--
-- Name: account_automatic_tag_policy_account_id_policy_automatic_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX account_automatic_tag_policy_account_id_policy_automatic_tag_id ON public."accountAutomaticTagPolicy" USING btree ("accountId", policy, "automaticTagId");


--
-- Name: account_blocklist_account_id_target_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX account_blocklist_account_id_target_account_id ON public."accountBlocklist" USING btree ("accountId", "targetAccountId");


--
-- Name: account_blocklist_target_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX account_blocklist_target_account_id ON public."accountBlocklist" USING btree ("targetAccountId");


--
-- Name: account_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX account_user_id ON public.account USING btree ("userId");


--
-- Name: account_video_rate_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX account_video_rate_account_id ON public."accountVideoRate" USING btree ("accountId");


--
-- Name: account_video_rate_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX account_video_rate_url ON public."accountVideoRate" USING btree (url);


--
-- Name: account_video_rate_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX account_video_rate_video_id ON public."accountVideoRate" USING btree ("videoId");


--
-- Name: account_video_rate_video_id_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX account_video_rate_video_id_account_id ON public."accountVideoRate" USING btree ("videoId", "accountId");


--
-- Name: account_video_rate_video_id_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX account_video_rate_video_id_type ON public."accountVideoRate" USING btree ("videoId", type);


--
-- Name: actor_custom_page_actor_id_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX actor_custom_page_actor_id_type ON public."actorCustomPage" USING btree ("actorId", type);


--
-- Name: actor_follow_actor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX actor_follow_actor_id ON public."actorFollow" USING btree ("actorId");


--
-- Name: actor_follow_actor_id_target_actor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX actor_follow_actor_id_target_actor_id ON public."actorFollow" USING btree ("actorId", "targetActorId");


--
-- Name: actor_follow_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX actor_follow_score ON public."actorFollow" USING btree (score);


--
-- Name: actor_follow_target_actor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX actor_follow_target_actor_id ON public."actorFollow" USING btree ("targetActorId");


--
-- Name: actor_follow_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX actor_follow_url ON public."actorFollow" USING btree (url);


--
-- Name: actor_followers_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX actor_followers_url ON public.actor USING btree ("followersUrl");


--
-- Name: actor_image_actor_id_type_width; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX actor_image_actor_id_type_width ON public."actorImage" USING btree ("actorId", type, width);


--
-- Name: actor_image_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX actor_image_filename ON public."actorImage" USING btree (filename);


--
-- Name: actor_inbox_url_shared_inbox_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX actor_inbox_url_shared_inbox_url ON public.actor USING btree ("inboxUrl", "sharedInboxUrl");


--
-- Name: actor_preferred_username_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX actor_preferred_username_lower ON public.actor USING btree (lower(("preferredUsername")::text)) WHERE ("serverId" IS NULL);


--
-- Name: actor_preferred_username_lower_server_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX actor_preferred_username_lower_server_id ON public.actor USING btree (lower(("preferredUsername")::text), "serverId") WHERE ("serverId" IS NOT NULL);


--
-- Name: actor_server_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX actor_server_id ON public.actor USING btree ("serverId");


--
-- Name: actor_shared_inbox_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX actor_shared_inbox_url ON public.actor USING btree ("sharedInboxUrl");


--
-- Name: actor_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX actor_url ON public.actor USING btree (url);


--
-- Name: automatic_tag_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX automatic_tag_lower_name ON public."automaticTag" USING btree (lower((name)::text));


--
-- Name: automatic_tag_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX automatic_tag_name ON public."automaticTag" USING btree (name);


--
-- Name: comment_abuse_abuse_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comment_abuse_abuse_id ON public."commentAbuse" USING btree ("abuseId");


--
-- Name: comment_abuse_video_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comment_abuse_video_comment_id ON public."commentAbuse" USING btree ("videoCommentId");


--
-- Name: local_video_viewer_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX local_video_viewer_url ON public."localVideoViewer" USING btree (url);


--
-- Name: local_video_viewer_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX local_video_viewer_video_id ON public."localVideoViewer" USING btree ("videoId");


--
-- Name: local_video_viewer_watch_section_local_video_viewer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX local_video_viewer_watch_section_local_video_viewer_id ON public."localVideoViewerWatchSection" USING btree ("localVideoViewerId");


--
-- Name: o_auth_client_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX o_auth_client_client_id ON public."oAuthClient" USING btree ("clientId");


--
-- Name: o_auth_client_client_id_client_secret; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX o_auth_client_client_id_client_secret ON public."oAuthClient" USING btree ("clientId", "clientSecret");


--
-- Name: o_auth_token_access_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX o_auth_token_access_token ON public."oAuthToken" USING btree ("accessToken");


--
-- Name: o_auth_token_o_auth_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX o_auth_token_o_auth_client_id ON public."oAuthToken" USING btree ("oAuthClientId");


--
-- Name: o_auth_token_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX o_auth_token_refresh_token ON public."oAuthToken" USING btree ("refreshToken");


--
-- Name: o_auth_token_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX o_auth_token_user_id ON public."oAuthToken" USING btree ("userId");


--
-- Name: plugin_name_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX plugin_name_type ON public.plugin USING btree (name, type);


--
-- Name: runner_job_processing_job_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX runner_job_processing_job_token ON public."runnerJob" USING btree ("processingJobToken");


--
-- Name: runner_job_runner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX runner_job_runner_id ON public."runnerJob" USING btree ("runnerId");


--
-- Name: runner_job_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX runner_job_uuid ON public."runnerJob" USING btree (uuid);


--
-- Name: runner_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX runner_name ON public.runner USING btree (name);


--
-- Name: runner_registration_token_registration_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX runner_registration_token_registration_token ON public."runnerRegistrationToken" USING btree ("registrationToken");


--
-- Name: runner_runner_registration_token_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX runner_runner_registration_token_id ON public.runner USING btree ("runnerRegistrationTokenId");


--
-- Name: runner_runner_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX runner_runner_token ON public.runner USING btree ("runnerToken");


--
-- Name: schedule_video_update_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX schedule_video_update_update_at ON public."scheduleVideoUpdate" USING btree ("updateAt");


--
-- Name: schedule_video_update_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX schedule_video_update_video_id ON public."scheduleVideoUpdate" USING btree ("videoId");


--
-- Name: server_blocklist_account_id_target_server_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX server_blocklist_account_id_target_server_id ON public."serverBlocklist" USING btree ("accountId", "targetServerId");


--
-- Name: server_blocklist_target_server_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX server_blocklist_target_server_id ON public."serverBlocklist" USING btree ("targetServerId");


--
-- Name: server_host; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX server_host ON public.server USING btree (host);


--
-- Name: storyboard_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX storyboard_filename ON public.storyboard USING btree (filename);


--
-- Name: storyboard_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX storyboard_video_id ON public.storyboard USING btree ("videoId");


--
-- Name: tag_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tag_lower_name ON public.tag USING btree (lower((name)::text));


--
-- Name: tag_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tag_name ON public.tag USING btree (name);


--
-- Name: thumbnail_filename_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX thumbnail_filename_type ON public.thumbnail USING btree (filename, type);


--
-- Name: thumbnail_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX thumbnail_video_id ON public.thumbnail USING btree ("videoId");


--
-- Name: thumbnail_video_playlist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX thumbnail_video_playlist_id ON public.thumbnail USING btree ("videoPlaylistId");


--
-- Name: tracker_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tracker_url ON public.tracker USING btree (url);


--
-- Name: upload_image_actor_id_type_width; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX upload_image_actor_id_type_width ON public."uploadImage" USING btree ("actorId", type, width);


--
-- Name: upload_image_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX upload_image_filename ON public."uploadImage" USING btree (filename);


--
-- Name: user_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_email ON public."user" USING btree (email);


--
-- Name: user_export_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_export_filename ON public."userExport" USING btree (filename);


--
-- Name: user_export_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_export_user_id ON public."userExport" USING btree ("userId");


--
-- Name: user_import_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_import_filename ON public."userImport" USING btree (filename);


--
-- Name: user_import_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_import_user_id ON public."userImport" USING btree ("userId");


--
-- Name: user_notification_abuse_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_notification_abuse_id ON public."userNotification" USING btree ("abuseId") WHERE ("abuseId" IS NOT NULL);


--
-- Name: user_notification_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_notification_account_id ON public."userNotification" USING btree ("accountId") WHERE ("accountId" IS NOT NULL);


--
-- Name: user_notification_actor_follow_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_notification_actor_follow_id ON public."userNotification" USING btree ("actorFollowId") WHERE ("actorFollowId" IS NOT NULL);


--
-- Name: user_notification_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_notification_application_id ON public."userNotification" USING btree ("applicationId") WHERE ("applicationId" IS NOT NULL);


--
-- Name: user_notification_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_notification_comment_id ON public."userNotification" USING btree ("commentId") WHERE ("commentId" IS NOT NULL);


--
-- Name: user_notification_plugin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_notification_plugin_id ON public."userNotification" USING btree ("pluginId") WHERE ("pluginId" IS NOT NULL);


--
-- Name: user_notification_setting_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_notification_setting_user_id ON public."userNotificationSetting" USING btree ("userId");


--
-- Name: user_notification_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_notification_user_id ON public."userNotification" USING btree ("userId");


--
-- Name: user_notification_user_registration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_notification_user_registration_id ON public."userNotification" USING btree ("userRegistrationId") WHERE ("userRegistrationId" IS NOT NULL);


--
-- Name: user_notification_video_blacklist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_notification_video_blacklist_id ON public."userNotification" USING btree ("videoBlacklistId") WHERE ("videoBlacklistId" IS NOT NULL);


--
-- Name: user_notification_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_notification_video_id ON public."userNotification" USING btree ("videoId") WHERE ("videoId" IS NOT NULL);


--
-- Name: user_notification_video_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_notification_video_import_id ON public."userNotification" USING btree ("videoImportId") WHERE ("videoImportId" IS NOT NULL);


--
-- Name: user_registration_channel_handle; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_registration_channel_handle ON public."userRegistration" USING btree ("channelHandle");


--
-- Name: user_registration_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_registration_email ON public."userRegistration" USING btree (email);


--
-- Name: user_registration_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_registration_user_id ON public."userRegistration" USING btree ("userId");


--
-- Name: user_registration_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_registration_username ON public."userRegistration" USING btree (username);


--
-- Name: user_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_username ON public."user" USING btree (username);


--
-- Name: user_video_history_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_video_history_user_id ON public."userVideoHistory" USING btree ("userId");


--
-- Name: user_video_history_user_id_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_video_history_user_id_video_id ON public."userVideoHistory" USING btree ("userId", "videoId");


--
-- Name: user_video_history_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_video_history_video_id ON public."userVideoHistory" USING btree ("videoId");


--
-- Name: video_abuse_abuse_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_abuse_abuse_id ON public."videoAbuse" USING btree ("abuseId");


--
-- Name: video_abuse_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_abuse_video_id ON public."videoAbuse" USING btree ("videoId");


--
-- Name: video_blacklist_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_blacklist_video_id ON public."videoBlacklist" USING btree ("videoId");


--
-- Name: video_caption_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_caption_filename ON public."videoCaption" USING btree (filename);


--
-- Name: video_caption_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_caption_video_id ON public."videoCaption" USING btree ("videoId");


--
-- Name: video_caption_video_id_language; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_caption_video_id_language ON public."videoCaption" USING btree ("videoId", language);


--
-- Name: video_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_category ON public.video USING btree (category) WHERE (category IS NOT NULL);


--
-- Name: video_change_ownership_initiator_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_change_ownership_initiator_account_id ON public."videoChangeOwnership" USING btree ("initiatorAccountId");


--
-- Name: video_change_ownership_next_owner_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_change_ownership_next_owner_account_id ON public."videoChangeOwnership" USING btree ("nextOwnerAccountId");


--
-- Name: video_change_ownership_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_change_ownership_video_id ON public."videoChangeOwnership" USING btree ("videoId");


--
-- Name: video_channel_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_channel_account_id ON public."videoChannel" USING btree ("accountId");


--
-- Name: video_channel_actor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_channel_actor_id ON public."videoChannel" USING btree ("actorId");


--
-- Name: video_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_channel_id ON public.video USING btree ("channelId");


--
-- Name: video_channel_name_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_channel_name_trigram ON public."videoChannel" USING gin (lower(public.immutable_unaccent((name)::text)) public.gin_trgm_ops);


--
-- Name: video_channel_sync_video_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_channel_sync_video_channel_id ON public."videoChannelSync" USING btree ("videoChannelId");


--
-- Name: video_chapter_video_id_timecode; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_chapter_video_id_timecode ON public."videoChapter" USING btree ("videoId", timecode);


--
-- Name: video_comment_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_comment_account_id ON public."videoComment" USING btree ("accountId");


--
-- Name: video_comment_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_comment_created_at ON public."videoComment" USING btree ("createdAt" DESC);


--
-- Name: video_comment_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_comment_url ON public."videoComment" USING btree (url);


--
-- Name: video_comment_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_comment_video_id ON public."videoComment" USING btree ("videoId");


--
-- Name: video_comment_video_id_origin_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_comment_video_id_origin_comment_id ON public."videoComment" USING btree ("videoId", "originCommentId");


--
-- Name: video_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_created_at ON public.video USING btree ("createdAt");


--
-- Name: video_duration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_duration ON public.video USING btree (duration);


--
-- Name: video_file_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_file_filename ON public."videoFile" USING btree (filename);


--
-- Name: video_file_info_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_file_info_hash ON public."videoFile" USING btree ("infoHash");


--
-- Name: video_file_torrent_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_file_torrent_filename ON public."videoFile" USING btree ("torrentFilename");


--
-- Name: video_file_video_id_resolution_fps; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_file_video_id_resolution_fps ON public."videoFile" USING btree ("videoId", resolution, fps) WHERE ("videoId" IS NOT NULL);


--
-- Name: video_file_video_streaming_playlist_id_resolution_fps; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_file_video_streaming_playlist_id_resolution_fps ON public."videoFile" USING btree ("videoStreamingPlaylistId", resolution, fps) WHERE ("videoStreamingPlaylistId" IS NOT NULL);


--
-- Name: video_import_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_import_user_id ON public."videoImport" USING btree ("userId");


--
-- Name: video_import_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_import_video_id ON public."videoImport" USING btree ("videoId");


--
-- Name: video_is_live; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_is_live ON public.video USING btree ("isLive") WHERE ("isLive" = true);


--
-- Name: video_job_info_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_job_info_video_id ON public."videoJobInfo" USING btree ("videoId") WHERE ("videoId" IS NOT NULL);


--
-- Name: video_language; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_language ON public.video USING btree (language) WHERE (language IS NOT NULL);


--
-- Name: video_licence; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_licence ON public.video USING btree (licence) WHERE (licence IS NOT NULL);


--
-- Name: video_live_replay_setting_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_live_replay_setting_id ON public."videoLive" USING btree ("replaySettingId");


--
-- Name: video_live_schedule_live_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_live_schedule_live_video_id ON public."videoLiveSchedule" USING btree ("liveVideoId");


--
-- Name: video_live_schedule_start_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_live_schedule_start_at ON public."videoLiveSchedule" USING btree ("startAt");


--
-- Name: video_live_session_live_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_live_session_live_video_id ON public."videoLiveSession" USING btree ("liveVideoId");


--
-- Name: video_live_session_replay_setting_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_live_session_replay_setting_id ON public."videoLiveSession" USING btree ("replaySettingId");


--
-- Name: video_live_session_replay_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_live_session_replay_video_id ON public."videoLiveSession" USING btree ("replayVideoId");


--
-- Name: video_live_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_live_video_id ON public."videoLive" USING btree ("videoId");


--
-- Name: video_name_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_name_trigram ON public.video USING gin (lower(public.immutable_unaccent((name)::text)) public.gin_trgm_ops);


--
-- Name: video_nsfw; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_nsfw ON public.video USING btree (nsfw) WHERE (nsfw = true);


--
-- Name: video_originally_published_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_originally_published_at ON public.video USING btree ("originallyPublishedAt") WHERE ("originallyPublishedAt" IS NOT NULL);


--
-- Name: video_password_video_id_password; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_password_video_id_password ON public."videoPassword" USING btree ("videoId", password);


--
-- Name: video_playlist_element_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_playlist_element_url ON public."videoPlaylistElement" USING btree (url);


--
-- Name: video_playlist_element_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_playlist_element_video_id ON public."videoPlaylistElement" USING btree ("videoId");


--
-- Name: video_playlist_element_video_playlist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_playlist_element_video_playlist_id ON public."videoPlaylistElement" USING btree ("videoPlaylistId");


--
-- Name: video_playlist_name_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_playlist_name_trigram ON public."videoPlaylist" USING gin (lower(public.immutable_unaccent((name)::text)) public.gin_trgm_ops);


--
-- Name: video_playlist_owner_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_playlist_owner_account_id ON public."videoPlaylist" USING btree ("ownerAccountId");


--
-- Name: video_playlist_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_playlist_url ON public."videoPlaylist" USING btree (url);


--
-- Name: video_playlist_video_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_playlist_video_channel_id ON public."videoPlaylist" USING btree ("videoChannelId");


--
-- Name: video_published_at_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_published_at_id ON public.video USING btree ("publishedAt" DESC, id);


--
-- Name: video_redundancy_actor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_redundancy_actor_id ON public."videoRedundancy" USING btree ("actorId");


--
-- Name: video_redundancy_expires_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_redundancy_expires_on ON public."videoRedundancy" USING btree ("expiresOn");


--
-- Name: video_redundancy_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_redundancy_url ON public."videoRedundancy" USING btree (url);


--
-- Name: video_redundancy_video_streaming_playlist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_redundancy_video_streaming_playlist_id ON public."videoRedundancy" USING btree ("videoStreamingPlaylistId");


--
-- Name: video_remote; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_remote ON public.video USING btree (remote) WHERE (remote = false);


--
-- Name: video_share_actor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_share_actor_id ON public."videoShare" USING btree ("actorId");


--
-- Name: video_share_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_share_url ON public."videoShare" USING btree (url);


--
-- Name: video_share_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_share_video_id ON public."videoShare" USING btree ("videoId");


--
-- Name: video_source_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_source_created_at ON public."videoSource" USING btree ("createdAt" DESC);


--
-- Name: video_source_kept_original_filename; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_source_kept_original_filename ON public."videoSource" USING btree ("keptOriginalFilename");


--
-- Name: video_source_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_source_video_id ON public."videoSource" USING btree ("videoId");


--
-- Name: video_streaming_playlist_p2p_media_loader_infohashes; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_streaming_playlist_p2p_media_loader_infohashes ON public."videoStreamingPlaylist" USING gin ("p2pMediaLoaderInfohashes");


--
-- Name: video_streaming_playlist_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_streaming_playlist_video_id ON public."videoStreamingPlaylist" USING btree ("videoId");


--
-- Name: video_streaming_playlist_video_id_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_streaming_playlist_video_id_type ON public."videoStreamingPlaylist" USING btree ("videoId", type);


--
-- Name: video_tag_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_tag_tag_id ON public."videoTag" USING btree ("tagId");


--
-- Name: video_tag_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_tag_video_id ON public."videoTag" USING btree ("videoId");


--
-- Name: video_tracker_tracker_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_tracker_tracker_id ON public."videoTracker" USING btree ("trackerId");


--
-- Name: video_tracker_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_tracker_video_id ON public."videoTracker" USING btree ("videoId");


--
-- Name: video_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_url ON public.video USING btree (url);


--
-- Name: video_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX video_uuid ON public.video USING btree (uuid);


--
-- Name: video_view_start_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_view_start_date ON public."videoView" USING btree ("startDate");


--
-- Name: video_view_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_view_video_id ON public."videoView" USING btree ("videoId");


--
-- Name: video_views_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX video_views_id ON public.video USING btree (views DESC, id);


--
-- Name: watched_words_list_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX watched_words_list_account_id ON public."watchedWordsList" USING btree ("accountId");


--
-- Name: watched_words_list_list_name_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX watched_words_list_list_name_account_id ON public."watchedWordsList" USING btree ("listName", "accountId");


--
-- Name: abuseMessage abuseMessage_abuseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."abuseMessage"
    ADD CONSTRAINT "abuseMessage_abuseId_fkey" FOREIGN KEY ("abuseId") REFERENCES public.abuse(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: abuseMessage abuseMessage_accountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."abuseMessage"
    ADD CONSTRAINT "abuseMessage_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: abuse abuse_flaggedAccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.abuse
    ADD CONSTRAINT "abuse_flaggedAccountId_fkey" FOREIGN KEY ("flaggedAccountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: abuse abuse_reporterAccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.abuse
    ADD CONSTRAINT "abuse_reporterAccountId_fkey" FOREIGN KEY ("reporterAccountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: accountAutomaticTagPolicy accountAutomaticTagPolicy_accountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."accountAutomaticTagPolicy"
    ADD CONSTRAINT "accountAutomaticTagPolicy_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: accountAutomaticTagPolicy accountAutomaticTagPolicy_automaticTagId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."accountAutomaticTagPolicy"
    ADD CONSTRAINT "accountAutomaticTagPolicy_automaticTagId_fkey" FOREIGN KEY ("automaticTagId") REFERENCES public."automaticTag"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: accountBlocklist accountBlocklist_accountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."accountBlocklist"
    ADD CONSTRAINT "accountBlocklist_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: accountBlocklist accountBlocklist_targetAccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."accountBlocklist"
    ADD CONSTRAINT "accountBlocklist_targetAccountId_fkey" FOREIGN KEY ("targetAccountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: accountVideoRate accountVideoRate_accountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."accountVideoRate"
    ADD CONSTRAINT "accountVideoRate_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: accountVideoRate accountVideoRate_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."accountVideoRate"
    ADD CONSTRAINT "accountVideoRate_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: account account_actorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT "account_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES public.actor(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: account account_applicationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT "account_applicationId_fkey" FOREIGN KEY ("applicationId") REFERENCES public.application(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: account account_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT "account_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: actorCustomPage actorCustomPage_actorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."actorCustomPage"
    ADD CONSTRAINT "actorCustomPage_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES public.actor(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: actorFollow actorFollow_actorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."actorFollow"
    ADD CONSTRAINT "actorFollow_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES public.actor(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: actorFollow actorFollow_targetActorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."actorFollow"
    ADD CONSTRAINT "actorFollow_targetActorId_fkey" FOREIGN KEY ("targetActorId") REFERENCES public.actor(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: actorImage actorImage_actorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."actorImage"
    ADD CONSTRAINT "actorImage_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES public.actor(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: actor actor_serverId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actor
    ADD CONSTRAINT "actor_serverId_fkey" FOREIGN KEY ("serverId") REFERENCES public.server(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: commentAbuse commentAbuse_abuseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."commentAbuse"
    ADD CONSTRAINT "commentAbuse_abuseId_fkey" FOREIGN KEY ("abuseId") REFERENCES public.abuse(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: commentAbuse commentAbuse_videoCommentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."commentAbuse"
    ADD CONSTRAINT "commentAbuse_videoCommentId_fkey" FOREIGN KEY ("videoCommentId") REFERENCES public."videoComment"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: commentAutomaticTag commentAutomaticTag_accountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."commentAutomaticTag"
    ADD CONSTRAINT "commentAutomaticTag_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: commentAutomaticTag commentAutomaticTag_automaticTagId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."commentAutomaticTag"
    ADD CONSTRAINT "commentAutomaticTag_automaticTagId_fkey" FOREIGN KEY ("automaticTagId") REFERENCES public."automaticTag"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: commentAutomaticTag commentAutomaticTag_commentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."commentAutomaticTag"
    ADD CONSTRAINT "commentAutomaticTag_commentId_fkey" FOREIGN KEY ("commentId") REFERENCES public."videoComment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: localVideoViewerWatchSection localVideoViewerWatchSection_localVideoViewerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."localVideoViewerWatchSection"
    ADD CONSTRAINT "localVideoViewerWatchSection_localVideoViewerId_fkey" FOREIGN KEY ("localVideoViewerId") REFERENCES public."localVideoViewer"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: localVideoViewer localVideoViewer_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."localVideoViewer"
    ADD CONSTRAINT "localVideoViewer_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: oAuthToken oAuthToken_oAuthClientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."oAuthToken"
    ADD CONSTRAINT "oAuthToken_oAuthClientId_fkey" FOREIGN KEY ("oAuthClientId") REFERENCES public."oAuthClient"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: oAuthToken oAuthToken_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."oAuthToken"
    ADD CONSTRAINT "oAuthToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: runnerJob runnerJob_dependsOnRunnerJobId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."runnerJob"
    ADD CONSTRAINT "runnerJob_dependsOnRunnerJobId_fkey" FOREIGN KEY ("dependsOnRunnerJobId") REFERENCES public."runnerJob"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: runnerJob runnerJob_runnerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."runnerJob"
    ADD CONSTRAINT "runnerJob_runnerId_fkey" FOREIGN KEY ("runnerId") REFERENCES public.runner(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: runner runner_runnerRegistrationTokenId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.runner
    ADD CONSTRAINT "runner_runnerRegistrationTokenId_fkey" FOREIGN KEY ("runnerRegistrationTokenId") REFERENCES public."runnerRegistrationToken"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: scheduleVideoUpdate scheduleVideoUpdate_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."scheduleVideoUpdate"
    ADD CONSTRAINT "scheduleVideoUpdate_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: serverBlocklist serverBlocklist_accountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."serverBlocklist"
    ADD CONSTRAINT "serverBlocklist_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: serverBlocklist serverBlocklist_targetServerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."serverBlocklist"
    ADD CONSTRAINT "serverBlocklist_targetServerId_fkey" FOREIGN KEY ("targetServerId") REFERENCES public.server(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: storyboard storyboard_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storyboard
    ADD CONSTRAINT "storyboard_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: thumbnail thumbnail_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thumbnail
    ADD CONSTRAINT "thumbnail_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: thumbnail thumbnail_videoPlaylistId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thumbnail
    ADD CONSTRAINT "thumbnail_videoPlaylistId_fkey" FOREIGN KEY ("videoPlaylistId") REFERENCES public."videoPlaylist"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: uploadImage uploadImage_actorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."uploadImage"
    ADD CONSTRAINT "uploadImage_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES public.actor(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userExport userExport_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userExport"
    ADD CONSTRAINT "userExport_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userImport userImport_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userImport"
    ADD CONSTRAINT "userImport_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userNotificationSetting userNotificationSetting_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotificationSetting"
    ADD CONSTRAINT "userNotificationSetting_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userNotification userNotification_abuseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotification"
    ADD CONSTRAINT "userNotification_abuseId_fkey" FOREIGN KEY ("abuseId") REFERENCES public.abuse(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userNotification userNotification_accountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotification"
    ADD CONSTRAINT "userNotification_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userNotification userNotification_actorFollowId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotification"
    ADD CONSTRAINT "userNotification_actorFollowId_fkey" FOREIGN KEY ("actorFollowId") REFERENCES public."actorFollow"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userNotification userNotification_applicationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotification"
    ADD CONSTRAINT "userNotification_applicationId_fkey" FOREIGN KEY ("applicationId") REFERENCES public.application(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userNotification userNotification_commentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotification"
    ADD CONSTRAINT "userNotification_commentId_fkey" FOREIGN KEY ("commentId") REFERENCES public."videoComment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userNotification userNotification_pluginId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotification"
    ADD CONSTRAINT "userNotification_pluginId_fkey" FOREIGN KEY ("pluginId") REFERENCES public.plugin(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userNotification userNotification_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotification"
    ADD CONSTRAINT "userNotification_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userNotification userNotification_userRegistrationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotification"
    ADD CONSTRAINT "userNotification_userRegistrationId_fkey" FOREIGN KEY ("userRegistrationId") REFERENCES public."userRegistration"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userNotification userNotification_videoBlacklistId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotification"
    ADD CONSTRAINT "userNotification_videoBlacklistId_fkey" FOREIGN KEY ("videoBlacklistId") REFERENCES public."videoBlacklist"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userNotification userNotification_videoCaptionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotification"
    ADD CONSTRAINT "userNotification_videoCaptionId_fkey" FOREIGN KEY ("videoCaptionId") REFERENCES public."videoCaption"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userNotification userNotification_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotification"
    ADD CONSTRAINT "userNotification_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userNotification userNotification_videoImportId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userNotification"
    ADD CONSTRAINT "userNotification_videoImportId_fkey" FOREIGN KEY ("videoImportId") REFERENCES public."videoImport"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userRegistration userRegistration_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userRegistration"
    ADD CONSTRAINT "userRegistration_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: userVideoHistory userVideoHistory_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userVideoHistory"
    ADD CONSTRAINT "userVideoHistory_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: userVideoHistory userVideoHistory_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."userVideoHistory"
    ADD CONSTRAINT "userVideoHistory_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoAbuse videoAbuse_abuseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoAbuse"
    ADD CONSTRAINT "videoAbuse_abuseId_fkey" FOREIGN KEY ("abuseId") REFERENCES public.abuse(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoAbuse videoAbuse_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoAbuse"
    ADD CONSTRAINT "videoAbuse_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: videoAutomaticTag videoAutomaticTag_accountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoAutomaticTag"
    ADD CONSTRAINT "videoAutomaticTag_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoAutomaticTag videoAutomaticTag_automaticTagId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoAutomaticTag"
    ADD CONSTRAINT "videoAutomaticTag_automaticTagId_fkey" FOREIGN KEY ("automaticTagId") REFERENCES public."automaticTag"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoAutomaticTag videoAutomaticTag_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoAutomaticTag"
    ADD CONSTRAINT "videoAutomaticTag_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoBlacklist videoBlacklist_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoBlacklist"
    ADD CONSTRAINT "videoBlacklist_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoCaption videoCaption_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoCaption"
    ADD CONSTRAINT "videoCaption_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoChangeOwnership videoChangeOwnership_initiatorAccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoChangeOwnership"
    ADD CONSTRAINT "videoChangeOwnership_initiatorAccountId_fkey" FOREIGN KEY ("initiatorAccountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoChangeOwnership videoChangeOwnership_nextOwnerAccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoChangeOwnership"
    ADD CONSTRAINT "videoChangeOwnership_nextOwnerAccountId_fkey" FOREIGN KEY ("nextOwnerAccountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoChangeOwnership videoChangeOwnership_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoChangeOwnership"
    ADD CONSTRAINT "videoChangeOwnership_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoChannelSync videoChannelSync_videoChannelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoChannelSync"
    ADD CONSTRAINT "videoChannelSync_videoChannelId_fkey" FOREIGN KEY ("videoChannelId") REFERENCES public."videoChannel"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoChannel videoChannel_accountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoChannel"
    ADD CONSTRAINT "videoChannel_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoChannel videoChannel_actorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoChannel"
    ADD CONSTRAINT "videoChannel_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES public.actor(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoChapter videoChapter_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoChapter"
    ADD CONSTRAINT "videoChapter_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoComment videoComment_accountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoComment"
    ADD CONSTRAINT "videoComment_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoComment videoComment_inReplyToCommentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoComment"
    ADD CONSTRAINT "videoComment_inReplyToCommentId_fkey" FOREIGN KEY ("inReplyToCommentId") REFERENCES public."videoComment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoComment videoComment_originCommentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoComment"
    ADD CONSTRAINT "videoComment_originCommentId_fkey" FOREIGN KEY ("originCommentId") REFERENCES public."videoComment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoComment videoComment_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoComment"
    ADD CONSTRAINT "videoComment_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoFile videoFile_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoFile"
    ADD CONSTRAINT "videoFile_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoFile videoFile_videoStreamingPlaylistId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoFile"
    ADD CONSTRAINT "videoFile_videoStreamingPlaylistId_fkey" FOREIGN KEY ("videoStreamingPlaylistId") REFERENCES public."videoStreamingPlaylist"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoImport videoImport_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoImport"
    ADD CONSTRAINT "videoImport_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoImport videoImport_videoChannelSyncId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoImport"
    ADD CONSTRAINT "videoImport_videoChannelSyncId_fkey" FOREIGN KEY ("videoChannelSyncId") REFERENCES public."videoChannelSync"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: videoImport videoImport_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoImport"
    ADD CONSTRAINT "videoImport_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: videoJobInfo videoJobInfo_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoJobInfo"
    ADD CONSTRAINT "videoJobInfo_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoLiveSchedule videoLiveSchedule_liveVideoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoLiveSchedule"
    ADD CONSTRAINT "videoLiveSchedule_liveVideoId_fkey" FOREIGN KEY ("liveVideoId") REFERENCES public."videoLive"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoLiveSession videoLiveSession_liveVideoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoLiveSession"
    ADD CONSTRAINT "videoLiveSession_liveVideoId_fkey" FOREIGN KEY ("liveVideoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: videoLiveSession videoLiveSession_replaySettingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoLiveSession"
    ADD CONSTRAINT "videoLiveSession_replaySettingId_fkey" FOREIGN KEY ("replaySettingId") REFERENCES public."videoLiveReplaySetting"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: videoLiveSession videoLiveSession_replayVideoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoLiveSession"
    ADD CONSTRAINT "videoLiveSession_replayVideoId_fkey" FOREIGN KEY ("replayVideoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: videoLive videoLive_replaySettingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoLive"
    ADD CONSTRAINT "videoLive_replaySettingId_fkey" FOREIGN KEY ("replaySettingId") REFERENCES public."videoLiveReplaySetting"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: videoLive videoLive_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoLive"
    ADD CONSTRAINT "videoLive_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoPassword videoPassword_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoPassword"
    ADD CONSTRAINT "videoPassword_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoPlaylistElement videoPlaylistElement_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoPlaylistElement"
    ADD CONSTRAINT "videoPlaylistElement_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: videoPlaylistElement videoPlaylistElement_videoPlaylistId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoPlaylistElement"
    ADD CONSTRAINT "videoPlaylistElement_videoPlaylistId_fkey" FOREIGN KEY ("videoPlaylistId") REFERENCES public."videoPlaylist"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoPlaylist videoPlaylist_ownerAccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoPlaylist"
    ADD CONSTRAINT "videoPlaylist_ownerAccountId_fkey" FOREIGN KEY ("ownerAccountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoPlaylist videoPlaylist_videoChannelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoPlaylist"
    ADD CONSTRAINT "videoPlaylist_videoChannelId_fkey" FOREIGN KEY ("videoChannelId") REFERENCES public."videoChannel"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoRedundancy videoRedundancy_actorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoRedundancy"
    ADD CONSTRAINT "videoRedundancy_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES public.actor(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoRedundancy videoRedundancy_videoStreamingPlaylistId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoRedundancy"
    ADD CONSTRAINT "videoRedundancy_videoStreamingPlaylistId_fkey" FOREIGN KEY ("videoStreamingPlaylistId") REFERENCES public."videoStreamingPlaylist"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoShare videoShare_actorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoShare"
    ADD CONSTRAINT "videoShare_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES public.actor(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoShare videoShare_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoShare"
    ADD CONSTRAINT "videoShare_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoSource videoSource_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoSource"
    ADD CONSTRAINT "videoSource_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoStreamingPlaylist videoStreamingPlaylist_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoStreamingPlaylist"
    ADD CONSTRAINT "videoStreamingPlaylist_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoTag videoTag_tagId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoTag"
    ADD CONSTRAINT "videoTag_tagId_fkey" FOREIGN KEY ("tagId") REFERENCES public.tag(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoTag videoTag_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoTag"
    ADD CONSTRAINT "videoTag_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoTracker videoTracker_trackerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoTracker"
    ADD CONSTRAINT "videoTracker_trackerId_fkey" FOREIGN KEY ("trackerId") REFERENCES public.tracker(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoTracker videoTracker_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoTracker"
    ADD CONSTRAINT "videoTracker_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: videoView videoView_videoId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."videoView"
    ADD CONSTRAINT "videoView_videoId_fkey" FOREIGN KEY ("videoId") REFERENCES public.video(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: video video_channelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.video
    ADD CONSTRAINT "video_channelId_fkey" FOREIGN KEY ("channelId") REFERENCES public."videoChannel"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: watchedWordsList watchedWordsList_accountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."watchedWordsList"
    ADD CONSTRAINT "watchedWordsList_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


