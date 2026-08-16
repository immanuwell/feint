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
-- Name: channel_bookmark_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.channel_bookmark_type AS ENUM (
    'link',
    'file',
    'board'
);


--
-- Name: channel_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.channel_type AS ENUM (
    'P',
    'G',
    'O',
    'D',
    'BO',
    'BP'
);


--
-- Name: outgoingoauthconnections_granttype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.outgoingoauthconnections_granttype AS ENUM (
    'client_credentials',
    'password'
);


--
-- Name: permission_level; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.permission_level AS ENUM (
    'none',
    'sysadmin',
    'member',
    'admin'
);


--
-- Name: property_field_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.property_field_type AS ENUM (
    'text',
    'select',
    'multiselect',
    'date',
    'user',
    'multiuser',
    'rank'
);


--
-- Name: team_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.team_type AS ENUM (
    'I',
    'O'
);


--
-- Name: upload_session_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.upload_session_type AS ENUM (
    'attachment',
    'import'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accesscontrolpolicies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accesscontrolpolicies (
    id character varying(26) NOT NULL,
    name character varying(128) NOT NULL,
    type character varying(128) NOT NULL,
    active boolean NOT NULL,
    createat bigint NOT NULL,
    revision integer NOT NULL,
    version character varying(8) NOT NULL,
    data jsonb,
    props jsonb
);


--
-- Name: accesscontrolpolicyhistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accesscontrolpolicyhistory (
    id character varying(26) NOT NULL,
    name character varying(128) NOT NULL,
    type character varying(128) NOT NULL,
    createat bigint NOT NULL,
    revision integer NOT NULL,
    version character varying(8) NOT NULL,
    data jsonb,
    props jsonb
);


--
-- Name: agents_confighistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agents_confighistory (
    id character varying(26) NOT NULL,
    config text NOT NULL,
    createat bigint NOT NULL,
    active boolean DEFAULT false NOT NULL
);


--
-- Name: agents_db_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agents_db_migrations (
    version bigint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: agents_system; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agents_system (
    skey character varying(64) NOT NULL,
    svalue text
);


--
-- Name: agents_useragents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agents_useragents (
    id character varying(26) NOT NULL,
    botuserid character varying(26) NOT NULL,
    creatorid character varying(26) NOT NULL,
    displayname character varying(256) DEFAULT ''::character varying NOT NULL,
    username character varying(64) NOT NULL,
    serviceid character varying(36) NOT NULL,
    custominstructions text DEFAULT ''::text NOT NULL,
    channelaccesslevel integer DEFAULT 0 NOT NULL,
    channelids text DEFAULT '[]'::text NOT NULL,
    useraccesslevel integer DEFAULT 0 NOT NULL,
    userids text DEFAULT '[]'::text NOT NULL,
    teamids text DEFAULT '[]'::text NOT NULL,
    adminuserids text DEFAULT '[]'::text NOT NULL,
    enabledtools text DEFAULT '[]'::text NOT NULL,
    autoenablenewmcptools boolean DEFAULT false NOT NULL,
    createat bigint NOT NULL,
    updateat bigint NOT NULL,
    deleteat bigint DEFAULT 0 NOT NULL,
    model character varying(512) DEFAULT ''::character varying NOT NULL,
    enablevision boolean DEFAULT false NOT NULL,
    disabletools boolean DEFAULT false NOT NULL,
    enablednativetools text DEFAULT '[]'::text NOT NULL,
    reasoningenabled boolean DEFAULT true NOT NULL,
    reasoningeffort character varying(32) DEFAULT ''::character varying NOT NULL,
    thinkingbudget integer DEFAULT 0 NOT NULL,
    structuredoutputenabled boolean DEFAULT false NOT NULL,
    mcp_dynamic_tool_loading boolean DEFAULT true NOT NULL,
    maxtoolturns integer DEFAULT 30 NOT NULL
);


--
-- Name: propertyfields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.propertyfields (
    id character varying(26) NOT NULL,
    groupid character varying(26) NOT NULL,
    name character varying(255) NOT NULL,
    type public.property_field_type,
    attrs jsonb,
    targetid character varying(255),
    targettype character varying(255),
    createat bigint NOT NULL,
    updateat bigint NOT NULL,
    deleteat bigint NOT NULL,
    createdby character varying(26),
    updatedby character varying(26),
    objecttype character varying(255) DEFAULT ''::character varying NOT NULL,
    protected boolean DEFAULT false NOT NULL,
    permissionfield public.permission_level,
    permissionvalues public.permission_level,
    permissionoptions public.permission_level,
    linkedfieldid character varying(26)
);


--
-- Name: propertyvalues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.propertyvalues (
    id character varying(26) NOT NULL,
    targetid character varying(255) NOT NULL,
    targettype character varying(255) NOT NULL,
    groupid character varying(26) NOT NULL,
    fieldid character varying(26) NOT NULL,
    value jsonb NOT NULL,
    createat bigint NOT NULL,
    updateat bigint NOT NULL,
    deleteat bigint NOT NULL,
    createdby character varying(26),
    updatedby character varying(26)
);


--
-- Name: attributeview; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.attributeview AS
 SELECT pv.groupid,
    pv.targetid,
    pv.targettype,
    jsonb_object_agg(pf.name,
        CASE
            WHEN (pf.type = 'select'::public.property_field_type) THEN ( SELECT to_jsonb(options.name) AS to_jsonb
               FROM jsonb_to_recordset((pf.attrs -> 'options'::text)) options(id text, name text)
              WHERE (options.id = (pv.value #>> '{}'::text[]))
             LIMIT 1)
            WHEN ((pf.type = 'multiselect'::public.property_field_type) AND (jsonb_typeof(pv.value) = 'array'::text)) THEN ( SELECT jsonb_agg(option_names.name) AS jsonb_agg
               FROM (jsonb_array_elements_text(pv.value) option_id(value)
                 JOIN jsonb_to_recordset((pf.attrs -> 'options'::text)) option_names(id text, name text) ON ((option_id.value = option_names.id))))
            WHEN (pf.type = 'rank'::public.property_field_type) THEN ( SELECT jsonb_build_object('name', options.name, 'rank', options.rank) AS jsonb_build_object
               FROM jsonb_to_recordset((pf.attrs -> 'options'::text)) options(id text, name text, rank integer)
              WHERE (options.id = (pv.value #>> '{}'::text[]))
             LIMIT 1)
            ELSE pv.value
        END) AS attributes
   FROM (public.propertyvalues pv
     LEFT JOIN public.propertyfields pf ON (((pf.id)::text = (pv.fieldid)::text)))
  WHERE (((pv.deleteat = 0) OR (pv.deleteat IS NULL)) AND ((pf.deleteat = 0) OR (pf.deleteat IS NULL)) AND ((pf.objecttype)::text = 'user'::text))
  GROUP BY pv.groupid, pv.targetid, pv.targettype
  WITH NO DATA;


--
-- Name: audits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audits (
    id character varying(26) NOT NULL,
    createat bigint,
    userid character varying(26),
    action character varying(512),
    extrainfo character varying(1024),
    ipaddress character varying(64),
    sessionid character varying(26)
);


--
-- Name: bots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bots (
    userid character varying(26) NOT NULL,
    description character varying(1024),
    ownerid character varying(190),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    lasticonupdate bigint
);


--
-- Name: channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channels (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    teamid character varying(26),
    type public.channel_type,
    displayname character varying(64),
    name character varying(64),
    header character varying(1024),
    purpose character varying(250),
    lastpostat bigint,
    totalmsgcount bigint,
    extraupdateat bigint,
    creatorid character varying(26),
    schemeid character varying(26),
    groupconstrained boolean,
    shared boolean,
    totalmsgcountroot bigint,
    lastrootpostat bigint DEFAULT '0'::bigint,
    bannerinfo jsonb,
    defaultcategoryname character varying(64) DEFAULT ''::character varying NOT NULL,
    autotranslation boolean DEFAULT false NOT NULL,
    discoverable boolean DEFAULT false NOT NULL
);


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    userid character varying(26),
    channelid character varying(26),
    rootid character varying(26),
    originalid character varying(26),
    message character varying(65535),
    type character varying(26),
    props jsonb,
    hashtags character varying(1000),
    filenames character varying(4000),
    fileids character varying(300),
    hasreactions boolean,
    editat bigint,
    ispinned boolean,
    remoteid character varying(26)
)
WITH (autovacuum_vacuum_scale_factor='0.1', autovacuum_analyze_scale_factor='0.05');
ALTER TABLE ONLY public.posts ALTER COLUMN channelid SET STATISTICS 5000;
ALTER TABLE ONLY public.posts ALTER COLUMN rootid SET STATISTICS 5000;


--
-- Name: bot_posts_by_team_day; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.bot_posts_by_team_day AS
 SELECT (to_timestamp(((p.createat / 1000))::double precision))::date AS day,
    count(*) AS num,
    c.teamid
   FROM ((public.posts p
     JOIN public.bots b ON (((p.userid)::text = (b.userid)::text)))
     JOIN public.channels c ON (((p.channelid)::text = (c.id)::text)))
  GROUP BY ((to_timestamp(((p.createat / 1000))::double precision))::date), c.teamid
  WITH NO DATA;


--
-- Name: calls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calls (
    id character varying(26) NOT NULL,
    channelid character varying(26),
    startat bigint,
    endat bigint,
    createat bigint,
    deleteat bigint,
    title character varying(256),
    postid character varying(26),
    threadid character varying(26),
    ownerid character varying(26),
    participants jsonb NOT NULL,
    stats jsonb NOT NULL,
    props jsonb NOT NULL
);


--
-- Name: calls_channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calls_channels (
    channelid character varying(26) NOT NULL,
    enabled boolean,
    props jsonb NOT NULL
);


--
-- Name: calls_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calls_jobs (
    id character varying(26) NOT NULL,
    callid character varying(26),
    type character varying(64),
    creatorid character varying(26),
    initat bigint,
    startat bigint,
    endat bigint,
    props jsonb NOT NULL
);


--
-- Name: calls_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calls_sessions (
    id character varying(26) NOT NULL,
    callid character varying(26),
    userid character varying(26),
    joinat bigint,
    unmuted boolean,
    raisedhand bigint,
    video boolean
);


--
-- Name: channelbookmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channelbookmarks (
    id character varying(26) NOT NULL,
    ownerid character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    fileinfoid character varying(26) DEFAULT NULL::character varying,
    createat bigint DEFAULT 0,
    updateat bigint DEFAULT 0,
    deleteat bigint DEFAULT 0,
    displayname text DEFAULT ''::text,
    sortorder integer DEFAULT 0,
    linkurl text,
    imageurl text,
    emoji character varying(64) DEFAULT NULL::character varying,
    type public.channel_bookmark_type DEFAULT 'link'::public.channel_bookmark_type,
    originalid character varying(26) DEFAULT NULL::character varying,
    parentid character varying(26) DEFAULT NULL::character varying,
    targetid character varying(26) DEFAULT NULL::character varying
);


--
-- Name: channelguards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channelguards (
    channelid character varying(26) NOT NULL,
    pluginid character varying(190) NOT NULL,
    createdat bigint NOT NULL
);


--
-- Name: channeljoinrequests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channeljoinrequests (
    id character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    message text DEFAULT ''::text NOT NULL,
    status character varying(16) DEFAULT 'pending'::character varying NOT NULL,
    denialreason text DEFAULT ''::text NOT NULL,
    createat bigint NOT NULL,
    updateat bigint NOT NULL,
    reviewedby character varying(26) DEFAULT ''::character varying NOT NULL,
    reviewedat bigint DEFAULT 0 NOT NULL
);


--
-- Name: channelmemberhistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channelmemberhistory (
    channelid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    jointime bigint NOT NULL,
    leavetime bigint
);


--
-- Name: channelmembers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channelmembers (
    channelid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    roles character varying(256),
    lastviewedat bigint,
    msgcount bigint,
    mentioncount bigint,
    notifyprops jsonb,
    lastupdateat bigint,
    schemeuser boolean,
    schemeadmin boolean,
    schemeguest boolean,
    mentioncountroot bigint,
    msgcountroot bigint,
    urgentmentioncount bigint,
    autotranslation boolean DEFAULT false NOT NULL,
    autotranslationdisabled boolean DEFAULT false NOT NULL
);


--
-- Name: clusterdiscovery; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clusterdiscovery (
    id character varying(26) NOT NULL,
    type character varying(64),
    clustername character varying(64),
    hostname character varying(512),
    gossipport integer,
    port integer,
    createat bigint,
    lastpingat bigint
);


--
-- Name: commands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commands (
    id character varying(26) NOT NULL,
    token character varying(26),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    creatorid character varying(26),
    teamid character varying(26),
    trigger character varying(128),
    method character varying(1),
    username character varying(64),
    iconurl character varying(1024),
    autocomplete boolean,
    autocompletedesc character varying(1024),
    autocompletehint character varying(1024),
    displayname character varying(64),
    description character varying(128),
    url character varying(1024),
    pluginid character varying(190)
);


--
-- Name: commandwebhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commandwebhooks (
    id character varying(26) NOT NULL,
    createat bigint,
    commandid character varying(26),
    userid character varying(26),
    channelid character varying(26),
    rootid character varying(26),
    usecount integer
);


--
-- Name: compliances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.compliances (
    id character varying(26) NOT NULL,
    createat bigint,
    userid character varying(26),
    status character varying(64),
    count integer,
    "desc" character varying(512),
    type character varying(64),
    startat bigint,
    endat bigint,
    keywords character varying(512),
    emails character varying(1024)
);


--
-- Name: contentflaggingcommonreviewers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contentflaggingcommonreviewers (
    userid character varying(26) NOT NULL
);


--
-- Name: contentflaggingteamreviewers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contentflaggingteamreviewers (
    teamid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL
);


--
-- Name: contentflaggingteamsettings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contentflaggingteamsettings (
    teamid character varying(26) NOT NULL,
    enabled boolean
);


--
-- Name: db_lock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.db_lock (
    id character varying(64) NOT NULL,
    expireat bigint
);


--
-- Name: db_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.db_migrations (
    version bigint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: db_migrations_calls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.db_migrations_calls (
    version bigint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: desktoptokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.desktoptokens (
    token character varying(64) NOT NULL,
    createat bigint NOT NULL,
    userid character varying(26) NOT NULL
);


--
-- Name: drafts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drafts (
    createat bigint,
    updateat bigint,
    deleteat bigint,
    userid character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    rootid character varying(26) DEFAULT ''::character varying NOT NULL,
    message character varying(65535),
    props character varying(8000),
    fileids character varying(300),
    priority text,
    type text
);


--
-- Name: emoji; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emoji (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    creatorid character varying(26),
    name character varying(64)
);


--
-- Name: fileinfo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fileinfo (
    id character varying(26) NOT NULL,
    creatorid character varying(26),
    postid character varying(26),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    path character varying(512),
    thumbnailpath character varying(512),
    previewpath character varying(512),
    name character varying(256),
    extension character varying(64),
    size bigint,
    mimetype character varying(256),
    width integer,
    height integer,
    haspreviewimage boolean,
    minipreview bytea,
    content text,
    remoteid character varying(26),
    archived boolean DEFAULT false NOT NULL,
    channelid character varying(26)
)
WITH (autovacuum_vacuum_scale_factor='0.1', autovacuum_analyze_scale_factor='0.05');


--
-- Name: file_stats; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.file_stats AS
 SELECT count(*) AS num,
    COALESCE(sum(size), (0)::numeric) AS usage
   FROM public.fileinfo
  WHERE (deleteat = 0)
  WITH NO DATA;


--
-- Name: groupchannels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groupchannels (
    groupid character varying(26) NOT NULL,
    autoadd boolean,
    schemeadmin boolean,
    createat bigint,
    deleteat bigint,
    updateat bigint,
    channelid character varying(26) NOT NULL
);


--
-- Name: groupmembers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groupmembers (
    groupid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    createat bigint,
    deleteat bigint
);


--
-- Name: groupteams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groupteams (
    groupid character varying(26) NOT NULL,
    autoadd boolean,
    schemeadmin boolean,
    createat bigint,
    deleteat bigint,
    updateat bigint,
    teamid character varying(26) NOT NULL
);


--
-- Name: incomingwebhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incomingwebhooks (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    userid character varying(26),
    channelid character varying(26),
    teamid character varying(26),
    displayname character varying(64),
    description character varying(500),
    username character varying(255),
    iconurl character varying(1024),
    channellocked boolean,
    lastused bigint DEFAULT 0 NOT NULL
);


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id character varying(26) NOT NULL,
    type character varying(32),
    priority bigint,
    createat bigint,
    startat bigint,
    lastactivityat bigint,
    status character varying(32),
    progress bigint,
    data jsonb
);


--
-- Name: licenses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.licenses (
    id character varying(26) NOT NULL,
    createat bigint,
    bytes character varying(10000)
);


--
-- Name: linkmetadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.linkmetadata (
    hash bigint NOT NULL,
    url character varying(2048),
    "timestamp" bigint,
    type character varying(16),
    data jsonb
);


--
-- Name: llm_conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.llm_conversations (
    id text NOT NULL,
    userid text NOT NULL,
    botid text NOT NULL,
    channelid text,
    rootpostid text,
    title text DEFAULT ''::text NOT NULL,
    systemprompt text DEFAULT ''::text NOT NULL,
    operation text DEFAULT ''::text NOT NULL,
    createdat bigint NOT NULL,
    updatedat bigint NOT NULL,
    deleteat bigint DEFAULT 0 NOT NULL
);


--
-- Name: llm_custompromptpins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.llm_custompromptpins (
    userid text NOT NULL,
    promptid text NOT NULL
);


--
-- Name: llm_customprompts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.llm_customprompts (
    id text NOT NULL,
    creatorid text NOT NULL,
    name text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    template text DEFAULT ''::text NOT NULL,
    isshared boolean DEFAULT false NOT NULL,
    createdat bigint DEFAULT 0 NOT NULL,
    updatedat bigint DEFAULT 0 NOT NULL,
    deletedat bigint DEFAULT 0 NOT NULL
);


--
-- Name: llm_turns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.llm_turns (
    id text NOT NULL,
    conversationid text NOT NULL,
    postid text,
    role text NOT NULL,
    content jsonb NOT NULL,
    tokensin bigint DEFAULT 0 NOT NULL,
    tokensout bigint DEFAULT 0 NOT NULL,
    sequence integer NOT NULL,
    createdat bigint NOT NULL
);


--
-- Name: notifyadmin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifyadmin (
    userid character varying(26) NOT NULL,
    createat bigint,
    requiredplan character varying(100) NOT NULL,
    requiredfeature character varying(255) NOT NULL,
    trial boolean NOT NULL,
    sentat bigint
);


--
-- Name: oauthaccessdata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauthaccessdata (
    token character varying(26) NOT NULL,
    refreshtoken character varying(26),
    redirecturi character varying(256),
    clientid character varying(26),
    userid character varying(26),
    expiresat bigint,
    scope character varying(128),
    audience character varying(512) DEFAULT ''::character varying
);


--
-- Name: oauthapps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauthapps (
    id character varying(26) NOT NULL,
    creatorid character varying(26),
    createat bigint,
    updateat bigint,
    clientsecret character varying(128),
    name character varying(64),
    description character varying(512),
    callbackurls character varying(1024),
    homepage character varying(256),
    istrusted boolean,
    iconurl character varying(512),
    mattermostappid character varying(32) DEFAULT ''::character varying NOT NULL,
    isdynamicallyregistered boolean DEFAULT false
);


--
-- Name: oauthauthdata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauthauthdata (
    clientid character varying(26),
    userid character varying(26),
    code character varying(128) NOT NULL,
    expiresin integer,
    createat bigint,
    redirecturi character varying(256),
    state character varying(1024),
    scope character varying(128),
    codechallenge character varying(128) DEFAULT ''::character varying,
    codechallengemethod character varying(10) DEFAULT ''::character varying,
    resource character varying(512) DEFAULT ''::character varying
);


--
-- Name: outgoingoauthconnections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outgoingoauthconnections (
    id character varying(26) NOT NULL,
    name character varying(64),
    creatorid character varying(26),
    createat bigint,
    updateat bigint,
    clientid character varying(255),
    clientsecret character varying(255),
    credentialsusername character varying(255),
    credentialspassword character varying(255),
    oauthtokenurl text,
    granttype public.outgoingoauthconnections_granttype DEFAULT 'client_credentials'::public.outgoingoauthconnections_granttype,
    audiences character varying(1024)
);


--
-- Name: outgoingwebhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outgoingwebhooks (
    id character varying(26) NOT NULL,
    token character varying(26),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    creatorid character varying(26),
    channelid character varying(26),
    teamid character varying(26),
    triggerwords character varying(1024),
    callbackurls character varying(1024),
    displayname character varying(64),
    contenttype character varying(128),
    triggerwhen integer,
    username character varying(64),
    iconurl character varying(1024),
    description character varying(500)
);


--
-- Name: persistentnotifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.persistentnotifications (
    postid character varying(26) NOT NULL,
    createat bigint,
    lastsentat bigint,
    deleteat bigint,
    sentcount smallint
);


--
-- Name: pluginkeyvaluestore; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pluginkeyvaluestore (
    pluginid character varying(190) NOT NULL,
    pkey character varying(150) NOT NULL,
    pvalue bytea,
    expireat bigint
);


--
-- Name: postacknowledgements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.postacknowledgements (
    postid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    acknowledgedat bigint,
    remoteid character varying(26) DEFAULT ''::character varying,
    channelid character varying(26) DEFAULT ''::character varying
);


--
-- Name: postreminders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.postreminders (
    postid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    targettime bigint
);


--
-- Name: posts_by_team_day; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.posts_by_team_day AS
 SELECT (to_timestamp(((p.createat / 1000))::double precision))::date AS day,
    count(*) AS num,
    c.teamid
   FROM (public.posts p
     JOIN public.channels c ON (((p.channelid)::text = (c.id)::text)))
  GROUP BY ((to_timestamp(((p.createat / 1000))::double precision))::date), c.teamid
  WITH NO DATA;


--
-- Name: postspriority; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.postspriority (
    postid character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    priority character varying(32) NOT NULL,
    requestedack boolean,
    persistentnotifications boolean
);


--
-- Name: poststats; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.poststats AS
 SELECT userid,
    (to_timestamp(((createat / 1000))::double precision))::date AS day,
    count(*) AS numposts,
    max(createat) AS lastpostdate
   FROM public.posts
  GROUP BY userid, ((to_timestamp(((createat / 1000))::double precision))::date)
  WITH NO DATA;


--
-- Name: preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.preferences (
    userid character varying(26) NOT NULL,
    category character varying(32) NOT NULL,
    name character varying(32) NOT NULL,
    value text
)
WITH (autovacuum_vacuum_scale_factor='0.1', autovacuum_analyze_scale_factor='0.05');


--
-- Name: productnoticeviewstate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.productnoticeviewstate (
    userid character varying(26) NOT NULL,
    noticeid character varying(26) NOT NULL,
    viewed integer,
    "timestamp" bigint
);


--
-- Name: propertygroups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.propertygroups (
    id character varying(26) NOT NULL,
    name character varying(64) NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    schemaversion integer DEFAULT 1 NOT NULL
);


--
-- Name: publicchannels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publicchannels (
    id character varying(26) NOT NULL,
    deleteat bigint,
    teamid character varying(26),
    displayname character varying(64),
    name character varying(64),
    header character varying(1024),
    purpose character varying(250)
);


--
-- Name: reactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reactions (
    userid character varying(26) NOT NULL,
    postid character varying(26) NOT NULL,
    emojiname character varying(64) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    remoteid character varying(26),
    channelid character varying(26) DEFAULT ''::character varying NOT NULL
);


--
-- Name: readreceipts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.readreceipts (
    postid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    expireat bigint NOT NULL
);


--
-- Name: recapchannels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recapchannels (
    id character varying(26) NOT NULL,
    recapid character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    channelname character varying(64) NOT NULL,
    highlights text,
    actionitems text,
    sourcepostids text,
    createat bigint NOT NULL
);


--
-- Name: recaps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recaps (
    id character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    title character varying(255) NOT NULL,
    createat bigint NOT NULL,
    updateat bigint NOT NULL,
    deleteat bigint NOT NULL,
    totalmessagecount integer NOT NULL,
    status character varying(32) NOT NULL,
    readat bigint DEFAULT 0 NOT NULL,
    botid character varying(26) DEFAULT ''::character varying NOT NULL,
    viewedat bigint DEFAULT 0 NOT NULL
);


--
-- Name: recentsearches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recentsearches (
    userid character(26) NOT NULL,
    searchpointer integer NOT NULL,
    query jsonb,
    createat bigint NOT NULL
);


--
-- Name: remoteclusters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.remoteclusters (
    remoteid character varying(26) NOT NULL,
    remoteteamid character varying(26),
    name character varying(64) NOT NULL,
    displayname character varying(64),
    siteurl character varying(512),
    createat bigint,
    lastpingat bigint,
    token character varying(26),
    remotetoken character varying(26),
    topics character varying(512),
    creatorid character varying(26),
    pluginid character varying(190) DEFAULT ''::character varying NOT NULL,
    options smallint DEFAULT 0 NOT NULL,
    defaultteamid character varying(26) DEFAULT ''::character varying,
    deleteat bigint DEFAULT 0,
    lastglobalusersyncat bigint DEFAULT 0
);


--
-- Name: retentionidsfordeletion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.retentionidsfordeletion (
    id character varying(26) NOT NULL,
    tablename character varying(64),
    ids character varying(26)[]
);


--
-- Name: retentionpolicies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.retentionpolicies (
    id character varying(26) NOT NULL,
    displayname character varying(64),
    postduration bigint
);


--
-- Name: retentionpolicieschannels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.retentionpolicieschannels (
    policyid character varying(26),
    channelid character varying(26) NOT NULL
);


--
-- Name: retentionpoliciesteams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.retentionpoliciesteams (
    policyid character varying(26),
    teamid character varying(26) NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id character varying(26) NOT NULL,
    name character varying(64),
    displayname character varying(128),
    description character varying(1024),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    permissions text,
    schememanaged boolean,
    builtin boolean,
    schemeid character varying(26)
);


--
-- Name: scheduledposts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduledposts (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    userid character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    rootid character varying(26),
    message character varying(65535),
    props character varying(8000),
    fileids character varying(300),
    priority text,
    scheduledat bigint NOT NULL,
    processedat bigint,
    errorcode character varying(200),
    type text
);


--
-- Name: schemes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schemes (
    id character varying(26) NOT NULL,
    name character varying(64),
    displayname character varying(128),
    description character varying(1024),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    scope character varying(32),
    defaultteamadminrole character varying(64),
    defaultteamuserrole character varying(64),
    defaultchanneladminrole character varying(64),
    defaultchanneluserrole character varying(64),
    defaultteamguestrole character varying(64),
    defaultchannelguestrole character varying(64),
    defaultplaybookadminrole character varying(64) DEFAULT ''::character varying,
    defaultplaybookmemberrole character varying(64) DEFAULT ''::character varying,
    defaultrunadminrole character varying(64) DEFAULT ''::character varying,
    defaultrunmemberrole character varying(64) DEFAULT ''::character varying
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id character varying(26) NOT NULL,
    token character varying(26),
    createat bigint,
    expiresat bigint,
    lastactivityat bigint,
    userid character varying(26),
    deviceid character varying(512),
    roles character varying(256),
    isoauth boolean,
    props jsonb,
    expirednotify boolean,
    voipdeviceid character varying(512) DEFAULT ''::character varying NOT NULL
);


--
-- Name: sharedchannelattachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sharedchannelattachments (
    id character varying(26) NOT NULL,
    fileid character varying(26),
    remoteid character varying(26),
    createat bigint,
    lastsyncat bigint
);


--
-- Name: sharedchannelremotes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sharedchannelremotes (
    id character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    creatorid character varying(26),
    createat bigint,
    updateat bigint,
    isinviteaccepted boolean,
    isinviteconfirmed boolean,
    remoteid character varying(26),
    lastpostupdateat bigint,
    lastpostid character varying(26),
    lastpostcreateat bigint DEFAULT 0 NOT NULL,
    lastpostcreateid character varying(26),
    deleteat bigint DEFAULT 0,
    lastmemberssyncat bigint DEFAULT 0
);


--
-- Name: sharedchannels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sharedchannels (
    channelid character varying(26) NOT NULL,
    teamid character varying(26),
    home boolean,
    readonly boolean,
    sharename character varying(64),
    sharedisplayname character varying(64),
    sharepurpose character varying(250),
    shareheader character varying(1024),
    creatorid character varying(26),
    createat bigint,
    updateat bigint,
    remoteid character varying(26)
);


--
-- Name: sharedchannelusers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sharedchannelusers (
    id character varying(26) NOT NULL,
    userid character varying(26),
    remoteid character varying(26),
    createat bigint,
    lastsyncat bigint,
    channelid character varying(26),
    lastmembershipsyncat bigint DEFAULT 0
);


--
-- Name: sidebarcategories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sidebarcategories (
    id character varying(128) NOT NULL,
    userid character varying(26),
    teamid character varying(26),
    sortorder bigint,
    sorting character varying(64),
    type character varying(64),
    displayname character varying(64),
    muted boolean,
    collapsed boolean
);


--
-- Name: sidebarchannels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sidebarchannels (
    channelid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    categoryid character varying(128) NOT NULL,
    sortorder bigint
);


--
-- Name: status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.status (
    userid character varying(26) NOT NULL,
    status character varying(32),
    manual boolean,
    lastactivityat bigint,
    dndendtime bigint,
    prevstatus character varying(32)
);


--
-- Name: systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.systems (
    name character varying(64) NOT NULL,
    value character varying(1024)
);


--
-- Name: teammembers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teammembers (
    teamid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    roles character varying(256),
    deleteat bigint,
    schemeuser boolean,
    schemeadmin boolean,
    schemeguest boolean,
    createat bigint DEFAULT 0
);


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    displayname character varying(64),
    name character varying(64),
    description character varying(255),
    email character varying(128),
    type public.team_type,
    companyname character varying(64),
    alloweddomains character varying(1000),
    inviteid character varying(32),
    schemeid character varying(26),
    allowopeninvite boolean,
    lastteamiconupdate bigint,
    groupconstrained boolean,
    cloudlimitsarchived boolean DEFAULT false NOT NULL
);


--
-- Name: temporaryposts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temporaryposts (
    postid character varying(26) NOT NULL,
    type character varying(26) NOT NULL,
    expireat bigint NOT NULL,
    message character varying(65535),
    fileids character varying(300)
);


--
-- Name: termsofservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.termsofservice (
    id character varying(26) NOT NULL,
    createat bigint,
    userid character varying(26),
    text character varying(65535)
);


--
-- Name: threadmemberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.threadmemberships (
    postid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    following boolean,
    lastviewed bigint,
    lastupdated bigint,
    unreadmentions bigint
)
WITH (autovacuum_vacuum_scale_factor='0.1', autovacuum_analyze_scale_factor='0.05');


--
-- Name: threads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.threads (
    postid character varying(26) NOT NULL,
    replycount bigint,
    lastreplyat bigint,
    participants jsonb,
    channelid character varying(26),
    threaddeleteat bigint,
    threadteamid character varying(26)
);


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tokens (
    token character varying(64) NOT NULL,
    createat bigint,
    type character varying(64),
    extra character varying(2048)
);


--
-- Name: translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.translations (
    objectid character varying(26) NOT NULL,
    dstlang character varying NOT NULL,
    objecttype character varying NOT NULL,
    providerid character varying NOT NULL,
    normhash character(64) NOT NULL,
    text text NOT NULL,
    confidence real,
    meta jsonb,
    updateat bigint NOT NULL,
    state character varying(20) NOT NULL,
    channelid character varying(26)
);


--
-- Name: uploadsessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.uploadsessions (
    id character varying(26) NOT NULL,
    type public.upload_session_type,
    createat bigint,
    userid character varying(26),
    channelid character varying(26),
    filename character varying(256),
    path character varying(512),
    filesize bigint,
    fileoffset bigint,
    remoteid character varying(26),
    reqfileid character varying(26)
);


--
-- Name: useraccesstokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.useraccesstokens (
    id character varying(26) NOT NULL,
    token character varying(26),
    userid character varying(26),
    description character varying(512),
    isactive boolean,
    expiresat bigint DEFAULT 0 NOT NULL,
    lastnotifiedat bigint
);


--
-- Name: usergroups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usergroups (
    id character varying(26) NOT NULL,
    name character varying(64),
    displayname character varying(128),
    description character varying(1024),
    source character varying(64),
    remoteid character varying(48),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    allowreference boolean
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    username character varying(64),
    password character varying(128),
    authdata character varying(128),
    authservice character varying(32),
    email character varying(128),
    emailverified boolean,
    nickname character varying(64),
    firstname character varying(64),
    lastname character varying(64),
    roles character varying(256),
    allowmarketing boolean,
    props jsonb,
    notifyprops jsonb,
    lastpasswordupdate bigint,
    lastpictureupdate bigint,
    failedattempts integer,
    locale character varying(5),
    mfaactive boolean,
    mfasecret character varying(128),
    "position" character varying(128),
    timezone jsonb,
    remoteid character varying(26),
    lastlogin bigint DEFAULT 0 NOT NULL,
    mfausedtimestamps jsonb
);


--
-- Name: usertermsofservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usertermsofservice (
    userid character varying(26) NOT NULL,
    termsofserviceid character varying(26),
    createat bigint
);


--
-- Name: views; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.views (
    id character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    type character varying(32) NOT NULL,
    creatorid character varying(26) NOT NULL,
    title character varying(256) NOT NULL,
    description text,
    sortorder integer DEFAULT 0 NOT NULL,
    props jsonb,
    createat bigint NOT NULL,
    updateat bigint NOT NULL,
    deleteat bigint DEFAULT 0 NOT NULL
);


--
-- Name: accesscontrolpolicies accesscontrolpolicies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accesscontrolpolicies
    ADD CONSTRAINT accesscontrolpolicies_pkey PRIMARY KEY (id);


--
-- Name: accesscontrolpolicyhistory accesscontrolpolicyhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accesscontrolpolicyhistory
    ADD CONSTRAINT accesscontrolpolicyhistory_pkey PRIMARY KEY (id, revision);


--
-- Name: agents_confighistory agents_confighistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agents_confighistory
    ADD CONSTRAINT agents_confighistory_pkey PRIMARY KEY (id);


--
-- Name: agents_db_migrations agents_db_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agents_db_migrations
    ADD CONSTRAINT agents_db_migrations_pkey PRIMARY KEY (version);


--
-- Name: agents_system agents_system_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agents_system
    ADD CONSTRAINT agents_system_pkey PRIMARY KEY (skey);


--
-- Name: agents_useragents agents_useragents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agents_useragents
    ADD CONSTRAINT agents_useragents_pkey PRIMARY KEY (id);


--
-- Name: audits audits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audits_pkey PRIMARY KEY (id);


--
-- Name: bots bots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bots
    ADD CONSTRAINT bots_pkey PRIMARY KEY (userid);


--
-- Name: calls_channels calls_channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calls_channels
    ADD CONSTRAINT calls_channels_pkey PRIMARY KEY (channelid);


--
-- Name: calls_jobs calls_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calls_jobs
    ADD CONSTRAINT calls_jobs_pkey PRIMARY KEY (id);


--
-- Name: calls calls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calls
    ADD CONSTRAINT calls_pkey PRIMARY KEY (id);


--
-- Name: calls_sessions calls_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calls_sessions
    ADD CONSTRAINT calls_sessions_pkey PRIMARY KEY (id);


--
-- Name: channelbookmarks channelbookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channelbookmarks
    ADD CONSTRAINT channelbookmarks_pkey PRIMARY KEY (id);


--
-- Name: channelguards channelguards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channelguards
    ADD CONSTRAINT channelguards_pkey PRIMARY KEY (channelid, pluginid);


--
-- Name: channeljoinrequests channeljoinrequests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channeljoinrequests
    ADD CONSTRAINT channeljoinrequests_pkey PRIMARY KEY (id);


--
-- Name: channelmemberhistory channelmemberhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channelmemberhistory
    ADD CONSTRAINT channelmemberhistory_pkey PRIMARY KEY (channelid, userid, jointime);


--
-- Name: channelmembers channelmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channelmembers
    ADD CONSTRAINT channelmembers_pkey PRIMARY KEY (channelid, userid);


--
-- Name: channels channels_name_teamid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_name_teamid_key UNIQUE (name, teamid);


--
-- Name: channels channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (id);


--
-- Name: clusterdiscovery clusterdiscovery_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clusterdiscovery
    ADD CONSTRAINT clusterdiscovery_pkey PRIMARY KEY (id);


--
-- Name: commands commands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commands
    ADD CONSTRAINT commands_pkey PRIMARY KEY (id);


--
-- Name: commandwebhooks commandwebhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commandwebhooks
    ADD CONSTRAINT commandwebhooks_pkey PRIMARY KEY (id);


--
-- Name: compliances compliances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compliances
    ADD CONSTRAINT compliances_pkey PRIMARY KEY (id);


--
-- Name: contentflaggingcommonreviewers contentflaggingcommonreviewers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contentflaggingcommonreviewers
    ADD CONSTRAINT contentflaggingcommonreviewers_pkey PRIMARY KEY (userid);


--
-- Name: contentflaggingteamreviewers contentflaggingteamreviewers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contentflaggingteamreviewers
    ADD CONSTRAINT contentflaggingteamreviewers_pkey PRIMARY KEY (teamid, userid);


--
-- Name: contentflaggingteamsettings contentflaggingteamsettings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contentflaggingteamsettings
    ADD CONSTRAINT contentflaggingteamsettings_pkey PRIMARY KEY (teamid);


--
-- Name: db_lock db_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.db_lock
    ADD CONSTRAINT db_lock_pkey PRIMARY KEY (id);


--
-- Name: db_migrations_calls db_migrations_calls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.db_migrations_calls
    ADD CONSTRAINT db_migrations_calls_pkey PRIMARY KEY (version);


--
-- Name: db_migrations db_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.db_migrations
    ADD CONSTRAINT db_migrations_pkey PRIMARY KEY (version);


--
-- Name: desktoptokens desktoptokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.desktoptokens
    ADD CONSTRAINT desktoptokens_pkey PRIMARY KEY (token);


--
-- Name: drafts drafts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drafts
    ADD CONSTRAINT drafts_pkey PRIMARY KEY (userid, channelid, rootid);


--
-- Name: emoji emoji_name_deleteat_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emoji
    ADD CONSTRAINT emoji_name_deleteat_key UNIQUE (name, deleteat);


--
-- Name: emoji emoji_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emoji
    ADD CONSTRAINT emoji_pkey PRIMARY KEY (id);


--
-- Name: fileinfo fileinfo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fileinfo
    ADD CONSTRAINT fileinfo_pkey PRIMARY KEY (id);


--
-- Name: groupchannels groupchannels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groupchannels
    ADD CONSTRAINT groupchannels_pkey PRIMARY KEY (groupid, channelid);


--
-- Name: groupmembers groupmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groupmembers
    ADD CONSTRAINT groupmembers_pkey PRIMARY KEY (groupid, userid);


--
-- Name: groupteams groupteams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groupteams
    ADD CONSTRAINT groupteams_pkey PRIMARY KEY (groupid, teamid);


--
-- Name: incomingwebhooks incomingwebhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incomingwebhooks
    ADD CONSTRAINT incomingwebhooks_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: licenses licenses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.licenses
    ADD CONSTRAINT licenses_pkey PRIMARY KEY (id);


--
-- Name: linkmetadata linkmetadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linkmetadata
    ADD CONSTRAINT linkmetadata_pkey PRIMARY KEY (hash);


--
-- Name: llm_conversations llm_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.llm_conversations
    ADD CONSTRAINT llm_conversations_pkey PRIMARY KEY (id);


--
-- Name: llm_custompromptpins llm_custompromptpins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.llm_custompromptpins
    ADD CONSTRAINT llm_custompromptpins_pkey PRIMARY KEY (userid, promptid);


--
-- Name: llm_customprompts llm_customprompts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.llm_customprompts
    ADD CONSTRAINT llm_customprompts_pkey PRIMARY KEY (id);


--
-- Name: llm_turns llm_turns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.llm_turns
    ADD CONSTRAINT llm_turns_pkey PRIMARY KEY (id);


--
-- Name: notifyadmin notifyadmin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifyadmin
    ADD CONSTRAINT notifyadmin_pkey PRIMARY KEY (userid, requiredfeature, requiredplan);


--
-- Name: oauthaccessdata oauthaccessdata_clientid_userid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauthaccessdata
    ADD CONSTRAINT oauthaccessdata_clientid_userid_key UNIQUE (clientid, userid);


--
-- Name: oauthaccessdata oauthaccessdata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauthaccessdata
    ADD CONSTRAINT oauthaccessdata_pkey PRIMARY KEY (token);


--
-- Name: oauthapps oauthapps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauthapps
    ADD CONSTRAINT oauthapps_pkey PRIMARY KEY (id);


--
-- Name: oauthauthdata oauthauthdata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauthauthdata
    ADD CONSTRAINT oauthauthdata_pkey PRIMARY KEY (code);


--
-- Name: outgoingoauthconnections outgoingoauthconnections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outgoingoauthconnections
    ADD CONSTRAINT outgoingoauthconnections_pkey PRIMARY KEY (id);


--
-- Name: outgoingwebhooks outgoingwebhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outgoingwebhooks
    ADD CONSTRAINT outgoingwebhooks_pkey PRIMARY KEY (id);


--
-- Name: persistentnotifications persistentnotifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persistentnotifications
    ADD CONSTRAINT persistentnotifications_pkey PRIMARY KEY (postid);


--
-- Name: pluginkeyvaluestore pluginkeyvaluestore_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pluginkeyvaluestore
    ADD CONSTRAINT pluginkeyvaluestore_pkey PRIMARY KEY (pluginid, pkey);


--
-- Name: postacknowledgements postacknowledgements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postacknowledgements
    ADD CONSTRAINT postacknowledgements_pkey PRIMARY KEY (postid, userid);


--
-- Name: postreminders postreminders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postreminders
    ADD CONSTRAINT postreminders_pkey PRIMARY KEY (postid, userid);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: postspriority postspriority_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postspriority
    ADD CONSTRAINT postspriority_pkey PRIMARY KEY (postid);


--
-- Name: preferences preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preferences
    ADD CONSTRAINT preferences_pkey PRIMARY KEY (userid, category, name);


--
-- Name: productnoticeviewstate productnoticeviewstate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productnoticeviewstate
    ADD CONSTRAINT productnoticeviewstate_pkey PRIMARY KEY (userid, noticeid);


--
-- Name: propertyfields propertyfields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.propertyfields
    ADD CONSTRAINT propertyfields_pkey PRIMARY KEY (id);


--
-- Name: propertygroups propertygroups_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.propertygroups
    ADD CONSTRAINT propertygroups_name_key UNIQUE (name);


--
-- Name: propertygroups propertygroups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.propertygroups
    ADD CONSTRAINT propertygroups_pkey PRIMARY KEY (id);


--
-- Name: propertyvalues propertyvalues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.propertyvalues
    ADD CONSTRAINT propertyvalues_pkey PRIMARY KEY (id);


--
-- Name: publicchannels publicchannels_name_teamid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicchannels
    ADD CONSTRAINT publicchannels_name_teamid_key UNIQUE (name, teamid);


--
-- Name: publicchannels publicchannels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicchannels
    ADD CONSTRAINT publicchannels_pkey PRIMARY KEY (id);


--
-- Name: reactions reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT reactions_pkey PRIMARY KEY (postid, userid, emojiname);


--
-- Name: readreceipts readreceipts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.readreceipts
    ADD CONSTRAINT readreceipts_pkey PRIMARY KEY (postid, userid);


--
-- Name: recapchannels recapchannels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recapchannels
    ADD CONSTRAINT recapchannels_pkey PRIMARY KEY (id);


--
-- Name: recaps recaps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recaps
    ADD CONSTRAINT recaps_pkey PRIMARY KEY (id);


--
-- Name: recentsearches recentsearches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recentsearches
    ADD CONSTRAINT recentsearches_pkey PRIMARY KEY (userid, searchpointer);


--
-- Name: remoteclusters remoteclusters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.remoteclusters
    ADD CONSTRAINT remoteclusters_pkey PRIMARY KEY (remoteid, name);


--
-- Name: retentionidsfordeletion retentionidsfordeletion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.retentionidsfordeletion
    ADD CONSTRAINT retentionidsfordeletion_pkey PRIMARY KEY (id);


--
-- Name: retentionpolicies retentionpolicies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.retentionpolicies
    ADD CONSTRAINT retentionpolicies_pkey PRIMARY KEY (id);


--
-- Name: retentionpolicieschannels retentionpolicieschannels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.retentionpolicieschannels
    ADD CONSTRAINT retentionpolicieschannels_pkey PRIMARY KEY (channelid);


--
-- Name: retentionpoliciesteams retentionpoliciesteams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.retentionpoliciesteams
    ADD CONSTRAINT retentionpoliciesteams_pkey PRIMARY KEY (teamid);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: scheduledposts scheduledposts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduledposts
    ADD CONSTRAINT scheduledposts_pkey PRIMARY KEY (id);


--
-- Name: schemes schemes_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT schemes_name_key UNIQUE (name);


--
-- Name: schemes schemes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT schemes_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sharedchannelattachments sharedchannelattachments_fileid_remoteid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sharedchannelattachments
    ADD CONSTRAINT sharedchannelattachments_fileid_remoteid_key UNIQUE (fileid, remoteid);


--
-- Name: sharedchannelattachments sharedchannelattachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sharedchannelattachments
    ADD CONSTRAINT sharedchannelattachments_pkey PRIMARY KEY (id);


--
-- Name: sharedchannelremotes sharedchannelremotes_channelid_remoteid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sharedchannelremotes
    ADD CONSTRAINT sharedchannelremotes_channelid_remoteid_key UNIQUE (channelid, remoteid);


--
-- Name: sharedchannelremotes sharedchannelremotes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sharedchannelremotes
    ADD CONSTRAINT sharedchannelremotes_pkey PRIMARY KEY (id, channelid);


--
-- Name: sharedchannels sharedchannels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sharedchannels
    ADD CONSTRAINT sharedchannels_pkey PRIMARY KEY (channelid);


--
-- Name: sharedchannels sharedchannels_sharename_teamid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sharedchannels
    ADD CONSTRAINT sharedchannels_sharename_teamid_key UNIQUE (sharename, teamid);


--
-- Name: sharedchannelusers sharedchannelusers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sharedchannelusers
    ADD CONSTRAINT sharedchannelusers_pkey PRIMARY KEY (id);


--
-- Name: sharedchannelusers sharedchannelusers_userid_channelid_remoteid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sharedchannelusers
    ADD CONSTRAINT sharedchannelusers_userid_channelid_remoteid_key UNIQUE (userid, channelid, remoteid);


--
-- Name: sidebarcategories sidebarcategories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sidebarcategories
    ADD CONSTRAINT sidebarcategories_pkey PRIMARY KEY (id);


--
-- Name: sidebarchannels sidebarchannels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sidebarchannels
    ADD CONSTRAINT sidebarchannels_pkey PRIMARY KEY (channelid, userid, categoryid);


--
-- Name: status status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_pkey PRIMARY KEY (userid);


--
-- Name: systems systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.systems
    ADD CONSTRAINT systems_pkey PRIMARY KEY (name);


--
-- Name: teammembers teammembers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teammembers
    ADD CONSTRAINT teammembers_pkey PRIMARY KEY (teamid, userid);


--
-- Name: teams teams_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_name_key UNIQUE (name);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: temporaryposts temporaryposts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.temporaryposts
    ADD CONSTRAINT temporaryposts_pkey PRIMARY KEY (postid);


--
-- Name: termsofservice termsofservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.termsofservice
    ADD CONSTRAINT termsofservice_pkey PRIMARY KEY (id);


--
-- Name: threadmemberships threadmemberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.threadmemberships
    ADD CONSTRAINT threadmemberships_pkey PRIMARY KEY (postid, userid);


--
-- Name: threads threads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.threads
    ADD CONSTRAINT threads_pkey PRIMARY KEY (postid);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (token);


--
-- Name: translations translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.translations
    ADD CONSTRAINT translations_pkey PRIMARY KEY (objectid, objecttype, dstlang);


--
-- Name: uploadsessions uploadsessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploadsessions
    ADD CONSTRAINT uploadsessions_pkey PRIMARY KEY (id);


--
-- Name: useraccesstokens useraccesstokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.useraccesstokens
    ADD CONSTRAINT useraccesstokens_pkey PRIMARY KEY (id);


--
-- Name: useraccesstokens useraccesstokens_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.useraccesstokens
    ADD CONSTRAINT useraccesstokens_token_key UNIQUE (token);


--
-- Name: usergroups usergroups_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usergroups
    ADD CONSTRAINT usergroups_name_key UNIQUE (name);


--
-- Name: usergroups usergroups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usergroups
    ADD CONSTRAINT usergroups_pkey PRIMARY KEY (id);


--
-- Name: usergroups usergroups_source_remoteid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usergroups
    ADD CONSTRAINT usergroups_source_remoteid_key UNIQUE (source, remoteid);


--
-- Name: users users_authdata_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_authdata_key UNIQUE (authdata);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: usertermsofservice usertermsofservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usertermsofservice
    ADD CONSTRAINT usertermsofservice_pkey PRIMARY KEY (userid);


--
-- Name: views views_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.views
    ADD CONSTRAINT views_pkey PRIMARY KEY (id);


--
-- Name: idx_access_control_policies_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_access_control_policies_type_id ON public.accesscontrolpolicies USING btree (type, id);


--
-- Name: idx_accesscontrolpolicies_name_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_accesscontrolpolicies_name_type ON public.accesscontrolpolicies USING btree (name, type) WHERE ((type)::text = 'parent'::text);


--
-- Name: idx_agents_confighistory_active; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_agents_confighistory_active ON public.agents_confighistory USING btree (active) WHERE (active = true);


--
-- Name: idx_audits_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audits_user_id ON public.audits USING btree (userid);


--
-- Name: idx_calls_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_calls_channel_id ON public.calls USING btree (channelid);


--
-- Name: idx_calls_end_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_calls_end_at ON public.calls USING btree (endat);


--
-- Name: idx_calls_jobs_call_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_calls_jobs_call_id ON public.calls_jobs USING btree (callid);


--
-- Name: idx_calls_sessions_call_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_calls_sessions_call_id ON public.calls_sessions USING btree (callid);


--
-- Name: idx_channel_guards_plugin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channel_guards_plugin_id ON public.channelguards USING btree (pluginid);


--
-- Name: idx_channel_search_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channel_search_txt ON public.channels USING gin (to_tsvector('english'::regconfig, (((((name)::text || ' '::text) || (displayname)::text) || ' '::text) || (purpose)::text)));


--
-- Name: idx_channelbookmarks_channelid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channelbookmarks_channelid ON public.channelbookmarks USING btree (channelid);


--
-- Name: idx_channelbookmarks_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channelbookmarks_delete_at ON public.channelbookmarks USING btree (deleteat);


--
-- Name: idx_channelbookmarks_type_targetid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channelbookmarks_type_targetid ON public.channelbookmarks USING btree (type, targetid) WHERE (targetid IS NOT NULL);


--
-- Name: idx_channelbookmarks_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channelbookmarks_update_at ON public.channelbookmarks USING btree (updateat);


--
-- Name: idx_channeljoinrequests_channel_status_createat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channeljoinrequests_channel_status_createat ON public.channeljoinrequests USING btree (channelid, status, createat DESC);


--
-- Name: idx_channeljoinrequests_pending_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_channeljoinrequests_pending_unique ON public.channeljoinrequests USING btree (channelid, userid) WHERE ((status)::text = 'pending'::text);


--
-- Name: idx_channeljoinrequests_user_status_createat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channeljoinrequests_user_status_createat ON public.channeljoinrequests USING btree (userid, status, createat DESC);


--
-- Name: idx_channelmembers_autotranslation_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channelmembers_autotranslation_enabled ON public.channelmembers USING btree (channelid) WHERE (autotranslation = true);


--
-- Name: idx_channelmembers_channel_id_scheme_guest_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channelmembers_channel_id_scheme_guest_user_id ON public.channelmembers USING btree (channelid, schemeguest, userid);


--
-- Name: idx_channelmembers_user_id_channel_id_last_viewed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channelmembers_user_id_channel_id_last_viewed_at ON public.channelmembers USING btree (userid, channelid, lastviewedat);


--
-- Name: idx_channels_autotranslation_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_autotranslation_enabled ON public.channels USING btree (id) WHERE (autotranslation = true);


--
-- Name: idx_channels_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_create_at ON public.channels USING btree (createat);


--
-- Name: idx_channels_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_delete_at ON public.channels USING btree (deleteat);


--
-- Name: idx_channels_discoverable_team; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_discoverable_team ON public.channels USING btree (teamid) WHERE ((discoverable = true) AND (type = 'P'::public.channel_type) AND (deleteat = 0));


--
-- Name: idx_channels_displayname_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_displayname_lower ON public.channels USING btree (lower((displayname)::text));


--
-- Name: idx_channels_name_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_name_lower ON public.channels USING btree (lower((name)::text));


--
-- Name: idx_channels_scheme_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_scheme_id ON public.channels USING btree (schemeid);


--
-- Name: idx_channels_team_id_display_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_team_id_display_name ON public.channels USING btree (teamid, displayname);


--
-- Name: idx_channels_team_id_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_team_id_type ON public.channels USING btree (teamid, type);


--
-- Name: idx_channels_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_update_at ON public.channels USING btree (updateat);


--
-- Name: idx_command_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_command_create_at ON public.commands USING btree (createat);


--
-- Name: idx_command_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_command_delete_at ON public.commands USING btree (deleteat);


--
-- Name: idx_command_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_command_team_id ON public.commands USING btree (teamid);


--
-- Name: idx_command_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_command_update_at ON public.commands USING btree (updateat);


--
-- Name: idx_command_webhook_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_command_webhook_create_at ON public.commandwebhooks USING btree (createat);


--
-- Name: idx_contentflaggingteamreviewers_userid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_contentflaggingteamreviewers_userid ON public.contentflaggingteamreviewers USING btree (userid);


--
-- Name: idx_desktoptokens_token_createat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_desktoptokens_token_createat ON public.desktoptokens USING btree (token, createat);


--
-- Name: idx_emoji_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_emoji_create_at ON public.emoji USING btree (createat);


--
-- Name: idx_emoji_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_emoji_delete_at ON public.emoji USING btree (deleteat);


--
-- Name: idx_emoji_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_emoji_update_at ON public.emoji USING btree (updateat);


--
-- Name: idx_fileinfo_channel_id_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_channel_id_create_at ON public.fileinfo USING btree (channelid, createat);


--
-- Name: idx_fileinfo_content_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_content_txt ON public.fileinfo USING gin (to_tsvector('english'::regconfig, content));


--
-- Name: idx_fileinfo_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_create_at ON public.fileinfo USING btree (createat);


--
-- Name: idx_fileinfo_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_delete_at ON public.fileinfo USING btree (deleteat);


--
-- Name: idx_fileinfo_extension_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_extension_at ON public.fileinfo USING btree (extension);


--
-- Name: idx_fileinfo_name_splitted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_name_splitted ON public.fileinfo USING gin (to_tsvector('english'::regconfig, translate((name)::text, '.,-'::text, '   '::text)));


--
-- Name: idx_fileinfo_name_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_name_txt ON public.fileinfo USING gin (to_tsvector('english'::regconfig, (name)::text));


--
-- Name: idx_fileinfo_postid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_postid_at ON public.fileinfo USING btree (postid);


--
-- Name: idx_fileinfo_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_update_at ON public.fileinfo USING btree (updateat);


--
-- Name: idx_groupchannels_channelid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_groupchannels_channelid ON public.groupchannels USING btree (channelid);


--
-- Name: idx_groupchannels_schemeadmin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_groupchannels_schemeadmin ON public.groupchannels USING btree (schemeadmin);


--
-- Name: idx_groupmembers_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_groupmembers_create_at ON public.groupmembers USING btree (createat);


--
-- Name: idx_groupteams_schemeadmin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_groupteams_schemeadmin ON public.groupteams USING btree (schemeadmin);


--
-- Name: idx_groupteams_teamid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_groupteams_teamid ON public.groupteams USING btree (teamid);


--
-- Name: idx_incoming_webhook_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incoming_webhook_create_at ON public.incomingwebhooks USING btree (createat);


--
-- Name: idx_incoming_webhook_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incoming_webhook_delete_at ON public.incomingwebhooks USING btree (deleteat);


--
-- Name: idx_incoming_webhook_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incoming_webhook_team_id ON public.incomingwebhooks USING btree (teamid);


--
-- Name: idx_incoming_webhook_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incoming_webhook_update_at ON public.incomingwebhooks USING btree (updateat);


--
-- Name: idx_incoming_webhook_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incoming_webhook_user_id ON public.incomingwebhooks USING btree (userid);


--
-- Name: idx_jobs_status_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_jobs_status_type ON public.jobs USING btree (status, type);


--
-- Name: idx_jobs_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_jobs_type ON public.jobs USING btree (type);


--
-- Name: idx_link_metadata_url_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_link_metadata_url_timestamp ON public.linkmetadata USING btree (url, "timestamp");


--
-- Name: idx_llm_conversations_thread_bot_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_llm_conversations_thread_bot_user ON public.llm_conversations USING btree (rootpostid, botid, userid) WHERE ((rootpostid IS NOT NULL) AND (deleteat = 0));


--
-- Name: idx_llm_conversations_userid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_llm_conversations_userid ON public.llm_conversations USING btree (userid, updatedat DESC) WHERE (deleteat = 0);


--
-- Name: idx_llm_turns_conversation_sequence; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_llm_turns_conversation_sequence ON public.llm_turns USING btree (conversationid, sequence);


--
-- Name: idx_llm_turns_post; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_llm_turns_post ON public.llm_turns USING btree (postid) WHERE (postid IS NOT NULL);


--
-- Name: idx_notice_views_notice_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notice_views_notice_id ON public.productnoticeviewstate USING btree (noticeid);


--
-- Name: idx_notice_views_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notice_views_timestamp ON public.productnoticeviewstate USING btree ("timestamp");


--
-- Name: idx_oauthaccessdata_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_oauthaccessdata_refresh_token ON public.oauthaccessdata USING btree (refreshtoken);


--
-- Name: idx_oauthaccessdata_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_oauthaccessdata_user_id ON public.oauthaccessdata USING btree (userid);


--
-- Name: idx_oauthapps_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_oauthapps_creator_id ON public.oauthapps USING btree (creatorid);


--
-- Name: idx_outgoing_webhook_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outgoing_webhook_create_at ON public.outgoingwebhooks USING btree (createat);


--
-- Name: idx_outgoing_webhook_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outgoing_webhook_delete_at ON public.outgoingwebhooks USING btree (deleteat);


--
-- Name: idx_outgoing_webhook_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outgoing_webhook_team_id ON public.outgoingwebhooks USING btree (teamid);


--
-- Name: idx_outgoing_webhook_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outgoing_webhook_update_at ON public.outgoingwebhooks USING btree (updateat);


--
-- Name: idx_outgoingoauthconnections_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outgoingoauthconnections_name ON public.outgoingoauthconnections USING btree (name);


--
-- Name: idx_postreminders_targettime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_postreminders_targettime ON public.postreminders USING btree (targettime);


--
-- Name: idx_posts_channel_id_delete_at_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_channel_id_delete_at_create_at ON public.posts USING btree (channelid, deleteat, createat);


--
-- Name: idx_posts_channel_id_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_channel_id_update_at ON public.posts USING btree (channelid, updateat);


--
-- Name: idx_posts_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_create_at ON public.posts USING btree (createat);


--
-- Name: idx_posts_create_at_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_create_at_id ON public.posts USING btree (createat, id);


--
-- Name: idx_posts_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_delete_at ON public.posts USING btree (deleteat);


--
-- Name: idx_posts_hashtags_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_hashtags_txt ON public.posts USING gin (to_tsvector('english'::regconfig, (hashtags)::text));


--
-- Name: idx_posts_is_pinned; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_is_pinned ON public.posts USING btree (ispinned);


--
-- Name: idx_posts_message_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_message_txt ON public.posts USING gin (to_tsvector('english'::regconfig, (message)::text));


--
-- Name: idx_posts_original_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_original_id ON public.posts USING btree (originalid);


--
-- Name: idx_posts_root_id_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_root_id_delete_at ON public.posts USING btree (rootid, deleteat);


--
-- Name: idx_posts_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_update_at ON public.posts USING btree (updateat);


--
-- Name: idx_posts_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_user_id ON public.posts USING btree (userid);


--
-- Name: idx_poststats_userid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_poststats_userid ON public.poststats USING btree (userid);


--
-- Name: idx_preferences_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_preferences_category ON public.preferences USING btree (category);


--
-- Name: idx_preferences_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_preferences_name ON public.preferences USING btree (name);


--
-- Name: idx_propertyfields_create_at_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_propertyfields_create_at_id ON public.propertyfields USING btree (createat, id);


--
-- Name: idx_propertyfields_groupid_updateat_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_propertyfields_groupid_updateat_id ON public.propertyfields USING btree (groupid, updateat, id);


--
-- Name: idx_propertyfields_linkedfieldid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_propertyfields_linkedfieldid ON public.propertyfields USING btree (linkedfieldid) WHERE ((linkedfieldid IS NOT NULL) AND (deleteat = 0));


--
-- Name: idx_propertyfields_unique_legacy; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_propertyfields_unique_legacy ON public.propertyfields USING btree (groupid, targetid, name) WHERE ((deleteat = 0) AND ((objecttype)::text = ''::text));


--
-- Name: idx_propertyfields_unique_typed; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_propertyfields_unique_typed ON public.propertyfields USING btree (objecttype, groupid, targettype, targetid, name) WHERE ((deleteat = 0) AND ((objecttype)::text <> ''::text));


--
-- Name: idx_propertyvalues_create_at_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_propertyvalues_create_at_id ON public.propertyvalues USING btree (createat, id);


--
-- Name: idx_propertyvalues_groupid_updateat_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_propertyvalues_groupid_updateat_id ON public.propertyvalues USING btree (groupid, updateat, id);


--
-- Name: idx_propertyvalues_targetid_groupid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_propertyvalues_targetid_groupid ON public.propertyvalues USING btree (targetid, groupid);


--
-- Name: idx_propertyvalues_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_propertyvalues_unique ON public.propertyvalues USING btree (groupid, targetid, fieldid) WHERE (deleteat = 0);


--
-- Name: idx_publicchannels_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_publicchannels_delete_at ON public.publicchannels USING btree (deleteat);


--
-- Name: idx_publicchannels_displayname_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_publicchannels_displayname_lower ON public.publicchannels USING btree (lower((displayname)::text));


--
-- Name: idx_publicchannels_name_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_publicchannels_name_lower ON public.publicchannels USING btree (lower((name)::text));


--
-- Name: idx_publicchannels_search_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_publicchannels_search_txt ON public.publicchannels USING gin (to_tsvector('english'::regconfig, (((((name)::text || ' '::text) || (displayname)::text) || ' '::text) || (purpose)::text)));


--
-- Name: idx_publicchannels_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_publicchannels_team_id ON public.publicchannels USING btree (teamid);


--
-- Name: idx_reactions_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reactions_channel_id ON public.reactions USING btree (channelid);


--
-- Name: idx_read_receipts_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_read_receipts_post_id ON public.readreceipts USING btree (postid);


--
-- Name: idx_read_receipts_user_id_post_id_expire_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_read_receipts_user_id_post_id_expire_at ON public.readreceipts USING btree (userid, postid, expireat);


--
-- Name: idx_recap_channels_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recap_channels_channel_id ON public.recapchannels USING btree (channelid);


--
-- Name: idx_recap_channels_recap_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recap_channels_recap_id ON public.recapchannels USING btree (recapid);


--
-- Name: idx_recaps_bot_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recaps_bot_id ON public.recaps USING btree (botid);


--
-- Name: idx_recaps_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recaps_create_at ON public.recaps USING btree (createat);


--
-- Name: idx_recaps_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recaps_user_id ON public.recaps USING btree (userid);


--
-- Name: idx_recaps_user_id_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recaps_user_id_delete_at ON public.recaps USING btree (userid, deleteat);


--
-- Name: idx_recaps_user_id_read_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recaps_user_id_read_at ON public.recaps USING btree (userid, readat);


--
-- Name: idx_recaps_user_id_viewed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recaps_user_id_viewed_at ON public.recaps USING btree (userid, viewedat);


--
-- Name: idx_retentionidsfordeletion_tablename; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_retentionidsfordeletion_tablename ON public.retentionidsfordeletion USING btree (tablename);


--
-- Name: idx_retentionpolicies_displayname; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_retentionpolicies_displayname ON public.retentionpolicies USING btree (displayname);


--
-- Name: idx_retentionpolicieschannels_policyid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_retentionpolicieschannels_policyid ON public.retentionpolicieschannels USING btree (policyid);


--
-- Name: idx_retentionpoliciesteams_policyid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_retentionpoliciesteams_policyid ON public.retentionpoliciesteams USING btree (policyid);


--
-- Name: idx_roles_scheme_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_roles_scheme_id ON public.roles USING btree (schemeid);


--
-- Name: idx_scheduledposts_userid_channel_id_scheduled_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_scheduledposts_userid_channel_id_scheduled_at ON public.scheduledposts USING btree (userid, channelid, scheduledat);


--
-- Name: idx_schemes_channel_admin_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_schemes_channel_admin_role ON public.schemes USING btree (defaultchanneladminrole);


--
-- Name: idx_schemes_channel_guest_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_schemes_channel_guest_role ON public.schemes USING btree (defaultchannelguestrole);


--
-- Name: idx_schemes_channel_user_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_schemes_channel_user_role ON public.schemes USING btree (defaultchanneluserrole);


--
-- Name: idx_sessions_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_create_at ON public.sessions USING btree (createat);


--
-- Name: idx_sessions_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_expires_at ON public.sessions USING btree (expiresat);


--
-- Name: idx_sessions_last_activity_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_last_activity_at ON public.sessions USING btree (lastactivityat);


--
-- Name: idx_sessions_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_token ON public.sessions USING btree (token);


--
-- Name: idx_sessions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_user_id ON public.sessions USING btree (userid);


--
-- Name: idx_sharedchannelusers_remote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sharedchannelusers_remote_id ON public.sharedchannelusers USING btree (remoteid);


--
-- Name: idx_sidebarcategories_userid_teamid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sidebarcategories_userid_teamid ON public.sidebarcategories USING btree (userid, teamid);


--
-- Name: idx_sidebarchannels_categoryid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sidebarchannels_categoryid ON public.sidebarchannels USING btree (categoryid);


--
-- Name: idx_status_status_dndendtime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_status_status_dndendtime ON public.status USING btree (status, dndendtime);


--
-- Name: idx_teammembers_createat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teammembers_createat ON public.teammembers USING btree (createat);


--
-- Name: idx_teammembers_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teammembers_delete_at ON public.teammembers USING btree (deleteat);


--
-- Name: idx_teammembers_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teammembers_user_id ON public.teammembers USING btree (userid);


--
-- Name: idx_teams_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teams_create_at ON public.teams USING btree (createat);


--
-- Name: idx_teams_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teams_delete_at ON public.teams USING btree (deleteat);


--
-- Name: idx_teams_invite_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teams_invite_id ON public.teams USING btree (inviteid);


--
-- Name: idx_teams_scheme_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teams_scheme_id ON public.teams USING btree (schemeid);


--
-- Name: idx_teams_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teams_update_at ON public.teams USING btree (updateat);


--
-- Name: idx_temporary_posts_expire_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_temporary_posts_expire_at ON public.temporaryposts USING btree (expireat);


--
-- Name: idx_thread_memberships_last_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_thread_memberships_last_update_at ON public.threadmemberships USING btree (lastupdated);


--
-- Name: idx_thread_memberships_last_view_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_thread_memberships_last_view_at ON public.threadmemberships USING btree (lastviewed);


--
-- Name: idx_thread_memberships_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_thread_memberships_user_id ON public.threadmemberships USING btree (userid);


--
-- Name: idx_threads_channel_id_last_reply_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_threads_channel_id_last_reply_at ON public.threads USING btree (channelid, lastreplyat);


--
-- Name: idx_translations_channel_updateat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_translations_channel_updateat ON public.translations USING btree (channelid, objecttype, updateat DESC, dstlang);


--
-- Name: idx_translations_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_translations_state ON public.translations USING btree (state) WHERE ((state)::text = 'processing'::text);


--
-- Name: idx_uploadsessions_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_uploadsessions_create_at ON public.uploadsessions USING btree (createat);


--
-- Name: idx_uploadsessions_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_uploadsessions_type ON public.uploadsessions USING btree (type);


--
-- Name: idx_uploadsessions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_uploadsessions_user_id ON public.uploadsessions USING btree (userid);


--
-- Name: idx_user_access_tokens_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_access_tokens_user_id ON public.useraccesstokens USING btree (userid);


--
-- Name: idx_useraccesstokens_expiresat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_useraccesstokens_expiresat ON public.useraccesstokens USING btree (expiresat) WHERE (expiresat > 0);


--
-- Name: idx_useragents_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_useragents_active ON public.agents_useragents USING btree (deleteat);


--
-- Name: idx_useragents_bot_user_id_active; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_useragents_bot_user_id_active ON public.agents_useragents USING btree (botuserid) WHERE (deleteat = 0);


--
-- Name: idx_useragents_creator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_useragents_creator ON public.agents_useragents USING btree (creatorid) WHERE (deleteat = 0);


--
-- Name: idx_usergroups_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usergroups_delete_at ON public.usergroups USING btree (deleteat);


--
-- Name: idx_usergroups_displayname; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usergroups_displayname ON public.usergroups USING btree (displayname);


--
-- Name: idx_usergroups_remote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usergroups_remote_id ON public.usergroups USING btree (remoteid);


--
-- Name: idx_users_all_no_full_name_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_all_no_full_name_txt ON public.users USING gin (to_tsvector('english'::regconfig, (((((username)::text || ' '::text) || (nickname)::text) || ' '::text) || (email)::text)));


--
-- Name: idx_users_all_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_all_txt ON public.users USING gin (to_tsvector('english'::regconfig, (((((((((username)::text || ' '::text) || (firstname)::text) || ' '::text) || (lastname)::text) || ' '::text) || (nickname)::text) || ' '::text) || (email)::text)));


--
-- Name: idx_users_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_create_at ON public.users USING btree (createat);


--
-- Name: idx_users_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_delete_at ON public.users USING btree (deleteat);


--
-- Name: idx_users_email_lower_textpattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_email_lower_textpattern ON public.users USING btree (lower((email)::text) text_pattern_ops);


--
-- Name: idx_users_firstname_lower_textpattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_firstname_lower_textpattern ON public.users USING btree (lower((firstname)::text) text_pattern_ops);


--
-- Name: idx_users_id_locale; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_id_locale ON public.users USING btree (id, locale);


--
-- Name: idx_users_lastname_lower_textpattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_lastname_lower_textpattern ON public.users USING btree (lower((lastname)::text) text_pattern_ops);


--
-- Name: idx_users_names_no_full_name_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_names_no_full_name_txt ON public.users USING gin (to_tsvector('english'::regconfig, (((username)::text || ' '::text) || (nickname)::text)));


--
-- Name: idx_users_names_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_names_txt ON public.users USING gin (to_tsvector('english'::regconfig, (((((((username)::text || ' '::text) || (firstname)::text) || ' '::text) || (lastname)::text) || ' '::text) || (nickname)::text)));


--
-- Name: idx_users_nickname_lower_textpattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_nickname_lower_textpattern ON public.users USING btree (lower((nickname)::text) text_pattern_ops);


--
-- Name: idx_users_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_update_at ON public.users USING btree (updateat);


--
-- Name: idx_users_username_lower_textpattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_username_lower_textpattern ON public.users USING btree (lower((username)::text) text_pattern_ops);


--
-- Name: idx_views_channel_id_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_views_channel_id_delete_at ON public.views USING btree (channelid, deleteat);


--
-- Name: retentionpolicieschannels fk_retentionpolicieschannels_retentionpolicies; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.retentionpolicieschannels
    ADD CONSTRAINT fk_retentionpolicieschannels_retentionpolicies FOREIGN KEY (policyid) REFERENCES public.retentionpolicies(id) ON DELETE CASCADE;


--
-- Name: retentionpoliciesteams fk_retentionpoliciesteams_retentionpolicies; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.retentionpoliciesteams
    ADD CONSTRAINT fk_retentionpoliciesteams_retentionpolicies FOREIGN KEY (policyid) REFERENCES public.retentionpolicies(id) ON DELETE CASCADE;


--
-- Name: recapchannels recapchannels_recapid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recapchannels
    ADD CONSTRAINT recapchannels_recapid_fkey FOREIGN KEY (recapid) REFERENCES public.recaps(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


