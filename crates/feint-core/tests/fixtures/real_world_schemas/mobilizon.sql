--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4 (Debian 16.4-1.pgdg110+2)
-- Dumped by pg_dump version 16.4 (Debian 16.4-1.pgdg110+2)

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
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tiger;


--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tiger_data;


--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA topology;


--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: actor_openness; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.actor_openness AS ENUM (
    'invite_only',
    'moderated',
    'open'
);


--
-- Name: actor_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.actor_type AS ENUM (
    'Person',
    'Application',
    'Group',
    'Organization',
    'Service'
);


--
-- Name: actor_visibility; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.actor_visibility AS ENUM (
    'public',
    'unlisted',
    'restricted',
    'private'
);


--
-- Name: comment_visibility; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.comment_visibility AS ENUM (
    'public',
    'unlisted',
    'private',
    'moderated',
    'invite'
);


--
-- Name: event_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.event_status AS ENUM (
    'tentative',
    'confirmed',
    'cancelled'
);


--
-- Name: event_visibility; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.event_visibility AS ENUM (
    'public',
    'unlisted',
    'restricted',
    'private'
);


--
-- Name: join_options; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.join_options AS ENUM (
    'free',
    'restricted',
    'invite',
    'external'
);


--
-- Name: member_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.member_role AS ENUM (
    'invited',
    'not_approved',
    'member',
    'moderator',
    'administrator',
    'creator',
    'rejected'
);


--
-- Name: oban_job_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.oban_job_state AS ENUM (
    'available',
    'suspended',
    'scheduled',
    'executing',
    'retryable',
    'completed',
    'discarded',
    'cancelled'
);


--
-- Name: participant_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.participant_role AS ENUM (
    'not_approved',
    'not_confirmed',
    'rejected',
    'participant',
    'moderator',
    'administrator',
    'creator'
);


--
-- Name: post_visibility; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.post_visibility AS ENUM (
    'public',
    'unlisted',
    'restricted',
    'private'
);


--
-- Name: report_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.report_status AS ENUM (
    'open',
    'closed',
    'resolved'
);


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role AS ENUM (
    'administrator',
    'moderator',
    'user',
    'pending'
);


