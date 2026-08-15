--
-- PostgreSQL database dump
--


-- Dumped from database version 16.15
-- Dumped by pg_dump version 16.15

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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: bounce_type; Type: TYPE; Schema: public; Owner: listmonk
--

CREATE TYPE public.bounce_type AS ENUM (
    'soft',
    'hard',
    'complaint'
);



--
-- Name: campaign_status; Type: TYPE; Schema: public; Owner: listmonk
--

CREATE TYPE public.campaign_status AS ENUM (
    'draft',
    'running',
    'scheduled',
    'paused',
    'cancelled',
    'finished'
);



--
-- Name: campaign_type; Type: TYPE; Schema: public; Owner: listmonk
--

CREATE TYPE public.campaign_type AS ENUM (
    'regular',
    'optin'
);



--
-- Name: content_type; Type: TYPE; Schema: public; Owner: listmonk
--

CREATE TYPE public.content_type AS ENUM (
    'richtext',
    'html',
    'plain',
    'markdown',
    'visual'
);



--
-- Name: list_optin; Type: TYPE; Schema: public; Owner: listmonk
--

CREATE TYPE public.list_optin AS ENUM (
    'single',
    'double'
);



--
-- Name: list_status; Type: TYPE; Schema: public; Owner: listmonk
--

CREATE TYPE public.list_status AS ENUM (
    'active',
    'archived'
);



--
-- Name: list_type; Type: TYPE; Schema: public; Owner: listmonk
--

CREATE TYPE public.list_type AS ENUM (
    'public',
    'private',
    'temporary'
);



--
-- Name: role_type; Type: TYPE; Schema: public; Owner: listmonk
--

CREATE TYPE public.role_type AS ENUM (
    'user',
    'list'
);



--
-- Name: subscriber_status; Type: TYPE; Schema: public; Owner: listmonk
--

CREATE TYPE public.subscriber_status AS ENUM (
    'enabled',
    'disabled',
    'blocklisted'
);



--
-- Name: subscription_status; Type: TYPE; Schema: public; Owner: listmonk
--

CREATE TYPE public.subscription_status AS ENUM (
    'unconfirmed',
    'confirmed',
    'unsubscribed'
);



--
-- Name: template_type; Type: TYPE; Schema: public; Owner: listmonk
--

CREATE TYPE public.template_type AS ENUM (
    'campaign',
    'campaign_visual',
    'tx'
);



--
-- Name: twofa_type; Type: TYPE; Schema: public; Owner: listmonk
--

CREATE TYPE public.twofa_type AS ENUM (
    'none',
    'totp'
);



--
-- Name: user_status; Type: TYPE; Schema: public; Owner: listmonk
--

CREATE TYPE public.user_status AS ENUM (
    'enabled',
    'disabled'
);



--
-- Name: user_type; Type: TYPE; Schema: public; Owner: listmonk
--

CREATE TYPE public.user_type AS ENUM (
    'user',
    'api'
);



SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bounces; Type: TABLE; Schema: public; Owner: listmonk
--

CREATE TABLE public.bounces (
    id integer NOT NULL,
    subscriber_id integer NOT NULL,
    campaign_id integer,
    type public.bounce_type DEFAULT 'hard'::public.bounce_type NOT NULL,
    source text DEFAULT ''::text NOT NULL,
    meta jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);



--
-- Name: bounces_id_seq; Type: SEQUENCE; Schema: public; Owner: listmonk
--

CREATE SEQUENCE public.bounces_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: bounces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: listmonk
--

ALTER SEQUENCE public.bounces_id_seq OWNED BY public.bounces.id;


--
-- Name: campaign_lists; Type: TABLE; Schema: public; Owner: listmonk
--

CREATE TABLE public.campaign_lists (
    id bigint NOT NULL,
    campaign_id integer NOT NULL,
    list_id integer,
    list_name text DEFAULT ''::text NOT NULL
);



--
-- Name: campaign_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: listmonk
--

CREATE SEQUENCE public.campaign_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: campaign_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: listmonk
--

ALTER SEQUENCE public.campaign_lists_id_seq OWNED BY public.campaign_lists.id;


--
-- Name: campaign_media; Type: TABLE; Schema: public; Owner: listmonk
--

CREATE TABLE public.campaign_media (
    campaign_id integer,
    media_id integer,
    filename text DEFAULT ''::text NOT NULL
);



--
-- Name: campaign_views; Type: TABLE; Schema: public; Owner: listmonk
--

CREATE TABLE public.campaign_views (
    id bigint NOT NULL,
    campaign_id integer NOT NULL,
    subscriber_id integer,
    created_at timestamp with time zone DEFAULT now()
);



--
-- Name: campaign_views_id_seq; Type: SEQUENCE; Schema: public; Owner: listmonk
--

CREATE SEQUENCE public.campaign_views_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: campaign_views_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: listmonk
--

ALTER SEQUENCE public.campaign_views_id_seq OWNED BY public.campaign_views.id;


--
-- Name: campaigns; Type: TABLE; Schema: public; Owner: listmonk
--

CREATE TABLE public.campaigns (
    id integer NOT NULL,
    uuid uuid NOT NULL,
    name text NOT NULL,
    subject text NOT NULL,
    from_email text NOT NULL,
    body text NOT NULL,
    body_source text,
    altbody text,
    content_type public.content_type DEFAULT 'richtext'::public.content_type NOT NULL,
    send_at timestamp with time zone,
    headers jsonb DEFAULT '[]'::jsonb NOT NULL,
    attribs jsonb DEFAULT '{}'::jsonb NOT NULL,
    status public.campaign_status DEFAULT 'draft'::public.campaign_status NOT NULL,
    tags character varying(100)[],
    type public.campaign_type DEFAULT 'regular'::public.campaign_type,
    messenger text NOT NULL,
    template_id integer,
    to_send integer DEFAULT 0 NOT NULL,
    sent integer DEFAULT 0 NOT NULL,
    max_subscriber_id integer DEFAULT 0 NOT NULL,
    last_subscriber_id integer DEFAULT 0 NOT NULL,
    archive boolean DEFAULT false NOT NULL,
    archive_slug text,
    archive_template_id integer,
    archive_meta jsonb DEFAULT '{}'::jsonb NOT NULL,
    started_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);



--
-- Name: campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: listmonk
--

CREATE SEQUENCE public.campaigns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: listmonk
--

ALTER SEQUENCE public.campaigns_id_seq OWNED BY public.campaigns.id;


--
-- Name: link_clicks; Type: TABLE; Schema: public; Owner: listmonk
--

CREATE TABLE public.link_clicks (
    id bigint NOT NULL,
    campaign_id integer,
    link_id integer NOT NULL,
    subscriber_id integer,
    created_at timestamp with time zone DEFAULT now()
);



--
-- Name: link_clicks_id_seq; Type: SEQUENCE; Schema: public; Owner: listmonk
--

CREATE SEQUENCE public.link_clicks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: link_clicks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: listmonk
--

ALTER SEQUENCE public.link_clicks_id_seq OWNED BY public.link_clicks.id;


--
-- Name: links; Type: TABLE; Schema: public; Owner: listmonk
--

CREATE TABLE public.links (
    id integer NOT NULL,
    uuid uuid NOT NULL,
    url text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);



--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: listmonk
--

CREATE SEQUENCE public.links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: listmonk
--

ALTER SEQUENCE public.links_id_seq OWNED BY public.links.id;


--
-- Name: lists; Type: TABLE; Schema: public; Owner: listmonk
--

CREATE TABLE public.lists (
    id integer NOT NULL,
    uuid uuid NOT NULL,
    name text NOT NULL,
    type public.list_type NOT NULL,
    optin public.list_optin DEFAULT 'single'::public.list_optin NOT NULL,
    status public.list_status DEFAULT 'active'::public.list_status NOT NULL,
    tags character varying(100)[],
    description text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);



--
-- Name: lists_id_seq; Type: SEQUENCE; Schema: public; Owner: listmonk
--

CREATE SEQUENCE public.lists_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: listmonk
--

ALTER SEQUENCE public.lists_id_seq OWNED BY public.lists.id;


--
-- Name: mat_dashboard_charts; Type: MATERIALIZED VIEW; Schema: public; Owner: listmonk
--