--
-- Name: f_unaccent(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.f_unaccent(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
SELECT public.unaccent('public.unaccent', $1)
$_$;


--
-- Name: refresh_instances(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.refresh_instances() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  REFRESH MATERIALIZED VIEW instances;
  RETURN NULL;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: actors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.actors (
    id bigint NOT NULL,
    name character varying(255),
    domain character varying(255),
    preferred_username character varying(255) NOT NULL,
    summary text,
    keys text,
    suspended boolean DEFAULT false NOT NULL,
    url character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    inbox_url character varying(255),
    outbox_url character varying(255),
    following_url character varying(255),
    followers_url character varying(255),
    shared_inbox_url character varying(255) DEFAULT NULL::character varying,
    type public.actor_type,
    manually_approves_followers boolean DEFAULT false,
    user_id bigint,
    openness public.actor_openness DEFAULT 'moderated'::public.actor_openness,
    visibility public.actor_visibility DEFAULT 'private'::public.actor_visibility,
    avatar jsonb,
    banner jsonb,
    last_refreshed_at timestamp(0) without time zone,
    members_url character varying(255),
    resources_url character varying(255),
    todos_url character varying(255),
    posts_url character varying(255),
    events_url character varying(255),
    discussions_url character varying(255),
    physical_address_id bigint,
    allow_see_participants boolean DEFAULT false NOT NULL
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.actors.id;


--
-- Name: activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activities (
    id bigint NOT NULL,
    priority integer NOT NULL,
    type character varying(255) NOT NULL,
    author_id bigint NOT NULL,
    group_id bigint NOT NULL,
    subject character varying(255) NOT NULL,
    subject_params jsonb NOT NULL,
    message character varying(255),
    message_params jsonb,
    object_type character varying(255),
    object_id character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activities_id_seq OWNED BY public.activities.id;


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id bigint NOT NULL,
    description text,
    country character varying(255),
    locality character varying(255),
    region character varying(255),
    postal_code character varying(255),
    street text,
    geom public.geometry,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    url character varying(255) NOT NULL,
    origin_id character varying(255),
    type character varying(255),
    timezone character varying(255)
);


--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;


--
-- Name: admin_action_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_action_logs (
    id bigint NOT NULL,
    action character varying(255) NOT NULL,
    target_type character varying(255) NOT NULL,
    target_id integer NOT NULL,
    changes jsonb,
    actor_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: admin_action_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_action_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_action_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_action_logs_id_seq OWNED BY public.admin_action_logs.id;


--
-- Name: admin_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_settings (
    id bigint NOT NULL,
    "group" character varying(255),
    name character varying(255),
    value text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: admin_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_settings_id_seq OWNED BY public.admin_settings.id;


--
-- Name: admin_settings_medias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_settings_medias (
    id bigint NOT NULL,
    "group" character varying(255),
    name character varying(255),
    media_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: admin_settings_medias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_settings_medias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_settings_medias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_settings_medias_id_seq OWNED BY public.admin_settings_medias.id;


--
-- Name: application_device_activation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_device_activation (
    id bigint NOT NULL,
    user_code character varying(255),
    device_code character varying(255),
    scope character varying(255),
    expires_in integer,
    status character varying(255) DEFAULT 'pending'::character varying,
    user_id bigint,
    application_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: application_device_activation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.application_device_activation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: application_device_activation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.application_device_activation_id_seq OWNED BY public.application_device_activation.id;


--
-- Name: application_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    application_id bigint NOT NULL,
    authorization_code character varying(255),
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    scope character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: application_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.application_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: application_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.application_tokens_id_seq OWNED BY public.application_tokens.id;


--
-- Name: applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.applications (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    client_id character varying(255) NOT NULL,
    client_secret character varying(255) NOT NULL,
    redirect_uris character varying(255)[] NOT NULL,
    scope character varying(255),
    website character varying(255),
    owner_type character varying(255),
    owner_id integer,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.applications_id_seq OWNED BY public.applications.id;


--
-- Name: bots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bots (
    id bigint NOT NULL,
    source text NOT NULL,
    type character varying(255) DEFAULT 'ics'::character varying,
    actor_id bigint NOT NULL,
    user_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: bots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bots_id_seq OWNED BY public.bots.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id bigint NOT NULL,
    url character varying(255),
    text text,
    actor_id bigint,
    event_id bigint,
    in_reply_to_comment_id bigint,
    origin_comment_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    local boolean DEFAULT true NOT NULL,
    uuid uuid,
    attributed_to_id bigint,
    visibility public.comment_visibility,
    deleted_at timestamp(0) without time zone,
    edits integer DEFAULT 0,
    discussion_id uuid,
    published_at timestamp(0) without time zone,
    is_announcement boolean DEFAULT false NOT NULL,
    language character varying(255) DEFAULT 'und'::character varying,
    conversation_id bigint
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: comments_medias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments_medias (
    comment_id bigint NOT NULL,
    media_id bigint NOT NULL
);


--
-- Name: comments_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments_tags (
    comment_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


--
-- Name: conversation_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversation_participants (
    id bigint NOT NULL,
    conversation_id bigint NOT NULL,
    actor_id bigint NOT NULL,
    unread boolean,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: conversation_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.conversation_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conversation_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.conversation_participants_id_seq OWNED BY public.conversation_participants.id;


--
-- Name: conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversations (
    id bigint NOT NULL,
    event_id bigint,
    origin_comment_id bigint NOT NULL,
    last_comment_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.conversations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.conversations_id_seq OWNED BY public.conversations.id;


--
-- Name: discussions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.discussions (
    title character varying(255),
    slug character varying(255),
    actor_id bigint NOT NULL,
    creator_id bigint,
    last_comment_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    id uuid NOT NULL,
    url character varying(255) NOT NULL
);


--
-- Name: event_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_contacts (
    event_id bigint NOT NULL,
    actor_id bigint NOT NULL
);


--
-- Name: event_search; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_search (
    id bigint NOT NULL,
    title text NOT NULL,
    document tsvector
);


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id bigint NOT NULL,
    title text NOT NULL,
    description text,
    organizer_actor_id bigint,
    physical_address_id bigint,
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    url character varying(255) DEFAULT 'https://'::character varying NOT NULL,
    local boolean DEFAULT true NOT NULL,
    uuid uuid,
    attributed_to_id bigint,
    online_address text,
    phone_address text,
    visibility public.event_visibility DEFAULT 'public'::public.event_visibility NOT NULL,
    status public.event_status,
    join_options public.join_options DEFAULT 'free'::public.join_options NOT NULL,
    begins_on timestamp(0) without time zone,
    ends_on timestamp(0) without time zone,
    publish_at timestamp(0) without time zone,
    category text,
    slug text,
    picture_id bigint,
    options jsonb,
    draft boolean DEFAULT false,
    participant_stats jsonb,
    metadata jsonb,
    language character varying(255) DEFAULT 'und'::character varying,
    external_participation_url character varying(255)
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: events_medias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events_medias (
    event_id bigint NOT NULL,
    media_id bigint NOT NULL
);


--
-- Name: events_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events_tags (
    event_id bigint,
    tag_id bigint
);


--
-- Name: exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exports (
    id bigint NOT NULL,
    file_path character varying(255),
    file_size integer,
    file_name character varying(255),
    type character varying(255),
    reference character varying(255),
    format character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: exports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exports_id_seq OWNED BY public.exports.id;


--
-- Name: feed_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feed_tokens (
    token uuid NOT NULL,
    actor_id bigint,
    user_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: followers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.followers (
    approved boolean DEFAULT false,
    actor_id bigint,
    target_actor_id bigint,
    id uuid NOT NULL,
    url character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    notify boolean DEFAULT true
);


--
-- Name: guardian_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guardian_tokens (
    jti character varying(255) NOT NULL,
    aud character varying(255) NOT NULL,
    typ character varying(255),
    iss character varying(255),
    sub character varying(255),
    exp bigint,
    jwt text,
    claims jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: instance_actors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instance_actors (
    id bigint NOT NULL,
    domain character varying(255),
    instance_name character varying(255),
    instance_description text,
    software character varying(255),
    software_version character varying(255),
    actor_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: instance_actors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.instance_actors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instance_actors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.instance_actors_id_seq OWNED BY public.instance_actors.id;


--
-- Name: medias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.medias (
    id bigint NOT NULL,
    file jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    actor_id bigint NOT NULL,
    metadata jsonb,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports (
    id bigint NOT NULL,
    content text,
    status public.report_status DEFAULT 'open'::public.report_status NOT NULL,
    url character varying(255) NOT NULL,
    reported_id bigint,
    reporter_id bigint,
    manager_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    local boolean DEFAULT true NOT NULL
);


--
-- Name: instances; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.instances AS
 SELECT a.domain,
    count(DISTINCT p.id) AS person_count,
    count(DISTINCT g.id) AS group_count,
    count(DISTINCT e.id) AS event_count,
    count(f1.id) AS followers_count,
    count(f2.id) AS followings_count,
    count(r.id) AS reports_count,
    sum(COALESCE(((m.file ->> 'size'::text))::integer, 0)) AS media_size
   FROM (((((((public.actors a
     LEFT JOIN public.actors p ON (((a.id = p.id) AND (p.type = 'Person'::public.actor_type))))
     LEFT JOIN public.actors g ON (((a.id = g.id) AND (g.type = 'Group'::public.actor_type))))
     LEFT JOIN public.events e ON ((a.id = e.organizer_actor_id)))
     LEFT JOIN public.followers f1 ON ((a.id = f1.actor_id)))
     LEFT JOIN public.followers f2 ON ((a.id = f2.target_actor_id)))
     LEFT JOIN public.reports r ON ((r.reported_id = a.id)))
     LEFT JOIN public.medias m ON ((m.actor_id = a.id)))
  WHERE (a.domain IS NOT NULL)
  GROUP BY a.domain
  WITH NO DATA;


--
-- Name: invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invitations (
    id bigint NOT NULL,
    label character varying(255) DEFAULT ''::character varying NOT NULL,
    token character varying(255) DEFAULT gen_random_uuid() NOT NULL,
    group_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invitations_id_seq OWNED BY public.invitations.id;


--
-- Name: members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members (
    actor_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    parent_id bigint,
    role public.member_role DEFAULT 'member'::public.member_role,
    id uuid NOT NULL,
    url character varying(255) NOT NULL,
    metadata jsonb,
    invited_by_id bigint,
    member_since timestamp(0) without time zone
);


--
-- Name: mentions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mentions (
    id bigint NOT NULL,
    silent boolean DEFAULT false NOT NULL,
    actor_id bigint NOT NULL,
    event_id bigint,
    comment_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: mentions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mentions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mentions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mentions_id_seq OWNED BY public.mentions.id;


--
-- Name: oban_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oban_jobs (
    id bigint NOT NULL,
    state public.oban_job_state DEFAULT 'available'::public.oban_job_state NOT NULL,
    queue text DEFAULT 'default'::text NOT NULL,
    worker text NOT NULL,
    args jsonb DEFAULT '{}'::jsonb NOT NULL,
    errors jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
    attempt integer DEFAULT 0 NOT NULL,
    max_attempts integer DEFAULT 20 NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    scheduled_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    attempted_at timestamp without time zone,
    completed_at timestamp without time zone,
    attempted_by text[],
    discarded_at timestamp without time zone,
    priority integer DEFAULT 0 NOT NULL,
    tags text[] DEFAULT ARRAY[]::text[],
    meta jsonb DEFAULT '{}'::jsonb,
    cancelled_at timestamp without time zone,
    CONSTRAINT attempt_range CHECK (((attempt >= 0) AND (attempt <= max_attempts))),
    CONSTRAINT positive_max_attempts CHECK ((max_attempts > 0)),
    CONSTRAINT queue_length CHECK (((char_length(queue) > 0) AND (char_length(queue) < 128))),
    CONSTRAINT worker_length CHECK (((char_length(worker) > 0) AND (char_length(worker) < 128)))
);


--
-- Name: TABLE oban_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.oban_jobs IS '14';


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oban_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oban_jobs_id_seq OWNED BY public.oban_jobs.id;


--
-- Name: oban_peers; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.oban_peers (
    name text NOT NULL,
    node text NOT NULL,
    started_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


--
-- Name: participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.participants (
    event_id bigint NOT NULL,
    actor_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    role public.participant_role DEFAULT 'participant'::public.participant_role,
    id uuid NOT NULL,
    url character varying(255) NOT NULL,
    metadata jsonb,
    code character varying(255)
);


--
-- Name: pictures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pictures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pictures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pictures_id_seq OWNED BY public.medias.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id uuid NOT NULL,
    title character varying(255),
    slug character varying(255),
    url character varying(255),
    body text,
    draft boolean DEFAULT false NOT NULL,
    local boolean DEFAULT true NOT NULL,
    visibility public.post_visibility DEFAULT 'public'::public.post_visibility,
    publish_at timestamp(0) without time zone,
    author_id bigint,
    attributed_to_id bigint,
    picture_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    language character varying(255) DEFAULT 'und'::character varying
);


--
-- Name: posts_medias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts_medias (
    post_id uuid NOT NULL,
    media_id bigint NOT NULL
);


--
-- Name: posts_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts_tags (
    post_id uuid NOT NULL,
    tag_id bigint NOT NULL
);


--
-- Name: report_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_notes (
    id bigint NOT NULL,
    content text NOT NULL,
    moderator_id bigint,
    report_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: report_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.report_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.report_notes_id_seq OWNED BY public.report_notes.id;


--
-- Name: reports_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports_comments (
    report_id bigint NOT NULL,
    comment_id bigint NOT NULL
);


--
-- Name: reports_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports_events (
    report_id bigint NOT NULL,
    event_id bigint NOT NULL
);


--
-- Name: reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reports_id_seq OWNED BY public.reports.id;


--
-- Name: resource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource (
    id uuid NOT NULL,
    title character varying(255) NOT NULL,
    url character varying(255) NOT NULL,
    type integer NOT NULL,
    summary text,
    resource_url character varying(255),
    metadata jsonb,
    path character varying(255) NOT NULL,
    parent_id uuid,
    actor_id bigint NOT NULL,
    creator_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    local boolean DEFAULT true,
    published_at timestamp(0) without time zone
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id bigint NOT NULL,
    title text NOT NULL,
    subtitle text,
    short_abstract text,
    long_abstract text,
    language character varying(255),
    slides_url text,
    videos_urls text,
    audios_urls text,
    event_id bigint NOT NULL,
    track_id bigint,
    speaker_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    begins_on timestamp(0) without time zone,
    ends_on timestamp(0) without time zone
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: shares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shares (
    id bigint NOT NULL,
    uri character varying(255) NOT NULL,
    actor_id bigint NOT NULL,
    owner_actor_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: shares_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shares_id_seq OWNED BY public.shares.id;


--
-- Name: tag_relations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_relations (
    tag_id bigint NOT NULL,
    link_id bigint NOT NULL,
    weight integer DEFAULT 1 NOT NULL,
    CONSTRAINT no_self_loops_check CHECK ((tag_id <> link_id))
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    title character varying(255),
    slug character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: todo_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.todo_lists (
    id uuid NOT NULL,
    title character varying(255),
    url character varying(255),
    actor_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    local boolean DEFAULT true,
    published_at timestamp(0) without time zone
);


--
-- Name: todos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.todos (
    id uuid NOT NULL,
    title character varying(255),
    url character varying(255),
    status boolean DEFAULT false NOT NULL,
    due_date timestamp(0) without time zone,
    creator_id bigint NOT NULL,
    assigned_to_id bigint,
    todo_list_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    local boolean DEFAULT true,
    published_at timestamp(0) without time zone
);


--
-- Name: tombstones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tombstones (
    id bigint NOT NULL,
    uri character varying(255),
    actor_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: tombstones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tombstones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tombstones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tombstones_id_seq OWNED BY public.tombstones.id;


--
-- Name: tracks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tracks (
    id bigint NOT NULL,
    name text NOT NULL,
    description text,
    color character varying(255),
    event_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: tracks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tracks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tracks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tracks_id_seq OWNED BY public.tracks.id;


--
-- Name: user_activity_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_activity_settings (
    id bigint NOT NULL,
    key character varying(255),
    method character varying(255) NOT NULL,
    enabled boolean NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: user_activity_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_activity_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_activity_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_activity_settings_id_seq OWNED BY public.user_activity_settings.id;


--
-- Name: user_push_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_push_subscriptions (
    id uuid NOT NULL,
    user_id bigint NOT NULL,
    digest text NOT NULL,
    endpoint character varying(255) NOT NULL,
    auth character varying(255) NOT NULL,
    p256dh character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: user_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_settings (
    timezone character varying(255),
    notification_on_day boolean,
    notification_each_week boolean,
    notification_before_event boolean,
    user_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    notification_pending_participation integer DEFAULT 10,
    notification_pending_membership integer DEFAULT 10,
    location jsonb,
    group_notifications integer DEFAULT 10 NOT NULL,
    last_notification_sent timestamp(0) without time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    confirmed_at timestamp(0) without time zone,
    confirmation_sent_at timestamp(0) without time zone,
    confirmation_token character varying(255),
    reset_password_sent_at timestamp(0) without time zone,
    reset_password_token character varying(255),
    default_actor_id integer,
    role public.user_role DEFAULT 'user'::public.user_role,
    locale character varying(255) DEFAULT 'en'::character varying,
    unconfirmed_email character varying(255),
    disabled boolean DEFAULT false NOT NULL,
    provider character varying(255),
    last_sign_in_at timestamp(0) without time zone,
    last_sign_in_ip character varying(255),
    current_sign_in_ip character varying(255),
    current_sign_in_at timestamp(0) without time zone,
    moderation character varying(255) DEFAULT ''::character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: activities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities ALTER COLUMN id SET DEFAULT nextval('public.activities_id_seq'::regclass);


--
-- Name: actors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actors ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);


--
-- Name: admin_action_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_action_logs ALTER COLUMN id SET DEFAULT nextval('public.admin_action_logs_id_seq'::regclass);


--
-- Name: admin_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_settings ALTER COLUMN id SET DEFAULT nextval('public.admin_settings_id_seq'::regclass);


--
-- Name: admin_settings_medias id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_settings_medias ALTER COLUMN id SET DEFAULT nextval('public.admin_settings_medias_id_seq'::regclass);


--
-- Name: application_device_activation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_device_activation ALTER COLUMN id SET DEFAULT nextval('public.application_device_activation_id_seq'::regclass);


--
-- Name: application_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_tokens ALTER COLUMN id SET DEFAULT nextval('public.application_tokens_id_seq'::regclass);


--
-- Name: applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.applications ALTER COLUMN id SET DEFAULT nextval('public.applications_id_seq'::regclass);


--
-- Name: bots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bots ALTER COLUMN id SET DEFAULT nextval('public.bots_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: conversation_participants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_participants ALTER COLUMN id SET DEFAULT nextval('public.conversation_participants_id_seq'::regclass);


--
-- Name: conversations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations ALTER COLUMN id SET DEFAULT nextval('public.conversations_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: exports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exports ALTER COLUMN id SET DEFAULT nextval('public.exports_id_seq'::regclass);


--
-- Name: instance_actors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instance_actors ALTER COLUMN id SET DEFAULT nextval('public.instance_actors_id_seq'::regclass);


--
-- Name: invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations ALTER COLUMN id SET DEFAULT nextval('public.invitations_id_seq'::regclass);


--
-- Name: medias id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medias ALTER COLUMN id SET DEFAULT nextval('public.pictures_id_seq'::regclass);


--
-- Name: mentions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions ALTER COLUMN id SET DEFAULT nextval('public.mentions_id_seq'::regclass);


--
-- Name: oban_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_jobs ALTER COLUMN id SET DEFAULT nextval('public.oban_jobs_id_seq'::regclass);


--
-- Name: report_notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_notes ALTER COLUMN id SET DEFAULT nextval('public.report_notes_id_seq'::regclass);


--
-- Name: reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports ALTER COLUMN id SET DEFAULT nextval('public.reports_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: shares id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares ALTER COLUMN id SET DEFAULT nextval('public.shares_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: tombstones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tombstones ALTER COLUMN id SET DEFAULT nextval('public.tombstones_id_seq'::regclass);


--
-- Name: tracks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracks ALTER COLUMN id SET DEFAULT nextval('public.tracks_id_seq'::regclass);


--
-- Name: user_activity_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_activity_settings ALTER COLUMN id SET DEFAULT nextval('public.user_activity_settings_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: actors actors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actors
    ADD CONSTRAINT actors_pkey PRIMARY KEY (id);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: admin_action_logs admin_action_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_action_logs
    ADD CONSTRAINT admin_action_logs_pkey PRIMARY KEY (id);


--
-- Name: admin_settings_medias admin_settings_medias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_settings_medias
    ADD CONSTRAINT admin_settings_medias_pkey PRIMARY KEY (id);


--
-- Name: admin_settings admin_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_settings
    ADD CONSTRAINT admin_settings_pkey PRIMARY KEY (id);


--
-- Name: application_device_activation application_device_activation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_device_activation
    ADD CONSTRAINT application_device_activation_pkey PRIMARY KEY (id);


--
-- Name: application_tokens application_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_tokens
    ADD CONSTRAINT application_tokens_pkey PRIMARY KEY (id);


--
-- Name: applications applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: bots bots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bots
    ADD CONSTRAINT bots_pkey PRIMARY KEY (id);


--
-- Name: comments_medias comments_medias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments_medias
    ADD CONSTRAINT comments_medias_pkey PRIMARY KEY (comment_id, media_id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: comments_tags comments_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments_tags
    ADD CONSTRAINT comments_tags_pkey PRIMARY KEY (comment_id, tag_id);


--
-- Name: conversation_participants conversation_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_participants
    ADD CONSTRAINT conversation_participants_pkey PRIMARY KEY (id);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: discussions discussions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussions
    ADD CONSTRAINT discussions_pkey PRIMARY KEY (id);


--
-- Name: event_contacts event_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_contacts
    ADD CONSTRAINT event_contacts_pkey PRIMARY KEY (event_id, actor_id);


--
-- Name: event_search event_search_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_search
    ADD CONSTRAINT event_search_pkey PRIMARY KEY (id);


--
-- Name: events_medias events_medias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events_medias
    ADD CONSTRAINT events_medias_pkey PRIMARY KEY (event_id, media_id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: exports exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exports
    ADD CONSTRAINT exports_pkey PRIMARY KEY (id);


--
-- Name: feed_tokens feed_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_tokens
    ADD CONSTRAINT feed_tokens_pkey PRIMARY KEY (token);


--
-- Name: followers followers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.followers
    ADD CONSTRAINT followers_pkey PRIMARY KEY (id);


--
-- Name: guardian_tokens guardian_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guardian_tokens
    ADD CONSTRAINT guardian_tokens_pkey PRIMARY KEY (jti, aud);


--
-- Name: instance_actors instance_actors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instance_actors
    ADD CONSTRAINT instance_actors_pkey PRIMARY KEY (id);


--
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: members members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: mentions mentions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT mentions_pkey PRIMARY KEY (id);


--
-- Name: oban_jobs non_negative_priority; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.oban_jobs
    ADD CONSTRAINT non_negative_priority CHECK ((priority >= 0)) NOT VALID;


--
-- Name: oban_jobs oban_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_jobs
    ADD CONSTRAINT oban_jobs_pkey PRIMARY KEY (id);


--
-- Name: oban_peers oban_peers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_peers
    ADD CONSTRAINT oban_peers_pkey PRIMARY KEY (name);


--
-- Name: participants participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_pkey PRIMARY KEY (id);


--
-- Name: medias pictures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medias
    ADD CONSTRAINT pictures_pkey PRIMARY KEY (id);


--
-- Name: posts_medias posts_medias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts_medias
    ADD CONSTRAINT posts_medias_pkey PRIMARY KEY (post_id, media_id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: posts_tags posts_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts_tags
    ADD CONSTRAINT posts_tags_pkey PRIMARY KEY (post_id, tag_id);


--
-- Name: report_notes report_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_notes
    ADD CONSTRAINT report_notes_pkey PRIMARY KEY (id);


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: resource resource_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource
    ADD CONSTRAINT resource_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: shares shares_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: tag_relations tag_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_relations
    ADD CONSTRAINT tag_relations_pkey PRIMARY KEY (tag_id, link_id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: todo_lists todo_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.todo_lists
    ADD CONSTRAINT todo_lists_pkey PRIMARY KEY (id);


--
-- Name: todos todos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.todos
    ADD CONSTRAINT todos_pkey PRIMARY KEY (id);


--
-- Name: tombstones tombstones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tombstones
    ADD CONSTRAINT tombstones_pkey PRIMARY KEY (id);


--
-- Name: tracks tracks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracks
    ADD CONSTRAINT tracks_pkey PRIMARY KEY (id);


--
-- Name: user_activity_settings user_activity_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_activity_settings
    ADD CONSTRAINT user_activity_settings_pkey PRIMARY KEY (id);


--
-- Name: user_push_subscriptions user_push_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_push_subscriptions
    ADD CONSTRAINT user_push_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: user_settings user_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_pkey PRIMARY KEY (user_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: activity_filter; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activity_filter ON public.activities USING btree (author_id, type);


--
-- Name: activity_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activity_group_id ON public.activities USING btree (group_id);


--
-- Name: actor_name_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX actor_name_trigram ON public.actors USING gin (public.f_unaccent((name)::text) public.gin_trgm_ops);


--
-- Name: actor_preferred_username_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX actor_preferred_username_trigram ON public.actors USING gin (public.f_unaccent((preferred_username)::text) public.gin_trgm_ops);


--
-- Name: actors_preferred_username_domain_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX actors_preferred_username_domain_type_index ON public.actors USING btree (preferred_username, domain, type);


--
-- Name: actors_url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX actors_url_index ON public.actors USING btree (url);


--
-- Name: addresses_origin_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX addresses_origin_id_index ON public.addresses USING btree (origin_id);


--
-- Name: addresses_url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX addresses_url_index ON public.addresses USING btree (url);


--
-- Name: admin_settings_group_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX admin_settings_group_name_index ON public.admin_settings USING btree ("group", name);


--
-- Name: admin_settings_medias_group_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX admin_settings_medias_group_name_index ON public.admin_settings_medias USING btree ("group", name);


--
-- Name: application_tokens_user_id_application_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX application_tokens_user_id_application_id_index ON public.application_tokens USING btree (user_id, application_id);


--
-- Name: applications_owner_id_owner_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX applications_owner_id_owner_type_index ON public.applications USING btree (owner_id, owner_type);


--
-- Name: comments_url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX comments_url_index ON public.comments USING btree (url);


--
-- Name: event_search_document_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_search_document_index ON public.event_search USING gin (document);


--
-- Name: event_search_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX event_search_id_index ON public.event_search USING btree (id);


--
-- Name: event_search_title_trgm_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_search_title_trgm_index ON public.event_search USING gin (title public.gin_trgm_ops);


--
-- Name: event_title_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX event_title_trigram ON public.events USING gin (public.f_unaccent(title) public.gin_trgm_ops);


--
-- Name: events_organizer_account_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_organizer_account_id_index ON public.events USING btree (organizer_actor_id);


--
-- Name: events_phys_addr_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_phys_addr_id ON public.events USING btree (physical_address_id);


--
-- Name: events_url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX events_url_index ON public.events USING btree (url);


--
-- Name: exports_file_path_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX exports_file_path_index ON public.exports USING btree (file_path);


--
-- Name: followers_actor_target_actor_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX followers_actor_target_actor_unique_index ON public.followers USING btree (actor_id, target_actor_id);


--
-- Name: idx_addresses_geom_x; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_addresses_geom_x ON public.addresses USING btree (public.st_x(geom));


--
-- Name: idx_addresses_geom_y; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_addresses_geom_y ON public.addresses USING btree (public.st_y(geom));


--
-- Name: index_tag_relations_link_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_relations_link_id ON public.tag_relations USING btree (link_id);


--
-- Name: index_tag_relations_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_relations_tag_id ON public.tag_relations USING btree (tag_id);


--
-- Name: index_unique_users_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_unique_users_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_unique_users_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_unique_users_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: instance_actors_domain_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX instance_actors_domain_index ON public.instance_actors USING btree (domain);


--
-- Name: invitations_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX invitations_token_index ON public.invitations USING btree (token);


--
-- Name: medias_uuid_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX medias_uuid_index ON public.medias USING btree (uuid);


--
-- Name: members_account_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX members_account_id_index ON public.members USING btree (actor_id);


--
-- Name: members_actor_parent_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX members_actor_parent_unique_index ON public.members USING btree (actor_id, parent_id);


--
-- Name: members_url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX members_url_index ON public.members USING btree (url);


--
-- Name: mentions_actor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mentions_actor_id_index ON public.mentions USING btree (actor_id);


--
-- Name: oban_jobs_args_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_args_index ON public.oban_jobs USING gin (args);


--
-- Name: oban_jobs_meta_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_meta_index ON public.oban_jobs USING gin (meta);


--
-- Name: oban_jobs_state_cancelled_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_state_cancelled_at_index ON public.oban_jobs USING btree (state, cancelled_at);


--
-- Name: oban_jobs_state_discarded_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_state_discarded_at_index ON public.oban_jobs USING btree (state, discarded_at);


--
-- Name: oban_jobs_state_queue_priority_scheduled_at_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_state_queue_priority_scheduled_at_id_index ON public.oban_jobs USING btree (state, queue, priority, scheduled_at, id);


--
-- Name: participants_actor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX participants_actor_id_index ON public.participants USING btree (actor_id);


--
-- Name: participants_event_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX participants_event_id_index ON public.participants USING btree (event_id);


--
-- Name: participants_metadata_confirmation_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX participants_metadata_confirmation_token_index ON public.participants USING btree (((metadata ->> 'confirmation_token'::text)));


--
-- Name: participants_url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX participants_url_index ON public.participants USING btree (url);


--
-- Name: posts_url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX posts_url_index ON public.posts USING btree (url);


--
-- Name: resource_url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX resource_url_index ON public.resource USING btree (url);


--
-- Name: shares_uri_actor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX shares_uri_actor_id_index ON public.shares USING btree (uri, actor_id);


--
-- Name: tags_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tags_slug_index ON public.tags USING btree (slug);


--
-- Name: todo_lists_url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX todo_lists_url_index ON public.todo_lists USING btree (url);


--
-- Name: todos_url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX todos_url_index ON public.todos USING btree (url);


--
-- Name: tombstones_uri_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tombstones_uri_index ON public.tombstones USING btree (uri);


--
-- Name: user_activity_settings_user_id_key_method_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_activity_settings_user_id_key_method_index ON public.user_activity_settings USING btree (user_id, key, method);


--
-- Name: user_push_subscriptions_user_id_digest_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_push_subscriptions_user_id_digest_index ON public.user_push_subscriptions USING btree (user_id, digest);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: activities activities_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: activities activities_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: actors actors_physical_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actors
    ADD CONSTRAINT actors_physical_address_id_fkey FOREIGN KEY (physical_address_id) REFERENCES public.addresses(id);


--
-- Name: actors actors_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actors
    ADD CONSTRAINT actors_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: admin_action_logs admin_action_logs_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_action_logs
    ADD CONSTRAINT admin_action_logs_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE SET NULL;


--
-- Name: admin_settings_medias admin_settings_medias_media_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_settings_medias
    ADD CONSTRAINT admin_settings_medias_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.medias(id) ON DELETE CASCADE;


--
-- Name: application_device_activation application_device_activation_application_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_device_activation
    ADD CONSTRAINT application_device_activation_application_id_fkey FOREIGN KEY (application_id) REFERENCES public.applications(id) ON DELETE CASCADE;


--
-- Name: application_device_activation application_device_activation_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_device_activation
    ADD CONSTRAINT application_device_activation_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: application_tokens application_tokens_application_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_tokens
    ADD CONSTRAINT application_tokens_application_id_fkey FOREIGN KEY (application_id) REFERENCES public.applications(id) ON DELETE CASCADE;


--
-- Name: application_tokens application_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_tokens
    ADD CONSTRAINT application_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: bots bots_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bots
    ADD CONSTRAINT bots_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: bots bots_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bots
    ADD CONSTRAINT bots_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: comments comments_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_account_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id);


--
-- Name: comments comments_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE SET NULL;


--
-- Name: comments comments_attributed_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_attributed_to_id_fkey FOREIGN KEY (attributed_to_id) REFERENCES public.actors(id);


--
-- Name: comments comments_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: comments comments_discussion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_discussion_id_fkey FOREIGN KEY (discussion_id) REFERENCES public.discussions(id);


--
-- Name: comments comments_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: comments comments_in_reply_to_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_in_reply_to_comment_id_fkey FOREIGN KEY (in_reply_to_comment_id) REFERENCES public.comments(id) ON DELETE SET NULL;


--
-- Name: comments_medias comments_medias_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments_medias
    ADD CONSTRAINT comments_medias_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: comments_medias comments_medias_media_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments_medias
    ADD CONSTRAINT comments_medias_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.medias(id) ON DELETE CASCADE;


--
-- Name: comments comments_origin_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_origin_comment_id_fkey FOREIGN KEY (origin_comment_id) REFERENCES public.comments(id) ON DELETE SET NULL;


--
-- Name: comments_tags comments_tags_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments_tags
    ADD CONSTRAINT comments_tags_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: comments_tags comments_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments_tags
    ADD CONSTRAINT comments_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE SET NULL;


--
-- Name: conversation_participants conversation_participants_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_participants
    ADD CONSTRAINT conversation_participants_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: conversation_participants conversation_participants_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_participants
    ADD CONSTRAINT conversation_participants_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: discussions conversations_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussions
    ADD CONSTRAINT conversations_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: discussions conversations_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussions
    ADD CONSTRAINT conversations_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.actors(id) ON DELETE SET NULL;


--
-- Name: conversations conversations_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: discussions conversations_last_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussions
    ADD CONSTRAINT conversations_last_comment_id_fkey FOREIGN KEY (last_comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: conversations conversations_last_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_last_comment_id_fkey FOREIGN KEY (last_comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: conversations conversations_origin_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_origin_comment_id_fkey FOREIGN KEY (origin_comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: event_contacts event_contacts_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_contacts
    ADD CONSTRAINT event_contacts_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: event_contacts event_contacts_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_contacts
    ADD CONSTRAINT event_contacts_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: event_search event_search_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_search
    ADD CONSTRAINT event_search_id_fkey FOREIGN KEY (id) REFERENCES public.events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: events events_attributed_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_attributed_to_id_fkey FOREIGN KEY (attributed_to_id) REFERENCES public.actors(id);


--
-- Name: events_medias events_medias_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events_medias
    ADD CONSTRAINT events_medias_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: events_medias events_medias_media_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events_medias
    ADD CONSTRAINT events_medias_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.medias(id) ON DELETE CASCADE;


--
-- Name: events events_organizer_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_organizer_actor_id_fkey FOREIGN KEY (organizer_actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: events events_physical_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_physical_address_id_fkey FOREIGN KEY (physical_address_id) REFERENCES public.addresses(id);


--
-- Name: events events_picture_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_picture_id_fkey FOREIGN KEY (picture_id) REFERENCES public.medias(id) ON DELETE SET NULL;


--
-- Name: events_tags events_tags_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events_tags
    ADD CONSTRAINT events_tags_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: events_tags events_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events_tags
    ADD CONSTRAINT events_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: feed_tokens feed_tokens_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_tokens
    ADD CONSTRAINT feed_tokens_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: feed_tokens feed_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_tokens
    ADD CONSTRAINT feed_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: followers followers_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.followers
    ADD CONSTRAINT followers_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: followers followers_target_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.followers
    ADD CONSTRAINT followers_target_actor_id_fkey FOREIGN KEY (target_actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: instance_actors instance_actors_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instance_actors
    ADD CONSTRAINT instance_actors_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: invitations invitations_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: members members_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: members members_invited_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_invited_by_id_fkey FOREIGN KEY (invited_by_id) REFERENCES public.actors(id) ON DELETE SET NULL;


--
-- Name: members members_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: mentions mentions_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT mentions_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: mentions mentions_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT mentions_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: mentions mentions_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT mentions_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: participants participants_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: participants participants_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: medias pictures_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medias
    ADD CONSTRAINT pictures_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: posts posts_attributed_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_attributed_to_id_fkey FOREIGN KEY (attributed_to_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: posts posts_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: posts_medias posts_medias_media_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts_medias
    ADD CONSTRAINT posts_medias_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.medias(id) ON DELETE CASCADE;


--
-- Name: posts_medias posts_medias_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts_medias
    ADD CONSTRAINT posts_medias_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: posts posts_picture_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_picture_id_fkey FOREIGN KEY (picture_id) REFERENCES public.medias(id) ON DELETE SET NULL;


--
-- Name: posts_tags posts_tags_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts_tags
    ADD CONSTRAINT posts_tags_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: posts_tags posts_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts_tags
    ADD CONSTRAINT posts_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: report_notes report_notes_moderator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_notes
    ADD CONSTRAINT report_notes_moderator_id_fkey FOREIGN KEY (moderator_id) REFERENCES public.actors(id) ON DELETE SET NULL;


--
-- Name: report_notes report_notes_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_notes
    ADD CONSTRAINT report_notes_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.reports(id) ON DELETE CASCADE;


--
-- Name: reports_comments reports_comments_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports_comments
    ADD CONSTRAINT reports_comments_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: reports_comments reports_comments_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports_comments
    ADD CONSTRAINT reports_comments_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.reports(id) ON DELETE CASCADE;


--
-- Name: reports_events reports_events_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports_events
    ADD CONSTRAINT reports_events_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: reports_events reports_events_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports_events
    ADD CONSTRAINT reports_events_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.reports(id) ON DELETE CASCADE;


--
-- Name: reports reports_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.actors(id) ON DELETE SET NULL;


--
-- Name: reports reports_reported_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_reported_id_fkey FOREIGN KEY (reported_id) REFERENCES public.actors(id) ON DELETE SET NULL;


--
-- Name: reports reports_reporter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.actors(id) ON DELETE SET NULL;


--
-- Name: resource resource_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource
    ADD CONSTRAINT resource_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: resource resource_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource
    ADD CONSTRAINT resource_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.actors(id) ON DELETE SET NULL;


--
-- Name: resource resource_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource
    ADD CONSTRAINT resource_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.resource(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_speaker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_speaker_id_fkey FOREIGN KEY (speaker_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_track_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_track_id_fkey FOREIGN KEY (track_id) REFERENCES public.tracks(id) ON DELETE CASCADE;


--
-- Name: shares shares_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: shares shares_owner_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_owner_actor_id_fkey FOREIGN KEY (owner_actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: tag_relations tag_relations_link_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_relations
    ADD CONSTRAINT tag_relations_link_id_fkey FOREIGN KEY (link_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: tag_relations tag_relations_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_relations
    ADD CONSTRAINT tag_relations_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: todo_lists todo_lists_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.todo_lists
    ADD CONSTRAINT todo_lists_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: todos todos_assigned_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.todos
    ADD CONSTRAINT todos_assigned_to_id_fkey FOREIGN KEY (assigned_to_id) REFERENCES public.actors(id) ON DELETE SET NULL;


--
-- Name: todos todos_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.todos
    ADD CONSTRAINT todos_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: todos todos_todo_list_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.todos
    ADD CONSTRAINT todos_todo_list_id_fkey FOREIGN KEY (todo_list_id) REFERENCES public.todo_lists(id) ON DELETE CASCADE;


--
-- Name: tombstones tombstones_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tombstones
    ADD CONSTRAINT tombstones_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actors(id) ON DELETE CASCADE;


--
-- Name: tracks tracks_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracks
    ADD CONSTRAINT tracks_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: user_activity_settings user_activity_settings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_activity_settings
    ADD CONSTRAINT user_activity_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_push_subscriptions user_push_subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_push_subscriptions
    ADD CONSTRAINT user_push_subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_settings user_settings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