CREATE MATERIALIZED VIEW public.mat_dashboard_charts AS
 WITH clicks AS (
         SELECT json_agg(row_to_json("row".*)) AS json_agg
           FROM ( WITH viewdates AS (
                         SELECT (link_clicks_1.created_at)::date AS to_date,
                            ((link_clicks_1.created_at)::date - '30 days'::interval) AS from_date
                           FROM public.link_clicks link_clicks_1
                          ORDER BY link_clicks_1.id DESC
                         LIMIT 1
                        )
                 SELECT count(*) AS count,
                    (link_clicks.created_at)::date AS date
                   FROM public.link_clicks
                  WHERE ((link_clicks.created_at >= ( SELECT viewdates.from_date
                           FROM viewdates)) AND (link_clicks.created_at < (( SELECT viewdates.to_date
                           FROM viewdates) + '1 day'::interval)))
                  GROUP BY ((link_clicks.created_at)::date)
                  ORDER BY ((link_clicks.created_at)::date)) "row"
        ), views AS (
         SELECT json_agg(row_to_json("row".*)) AS json_agg
           FROM ( WITH viewdates AS (
                         SELECT (campaign_views_1.created_at)::date AS to_date,
                            ((campaign_views_1.created_at)::date - '30 days'::interval) AS from_date
                           FROM public.campaign_views campaign_views_1
                          ORDER BY campaign_views_1.id DESC
                         LIMIT 1
                        )
                 SELECT count(*) AS count,
                    (campaign_views.created_at)::date AS date
                   FROM public.campaign_views
                  WHERE ((campaign_views.created_at >= ( SELECT viewdates.from_date
                           FROM viewdates)) AND (campaign_views.created_at < (( SELECT viewdates.to_date
                           FROM viewdates) + '1 day'::interval)))
                  GROUP BY ((campaign_views.created_at)::date)
                  ORDER BY ((campaign_views.created_at)::date)) "row"
        )
 SELECT now() AS updated_at,
    json_build_object('link_clicks', COALESCE(( SELECT clicks.json_agg
           FROM clicks), '[]'::json), 'campaign_views', COALESCE(( SELECT views.json_agg
           FROM views), '[]'::json)) AS data
  WITH NO DATA;



--
-- Name: subscriber_lists; Type: TABLE; Schema: public; Owner: listmonk
--

CREATE TABLE public.subscriber_lists (
    subscriber_id integer NOT NULL,
    list_id integer NOT NULL,
    meta jsonb DEFAULT '{}'::jsonb NOT NULL,
    status public.subscription_status DEFAULT 'unconfirmed'::public.subscription_status NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);



--
-- Name: subscribers; Type: TABLE; Schema: public; Owner: listmonk
--

CREATE TABLE public.subscribers (
    id integer NOT NULL,
    uuid uuid NOT NULL,
    email text NOT NULL,
    name text NOT NULL,
    attribs jsonb DEFAULT '{}'::jsonb NOT NULL,
    status public.subscriber_status DEFAULT 'enabled'::public.subscriber_status NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);



--
-- Name: mat_dashboard_counts; Type: MATERIALIZED VIEW; Schema: public; Owner: listmonk
--

CREATE MATERIALIZED VIEW public.mat_dashboard_counts AS
 WITH subs AS (
         SELECT count(*) AS num,
            subscribers.status
           FROM public.subscribers
          GROUP BY subscribers.status
        )
 SELECT now() AS updated_at,
    json_build_object('subscribers', json_build_object('total', ( SELECT sum(subs.num) AS sum
           FROM subs), 'blocklisted', ( SELECT subs.num
           FROM subs
          WHERE (subs.status = 'blocklisted'::public.subscriber_status)), 'orphans', ( SELECT count(subscribers.id) AS count
           FROM (public.subscribers
             LEFT JOIN public.subscriber_lists ON ((subscribers.id = subscriber_lists.subscriber_id)))
          WHERE (subscriber_lists.subscriber_id IS NULL))), 'lists', json_build_object('total', ( SELECT count(*) AS count
           FROM public.lists), 'private', ( SELECT count(*) AS count
           FROM public.lists
          WHERE (lists.type = 'private'::public.list_type)), 'public', ( SELECT count(*) AS count
           FROM public.lists
          WHERE (lists.type = 'public'::public.list_type)), 'optin_single', ( SELECT count(*) AS count
           FROM public.lists
          WHERE (lists.optin = 'single'::public.list_optin)), 'optin_double', ( SELECT count(*) AS count
           FROM public.lists
          WHERE (lists.optin = 'double'::public.list_optin))), 'campaigns', json_build_object('total', ( SELECT count(*) AS count
           FROM public.campaigns), 'by_status', ( SELECT json_object_agg(r.status, r.num) AS json_object_agg
           FROM ( SELECT campaigns.status,
                    count(*) AS num
                   FROM public.campaigns
                  GROUP BY campaigns.status) r)), 'messages', ( SELECT sum(campaigns.sent) AS messages
           FROM public.campaigns)) AS data
  WITH NO DATA;



--
-- Name: mat_list_subscriber_stats; Type: MATERIALIZED VIEW; Schema: public; Owner: listmonk
--

CREATE MATERIALIZED VIEW public.mat_list_subscriber_stats AS
 SELECT now() AS updated_at,
    lists.id AS list_id,
    subscriber_lists.status,
    count(subscriber_lists.status) AS subscriber_count
   FROM (public.lists
     LEFT JOIN public.subscriber_lists ON ((subscriber_lists.list_id = lists.id)))
  GROUP BY lists.id, subscriber_lists.status
UNION ALL
 SELECT now() AS updated_at,
    0 AS list_id,
    NULL::public.subscription_status AS status,
    count(subscribers.id) AS subscriber_count
   FROM public.subscribers
  WITH NO DATA;



--
-- Name: media; Type: TABLE; Schema: public; Owner: listmonk
--

CREATE TABLE public.media (
    id integer NOT NULL,
    uuid uuid NOT NULL,
    provider text DEFAULT ''::text NOT NULL,
    filename text NOT NULL,
    content_type text DEFAULT 'application/octet-stream'::text NOT NULL,
    thumb text NOT NULL,
    meta jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);



--
-- Name: media_id_seq; Type: SEQUENCE; Schema: public; Owner: listmonk
--

CREATE SEQUENCE public.media_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: media_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: listmonk
--

ALTER SEQUENCE public.media_id_seq OWNED BY public.media.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: listmonk
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    type public.role_type DEFAULT 'user'::public.role_type NOT NULL,
    parent_id integer,
    list_id integer,
    permissions text[] DEFAULT '{}'::text[] NOT NULL,
    name text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);



--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: listmonk
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: listmonk
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: listmonk
--

CREATE TABLE public.sessions (
    id text NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);



--
-- Name: settings; Type: TABLE; Schema: public; Owner: listmonk
--

CREATE TABLE public.settings (
    key text NOT NULL,
    value jsonb DEFAULT '{}'::jsonb NOT NULL,
    updated_at timestamp with time zone DEFAULT now()
);



--
-- Name: subscribers_id_seq; Type: SEQUENCE; Schema: public; Owner: listmonk
--

CREATE SEQUENCE public.subscribers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: subscribers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: listmonk
--

ALTER SEQUENCE public.subscribers_id_seq OWNED BY public.subscribers.id;


--
-- Name: templates; Type: TABLE; Schema: public; Owner: listmonk
--

CREATE TABLE public.templates (
    id integer NOT NULL,
    name text NOT NULL,
    type public.template_type DEFAULT 'campaign'::public.template_type NOT NULL,
    subject text NOT NULL,
    body text NOT NULL,
    body_source text,
    is_default boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);



--
-- Name: templates_id_seq; Type: SEQUENCE; Schema: public; Owner: listmonk
--

CREATE SEQUENCE public.templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: listmonk
--

ALTER SEQUENCE public.templates_id_seq OWNED BY public.templates.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: listmonk
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    password_login boolean DEFAULT false NOT NULL,
    password text,
    email text NOT NULL,
    name text NOT NULL,
    avatar text,
    type public.user_type DEFAULT 'user'::public.user_type NOT NULL,
    user_role_id integer NOT NULL,
    list_role_id integer,
    status public.user_status DEFAULT 'disabled'::public.user_status NOT NULL,
    twofa_type public.twofa_type DEFAULT 'none'::public.twofa_type NOT NULL,
    twofa_key text,
    loggedin_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);



--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: listmonk
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: listmonk
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: bounces id; Type: DEFAULT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.bounces ALTER COLUMN id SET DEFAULT nextval('public.bounces_id_seq'::regclass);


--
-- Name: campaign_lists id; Type: DEFAULT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.campaign_lists ALTER COLUMN id SET DEFAULT nextval('public.campaign_lists_id_seq'::regclass);


--
-- Name: campaign_views id; Type: DEFAULT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.campaign_views ALTER COLUMN id SET DEFAULT nextval('public.campaign_views_id_seq'::regclass);


--
-- Name: campaigns id; Type: DEFAULT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.campaigns ALTER COLUMN id SET DEFAULT nextval('public.campaigns_id_seq'::regclass);


--
-- Name: link_clicks id; Type: DEFAULT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.link_clicks ALTER COLUMN id SET DEFAULT nextval('public.link_clicks_id_seq'::regclass);


--
-- Name: links id; Type: DEFAULT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.links ALTER COLUMN id SET DEFAULT nextval('public.links_id_seq'::regclass);


--
-- Name: lists id; Type: DEFAULT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.lists ALTER COLUMN id SET DEFAULT nextval('public.lists_id_seq'::regclass);


--
-- Name: media id; Type: DEFAULT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.media ALTER COLUMN id SET DEFAULT nextval('public.media_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: subscribers id; Type: DEFAULT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.subscribers ALTER COLUMN id SET DEFAULT nextval('public.subscribers_id_seq'::regclass);


--
-- Name: templates id; Type: DEFAULT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.templates ALTER COLUMN id SET DEFAULT nextval('public.templates_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: bounces bounces_pkey; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.bounces
    ADD CONSTRAINT bounces_pkey PRIMARY KEY (id);


--
-- Name: campaign_lists campaign_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.campaign_lists
    ADD CONSTRAINT campaign_lists_pkey PRIMARY KEY (id);


--
-- Name: campaign_views campaign_views_pkey; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.campaign_views
    ADD CONSTRAINT campaign_views_pkey PRIMARY KEY (id);


--
-- Name: campaigns campaigns_archive_slug_key; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.campaigns
    ADD CONSTRAINT campaigns_archive_slug_key UNIQUE (archive_slug);


--
-- Name: campaigns campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.campaigns
    ADD CONSTRAINT campaigns_pkey PRIMARY KEY (id);


--
-- Name: campaigns campaigns_uuid_key; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.campaigns
    ADD CONSTRAINT campaigns_uuid_key UNIQUE (uuid);


--
-- Name: link_clicks link_clicks_pkey; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.link_clicks
    ADD CONSTRAINT link_clicks_pkey PRIMARY KEY (id);


--
-- Name: links links_pkey; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: links links_url_key; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_url_key UNIQUE (url);


--
-- Name: links links_uuid_key; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_uuid_key UNIQUE (uuid);


--
-- Name: lists lists_pkey; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.lists
    ADD CONSTRAINT lists_pkey PRIMARY KEY (id);


--
-- Name: lists lists_uuid_key; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.lists
    ADD CONSTRAINT lists_uuid_key UNIQUE (uuid);


--
-- Name: media media_pkey; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_pkey PRIMARY KEY (id);


--
-- Name: media media_uuid_key; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_uuid_key UNIQUE (uuid);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: settings settings_key_key; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key UNIQUE (key);


--
-- Name: subscriber_lists subscriber_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.subscriber_lists
    ADD CONSTRAINT subscriber_lists_pkey PRIMARY KEY (subscriber_id, list_id);


--
-- Name: subscribers subscribers_email_key; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.subscribers
    ADD CONSTRAINT subscribers_email_key UNIQUE (email);


--
-- Name: subscribers subscribers_pkey; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.subscribers
    ADD CONSTRAINT subscribers_pkey PRIMARY KEY (id);


--
-- Name: subscribers subscribers_uuid_key; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.subscribers
    ADD CONSTRAINT subscribers_uuid_key UNIQUE (uuid);


--
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: campaign_lists_campaign_id_list_id_idx; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE UNIQUE INDEX campaign_lists_campaign_id_list_id_idx ON public.campaign_lists USING btree (campaign_id, list_id);


--
-- Name: idx_bounces_camp_id; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_bounces_camp_id ON public.bounces USING btree (campaign_id);


--
-- Name: idx_bounces_date; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_bounces_date ON public.bounces USING btree (created_at);


--
-- Name: idx_bounces_source; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_bounces_source ON public.bounces USING btree (source);


--
-- Name: idx_bounces_sub_id; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_bounces_sub_id ON public.bounces USING btree (subscriber_id);


--
-- Name: idx_camp_lists_camp_id; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_camp_lists_camp_id ON public.campaign_lists USING btree (campaign_id);


--
-- Name: idx_camp_lists_list_id; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_camp_lists_list_id ON public.campaign_lists USING btree (list_id);


--
-- Name: idx_camp_media_camp_id; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_camp_media_camp_id ON public.campaign_media USING btree (campaign_id);


--
-- Name: idx_camp_media_id; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE UNIQUE INDEX idx_camp_media_id ON public.campaign_media USING btree (campaign_id, media_id);


--
-- Name: idx_camps_created_at; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_camps_created_at ON public.campaigns USING btree (created_at);


--
-- Name: idx_camps_name; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_camps_name ON public.campaigns USING btree (name);


--
-- Name: idx_camps_status; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_camps_status ON public.campaigns USING btree (status);


--
-- Name: idx_camps_updated_at; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_camps_updated_at ON public.campaigns USING btree (updated_at);


--
-- Name: idx_clicks_camp_id; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_clicks_camp_id ON public.link_clicks USING btree (campaign_id);


--
-- Name: idx_clicks_date; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_clicks_date ON public.link_clicks USING btree (created_at);


--
-- Name: idx_clicks_link_id; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_clicks_link_id ON public.link_clicks USING btree (link_id);


--
-- Name: idx_clicks_sub_id; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_clicks_sub_id ON public.link_clicks USING btree (subscriber_id);


--
-- Name: idx_lists_created_at; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_lists_created_at ON public.lists USING btree (created_at);


--
-- Name: idx_lists_name; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_lists_name ON public.lists USING btree (name);


--
-- Name: idx_lists_optin; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_lists_optin ON public.lists USING btree (optin);


--
-- Name: idx_lists_status; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_lists_status ON public.lists USING btree (status);


--
-- Name: idx_lists_type; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_lists_type ON public.lists USING btree (type);


--
-- Name: idx_lists_updated_at; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_lists_updated_at ON public.lists USING btree (updated_at);


--
-- Name: idx_media_filename; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_media_filename ON public.media USING btree (provider, filename);


--
-- Name: idx_roles; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE UNIQUE INDEX idx_roles ON public.roles USING btree (parent_id, list_id);


--
-- Name: idx_roles_name; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE UNIQUE INDEX idx_roles_name ON public.roles USING btree (type, name) WHERE (name IS NOT NULL);


--
-- Name: idx_sessions; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_sessions ON public.sessions USING btree (id, created_at);


--
-- Name: idx_settings_key; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_settings_key ON public.settings USING btree (key);


--
-- Name: idx_sub_lists_list_id; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_sub_lists_list_id ON public.subscriber_lists USING btree (list_id);


--
-- Name: idx_sub_lists_status; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_sub_lists_status ON public.subscriber_lists USING btree (status);


--
-- Name: idx_sub_lists_sub_id; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_sub_lists_sub_id ON public.subscriber_lists USING btree (subscriber_id);


--
-- Name: idx_subs_created_at; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_subs_created_at ON public.subscribers USING btree (created_at);


--
-- Name: idx_subs_email; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE UNIQUE INDEX idx_subs_email ON public.subscribers USING btree (lower(email));


--
-- Name: idx_subs_id_status; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_subs_id_status ON public.subscribers USING btree (id, status);


--
-- Name: idx_subs_status; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_subs_status ON public.subscribers USING btree (status);


--
-- Name: idx_subs_updated_at; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_subs_updated_at ON public.subscribers USING btree (updated_at);


--
-- Name: idx_views_camp_id; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_views_camp_id ON public.campaign_views USING btree (campaign_id);


--
-- Name: idx_views_date; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_views_date ON public.campaign_views USING btree (created_at);


--
-- Name: idx_views_subscriber_id; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE INDEX idx_views_subscriber_id ON public.campaign_views USING btree (subscriber_id);


--
-- Name: mat_dashboard_charts_idx; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE UNIQUE INDEX mat_dashboard_charts_idx ON public.mat_dashboard_charts USING btree (updated_at);


--
-- Name: mat_dashboard_stats_idx; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE UNIQUE INDEX mat_dashboard_stats_idx ON public.mat_dashboard_counts USING btree (updated_at);


--
-- Name: mat_list_subscriber_stats_idx; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE UNIQUE INDEX mat_list_subscriber_stats_idx ON public.mat_list_subscriber_stats USING btree (list_id, status);


--
-- Name: templates_is_default_idx; Type: INDEX; Schema: public; Owner: listmonk
--

CREATE UNIQUE INDEX templates_is_default_idx ON public.templates USING btree (is_default) WHERE (is_default = true);


--
-- Name: bounces bounces_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.bounces
    ADD CONSTRAINT bounces_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.campaigns(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: bounces bounces_subscriber_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.bounces
    ADD CONSTRAINT bounces_subscriber_id_fkey FOREIGN KEY (subscriber_id) REFERENCES public.subscribers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: campaign_lists campaign_lists_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.campaign_lists
    ADD CONSTRAINT campaign_lists_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.campaigns(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: campaign_lists campaign_lists_list_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.campaign_lists
    ADD CONSTRAINT campaign_lists_list_id_fkey FOREIGN KEY (list_id) REFERENCES public.lists(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: campaign_media campaign_media_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.campaign_media
    ADD CONSTRAINT campaign_media_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.campaigns(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: campaign_media campaign_media_media_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.campaign_media
    ADD CONSTRAINT campaign_media_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.media(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: campaign_views campaign_views_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.campaign_views
    ADD CONSTRAINT campaign_views_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.campaigns(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: campaign_views campaign_views_subscriber_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.campaign_views
    ADD CONSTRAINT campaign_views_subscriber_id_fkey FOREIGN KEY (subscriber_id) REFERENCES public.subscribers(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: campaigns campaigns_archive_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.campaigns
    ADD CONSTRAINT campaigns_archive_template_id_fkey FOREIGN KEY (archive_template_id) REFERENCES public.templates(id) ON DELETE SET NULL;


--
-- Name: campaigns campaigns_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.campaigns
    ADD CONSTRAINT campaigns_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.templates(id) ON DELETE SET NULL;


--
-- Name: link_clicks link_clicks_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.link_clicks
    ADD CONSTRAINT link_clicks_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.campaigns(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: link_clicks link_clicks_link_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.link_clicks
    ADD CONSTRAINT link_clicks_link_id_fkey FOREIGN KEY (link_id) REFERENCES public.links(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: link_clicks link_clicks_subscriber_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.link_clicks
    ADD CONSTRAINT link_clicks_subscriber_id_fkey FOREIGN KEY (subscriber_id) REFERENCES public.subscribers(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: roles roles_list_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_list_id_fkey FOREIGN KEY (list_id) REFERENCES public.lists(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: roles roles_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.roles(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: subscriber_lists subscriber_lists_list_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.subscriber_lists
    ADD CONSTRAINT subscriber_lists_list_id_fkey FOREIGN KEY (list_id) REFERENCES public.lists(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: subscriber_lists subscriber_lists_subscriber_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.subscriber_lists
    ADD CONSTRAINT subscriber_lists_subscriber_id_fkey FOREIGN KEY (subscriber_id) REFERENCES public.subscribers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users users_list_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_list_role_id_fkey FOREIGN KEY (list_role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: users users_user_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: listmonk
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_role_id_fkey FOREIGN KEY (user_role_id) REFERENCES public.roles(id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--


