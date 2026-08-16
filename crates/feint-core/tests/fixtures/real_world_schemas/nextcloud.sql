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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: oc_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_accounts (
    uid character varying(64) DEFAULT ''::character varying NOT NULL,
    data text DEFAULT ''::text NOT NULL
);


--
-- Name: oc_accounts_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_accounts_data (
    id bigint NOT NULL,
    uid character varying(64) NOT NULL,
    name character varying(64) NOT NULL,
    value character varying(255) DEFAULT ''::character varying
);


--
-- Name: oc_accounts_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_accounts_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_accounts_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_accounts_data_id_seq OWNED BY public.oc_accounts_data.id;


--
-- Name: oc_activity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_activity (
    activity_id bigint NOT NULL,
    "timestamp" integer DEFAULT 0 NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    type character varying(255) DEFAULT NULL::character varying,
    "user" character varying(64) DEFAULT NULL::character varying,
    affecteduser character varying(64) NOT NULL,
    app character varying(32) NOT NULL,
    subject character varying(255) NOT NULL,
    subjectparams text NOT NULL,
    message character varying(255) DEFAULT NULL::character varying,
    messageparams text,
    file character varying(4000) DEFAULT NULL::character varying,
    link character varying(4000) DEFAULT NULL::character varying,
    object_type character varying(255) DEFAULT NULL::character varying,
    object_id bigint DEFAULT 0 NOT NULL
);


--
-- Name: oc_activity_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_activity_activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_activity_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_activity_activity_id_seq OWNED BY public.oc_activity.activity_id;


--
-- Name: oc_activity_mq; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_activity_mq (
    mail_id bigint NOT NULL,
    amq_timestamp integer DEFAULT 0 NOT NULL,
    amq_latest_send integer DEFAULT 0 NOT NULL,
    amq_type character varying(255) NOT NULL,
    amq_affecteduser character varying(64) NOT NULL,
    amq_appid character varying(32) NOT NULL,
    amq_subject character varying(255) NOT NULL,
    amq_subjectparams text,
    object_type character varying(255) DEFAULT NULL::character varying,
    object_id bigint DEFAULT 0 NOT NULL
);


--
-- Name: oc_activity_mq_mail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_activity_mq_mail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_activity_mq_mail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_activity_mq_mail_id_seq OWNED BY public.oc_activity_mq.mail_id;


--
-- Name: oc_addressbookchanges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_addressbookchanges (
    id bigint NOT NULL,
    uri character varying(255) DEFAULT NULL::character varying,
    synctoken integer DEFAULT 1 NOT NULL,
    addressbookid bigint NOT NULL,
    operation smallint NOT NULL,
    created_at integer DEFAULT 0 NOT NULL
);


--
-- Name: oc_addressbookchanges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_addressbookchanges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_addressbookchanges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_addressbookchanges_id_seq OWNED BY public.oc_addressbookchanges.id;


--
-- Name: oc_addressbooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_addressbooks (
    id bigint NOT NULL,
    principaluri character varying(255) DEFAULT NULL::character varying,
    displayname character varying(255) DEFAULT NULL::character varying,
    uri character varying(255) DEFAULT NULL::character varying,
    description character varying(255) DEFAULT NULL::character varying,
    synctoken integer DEFAULT 1 NOT NULL
);


--
-- Name: oc_addressbooks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_addressbooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_addressbooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_addressbooks_id_seq OWNED BY public.oc_addressbooks.id;


--
-- Name: oc_appconfig; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_appconfig (
    appid character varying(32) DEFAULT ''::character varying NOT NULL,
    configkey character varying(64) DEFAULT ''::character varying NOT NULL,
    configvalue text,
    type integer DEFAULT 2 NOT NULL,
    lazy smallint DEFAULT 0 NOT NULL
);


--
-- Name: oc_appconfig_ex; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_appconfig_ex (
    id bigint NOT NULL,
    appid character varying(32) NOT NULL,
    configkey character varying(64) NOT NULL,
    configvalue text,
    sensitive smallint DEFAULT 0 NOT NULL
);


--
-- Name: oc_appconfig_ex_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_appconfig_ex_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_appconfig_ex_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_appconfig_ex_id_seq OWNED BY public.oc_appconfig_ex.id;


--
-- Name: oc_authorized_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_authorized_groups (
    id integer NOT NULL,
    group_id character varying(200) NOT NULL,
    class character varying(200) NOT NULL
);


--
-- Name: oc_authorized_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_authorized_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_authorized_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_authorized_groups_id_seq OWNED BY public.oc_authorized_groups.id;


--
-- Name: oc_authtoken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_authtoken (
    id bigint NOT NULL,
    uid character varying(64) DEFAULT ''::character varying NOT NULL,
    login_name character varying(255) DEFAULT ''::character varying NOT NULL,
    password text,
    name text DEFAULT ''::text NOT NULL,
    token character varying(200) DEFAULT ''::character varying NOT NULL,
    type smallint DEFAULT 0,
    remember smallint DEFAULT 0,
    last_activity integer DEFAULT 0,
    last_check integer DEFAULT 0,
    scope text,
    expires integer,
    private_key text,
    public_key text,
    version smallint DEFAULT 1 NOT NULL,
    password_invalid boolean DEFAULT false,
    password_hash character varying(255) DEFAULT NULL::character varying
);


--
-- Name: oc_authtoken_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_authtoken_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_authtoken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_authtoken_id_seq OWNED BY public.oc_authtoken.id;


--
-- Name: oc_bruteforce_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_bruteforce_attempts (
    id bigint NOT NULL,
    action character varying(64) DEFAULT ''::character varying NOT NULL,
    occurred integer DEFAULT 0 NOT NULL,
    ip character varying(255) DEFAULT ''::character varying NOT NULL,
    subnet character varying(255) DEFAULT ''::character varying NOT NULL,
    metadata character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: oc_bruteforce_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_bruteforce_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_bruteforce_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_bruteforce_attempts_id_seq OWNED BY public.oc_bruteforce_attempts.id;


--
-- Name: oc_calendar_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_calendar_invitations (
    id bigint NOT NULL,
    uid character varying(512) NOT NULL,
    recurrenceid character varying(255) DEFAULT NULL::character varying,
    attendee character varying(255) NOT NULL,
    organizer character varying(255) NOT NULL,
    sequence bigint,
    token character varying(60) NOT NULL,
    expiration bigint NOT NULL
);


--
-- Name: oc_calendar_invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_calendar_invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_calendar_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_calendar_invitations_id_seq OWNED BY public.oc_calendar_invitations.id;


--
-- Name: oc_calendar_reminders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_calendar_reminders (
    id bigint NOT NULL,
    calendar_id bigint NOT NULL,
    object_id bigint NOT NULL,
    is_recurring smallint,
    uid character varying(512) NOT NULL,
    recurrence_id bigint,
    is_recurrence_exception smallint NOT NULL,
    event_hash character varying(255) NOT NULL,
    alarm_hash character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    is_relative smallint NOT NULL,
    notification_date bigint NOT NULL,
    is_repeat_based smallint NOT NULL
);


--
-- Name: oc_calendar_reminders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_calendar_reminders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_calendar_reminders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_calendar_reminders_id_seq OWNED BY public.oc_calendar_reminders.id;


--
-- Name: oc_calendar_resources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_calendar_resources (
    id bigint NOT NULL,
    backend_id character varying(64) DEFAULT NULL::character varying,
    resource_id character varying(64) DEFAULT NULL::character varying,
    email character varying(255) DEFAULT NULL::character varying,
    displayname character varying(255) DEFAULT NULL::character varying,
    group_restrictions character varying(4000) DEFAULT NULL::character varying
);


--
-- Name: oc_calendar_resources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_calendar_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_calendar_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_calendar_resources_id_seq OWNED BY public.oc_calendar_resources.id;


--
-- Name: oc_calendar_resources_md; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_calendar_resources_md (
    id bigint NOT NULL,
    resource_id bigint NOT NULL,
    key character varying(255) NOT NULL,
    value character varying(4000) DEFAULT NULL::character varying
);


--
-- Name: oc_calendar_resources_md_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_calendar_resources_md_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_calendar_resources_md_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_calendar_resources_md_id_seq OWNED BY public.oc_calendar_resources_md.id;


--
-- Name: oc_calendar_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_calendar_rooms (
    id bigint NOT NULL,
    backend_id character varying(64) DEFAULT NULL::character varying,
    resource_id character varying(64) DEFAULT NULL::character varying,
    email character varying(255) DEFAULT NULL::character varying,
    displayname character varying(255) DEFAULT NULL::character varying,
    group_restrictions character varying(4000) DEFAULT NULL::character varying
);


--
-- Name: oc_calendar_rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_calendar_rooms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_calendar_rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_calendar_rooms_id_seq OWNED BY public.oc_calendar_rooms.id;


--
-- Name: oc_calendar_rooms_md; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_calendar_rooms_md (
    id bigint NOT NULL,
    room_id bigint NOT NULL,
    key character varying(255) NOT NULL,
    value character varying(4000) DEFAULT NULL::character varying
);


--
-- Name: oc_calendar_rooms_md_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_calendar_rooms_md_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_calendar_rooms_md_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_calendar_rooms_md_id_seq OWNED BY public.oc_calendar_rooms_md.id;


--
-- Name: oc_calendarchanges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_calendarchanges (
    id bigint NOT NULL,
    uri character varying(255) DEFAULT NULL::character varying,
    synctoken integer DEFAULT 1 NOT NULL,
    calendarid bigint NOT NULL,
    operation smallint NOT NULL,
    calendartype integer DEFAULT 0 NOT NULL,
    created_at integer DEFAULT 0 NOT NULL
);


--
-- Name: oc_calendarchanges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_calendarchanges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_calendarchanges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_calendarchanges_id_seq OWNED BY public.oc_calendarchanges.id;


--
-- Name: oc_calendarobjects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_calendarobjects (
    id bigint NOT NULL,
    calendardata bytea,
    uri character varying(255) DEFAULT NULL::character varying,
    calendarid bigint NOT NULL,
    lastmodified integer,
    etag character varying(32) DEFAULT NULL::character varying,
    size bigint NOT NULL,
    componenttype character varying(8) DEFAULT NULL::character varying,
    firstoccurence bigint,
    lastoccurence bigint,
    uid character varying(512) DEFAULT NULL::character varying,
    classification integer DEFAULT 0,
    calendartype integer DEFAULT 0 NOT NULL,
    deleted_at integer
);


--
-- Name: oc_calendarobjects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_calendarobjects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_calendarobjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_calendarobjects_id_seq OWNED BY public.oc_calendarobjects.id;


--
-- Name: oc_calendarobjects_props; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_calendarobjects_props (
    id bigint NOT NULL,
    calendarid bigint DEFAULT 0 NOT NULL,
    objectid bigint DEFAULT 0 NOT NULL,
    name character varying(64) DEFAULT NULL::character varying,
    parameter character varying(64) DEFAULT NULL::character varying,
    value character varying(255) DEFAULT NULL::character varying,
    calendartype integer DEFAULT 0 NOT NULL
);


--
-- Name: oc_calendarobjects_props_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_calendarobjects_props_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_calendarobjects_props_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_calendarobjects_props_id_seq OWNED BY public.oc_calendarobjects_props.id;


--
-- Name: oc_calendars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_calendars (
    id bigint NOT NULL,
    principaluri character varying(255) DEFAULT NULL::character varying,
    displayname character varying(255) DEFAULT NULL::character varying,
    uri character varying(255) DEFAULT NULL::character varying,
    synctoken integer DEFAULT 1 NOT NULL,
    description character varying(255) DEFAULT NULL::character varying,
    calendarorder integer DEFAULT 0 NOT NULL,
    calendarcolor character varying(255) DEFAULT NULL::character varying,
    timezone text,
    components character varying(64) DEFAULT NULL::character varying,
    transparent smallint DEFAULT 0 NOT NULL,
    deleted_at integer,
    default_alarm_pday integer,
    default_alarm_fday integer
);


--
-- Name: oc_calendars_federated; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_calendars_federated (
    id bigint NOT NULL,
    display_name character varying(255) NOT NULL,
    color character varying(7) DEFAULT NULL::character varying,
    uri character varying(255) NOT NULL,
    principaluri character varying(255) NOT NULL,
    remote_url character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    sync_token integer DEFAULT 0 NOT NULL,
    last_sync bigint,
    shared_by character varying(255) NOT NULL,
    shared_by_display_name character varying(255) NOT NULL,
    components character varying(255) NOT NULL,
    permissions integer NOT NULL,
    state integer DEFAULT 0 NOT NULL
);


--
-- Name: oc_calendars_federated_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_calendars_federated_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_calendars_federated_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_calendars_federated_id_seq OWNED BY public.oc_calendars_federated.id;


--
-- Name: oc_calendars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_calendars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_calendars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_calendars_id_seq OWNED BY public.oc_calendars.id;


--
-- Name: oc_calendarsubscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_calendarsubscriptions (
    id bigint NOT NULL,
    uri character varying(255) DEFAULT NULL::character varying,
    principaluri character varying(255) DEFAULT NULL::character varying,
    displayname character varying(100) DEFAULT NULL::character varying,
    refreshrate character varying(10) DEFAULT NULL::character varying,
    calendarorder integer DEFAULT 0 NOT NULL,
    calendarcolor character varying(255) DEFAULT NULL::character varying,
    striptodos smallint,
    stripalarms smallint,
    stripattachments smallint,
    lastmodified integer,
    synctoken integer DEFAULT 1 NOT NULL,
    source text
);


--
-- Name: oc_calendarsubscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_calendarsubscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_calendarsubscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_calendarsubscriptions_id_seq OWNED BY public.oc_calendarsubscriptions.id;


--
-- Name: oc_cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_cards (
    id bigint NOT NULL,
    addressbookid bigint DEFAULT 0 NOT NULL,
    carddata bytea,
    uri character varying(255) DEFAULT NULL::character varying,
    lastmodified bigint,
    etag character varying(32) DEFAULT NULL::character varying,
    size bigint NOT NULL,
    uid character varying(255) DEFAULT NULL::character varying
);


--
-- Name: oc_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_cards_id_seq OWNED BY public.oc_cards.id;


--
-- Name: oc_cards_properties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_cards_properties (
    id bigint NOT NULL,
    addressbookid bigint DEFAULT 0 NOT NULL,
    cardid bigint DEFAULT 0 NOT NULL,
    name character varying(64) DEFAULT NULL::character varying,
    value character varying(255) DEFAULT NULL::character varying,
    preferred integer DEFAULT 1 NOT NULL
);


--
-- Name: oc_cards_properties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_cards_properties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_cards_properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_cards_properties_id_seq OWNED BY public.oc_cards_properties.id;


--
-- Name: oc_circles_circle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_circles_circle (
    id integer NOT NULL,
    unique_id character varying(31) NOT NULL,
    name character varying(127) NOT NULL,
    display_name character varying(255) DEFAULT ''::character varying,
    sanitized_name character varying(127) DEFAULT ''::character varying,
    instance character varying(255) DEFAULT ''::character varying,
    config integer,
    source integer,
    settings text,
    description text,
    creation timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    contact_addressbook integer,
    contact_groupname character varying(127) DEFAULT NULL::character varying
);


--
-- Name: oc_circles_circle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_circles_circle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_circles_circle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_circles_circle_id_seq OWNED BY public.oc_circles_circle.id;


--
-- Name: oc_circles_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_circles_event (
    token character varying(63) NOT NULL,
    instance character varying(255) NOT NULL,
    event text,
    result text,
    interface integer DEFAULT 0 NOT NULL,
    severity integer,
    retry integer,
    status integer,
    updated timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    creation bigint
);


--
-- Name: oc_circles_member; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_circles_member (
    id integer NOT NULL,
    single_id character varying(31) DEFAULT NULL::character varying,
    circle_id character varying(31) NOT NULL,
    member_id character varying(31) DEFAULT NULL::character varying,
    user_id character varying(127) NOT NULL,
    user_type smallint DEFAULT 1 NOT NULL,
    instance character varying(255) DEFAULT ''::character varying,
    invited_by character varying(31) DEFAULT NULL::character varying,
    level smallint NOT NULL,
    status character varying(15) DEFAULT NULL::character varying,
    note text,
    cached_name character varying(255) DEFAULT ''::character varying,
    cached_update timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    contact_id character varying(127) DEFAULT NULL::character varying,
    contact_meta text,
    joined timestamp(0) without time zone DEFAULT NULL::timestamp without time zone
);


--
-- Name: oc_circles_member_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_circles_member_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_circles_member_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_circles_member_id_seq OWNED BY public.oc_circles_member.id;


--
-- Name: oc_circles_membership; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_circles_membership (
    circle_id character varying(31) NOT NULL,
    single_id character varying(31) NOT NULL,
    level integer NOT NULL,
    inheritance_first character varying(31) NOT NULL,
    inheritance_last character varying(31) NOT NULL,
    inheritance_depth integer NOT NULL,
    inheritance_path text NOT NULL
);


--
-- Name: oc_circles_mount; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_circles_mount (
    id integer NOT NULL,
    mount_id character varying(31) NOT NULL,
    circle_id character varying(31) NOT NULL,
    single_id character varying(31) NOT NULL,
    token character varying(63) DEFAULT NULL::character varying,
    parent integer,
    mountpoint text,
    mountpoint_hash character varying(64) DEFAULT NULL::character varying,
    remote character varying(255) DEFAULT ''::character varying,
    remote_id integer DEFAULT 0 NOT NULL
);


--
-- Name: oc_circles_mount_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_circles_mount_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_circles_mount_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_circles_mount_id_seq OWNED BY public.oc_circles_mount.id;


--
-- Name: oc_circles_mountpoint; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_circles_mountpoint (
    id integer NOT NULL,
    mount_id character varying(31) NOT NULL,
    single_id character varying(31) NOT NULL,
    mountpoint text,
    mountpoint_hash character varying(64) DEFAULT NULL::character varying
);


--
-- Name: oc_circles_mountpoint_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_circles_mountpoint_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_circles_mountpoint_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_circles_mountpoint_id_seq OWNED BY public.oc_circles_mountpoint.id;


--
-- Name: oc_circles_remote; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_circles_remote (
    id integer NOT NULL,
    type character varying(15) DEFAULT 'Unknown'::character varying NOT NULL,
    interface integer DEFAULT 0 NOT NULL,
    uid character varying(20) DEFAULT NULL::character varying,
    instance character varying(127) DEFAULT NULL::character varying,
    href character varying(254) DEFAULT NULL::character varying,
    item text,
    creation timestamp(0) without time zone DEFAULT NULL::timestamp without time zone
);


--
-- Name: oc_circles_remote_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_circles_remote_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_circles_remote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_circles_remote_id_seq OWNED BY public.oc_circles_remote.id;


--
-- Name: oc_circles_share_lock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_circles_share_lock (
    id integer NOT NULL,
    item_id character varying(31) NOT NULL,
    circle_id character varying(31) NOT NULL,
    instance character varying(127) NOT NULL
);


--
-- Name: oc_circles_share_lock_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_circles_share_lock_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_circles_share_lock_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_circles_share_lock_id_seq OWNED BY public.oc_circles_share_lock.id;


--
-- Name: oc_circles_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_circles_token (
    id integer NOT NULL,
    share_id integer,
    circle_id character varying(31) DEFAULT NULL::character varying,
    single_id character varying(31) DEFAULT NULL::character varying,
    member_id character varying(31) DEFAULT NULL::character varying,
    token character varying(31) DEFAULT NULL::character varying,
    password character varying(127) DEFAULT NULL::character varying,
    accepted integer
);


--
-- Name: oc_circles_token_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_circles_token_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_circles_token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_circles_token_id_seq OWNED BY public.oc_circles_token.id;


--
-- Name: oc_collres_accesscache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_collres_accesscache (
    user_id character varying(64) NOT NULL,
    collection_id bigint DEFAULT 0 NOT NULL,
    resource_type character varying(64) DEFAULT ''::character varying NOT NULL,
    resource_id character varying(64) DEFAULT ''::character varying NOT NULL,
    access boolean DEFAULT false
);


--
-- Name: oc_collres_collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_collres_collections (
    id bigint NOT NULL,
    name character varying(64) NOT NULL
);


--
-- Name: oc_collres_collections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_collres_collections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_collres_collections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_collres_collections_id_seq OWNED BY public.oc_collres_collections.id;


--
-- Name: oc_collres_resources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_collres_resources (
    collection_id bigint NOT NULL,
    resource_type character varying(64) NOT NULL,
    resource_id character varying(64) NOT NULL
);


--
-- Name: oc_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_comments (
    id bigint NOT NULL,
    parent_id bigint DEFAULT 0 NOT NULL,
    topmost_parent_id bigint DEFAULT 0 NOT NULL,
    children_count integer DEFAULT 0 NOT NULL,
    actor_type character varying(64) DEFAULT ''::character varying NOT NULL,
    actor_id character varying(64) DEFAULT ''::character varying NOT NULL,
    message text,
    verb character varying(64) DEFAULT NULL::character varying,
    creation_timestamp timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    latest_child_timestamp timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    object_type character varying(64) DEFAULT ''::character varying NOT NULL,
    object_id character varying(64) DEFAULT ''::character varying NOT NULL,
    reference_id character varying(64) DEFAULT NULL::character varying,
    reactions character varying(4000) DEFAULT NULL::character varying,
    expire_date timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    meta_data text DEFAULT ''::text
);


--
-- Name: oc_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_comments_id_seq OWNED BY public.oc_comments.id;


--
-- Name: oc_comments_read_markers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_comments_read_markers (
    user_id character varying(64) DEFAULT ''::character varying NOT NULL,
    object_type character varying(64) DEFAULT ''::character varying NOT NULL,
    object_id character varying(64) DEFAULT ''::character varying NOT NULL,
    marker_datetime timestamp(0) without time zone DEFAULT NULL::timestamp without time zone
);


--
-- Name: oc_dav_absence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_dav_absence (
    id integer NOT NULL,
    user_id character varying(64) NOT NULL,
    first_day character varying(10) NOT NULL,
    last_day character varying(10) NOT NULL,
    status character varying(100) NOT NULL,
    message text NOT NULL,
    replacement_user_id character varying(64) DEFAULT ''::character varying,
    replacement_user_display_name character varying(64) DEFAULT ''::character varying
);


--
-- Name: oc_dav_absence_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_dav_absence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_dav_absence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_dav_absence_id_seq OWNED BY public.oc_dav_absence.id;


--
-- Name: oc_dav_cal_proxy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_dav_cal_proxy (
    id bigint NOT NULL,
    owner_id character varying(64) NOT NULL,
    proxy_id character varying(64) NOT NULL,
    permissions integer
);


--
-- Name: oc_dav_cal_proxy_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_dav_cal_proxy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_dav_cal_proxy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_dav_cal_proxy_id_seq OWNED BY public.oc_dav_cal_proxy.id;


--
-- Name: oc_dav_shares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_dav_shares (
    id bigint NOT NULL,
    principaluri character varying(255) DEFAULT NULL::character varying,
    type character varying(255) DEFAULT NULL::character varying,
    access smallint,
    resourceid bigint NOT NULL,
    publicuri character varying(255) DEFAULT NULL::character varying,
    token character varying(255) DEFAULT NULL::character varying
);


--
-- Name: oc_dav_shares_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_dav_shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_dav_shares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_dav_shares_id_seq OWNED BY public.oc_dav_shares.id;


--
-- Name: oc_direct_edit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_direct_edit (
    id bigint NOT NULL,
    editor_id character varying(64) NOT NULL,
    token character varying(64) NOT NULL,
    file_id bigint NOT NULL,
    user_id character varying(64) DEFAULT NULL::character varying,
    share_id bigint,
    "timestamp" bigint NOT NULL,
    accessed boolean DEFAULT false,
    file_path character varying(4000) DEFAULT NULL::character varying
);


--
-- Name: oc_direct_edit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_direct_edit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_direct_edit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_direct_edit_id_seq OWNED BY public.oc_direct_edit.id;


--
-- Name: oc_directlink; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_directlink (
    id bigint NOT NULL,
    user_id character varying(64) DEFAULT NULL::character varying,
    file_id bigint NOT NULL,
    token character varying(60) DEFAULT NULL::character varying,
    expiration bigint NOT NULL
);


--
-- Name: oc_directlink_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_directlink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_directlink_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_directlink_id_seq OWNED BY public.oc_directlink.id;


--
-- Name: oc_ex_apps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_ex_apps (
    id bigint NOT NULL,
    appid character varying(32) NOT NULL,
    version character varying(32) NOT NULL,
    name character varying(64) NOT NULL,
    daemon_config_name character varying(64) DEFAULT '0'::character varying NOT NULL,
    port smallint NOT NULL,
    secret character varying(256) NOT NULL,
    status json NOT NULL,
    enabled smallint DEFAULT 0 NOT NULL,
    created_time bigint NOT NULL
);


--
-- Name: oc_ex_apps_daemons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_ex_apps_daemons (
    id bigint NOT NULL,
    name character varying(64) NOT NULL,
    display_name character varying(255) NOT NULL,
    accepts_deploy_id character varying(64) NOT NULL,
    protocol character varying(32) NOT NULL,
    host character varying(255) NOT NULL,
    deploy_config json NOT NULL
);


--
-- Name: oc_ex_apps_daemons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_ex_apps_daemons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_ex_apps_daemons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_ex_apps_daemons_id_seq OWNED BY public.oc_ex_apps_daemons.id;


--
-- Name: oc_ex_apps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_ex_apps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_ex_apps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_ex_apps_id_seq OWNED BY public.oc_ex_apps.id;


--
-- Name: oc_ex_apps_routes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_ex_apps_routes (
    id integer NOT NULL,
    appid character varying(32) NOT NULL,
    url character varying(512) NOT NULL,
    verb character varying(64) NOT NULL,
    access_level integer DEFAULT 0 NOT NULL,
    headers_to_exclude character varying(512) DEFAULT NULL::character varying,
    bruteforce_protection character varying(512) DEFAULT NULL::character varying
);


--
-- Name: oc_ex_apps_routes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_ex_apps_routes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_ex_apps_routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_ex_apps_routes_id_seq OWNED BY public.oc_ex_apps_routes.id;


--
-- Name: oc_ex_apps_talk_bots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_ex_apps_talk_bots (
    id bigint NOT NULL,
    appid character varying(32) NOT NULL,
    route character varying(128) NOT NULL,
    secret text NOT NULL,
    created_time bigint DEFAULT 0 NOT NULL
);


--
-- Name: oc_ex_apps_talk_bots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_ex_apps_talk_bots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_ex_apps_talk_bots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_ex_apps_talk_bots_id_seq OWNED BY public.oc_ex_apps_talk_bots.id;


--
-- Name: oc_ex_deploy_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_ex_deploy_options (
    id bigint NOT NULL,
    appid character varying(32) NOT NULL,
    type character varying(32) NOT NULL,
    value json NOT NULL
);


--
-- Name: oc_ex_deploy_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_ex_deploy_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_ex_deploy_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_ex_deploy_options_id_seq OWNED BY public.oc_ex_deploy_options.id;


--
-- Name: oc_ex_occ_commands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_ex_occ_commands (
    id bigint NOT NULL,
    appid character varying(32) NOT NULL,
    name character varying(64) NOT NULL,
    description character varying(255) DEFAULT NULL::character varying,
    hidden smallint DEFAULT 0 NOT NULL,
    arguments json NOT NULL,
    options json NOT NULL,
    usages json NOT NULL,
    execute_handler character varying(410) NOT NULL
);


--
-- Name: oc_ex_occ_commands_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_ex_occ_commands_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_ex_occ_commands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_ex_occ_commands_id_seq OWNED BY public.oc_ex_occ_commands.id;


--
-- Name: oc_ex_settings_forms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_ex_settings_forms (
    id bigint NOT NULL,
    appid character varying(32) NOT NULL,
    formid character varying(64) NOT NULL,
    scheme json NOT NULL
);


--
-- Name: oc_ex_settings_forms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_ex_settings_forms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_ex_settings_forms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_ex_settings_forms_id_seq OWNED BY public.oc_ex_settings_forms.id;


--
-- Name: oc_ex_task_processing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_ex_task_processing (
    id bigint NOT NULL,
    app_id character varying(32) NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    task_type character varying(255) NOT NULL,
    custom_task_type text,
    provider text NOT NULL
);


--
-- Name: oc_ex_task_processing_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_ex_task_processing_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_ex_task_processing_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_ex_task_processing_id_seq OWNED BY public.oc_ex_task_processing.id;


--
-- Name: oc_ex_ui_files_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_ex_ui_files_actions (
    id bigint NOT NULL,
    appid character varying(32) NOT NULL,
    name character varying(64) NOT NULL,
    display_name character varying(64) NOT NULL,
    mime text DEFAULT 'file'::text NOT NULL,
    permissions character varying(255) NOT NULL,
    "order" bigint DEFAULT 0 NOT NULL,
    icon character varying(255) DEFAULT ''::character varying,
    action_handler character varying(64) NOT NULL,
    version character varying(64) DEFAULT '1.0'::character varying NOT NULL
);


--
-- Name: oc_ex_ui_files_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_ex_ui_files_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_ex_ui_files_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_ex_ui_files_actions_id_seq OWNED BY public.oc_ex_ui_files_actions.id;


--
-- Name: oc_ex_ui_scripts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_ex_ui_scripts (
    id bigint NOT NULL,
    appid character varying(32) NOT NULL,
    type character varying(16) NOT NULL,
    name character varying(32) NOT NULL,
    path character varying(410) NOT NULL,
    after_app_id character varying(32) DEFAULT NULL::character varying
);


--
-- Name: oc_ex_ui_scripts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_ex_ui_scripts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_ex_ui_scripts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_ex_ui_scripts_id_seq OWNED BY public.oc_ex_ui_scripts.id;


--
-- Name: oc_ex_ui_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_ex_ui_states (
    id bigint NOT NULL,
    appid character varying(32) NOT NULL,
    type character varying(16) NOT NULL,
    name character varying(32) NOT NULL,
    key character varying(64) NOT NULL,
    value json NOT NULL
);


--
-- Name: oc_ex_ui_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_ex_ui_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_ex_ui_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_ex_ui_states_id_seq OWNED BY public.oc_ex_ui_states.id;


--
-- Name: oc_ex_ui_styles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_ex_ui_styles (
    id bigint NOT NULL,
    appid character varying(32) NOT NULL,
    type character varying(16) NOT NULL,
    name character varying(32) NOT NULL,
    path character varying(410) NOT NULL
);


--
-- Name: oc_ex_ui_styles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_ex_ui_styles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_ex_ui_styles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_ex_ui_styles_id_seq OWNED BY public.oc_ex_ui_styles.id;


--
-- Name: oc_ex_ui_top_menu; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_ex_ui_top_menu (
    id bigint NOT NULL,
    appid character varying(32) NOT NULL,
    name character varying(32) NOT NULL,
    display_name character varying(32) NOT NULL,
    icon character varying(255) DEFAULT ''::character varying,
    admin_required smallint DEFAULT 0 NOT NULL
);


--
-- Name: oc_ex_ui_top_menu_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_ex_ui_top_menu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_ex_ui_top_menu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_ex_ui_top_menu_id_seq OWNED BY public.oc_ex_ui_top_menu.id;


--
-- Name: oc_federated_invites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_federated_invites (
    id bigint NOT NULL,
    user_id character varying(64) NOT NULL,
    recipient_provider character varying(2083) DEFAULT NULL::character varying,
    recipient_user_id character varying(1024) DEFAULT NULL::character varying,
    recipient_name character varying(1024) DEFAULT NULL::character varying,
    recipient_email character varying(320) DEFAULT NULL::character varying,
    token character varying(60) NOT NULL,
    accepted boolean DEFAULT false,
    created_at bigint NOT NULL,
    expired_at bigint,
    accepted_at bigint
);


--
-- Name: oc_federated_invites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_federated_invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_federated_invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_federated_invites_id_seq OWNED BY public.oc_federated_invites.id;


--
-- Name: oc_federated_reshares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_federated_reshares (
    share_id bigint NOT NULL,
    remote_id character varying(255) DEFAULT ''::character varying
);


--
-- Name: oc_file_locks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_file_locks (
    id bigint NOT NULL,
    lock integer DEFAULT 0 NOT NULL,
    key character varying(64) NOT NULL,
    ttl integer DEFAULT '-1'::integer NOT NULL
);


--
-- Name: oc_file_locks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_file_locks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_file_locks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_file_locks_id_seq OWNED BY public.oc_file_locks.id;


--
-- Name: oc_filecache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_filecache (
    fileid bigint NOT NULL,
    storage bigint DEFAULT 0 NOT NULL,
    path character varying(4000) DEFAULT NULL::character varying,
    path_hash character varying(32) DEFAULT ''::character varying NOT NULL,
    parent bigint DEFAULT 0 NOT NULL,
    name character varying(250) DEFAULT NULL::character varying,
    mimetype bigint DEFAULT 0 NOT NULL,
    mimepart bigint DEFAULT 0 NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    mtime bigint DEFAULT 0 NOT NULL,
    storage_mtime bigint DEFAULT 0 NOT NULL,
    encrypted integer DEFAULT 0 NOT NULL,
    unencrypted_size bigint DEFAULT 0 NOT NULL,
    etag character varying(40) DEFAULT NULL::character varying,
    permissions integer DEFAULT 0,
    checksum character varying(255) DEFAULT NULL::character varying
);


--
-- Name: oc_filecache_extended; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_filecache_extended (
    fileid bigint NOT NULL,
    metadata_etag character varying(40) DEFAULT NULL::character varying,
    creation_time bigint DEFAULT 0 NOT NULL,
    upload_time bigint DEFAULT 0 NOT NULL
);


--
-- Name: oc_filecache_fileid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_filecache_fileid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_filecache_fileid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_filecache_fileid_seq OWNED BY public.oc_filecache.fileid;


--
-- Name: oc_files_lock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_files_lock (
    id integer NOT NULL,
    user_id character varying(255) NOT NULL,
    file_id integer NOT NULL,
    token character varying(63) NOT NULL,
    creation bigint NOT NULL,
    type smallint DEFAULT 0 NOT NULL,
    scope smallint DEFAULT 0 NOT NULL,
    ttl integer DEFAULT 0 NOT NULL,
    owner character varying(255) DEFAULT ''::character varying
);


--
-- Name: oc_files_lock_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_files_lock_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_files_lock_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_files_lock_id_seq OWNED BY public.oc_files_lock.id;


--
-- Name: oc_files_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_files_metadata (
    id bigint NOT NULL,
    file_id bigint NOT NULL,
    json text NOT NULL,
    sync_token character varying(15) NOT NULL,
    last_update timestamp(0) without time zone NOT NULL
);


--
-- Name: oc_files_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_files_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_files_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_files_metadata_id_seq OWNED BY public.oc_files_metadata.id;


--
-- Name: oc_files_metadata_index; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_files_metadata_index (
    id bigint NOT NULL,
    file_id bigint NOT NULL,
    meta_key character varying(31) DEFAULT NULL::character varying,
    meta_value_string character varying(63) DEFAULT NULL::character varying,
    meta_value_int bigint
);


--
-- Name: oc_files_metadata_index_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_files_metadata_index_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_files_metadata_index_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_files_metadata_index_id_seq OWNED BY public.oc_files_metadata_index.id;


--
-- Name: oc_files_reminders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_files_reminders (
    id bigint NOT NULL,
    user_id character varying(64) NOT NULL,
    file_id bigint NOT NULL,
    due_date timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    created_at timestamp(0) without time zone NOT NULL,
    notified boolean DEFAULT false
);


--
-- Name: oc_files_reminders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_files_reminders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_files_reminders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_files_reminders_id_seq OWNED BY public.oc_files_reminders.id;


--
-- Name: oc_files_trash; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_files_trash (
    auto_id bigint NOT NULL,
    id character varying(250) DEFAULT ''::character varying NOT NULL,
    "user" character varying(64) DEFAULT ''::character varying NOT NULL,
    "timestamp" character varying(12) DEFAULT ''::character varying NOT NULL,
    location character varying(512) DEFAULT ''::character varying NOT NULL,
    type character varying(4) DEFAULT NULL::character varying,
    mime character varying(255) DEFAULT NULL::character varying,
    deleted_by character varying(64) DEFAULT NULL::character varying
);


--
-- Name: oc_files_trash_auto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_files_trash_auto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_files_trash_auto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_files_trash_auto_id_seq OWNED BY public.oc_files_trash.auto_id;


--
-- Name: oc_files_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_files_versions (
    id bigint NOT NULL,
    file_id bigint NOT NULL,
    "timestamp" bigint NOT NULL,
    size bigint NOT NULL,
    mimetype bigint NOT NULL,
    metadata json NOT NULL
);


--
-- Name: oc_files_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_files_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_files_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_files_versions_id_seq OWNED BY public.oc_files_versions.id;


--
-- Name: oc_flow_checks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_flow_checks (
    id integer NOT NULL,
    class character varying(256) DEFAULT ''::character varying NOT NULL,
    operator character varying(16) DEFAULT ''::character varying NOT NULL,
    value text,
    hash character varying(32) DEFAULT ''::character varying NOT NULL
);


--
-- Name: oc_flow_checks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_flow_checks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_flow_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_flow_checks_id_seq OWNED BY public.oc_flow_checks.id;


--
-- Name: oc_flow_operations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_flow_operations (
    id integer NOT NULL,
    class character varying(256) DEFAULT ''::character varying NOT NULL,
    name character varying(256) DEFAULT ''::character varying,
    checks text,
    operation text,
    entity character varying(256) DEFAULT 'OCA\WorkflowEngine\Entity\File'::character varying NOT NULL,
    events text DEFAULT '[]'::text NOT NULL
);


--
-- Name: oc_flow_operations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_flow_operations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_flow_operations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_flow_operations_id_seq OWNED BY public.oc_flow_operations.id;


--
-- Name: oc_flow_operations_scope; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_flow_operations_scope (
    id bigint NOT NULL,
    operation_id integer DEFAULT 0 NOT NULL,
    type integer DEFAULT 0 NOT NULL,
    value character varying(64) DEFAULT ''::character varying
);


--
-- Name: oc_flow_operations_scope_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_flow_operations_scope_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_flow_operations_scope_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_flow_operations_scope_id_seq OWNED BY public.oc_flow_operations_scope.id;


--
-- Name: oc_group_admin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_group_admin (
    gid character varying(64) DEFAULT ''::character varying NOT NULL,
    uid character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: oc_group_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_group_user (
    gid character varying(64) DEFAULT ''::character varying NOT NULL,
    uid character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: oc_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_groups (
    gid character varying(64) DEFAULT ''::character varying NOT NULL,
    displayname character varying(255) DEFAULT 'name'::character varying NOT NULL
);


--
-- Name: oc_job_classes_registry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_job_classes_registry (
    class_id bigint NOT NULL,
    class_name character varying(255) NOT NULL
);


--
-- Name: oc_job_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_job_runs (
    run_id bigint NOT NULL,
    class_id bigint NOT NULL,
    pid integer NOT NULL,
    status smallint NOT NULL,
    duration integer DEFAULT 0 NOT NULL,
    ram_peak_usage integer DEFAULT 0 NOT NULL
);


--
-- Name: oc_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_jobs (
    id bigint NOT NULL,
    class character varying(255) DEFAULT ''::character varying NOT NULL,
    argument text DEFAULT ''::text NOT NULL,
    last_run integer DEFAULT 0,
    last_checked integer DEFAULT 0,
    reserved_at integer DEFAULT 0,
    execution_duration integer DEFAULT 0,
    argument_hash character varying(64) DEFAULT NULL::character varying,
    time_sensitive smallint DEFAULT 1 NOT NULL
);


--
-- Name: oc_known_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_known_users (
    id bigint NOT NULL,
    known_to character varying(255) NOT NULL,
    known_user character varying(255) NOT NULL
);


--
-- Name: oc_known_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_known_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_known_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_known_users_id_seq OWNED BY public.oc_known_users.id;


--
-- Name: oc_login_flow_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_login_flow_v2 (
    id bigint NOT NULL,
    "timestamp" bigint NOT NULL,
    started smallint DEFAULT 0 NOT NULL,
    poll_token character varying(255) NOT NULL,
    login_token character varying(255) NOT NULL,
    public_key text NOT NULL,
    private_key text NOT NULL,
    client_name character varying(255) NOT NULL,
    login_name character varying(255) DEFAULT NULL::character varying,
    server character varying(255) DEFAULT NULL::character varying,
    app_password character varying(1024) DEFAULT NULL::character varying
);


--
-- Name: oc_login_flow_v2_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_login_flow_v2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_login_flow_v2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_login_flow_v2_id_seq OWNED BY public.oc_login_flow_v2.id;


--
-- Name: oc_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_migrations (
    app character varying(255) NOT NULL,
    version character varying(255) NOT NULL
);


--
-- Name: oc_mimetypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_mimetypes (
    id bigint NOT NULL,
    mimetype character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: oc_mimetypes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_mimetypes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_mimetypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_mimetypes_id_seq OWNED BY public.oc_mimetypes.id;


--
-- Name: oc_mounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_mounts (
    id bigint NOT NULL,
    storage_id bigint NOT NULL,
    root_id bigint NOT NULL,
    user_id character varying(64) NOT NULL,
    mount_point character varying(4000) NOT NULL,
    mount_id bigint,
    mount_provider_class character varying(128) DEFAULT NULL::character varying,
    mount_point_hash character varying(32) NOT NULL
);


--
-- Name: oc_mounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_mounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_mounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_mounts_id_seq OWNED BY public.oc_mounts.id;


--
-- Name: oc_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_notifications (
    notification_id integer NOT NULL,
    app character varying(32) NOT NULL,
    "user" character varying(64) NOT NULL,
    "timestamp" integer DEFAULT 0 NOT NULL,
    object_type character varying(64) NOT NULL,
    object_id character varying(64) NOT NULL,
    subject character varying(64) NOT NULL,
    subject_parameters text,
    message character varying(64) DEFAULT NULL::character varying,
    message_parameters text,
    link character varying(4000) DEFAULT NULL::character varying,
    icon character varying(4000) DEFAULT NULL::character varying,
    actions text
);


--
-- Name: oc_notifications_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_notifications_notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_notifications_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_notifications_notification_id_seq OWNED BY public.oc_notifications.notification_id;


--
-- Name: oc_notifications_pushhash; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_notifications_pushhash (
    id integer NOT NULL,
    uid character varying(64) NOT NULL,
    token integer DEFAULT 0 NOT NULL,
    deviceidentifier character varying(128) NOT NULL,
    devicepublickey character varying(512) NOT NULL,
    devicepublickeyhash character varying(128) NOT NULL,
    pushtokenhash character varying(128) NOT NULL,
    proxyserver character varying(256) NOT NULL,
    apptype character varying(32) DEFAULT 'unknown'::character varying NOT NULL
);


--
-- Name: oc_notifications_pushhash_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_notifications_pushhash_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_notifications_pushhash_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_notifications_pushhash_id_seq OWNED BY public.oc_notifications_pushhash.id;


--
-- Name: oc_notifications_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_notifications_settings (
    id bigint NOT NULL,
    user_id character varying(64) NOT NULL,
    batch_time integer DEFAULT 0 NOT NULL,
    last_send_id bigint DEFAULT 0 NOT NULL,
    next_send_time integer DEFAULT 0 NOT NULL
);


--
-- Name: oc_notifications_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_notifications_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_notifications_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_notifications_settings_id_seq OWNED BY public.oc_notifications_settings.id;


--
-- Name: oc_notifications_webpush; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_notifications_webpush (
    id bigint NOT NULL,
    uid character varying(64) NOT NULL,
    token bigint DEFAULT 0 NOT NULL,
    endpoint character varying(767) NOT NULL,
    ua_public character varying(128) NOT NULL,
    auth character varying(32) NOT NULL,
    app_types character varying(256) NOT NULL,
    activated boolean DEFAULT false,
    activation_token character varying(36) NOT NULL
);


--
-- Name: oc_notifications_webpush_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_notifications_webpush_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_notifications_webpush_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_notifications_webpush_id_seq OWNED BY public.oc_notifications_webpush.id;


--
-- Name: oc_oauth2_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_oauth2_access_tokens (
    id integer NOT NULL,
    token_id integer NOT NULL,
    client_id integer NOT NULL,
    hashed_code character varying(128) NOT NULL,
    encrypted_token character varying(786) NOT NULL,
    code_created_at bigint DEFAULT 0 NOT NULL,
    token_count bigint DEFAULT 0 NOT NULL
);


--
-- Name: oc_oauth2_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_oauth2_access_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_oauth2_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_oauth2_access_tokens_id_seq OWNED BY public.oc_oauth2_access_tokens.id;


--
-- Name: oc_oauth2_clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_oauth2_clients (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    redirect_uri character varying(2000) NOT NULL,
    client_identifier character varying(64) NOT NULL,
    secret character varying(512) NOT NULL
);


--
-- Name: oc_oauth2_clients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_oauth2_clients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_oauth2_clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_oauth2_clients_id_seq OWNED BY public.oc_oauth2_clients.id;


--
-- Name: oc_open_local_editor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_open_local_editor (
    id bigint NOT NULL,
    user_id character varying(64) NOT NULL,
    path_hash character varying(64) NOT NULL,
    expiration_time bigint NOT NULL,
    token character varying(128) NOT NULL
);


--
-- Name: oc_open_local_editor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_open_local_editor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_open_local_editor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_open_local_editor_id_seq OWNED BY public.oc_open_local_editor.id;


--
-- Name: oc_photos_albums; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_photos_albums (
    album_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    "user" character varying(255) NOT NULL,
    created bigint NOT NULL,
    location character varying(255) NOT NULL,
    last_added_photo bigint NOT NULL,
    filters text
);


--
-- Name: oc_photos_albums_album_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_photos_albums_album_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_photos_albums_album_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_photos_albums_album_id_seq OWNED BY public.oc_photos_albums.album_id;


--
-- Name: oc_photos_albums_collabs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_photos_albums_collabs (
    id bigint NOT NULL,
    album_id bigint NOT NULL,
    collaborator_id character varying(64) NOT NULL,
    collaborator_type integer NOT NULL
);


--
-- Name: oc_photos_albums_collabs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_photos_albums_collabs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_photos_albums_collabs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_photos_albums_collabs_id_seq OWNED BY public.oc_photos_albums_collabs.id;


--
-- Name: oc_photos_albums_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_photos_albums_files (
    album_file_id bigint NOT NULL,
    album_id bigint NOT NULL,
    file_id bigint NOT NULL,
    added bigint NOT NULL,
    owner character varying(64) DEFAULT NULL::character varying
);


--
-- Name: oc_photos_albums_files_album_file_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_photos_albums_files_album_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_photos_albums_files_album_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_photos_albums_files_album_file_id_seq OWNED BY public.oc_photos_albums_files.album_file_id;


--
-- Name: oc_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_preferences (
    userid character varying(64) DEFAULT ''::character varying NOT NULL,
    appid character varying(32) DEFAULT ''::character varying NOT NULL,
    configkey character varying(64) DEFAULT ''::character varying NOT NULL,
    configvalue text,
    lazy smallint DEFAULT 0 NOT NULL,
    type smallint DEFAULT 0 NOT NULL,
    flags integer DEFAULT 0 NOT NULL,
    indexed character varying(64) DEFAULT ''::character varying
);


--
-- Name: oc_preferences_ex; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_preferences_ex (
    id bigint NOT NULL,
    userid character varying(64) NOT NULL,
    appid character varying(32) NOT NULL,
    configkey character varying(64) NOT NULL,
    configvalue text,
    sensitive smallint DEFAULT 0 NOT NULL
);


--
-- Name: oc_preferences_ex_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_preferences_ex_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_preferences_ex_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_preferences_ex_id_seq OWNED BY public.oc_preferences_ex.id;


--
-- Name: oc_preview_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_preview_locations (
    id bigint NOT NULL,
    bucket_name character varying(40) NOT NULL,
    object_store_name character varying(40) NOT NULL
);


--
-- Name: oc_preview_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_preview_versions (
    id bigint NOT NULL,
    file_id bigint NOT NULL,
    version character varying(1024) DEFAULT ''::character varying NOT NULL
);


--
-- Name: oc_previews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_previews (
    id bigint NOT NULL,
    file_id bigint NOT NULL,
    storage_id bigint NOT NULL,
    old_file_id bigint,
    location_id bigint,
    width integer NOT NULL,
    height integer NOT NULL,
    mimetype_id integer NOT NULL,
    source_mimetype_id integer NOT NULL,
    max boolean DEFAULT false NOT NULL,
    cropped boolean DEFAULT false NOT NULL,
    encrypted boolean DEFAULT false NOT NULL,
    etag character(40) NOT NULL,
    mtime integer NOT NULL,
    size integer NOT NULL,
    version_id bigint DEFAULT '-1'::integer NOT NULL
);


--
-- Name: oc_privacy_admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_privacy_admins (
    id integer NOT NULL,
    displayname character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: oc_privacy_admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_privacy_admins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_privacy_admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_privacy_admins_id_seq OWNED BY public.oc_privacy_admins.id;


--
-- Name: oc_profile_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_profile_config (
    id bigint NOT NULL,
    user_id character varying(64) NOT NULL,
    config text NOT NULL
);


--
-- Name: oc_profile_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_profile_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_profile_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_profile_config_id_seq OWNED BY public.oc_profile_config.id;


--
-- Name: oc_properties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_properties (
    id bigint NOT NULL,
    userid character varying(64) DEFAULT ''::character varying NOT NULL,
    propertypath character varying(255) DEFAULT ''::character varying NOT NULL,
    propertyname character varying(255) DEFAULT ''::character varying NOT NULL,
    propertyvalue text NOT NULL,
    valuetype smallint DEFAULT 1
);


--
-- Name: oc_properties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_properties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_properties_id_seq OWNED BY public.oc_properties.id;


--
-- Name: oc_ratelimit_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_ratelimit_entries (
    id bigint NOT NULL,
    hash character varying(128) NOT NULL,
    delete_after timestamp(0) without time zone NOT NULL
);


--
-- Name: oc_ratelimit_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_ratelimit_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_ratelimit_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_ratelimit_entries_id_seq OWNED BY public.oc_ratelimit_entries.id;


--
-- Name: oc_reactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_reactions (
    id bigint NOT NULL,
    parent_id bigint NOT NULL,
    message_id bigint NOT NULL,
    actor_type character varying(64) DEFAULT ''::character varying NOT NULL,
    actor_id character varying(64) DEFAULT ''::character varying NOT NULL,
    reaction character varying(32) NOT NULL
);


--
-- Name: oc_reactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_reactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_reactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_reactions_id_seq OWNED BY public.oc_reactions.id;


--
-- Name: oc_recent_contact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_recent_contact (
    id integer NOT NULL,
    actor_uid character varying(64) NOT NULL,
    uid character varying(64) DEFAULT NULL::character varying,
    email character varying(255) DEFAULT NULL::character varying,
    federated_cloud_id character varying(255) DEFAULT NULL::character varying,
    card bytea NOT NULL,
    last_contact integer NOT NULL
);


--
-- Name: oc_recent_contact_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_recent_contact_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_recent_contact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_recent_contact_id_seq OWNED BY public.oc_recent_contact.id;


--
-- Name: oc_schedulingobjects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_schedulingobjects (
    id bigint NOT NULL,
    principaluri character varying(255) DEFAULT NULL::character varying,
    calendardata bytea,
    uri character varying(255) DEFAULT NULL::character varying,
    lastmodified integer,
    etag character varying(32) DEFAULT NULL::character varying,
    size bigint NOT NULL
);


--
-- Name: oc_schedulingobjects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_schedulingobjects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_schedulingobjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_schedulingobjects_id_seq OWNED BY public.oc_schedulingobjects.id;


--
-- Name: oc_sec_signatory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_sec_signatory (
    id bigint NOT NULL,
    key_id_sum character varying(127) NOT NULL,
    key_id character varying(512) NOT NULL,
    host character varying(512) NOT NULL,
    provider_id character varying(31) NOT NULL,
    account character varying(127) DEFAULT ''::character varying,
    public_key text DEFAULT ''::text NOT NULL,
    metadata text DEFAULT '[]'::text NOT NULL,
    type smallint DEFAULT 9 NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    creation integer DEFAULT 0,
    last_updated integer DEFAULT 0
);


--
-- Name: oc_sec_signatory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_sec_signatory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_sec_signatory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_sec_signatory_id_seq OWNED BY public.oc_sec_signatory.id;


--
-- Name: oc_share; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_share (
    id bigint NOT NULL,
    share_type smallint DEFAULT 0 NOT NULL,
    share_with character varying(255) DEFAULT NULL::character varying,
    password character varying(255) DEFAULT NULL::character varying,
    uid_owner character varying(64) DEFAULT ''::character varying NOT NULL,
    uid_initiator character varying(64) DEFAULT NULL::character varying,
    parent bigint,
    item_type character varying(64) DEFAULT ''::character varying NOT NULL,
    item_source character varying(255) DEFAULT NULL::character varying,
    item_target character varying(255) DEFAULT NULL::character varying,
    file_source bigint,
    file_target character varying(512) DEFAULT NULL::character varying,
    permissions smallint DEFAULT 0 NOT NULL,
    stime bigint DEFAULT 0 NOT NULL,
    accepted smallint DEFAULT 0 NOT NULL,
    expiration timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    token character varying(32) DEFAULT NULL::character varying,
    mail_send smallint DEFAULT 0 NOT NULL,
    share_name character varying(64) DEFAULT NULL::character varying,
    password_by_talk boolean DEFAULT false,
    note text,
    hide_download smallint DEFAULT 0,
    label character varying(255) DEFAULT NULL::character varying,
    attributes json,
    password_expiration_time timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    reminder_sent boolean DEFAULT false
);


--
-- Name: oc_share_external; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_share_external (
    id bigint NOT NULL,
    parent bigint DEFAULT '-1'::integer,
    share_type integer,
    remote character varying(512) NOT NULL,
    remote_id character varying(255) DEFAULT ''::character varying,
    share_token character varying(64) NOT NULL,
    password character varying(64) DEFAULT NULL::character varying,
    name character varying(4000) NOT NULL,
    owner character varying(255) NOT NULL,
    "user" character varying(64) NOT NULL,
    mountpoint character varying(4000) NOT NULL,
    mountpoint_hash character varying(32) NOT NULL,
    accepted integer DEFAULT 0 NOT NULL
);


--
-- Name: oc_share_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_share_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_share_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_share_id_seq OWNED BY public.oc_share.id;


--
-- Name: oc_shares_limits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_shares_limits (
    id character varying(32) NOT NULL,
    "limit" bigint NOT NULL,
    downloads bigint DEFAULT 0 NOT NULL
);


--
-- Name: oc_storages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_storages (
    numeric_id bigint NOT NULL,
    id character varying(64) DEFAULT NULL::character varying,
    available integer DEFAULT 1 NOT NULL,
    last_checked integer
);


--
-- Name: oc_storages_credentials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_storages_credentials (
    id bigint NOT NULL,
    "user" character varying(64) DEFAULT NULL::character varying,
    identifier character varying(64) NOT NULL,
    credentials text
);


--
-- Name: oc_storages_credentials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_storages_credentials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_storages_credentials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_storages_credentials_id_seq OWNED BY public.oc_storages_credentials.id;


--
-- Name: oc_storages_numeric_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_storages_numeric_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_storages_numeric_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_storages_numeric_id_seq OWNED BY public.oc_storages.numeric_id;


--
-- Name: oc_systemtag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_systemtag (
    id bigint NOT NULL,
    name character varying(64) DEFAULT ''::character varying NOT NULL,
    visibility smallint DEFAULT 1 NOT NULL,
    editable smallint DEFAULT 1 NOT NULL,
    etag character varying(32) DEFAULT NULL::character varying,
    color character varying(6) DEFAULT NULL::character varying
);


--
-- Name: oc_systemtag_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_systemtag_group (
    systemtagid bigint DEFAULT 0 NOT NULL,
    gid character varying(255) NOT NULL
);


--
-- Name: oc_systemtag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_systemtag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_systemtag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_systemtag_id_seq OWNED BY public.oc_systemtag.id;


--
-- Name: oc_systemtag_object_mapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_systemtag_object_mapping (
    objectid character varying(64) DEFAULT ''::character varying NOT NULL,
    objecttype character varying(64) DEFAULT ''::character varying NOT NULL,
    systemtagid bigint DEFAULT 0 NOT NULL
);


--
-- Name: oc_taskprocessing_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_taskprocessing_tasks (
    id bigint NOT NULL,
    type character varying(255) NOT NULL,
    input text NOT NULL,
    output text,
    status integer DEFAULT 0,
    user_id character varying(64) DEFAULT NULL::character varying,
    app_id character varying(32) DEFAULT ''::character varying NOT NULL,
    custom_id character varying(255) DEFAULT ''::character varying,
    last_updated integer DEFAULT 0,
    completion_expected_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    progress double precision DEFAULT '0'::double precision,
    error_message character varying(4000) DEFAULT NULL::character varying,
    scheduled_at integer,
    started_at integer,
    ended_at integer,
    webhook_uri character varying(4000) DEFAULT NULL::character varying,
    webhook_method character varying(64) DEFAULT NULL::character varying,
    allow_cleanup smallint DEFAULT 1 NOT NULL,
    user_facing_error_message character varying(4000) DEFAULT NULL::character varying,
    include_watermark smallint DEFAULT 1 NOT NULL
);


--
-- Name: oc_taskprocessing_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_taskprocessing_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_taskprocessing_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_taskprocessing_tasks_id_seq OWNED BY public.oc_taskprocessing_tasks.id;


--
-- Name: oc_text2image_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_text2image_tasks (
    id bigint NOT NULL,
    input text NOT NULL,
    status integer DEFAULT 0,
    number_of_images integer DEFAULT 1 NOT NULL,
    user_id character varying(64) DEFAULT NULL::character varying,
    app_id character varying(32) DEFAULT ''::character varying NOT NULL,
    identifier character varying(255) DEFAULT ''::character varying,
    last_updated timestamp(0) without time zone DEFAULT NULL::timestamp without time zone,
    completion_expected_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone
);


--
-- Name: oc_text2image_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_text2image_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_text2image_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_text2image_tasks_id_seq OWNED BY public.oc_text2image_tasks.id;


--
-- Name: oc_text_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_text_documents (
    id bigint NOT NULL,
    current_version bigint DEFAULT 0,
    last_saved_version bigint DEFAULT 0,
    last_saved_version_time bigint NOT NULL,
    last_saved_version_etag character varying(64) DEFAULT ''::character varying,
    base_version_etag character varying(64) DEFAULT ''::character varying,
    checksum character varying(8) DEFAULT NULL::character varying
);


--
-- Name: oc_text_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_text_sessions (
    id bigint NOT NULL,
    user_id character varying(64) DEFAULT NULL::character varying,
    guest_name character varying(64) DEFAULT NULL::character varying,
    color character varying(7) DEFAULT NULL::character varying,
    token character varying(64) NOT NULL,
    document_id bigint NOT NULL,
    last_contact bigint NOT NULL,
    last_awareness_message text DEFAULT ''::text
);


--
-- Name: oc_text_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_text_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_text_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_text_sessions_id_seq OWNED BY public.oc_text_sessions.id;


--
-- Name: oc_text_steps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_text_steps (
    id bigint NOT NULL,
    document_id bigint NOT NULL,
    session_id bigint NOT NULL,
    data text NOT NULL,
    version bigint DEFAULT 0,
    "timestamp" bigint DEFAULT 0 NOT NULL
);


--
-- Name: oc_text_steps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_text_steps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_text_steps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_text_steps_id_seq OWNED BY public.oc_text_steps.id;


--
-- Name: oc_textprocessing_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_textprocessing_tasks (
    id bigint NOT NULL,
    type character varying(255) NOT NULL,
    input text NOT NULL,
    output text,
    status integer DEFAULT 0,
    user_id character varying(64) DEFAULT NULL::character varying,
    app_id character varying(32) DEFAULT ''::character varying NOT NULL,
    identifier character varying(255) DEFAULT ''::character varying NOT NULL,
    last_updated integer DEFAULT 0,
    completion_expected_at timestamp(0) without time zone DEFAULT NULL::timestamp without time zone
);


--
-- Name: oc_textprocessing_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_textprocessing_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_textprocessing_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_textprocessing_tasks_id_seq OWNED BY public.oc_textprocessing_tasks.id;


--
-- Name: oc_trusted_servers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_trusted_servers (
    id integer NOT NULL,
    url character varying(512) NOT NULL,
    url_hash character varying(255) DEFAULT ''::character varying NOT NULL,
    token character varying(128) DEFAULT NULL::character varying,
    shared_secret character varying(256) DEFAULT NULL::character varying,
    status integer DEFAULT 2 NOT NULL,
    sync_token character varying(512) DEFAULT NULL::character varying
);


--
-- Name: oc_trusted_servers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_trusted_servers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_trusted_servers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_trusted_servers_id_seq OWNED BY public.oc_trusted_servers.id;


--
-- Name: oc_twofactor_backupcodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_twofactor_backupcodes (
    id bigint NOT NULL,
    user_id character varying(64) DEFAULT ''::character varying NOT NULL,
    code character varying(128) NOT NULL,
    used smallint DEFAULT 0 NOT NULL
);


--
-- Name: oc_twofactor_backupcodes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_twofactor_backupcodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_twofactor_backupcodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_twofactor_backupcodes_id_seq OWNED BY public.oc_twofactor_backupcodes.id;


--
-- Name: oc_twofactor_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_twofactor_providers (
    provider_id character varying(32) NOT NULL,
    uid character varying(64) NOT NULL,
    enabled smallint NOT NULL
);


--
-- Name: oc_twofactor_totp_secrets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_twofactor_totp_secrets (
    id integer NOT NULL,
    user_id character varying(64) DEFAULT ''::character varying NOT NULL,
    secret text NOT NULL,
    state integer DEFAULT 2 NOT NULL,
    last_counter bigint DEFAULT '-1'::integer NOT NULL
);


--
-- Name: oc_twofactor_totp_secrets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_twofactor_totp_secrets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_twofactor_totp_secrets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_twofactor_totp_secrets_id_seq OWNED BY public.oc_twofactor_totp_secrets.id;


--
-- Name: oc_user_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_user_status (
    id bigint NOT NULL,
    user_id character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    status_timestamp integer NOT NULL,
    is_user_defined boolean,
    message_id character varying(255) DEFAULT NULL::character varying,
    custom_icon character varying(255) DEFAULT NULL::character varying,
    custom_message text,
    clear_at integer,
    is_backup boolean DEFAULT false,
    status_message_timestamp integer DEFAULT 0 NOT NULL
);


--
-- Name: oc_user_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_user_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_user_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_user_status_id_seq OWNED BY public.oc_user_status.id;


--
-- Name: oc_user_transfer_owner; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_user_transfer_owner (
    id bigint NOT NULL,
    source_user character varying(64) NOT NULL,
    target_user character varying(64) NOT NULL,
    file_id bigint NOT NULL,
    node_name character varying(255) NOT NULL
);


--
-- Name: oc_user_transfer_owner_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_user_transfer_owner_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_user_transfer_owner_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_user_transfer_owner_id_seq OWNED BY public.oc_user_transfer_owner.id;


--
-- Name: oc_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_users (
    uid character varying(64) DEFAULT ''::character varying NOT NULL,
    displayname character varying(64) DEFAULT NULL::character varying,
    password character varying(255) DEFAULT ''::character varying NOT NULL,
    uid_lower character varying(64) DEFAULT ''::character varying
);


--
-- Name: oc_vcategory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_vcategory (
    id bigint NOT NULL,
    uid character varying(64) DEFAULT ''::character varying NOT NULL,
    type character varying(64) DEFAULT ''::character varying NOT NULL,
    category character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: oc_vcategory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_vcategory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_vcategory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_vcategory_id_seq OWNED BY public.oc_vcategory.id;


--
-- Name: oc_vcategory_to_object; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_vcategory_to_object (
    objid bigint DEFAULT 0 NOT NULL,
    categoryid bigint DEFAULT 0 NOT NULL,
    type character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: oc_webauthn; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_webauthn (
    id integer NOT NULL,
    uid character varying(64) NOT NULL,
    name character varying(64) NOT NULL,
    public_key_credential_id character varying(512) NOT NULL,
    data text NOT NULL,
    user_verification boolean DEFAULT false
);


--
-- Name: oc_webauthn_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_webauthn_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_webauthn_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_webauthn_id_seq OWNED BY public.oc_webauthn.id;


--
-- Name: oc_webhook_listeners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_webhook_listeners (
    id bigint NOT NULL,
    app_id character varying(64) DEFAULT NULL::character varying,
    user_id character varying(64) DEFAULT NULL::character varying,
    http_method character varying(32) NOT NULL,
    uri character varying(4000) NOT NULL,
    event character varying(4000) NOT NULL,
    event_filter text,
    user_id_filter character varying(64) DEFAULT NULL::character varying,
    headers text,
    auth_method character varying(16) DEFAULT ''::character varying NOT NULL,
    auth_data text,
    token_needed text
);


--
-- Name: oc_webhook_listeners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_webhook_listeners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_webhook_listeners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_webhook_listeners_id_seq OWNED BY public.oc_webhook_listeners.id;


--
-- Name: oc_webhook_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oc_webhook_tokens (
    id bigint NOT NULL,
    token_id bigint NOT NULL,
    user_id character varying(64) DEFAULT NULL::character varying,
    created_at bigint NOT NULL
);


--
-- Name: oc_webhook_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oc_webhook_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oc_webhook_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oc_webhook_tokens_id_seq OWNED BY public.oc_webhook_tokens.id;


--
-- Name: oc_accounts_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_accounts_data ALTER COLUMN id SET DEFAULT nextval('public.oc_accounts_data_id_seq'::regclass);


--
-- Name: oc_activity activity_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_activity ALTER COLUMN activity_id SET DEFAULT nextval('public.oc_activity_activity_id_seq'::regclass);


--
-- Name: oc_activity_mq mail_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_activity_mq ALTER COLUMN mail_id SET DEFAULT nextval('public.oc_activity_mq_mail_id_seq'::regclass);


--
-- Name: oc_addressbookchanges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_addressbookchanges ALTER COLUMN id SET DEFAULT nextval('public.oc_addressbookchanges_id_seq'::regclass);


--
-- Name: oc_addressbooks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_addressbooks ALTER COLUMN id SET DEFAULT nextval('public.oc_addressbooks_id_seq'::regclass);


--
-- Name: oc_appconfig_ex id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_appconfig_ex ALTER COLUMN id SET DEFAULT nextval('public.oc_appconfig_ex_id_seq'::regclass);


--
-- Name: oc_authorized_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_authorized_groups ALTER COLUMN id SET DEFAULT nextval('public.oc_authorized_groups_id_seq'::regclass);


--
-- Name: oc_authtoken id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_authtoken ALTER COLUMN id SET DEFAULT nextval('public.oc_authtoken_id_seq'::regclass);


--
-- Name: oc_bruteforce_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_bruteforce_attempts ALTER COLUMN id SET DEFAULT nextval('public.oc_bruteforce_attempts_id_seq'::regclass);


--
-- Name: oc_calendar_invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendar_invitations ALTER COLUMN id SET DEFAULT nextval('public.oc_calendar_invitations_id_seq'::regclass);


--
-- Name: oc_calendar_reminders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendar_reminders ALTER COLUMN id SET DEFAULT nextval('public.oc_calendar_reminders_id_seq'::regclass);


--
-- Name: oc_calendar_resources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendar_resources ALTER COLUMN id SET DEFAULT nextval('public.oc_calendar_resources_id_seq'::regclass);


--
-- Name: oc_calendar_resources_md id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendar_resources_md ALTER COLUMN id SET DEFAULT nextval('public.oc_calendar_resources_md_id_seq'::regclass);


--
-- Name: oc_calendar_rooms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendar_rooms ALTER COLUMN id SET DEFAULT nextval('public.oc_calendar_rooms_id_seq'::regclass);


--
-- Name: oc_calendar_rooms_md id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendar_rooms_md ALTER COLUMN id SET DEFAULT nextval('public.oc_calendar_rooms_md_id_seq'::regclass);


--
-- Name: oc_calendarchanges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendarchanges ALTER COLUMN id SET DEFAULT nextval('public.oc_calendarchanges_id_seq'::regclass);


--
-- Name: oc_calendarobjects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendarobjects ALTER COLUMN id SET DEFAULT nextval('public.oc_calendarobjects_id_seq'::regclass);


--
-- Name: oc_calendarobjects_props id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendarobjects_props ALTER COLUMN id SET DEFAULT nextval('public.oc_calendarobjects_props_id_seq'::regclass);


--
-- Name: oc_calendars id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendars ALTER COLUMN id SET DEFAULT nextval('public.oc_calendars_id_seq'::regclass);


--
-- Name: oc_calendars_federated id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendars_federated ALTER COLUMN id SET DEFAULT nextval('public.oc_calendars_federated_id_seq'::regclass);


--
-- Name: oc_calendarsubscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendarsubscriptions ALTER COLUMN id SET DEFAULT nextval('public.oc_calendarsubscriptions_id_seq'::regclass);


--
-- Name: oc_cards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_cards ALTER COLUMN id SET DEFAULT nextval('public.oc_cards_id_seq'::regclass);


--
-- Name: oc_cards_properties id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_cards_properties ALTER COLUMN id SET DEFAULT nextval('public.oc_cards_properties_id_seq'::regclass);


--
-- Name: oc_circles_circle id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_circles_circle ALTER COLUMN id SET DEFAULT nextval('public.oc_circles_circle_id_seq'::regclass);


--
-- Name: oc_circles_member id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_circles_member ALTER COLUMN id SET DEFAULT nextval('public.oc_circles_member_id_seq'::regclass);


--
-- Name: oc_circles_mount id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_circles_mount ALTER COLUMN id SET DEFAULT nextval('public.oc_circles_mount_id_seq'::regclass);


--
-- Name: oc_circles_mountpoint id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_circles_mountpoint ALTER COLUMN id SET DEFAULT nextval('public.oc_circles_mountpoint_id_seq'::regclass);


--
-- Name: oc_circles_remote id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_circles_remote ALTER COLUMN id SET DEFAULT nextval('public.oc_circles_remote_id_seq'::regclass);


--
-- Name: oc_circles_share_lock id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_circles_share_lock ALTER COLUMN id SET DEFAULT nextval('public.oc_circles_share_lock_id_seq'::regclass);


--
-- Name: oc_circles_token id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_circles_token ALTER COLUMN id SET DEFAULT nextval('public.oc_circles_token_id_seq'::regclass);


--
-- Name: oc_collres_collections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_collres_collections ALTER COLUMN id SET DEFAULT nextval('public.oc_collres_collections_id_seq'::regclass);


--
-- Name: oc_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_comments ALTER COLUMN id SET DEFAULT nextval('public.oc_comments_id_seq'::regclass);


--
-- Name: oc_dav_absence id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_dav_absence ALTER COLUMN id SET DEFAULT nextval('public.oc_dav_absence_id_seq'::regclass);


--
-- Name: oc_dav_cal_proxy id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_dav_cal_proxy ALTER COLUMN id SET DEFAULT nextval('public.oc_dav_cal_proxy_id_seq'::regclass);


--
-- Name: oc_dav_shares id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_dav_shares ALTER COLUMN id SET DEFAULT nextval('public.oc_dav_shares_id_seq'::regclass);


--
-- Name: oc_direct_edit id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_direct_edit ALTER COLUMN id SET DEFAULT nextval('public.oc_direct_edit_id_seq'::regclass);


--
-- Name: oc_directlink id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_directlink ALTER COLUMN id SET DEFAULT nextval('public.oc_directlink_id_seq'::regclass);


--
-- Name: oc_ex_apps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_apps ALTER COLUMN id SET DEFAULT nextval('public.oc_ex_apps_id_seq'::regclass);


--
-- Name: oc_ex_apps_daemons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_apps_daemons ALTER COLUMN id SET DEFAULT nextval('public.oc_ex_apps_daemons_id_seq'::regclass);


--
-- Name: oc_ex_apps_routes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_apps_routes ALTER COLUMN id SET DEFAULT nextval('public.oc_ex_apps_routes_id_seq'::regclass);


--
-- Name: oc_ex_apps_talk_bots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_apps_talk_bots ALTER COLUMN id SET DEFAULT nextval('public.oc_ex_apps_talk_bots_id_seq'::regclass);


--
-- Name: oc_ex_deploy_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_deploy_options ALTER COLUMN id SET DEFAULT nextval('public.oc_ex_deploy_options_id_seq'::regclass);


--
-- Name: oc_ex_occ_commands id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_occ_commands ALTER COLUMN id SET DEFAULT nextval('public.oc_ex_occ_commands_id_seq'::regclass);


--
-- Name: oc_ex_settings_forms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_settings_forms ALTER COLUMN id SET DEFAULT nextval('public.oc_ex_settings_forms_id_seq'::regclass);


--
-- Name: oc_ex_task_processing id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_task_processing ALTER COLUMN id SET DEFAULT nextval('public.oc_ex_task_processing_id_seq'::regclass);


--
-- Name: oc_ex_ui_files_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_ui_files_actions ALTER COLUMN id SET DEFAULT nextval('public.oc_ex_ui_files_actions_id_seq'::regclass);


--
-- Name: oc_ex_ui_scripts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_ui_scripts ALTER COLUMN id SET DEFAULT nextval('public.oc_ex_ui_scripts_id_seq'::regclass);


--
-- Name: oc_ex_ui_states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_ui_states ALTER COLUMN id SET DEFAULT nextval('public.oc_ex_ui_states_id_seq'::regclass);


--
-- Name: oc_ex_ui_styles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_ui_styles ALTER COLUMN id SET DEFAULT nextval('public.oc_ex_ui_styles_id_seq'::regclass);


--
-- Name: oc_ex_ui_top_menu id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_ui_top_menu ALTER COLUMN id SET DEFAULT nextval('public.oc_ex_ui_top_menu_id_seq'::regclass);


--
-- Name: oc_federated_invites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_federated_invites ALTER COLUMN id SET DEFAULT nextval('public.oc_federated_invites_id_seq'::regclass);


--
-- Name: oc_file_locks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_file_locks ALTER COLUMN id SET DEFAULT nextval('public.oc_file_locks_id_seq'::regclass);


--
-- Name: oc_filecache fileid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_filecache ALTER COLUMN fileid SET DEFAULT nextval('public.oc_filecache_fileid_seq'::regclass);


--
-- Name: oc_files_lock id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_files_lock ALTER COLUMN id SET DEFAULT nextval('public.oc_files_lock_id_seq'::regclass);


--
-- Name: oc_files_metadata id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_files_metadata ALTER COLUMN id SET DEFAULT nextval('public.oc_files_metadata_id_seq'::regclass);


--
-- Name: oc_files_metadata_index id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_files_metadata_index ALTER COLUMN id SET DEFAULT nextval('public.oc_files_metadata_index_id_seq'::regclass);


--
-- Name: oc_files_reminders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_files_reminders ALTER COLUMN id SET DEFAULT nextval('public.oc_files_reminders_id_seq'::regclass);


--
-- Name: oc_files_trash auto_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_files_trash ALTER COLUMN auto_id SET DEFAULT nextval('public.oc_files_trash_auto_id_seq'::regclass);


--
-- Name: oc_files_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_files_versions ALTER COLUMN id SET DEFAULT nextval('public.oc_files_versions_id_seq'::regclass);


--
-- Name: oc_flow_checks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_flow_checks ALTER COLUMN id SET DEFAULT nextval('public.oc_flow_checks_id_seq'::regclass);


--
-- Name: oc_flow_operations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_flow_operations ALTER COLUMN id SET DEFAULT nextval('public.oc_flow_operations_id_seq'::regclass);


--
-- Name: oc_flow_operations_scope id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_flow_operations_scope ALTER COLUMN id SET DEFAULT nextval('public.oc_flow_operations_scope_id_seq'::regclass);


--
-- Name: oc_known_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_known_users ALTER COLUMN id SET DEFAULT nextval('public.oc_known_users_id_seq'::regclass);


--
-- Name: oc_login_flow_v2 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_login_flow_v2 ALTER COLUMN id SET DEFAULT nextval('public.oc_login_flow_v2_id_seq'::regclass);


--
-- Name: oc_mimetypes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_mimetypes ALTER COLUMN id SET DEFAULT nextval('public.oc_mimetypes_id_seq'::regclass);


--
-- Name: oc_mounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_mounts ALTER COLUMN id SET DEFAULT nextval('public.oc_mounts_id_seq'::regclass);


--
-- Name: oc_notifications notification_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_notifications ALTER COLUMN notification_id SET DEFAULT nextval('public.oc_notifications_notification_id_seq'::regclass);


--
-- Name: oc_notifications_pushhash id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_notifications_pushhash ALTER COLUMN id SET DEFAULT nextval('public.oc_notifications_pushhash_id_seq'::regclass);


--
-- Name: oc_notifications_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_notifications_settings ALTER COLUMN id SET DEFAULT nextval('public.oc_notifications_settings_id_seq'::regclass);


--
-- Name: oc_notifications_webpush id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_notifications_webpush ALTER COLUMN id SET DEFAULT nextval('public.oc_notifications_webpush_id_seq'::regclass);


--
-- Name: oc_oauth2_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_oauth2_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.oc_oauth2_access_tokens_id_seq'::regclass);


--
-- Name: oc_oauth2_clients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_oauth2_clients ALTER COLUMN id SET DEFAULT nextval('public.oc_oauth2_clients_id_seq'::regclass);


--
-- Name: oc_open_local_editor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_open_local_editor ALTER COLUMN id SET DEFAULT nextval('public.oc_open_local_editor_id_seq'::regclass);


--
-- Name: oc_photos_albums album_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_photos_albums ALTER COLUMN album_id SET DEFAULT nextval('public.oc_photos_albums_album_id_seq'::regclass);


--
-- Name: oc_photos_albums_collabs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_photos_albums_collabs ALTER COLUMN id SET DEFAULT nextval('public.oc_photos_albums_collabs_id_seq'::regclass);


--
-- Name: oc_photos_albums_files album_file_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_photos_albums_files ALTER COLUMN album_file_id SET DEFAULT nextval('public.oc_photos_albums_files_album_file_id_seq'::regclass);


--
-- Name: oc_preferences_ex id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_preferences_ex ALTER COLUMN id SET DEFAULT nextval('public.oc_preferences_ex_id_seq'::regclass);


--
-- Name: oc_privacy_admins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_privacy_admins ALTER COLUMN id SET DEFAULT nextval('public.oc_privacy_admins_id_seq'::regclass);


--
-- Name: oc_profile_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_profile_config ALTER COLUMN id SET DEFAULT nextval('public.oc_profile_config_id_seq'::regclass);


--
-- Name: oc_properties id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_properties ALTER COLUMN id SET DEFAULT nextval('public.oc_properties_id_seq'::regclass);


--
-- Name: oc_ratelimit_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ratelimit_entries ALTER COLUMN id SET DEFAULT nextval('public.oc_ratelimit_entries_id_seq'::regclass);


--
-- Name: oc_reactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_reactions ALTER COLUMN id SET DEFAULT nextval('public.oc_reactions_id_seq'::regclass);


--
-- Name: oc_recent_contact id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_recent_contact ALTER COLUMN id SET DEFAULT nextval('public.oc_recent_contact_id_seq'::regclass);


--
-- Name: oc_schedulingobjects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_schedulingobjects ALTER COLUMN id SET DEFAULT nextval('public.oc_schedulingobjects_id_seq'::regclass);


--
-- Name: oc_sec_signatory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_sec_signatory ALTER COLUMN id SET DEFAULT nextval('public.oc_sec_signatory_id_seq'::regclass);


--
-- Name: oc_share id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_share ALTER COLUMN id SET DEFAULT nextval('public.oc_share_id_seq'::regclass);


--
-- Name: oc_storages numeric_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_storages ALTER COLUMN numeric_id SET DEFAULT nextval('public.oc_storages_numeric_id_seq'::regclass);


--
-- Name: oc_storages_credentials id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_storages_credentials ALTER COLUMN id SET DEFAULT nextval('public.oc_storages_credentials_id_seq'::regclass);


--
-- Name: oc_systemtag id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_systemtag ALTER COLUMN id SET DEFAULT nextval('public.oc_systemtag_id_seq'::regclass);


--
-- Name: oc_taskprocessing_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_taskprocessing_tasks ALTER COLUMN id SET DEFAULT nextval('public.oc_taskprocessing_tasks_id_seq'::regclass);


--
-- Name: oc_text2image_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_text2image_tasks ALTER COLUMN id SET DEFAULT nextval('public.oc_text2image_tasks_id_seq'::regclass);


--
-- Name: oc_text_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_text_sessions ALTER COLUMN id SET DEFAULT nextval('public.oc_text_sessions_id_seq'::regclass);


--
-- Name: oc_text_steps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_text_steps ALTER COLUMN id SET DEFAULT nextval('public.oc_text_steps_id_seq'::regclass);


--
-- Name: oc_textprocessing_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_textprocessing_tasks ALTER COLUMN id SET DEFAULT nextval('public.oc_textprocessing_tasks_id_seq'::regclass);


--
-- Name: oc_trusted_servers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_trusted_servers ALTER COLUMN id SET DEFAULT nextval('public.oc_trusted_servers_id_seq'::regclass);


--
-- Name: oc_twofactor_backupcodes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_twofactor_backupcodes ALTER COLUMN id SET DEFAULT nextval('public.oc_twofactor_backupcodes_id_seq'::regclass);


--
-- Name: oc_twofactor_totp_secrets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_twofactor_totp_secrets ALTER COLUMN id SET DEFAULT nextval('public.oc_twofactor_totp_secrets_id_seq'::regclass);


--
-- Name: oc_user_status id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_user_status ALTER COLUMN id SET DEFAULT nextval('public.oc_user_status_id_seq'::regclass);


--
-- Name: oc_user_transfer_owner id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_user_transfer_owner ALTER COLUMN id SET DEFAULT nextval('public.oc_user_transfer_owner_id_seq'::regclass);


--
-- Name: oc_vcategory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_vcategory ALTER COLUMN id SET DEFAULT nextval('public.oc_vcategory_id_seq'::regclass);


--
-- Name: oc_webauthn id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_webauthn ALTER COLUMN id SET DEFAULT nextval('public.oc_webauthn_id_seq'::regclass);


--
-- Name: oc_webhook_listeners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_webhook_listeners ALTER COLUMN id SET DEFAULT nextval('public.oc_webhook_listeners_id_seq'::regclass);


--
-- Name: oc_webhook_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_webhook_tokens ALTER COLUMN id SET DEFAULT nextval('public.oc_webhook_tokens_id_seq'::regclass);


--
-- Name: oc_job_classes_registry class_index; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_job_classes_registry
    ADD CONSTRAINT class_index UNIQUE (class_name);


--
-- Name: oc_accounts_data oc_accounts_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_accounts_data
    ADD CONSTRAINT oc_accounts_data_pkey PRIMARY KEY (id);


--
-- Name: oc_accounts oc_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_accounts
    ADD CONSTRAINT oc_accounts_pkey PRIMARY KEY (uid);


--
-- Name: oc_activity_mq oc_activity_mq_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_activity_mq
    ADD CONSTRAINT oc_activity_mq_pkey PRIMARY KEY (mail_id);


--
-- Name: oc_activity oc_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_activity
    ADD CONSTRAINT oc_activity_pkey PRIMARY KEY (activity_id);


--
-- Name: oc_addressbookchanges oc_addressbookchanges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_addressbookchanges
    ADD CONSTRAINT oc_addressbookchanges_pkey PRIMARY KEY (id);


--
-- Name: oc_addressbooks oc_addressbooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_addressbooks
    ADD CONSTRAINT oc_addressbooks_pkey PRIMARY KEY (id);


--
-- Name: oc_appconfig_ex oc_appconfig_ex_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_appconfig_ex
    ADD CONSTRAINT oc_appconfig_ex_pkey PRIMARY KEY (id);


--
-- Name: oc_appconfig oc_appconfig_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_appconfig
    ADD CONSTRAINT oc_appconfig_pkey PRIMARY KEY (appid, configkey);


--
-- Name: oc_authorized_groups oc_authorized_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_authorized_groups
    ADD CONSTRAINT oc_authorized_groups_pkey PRIMARY KEY (id);


--
-- Name: oc_authtoken oc_authtoken_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_authtoken
    ADD CONSTRAINT oc_authtoken_pkey PRIMARY KEY (id);


--
-- Name: oc_bruteforce_attempts oc_bruteforce_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_bruteforce_attempts
    ADD CONSTRAINT oc_bruteforce_attempts_pkey PRIMARY KEY (id);


--
-- Name: oc_calendar_invitations oc_calendar_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendar_invitations
    ADD CONSTRAINT oc_calendar_invitations_pkey PRIMARY KEY (id);


--
-- Name: oc_calendar_reminders oc_calendar_reminders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendar_reminders
    ADD CONSTRAINT oc_calendar_reminders_pkey PRIMARY KEY (id);


--
-- Name: oc_calendar_resources_md oc_calendar_resources_md_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendar_resources_md
    ADD CONSTRAINT oc_calendar_resources_md_pkey PRIMARY KEY (id);


--
-- Name: oc_calendar_resources oc_calendar_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendar_resources
    ADD CONSTRAINT oc_calendar_resources_pkey PRIMARY KEY (id);


--
-- Name: oc_calendar_rooms_md oc_calendar_rooms_md_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendar_rooms_md
    ADD CONSTRAINT oc_calendar_rooms_md_pkey PRIMARY KEY (id);


--
-- Name: oc_calendar_rooms oc_calendar_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendar_rooms
    ADD CONSTRAINT oc_calendar_rooms_pkey PRIMARY KEY (id);


--
-- Name: oc_calendarchanges oc_calendarchanges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendarchanges
    ADD CONSTRAINT oc_calendarchanges_pkey PRIMARY KEY (id);


--
-- Name: oc_calendarobjects oc_calendarobjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendarobjects
    ADD CONSTRAINT oc_calendarobjects_pkey PRIMARY KEY (id);


--
-- Name: oc_calendarobjects_props oc_calendarobjects_props_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendarobjects_props
    ADD CONSTRAINT oc_calendarobjects_props_pkey PRIMARY KEY (id);


--
-- Name: oc_calendars_federated oc_calendars_federated_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendars_federated
    ADD CONSTRAINT oc_calendars_federated_pkey PRIMARY KEY (id);


--
-- Name: oc_calendars oc_calendars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendars
    ADD CONSTRAINT oc_calendars_pkey PRIMARY KEY (id);


--
-- Name: oc_calendarsubscriptions oc_calendarsubscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_calendarsubscriptions
    ADD CONSTRAINT oc_calendarsubscriptions_pkey PRIMARY KEY (id);


--
-- Name: oc_cards oc_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_cards
    ADD CONSTRAINT oc_cards_pkey PRIMARY KEY (id);


--
-- Name: oc_cards_properties oc_cards_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_cards_properties
    ADD CONSTRAINT oc_cards_properties_pkey PRIMARY KEY (id);


--
-- Name: oc_circles_circle oc_circles_circle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_circles_circle
    ADD CONSTRAINT oc_circles_circle_pkey PRIMARY KEY (id);


--
-- Name: oc_circles_event oc_circles_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_circles_event
    ADD CONSTRAINT oc_circles_event_pkey PRIMARY KEY (token, instance);


--
-- Name: oc_circles_member oc_circles_member_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_circles_member
    ADD CONSTRAINT oc_circles_member_pkey PRIMARY KEY (id);


--
-- Name: oc_circles_membership oc_circles_membership_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_circles_membership
    ADD CONSTRAINT oc_circles_membership_pkey PRIMARY KEY (single_id, circle_id);


--
-- Name: oc_circles_mount oc_circles_mount_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_circles_mount
    ADD CONSTRAINT oc_circles_mount_pkey PRIMARY KEY (id);


--
-- Name: oc_circles_mountpoint oc_circles_mountpoint_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_circles_mountpoint
    ADD CONSTRAINT oc_circles_mountpoint_pkey PRIMARY KEY (id);


--
-- Name: oc_circles_remote oc_circles_remote_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_circles_remote
    ADD CONSTRAINT oc_circles_remote_pkey PRIMARY KEY (id);


--
-- Name: oc_circles_share_lock oc_circles_share_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_circles_share_lock
    ADD CONSTRAINT oc_circles_share_lock_pkey PRIMARY KEY (id);


--
-- Name: oc_circles_token oc_circles_token_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_circles_token
    ADD CONSTRAINT oc_circles_token_pkey PRIMARY KEY (id);


--
-- Name: oc_collres_accesscache oc_collres_accesscache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_collres_accesscache
    ADD CONSTRAINT oc_collres_accesscache_pkey PRIMARY KEY (user_id, collection_id, resource_type, resource_id);


--
-- Name: oc_collres_collections oc_collres_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_collres_collections
    ADD CONSTRAINT oc_collres_collections_pkey PRIMARY KEY (id);


--
-- Name: oc_collres_resources oc_collres_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_collres_resources
    ADD CONSTRAINT oc_collres_resources_pkey PRIMARY KEY (collection_id, resource_type, resource_id);


--
-- Name: oc_comments oc_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_comments
    ADD CONSTRAINT oc_comments_pkey PRIMARY KEY (id);


--
-- Name: oc_comments_read_markers oc_comments_read_markers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_comments_read_markers
    ADD CONSTRAINT oc_comments_read_markers_pkey PRIMARY KEY (user_id, object_type, object_id);


--
-- Name: oc_dav_absence oc_dav_absence_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_dav_absence
    ADD CONSTRAINT oc_dav_absence_pkey PRIMARY KEY (id);


--
-- Name: oc_dav_cal_proxy oc_dav_cal_proxy_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_dav_cal_proxy
    ADD CONSTRAINT oc_dav_cal_proxy_pkey PRIMARY KEY (id);


--
-- Name: oc_dav_shares oc_dav_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_dav_shares
    ADD CONSTRAINT oc_dav_shares_pkey PRIMARY KEY (id);


--
-- Name: oc_direct_edit oc_direct_edit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_direct_edit
    ADD CONSTRAINT oc_direct_edit_pkey PRIMARY KEY (id);


--
-- Name: oc_directlink oc_directlink_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_directlink
    ADD CONSTRAINT oc_directlink_pkey PRIMARY KEY (id);


--
-- Name: oc_ex_apps_daemons oc_ex_apps_daemons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_apps_daemons
    ADD CONSTRAINT oc_ex_apps_daemons_pkey PRIMARY KEY (id);


--
-- Name: oc_ex_apps oc_ex_apps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_apps
    ADD CONSTRAINT oc_ex_apps_pkey PRIMARY KEY (id);


--
-- Name: oc_ex_apps_routes oc_ex_apps_routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_apps_routes
    ADD CONSTRAINT oc_ex_apps_routes_pkey PRIMARY KEY (id);


--
-- Name: oc_ex_apps_talk_bots oc_ex_apps_talk_bots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_apps_talk_bots
    ADD CONSTRAINT oc_ex_apps_talk_bots_pkey PRIMARY KEY (id);


--
-- Name: oc_ex_deploy_options oc_ex_deploy_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_deploy_options
    ADD CONSTRAINT oc_ex_deploy_options_pkey PRIMARY KEY (id);


--
-- Name: oc_ex_occ_commands oc_ex_occ_commands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_occ_commands
    ADD CONSTRAINT oc_ex_occ_commands_pkey PRIMARY KEY (id);


--
-- Name: oc_ex_settings_forms oc_ex_settings_forms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_settings_forms
    ADD CONSTRAINT oc_ex_settings_forms_pkey PRIMARY KEY (id);


--
-- Name: oc_ex_task_processing oc_ex_task_processing_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_task_processing
    ADD CONSTRAINT oc_ex_task_processing_pkey PRIMARY KEY (id);


--
-- Name: oc_ex_ui_files_actions oc_ex_ui_files_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_ui_files_actions
    ADD CONSTRAINT oc_ex_ui_files_actions_pkey PRIMARY KEY (id);


--
-- Name: oc_ex_ui_scripts oc_ex_ui_scripts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_ui_scripts
    ADD CONSTRAINT oc_ex_ui_scripts_pkey PRIMARY KEY (id);


--
-- Name: oc_ex_ui_states oc_ex_ui_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_ui_states
    ADD CONSTRAINT oc_ex_ui_states_pkey PRIMARY KEY (id);


--
-- Name: oc_ex_ui_styles oc_ex_ui_styles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_ui_styles
    ADD CONSTRAINT oc_ex_ui_styles_pkey PRIMARY KEY (id);


--
-- Name: oc_ex_ui_top_menu oc_ex_ui_top_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ex_ui_top_menu
    ADD CONSTRAINT oc_ex_ui_top_menu_pkey PRIMARY KEY (id);


--
-- Name: oc_federated_invites oc_federated_invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_federated_invites
    ADD CONSTRAINT oc_federated_invites_pkey PRIMARY KEY (id);


--
-- Name: oc_federated_reshares oc_federated_reshares_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_federated_reshares
    ADD CONSTRAINT oc_federated_reshares_pkey PRIMARY KEY (share_id);


--
-- Name: oc_file_locks oc_file_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_file_locks
    ADD CONSTRAINT oc_file_locks_pkey PRIMARY KEY (id);


--
-- Name: oc_filecache_extended oc_filecache_extended_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_filecache_extended
    ADD CONSTRAINT oc_filecache_extended_pkey PRIMARY KEY (fileid);


--
-- Name: oc_filecache oc_filecache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_filecache
    ADD CONSTRAINT oc_filecache_pkey PRIMARY KEY (fileid);


--
-- Name: oc_files_lock oc_files_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_files_lock
    ADD CONSTRAINT oc_files_lock_pkey PRIMARY KEY (id);


--
-- Name: oc_files_metadata_index oc_files_metadata_index_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_files_metadata_index
    ADD CONSTRAINT oc_files_metadata_index_pkey PRIMARY KEY (id);


--
-- Name: oc_files_metadata oc_files_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_files_metadata
    ADD CONSTRAINT oc_files_metadata_pkey PRIMARY KEY (id);


--
-- Name: oc_files_reminders oc_files_reminders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_files_reminders
    ADD CONSTRAINT oc_files_reminders_pkey PRIMARY KEY (id);


--
-- Name: oc_files_trash oc_files_trash_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_files_trash
    ADD CONSTRAINT oc_files_trash_pkey PRIMARY KEY (auto_id);


--
-- Name: oc_files_versions oc_files_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_files_versions
    ADD CONSTRAINT oc_files_versions_pkey PRIMARY KEY (id);


--
-- Name: oc_flow_checks oc_flow_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_flow_checks
    ADD CONSTRAINT oc_flow_checks_pkey PRIMARY KEY (id);


--
-- Name: oc_flow_operations oc_flow_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_flow_operations
    ADD CONSTRAINT oc_flow_operations_pkey PRIMARY KEY (id);


--
-- Name: oc_flow_operations_scope oc_flow_operations_scope_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_flow_operations_scope
    ADD CONSTRAINT oc_flow_operations_scope_pkey PRIMARY KEY (id);


--
-- Name: oc_group_admin oc_group_admin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_group_admin
    ADD CONSTRAINT oc_group_admin_pkey PRIMARY KEY (gid, uid);


--
-- Name: oc_group_user oc_group_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_group_user
    ADD CONSTRAINT oc_group_user_pkey PRIMARY KEY (gid, uid);


--
-- Name: oc_groups oc_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_groups
    ADD CONSTRAINT oc_groups_pkey PRIMARY KEY (gid);


--
-- Name: oc_job_classes_registry oc_job_classes_registry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_job_classes_registry
    ADD CONSTRAINT oc_job_classes_registry_pkey PRIMARY KEY (class_id);


--
-- Name: oc_job_runs oc_job_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_job_runs
    ADD CONSTRAINT oc_job_runs_pkey PRIMARY KEY (run_id);


--
-- Name: oc_jobs oc_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_jobs
    ADD CONSTRAINT oc_jobs_pkey PRIMARY KEY (id);


--
-- Name: oc_known_users oc_known_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_known_users
    ADD CONSTRAINT oc_known_users_pkey PRIMARY KEY (id);


--
-- Name: oc_login_flow_v2 oc_login_flow_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_login_flow_v2
    ADD CONSTRAINT oc_login_flow_v2_pkey PRIMARY KEY (id);


--
-- Name: oc_migrations oc_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_migrations
    ADD CONSTRAINT oc_migrations_pkey PRIMARY KEY (app, version);


--
-- Name: oc_mimetypes oc_mimetypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_mimetypes
    ADD CONSTRAINT oc_mimetypes_pkey PRIMARY KEY (id);


--
-- Name: oc_mounts oc_mounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_mounts
    ADD CONSTRAINT oc_mounts_pkey PRIMARY KEY (id);


--
-- Name: oc_notifications oc_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_notifications
    ADD CONSTRAINT oc_notifications_pkey PRIMARY KEY (notification_id);


--
-- Name: oc_notifications_pushhash oc_notifications_pushhash_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_notifications_pushhash
    ADD CONSTRAINT oc_notifications_pushhash_pkey PRIMARY KEY (id);


--
-- Name: oc_notifications_settings oc_notifications_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_notifications_settings
    ADD CONSTRAINT oc_notifications_settings_pkey PRIMARY KEY (id);


--
-- Name: oc_notifications_webpush oc_notifications_webpush_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_notifications_webpush
    ADD CONSTRAINT oc_notifications_webpush_pkey PRIMARY KEY (id);


--
-- Name: oc_oauth2_access_tokens oc_oauth2_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_oauth2_access_tokens
    ADD CONSTRAINT oc_oauth2_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oc_oauth2_clients oc_oauth2_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_oauth2_clients
    ADD CONSTRAINT oc_oauth2_clients_pkey PRIMARY KEY (id);


--
-- Name: oc_open_local_editor oc_open_local_editor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_open_local_editor
    ADD CONSTRAINT oc_open_local_editor_pkey PRIMARY KEY (id);


--
-- Name: oc_photos_albums_collabs oc_photos_albums_collabs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_photos_albums_collabs
    ADD CONSTRAINT oc_photos_albums_collabs_pkey PRIMARY KEY (id);


--
-- Name: oc_photos_albums_files oc_photos_albums_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_photos_albums_files
    ADD CONSTRAINT oc_photos_albums_files_pkey PRIMARY KEY (album_file_id);


--
-- Name: oc_photos_albums oc_photos_albums_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_photos_albums
    ADD CONSTRAINT oc_photos_albums_pkey PRIMARY KEY (album_id);


--
-- Name: oc_preferences_ex oc_preferences_ex_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_preferences_ex
    ADD CONSTRAINT oc_preferences_ex_pkey PRIMARY KEY (id);


--
-- Name: oc_preferences oc_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_preferences
    ADD CONSTRAINT oc_preferences_pkey PRIMARY KEY (userid, appid, configkey);


--
-- Name: oc_preview_locations oc_preview_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_preview_locations
    ADD CONSTRAINT oc_preview_locations_pkey PRIMARY KEY (id);


--
-- Name: oc_preview_versions oc_preview_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_preview_versions
    ADD CONSTRAINT oc_preview_versions_pkey PRIMARY KEY (id);


--
-- Name: oc_previews oc_previews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_previews
    ADD CONSTRAINT oc_previews_pkey PRIMARY KEY (id);


--
-- Name: oc_privacy_admins oc_privacy_admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_privacy_admins
    ADD CONSTRAINT oc_privacy_admins_pkey PRIMARY KEY (id);


--
-- Name: oc_profile_config oc_profile_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_profile_config
    ADD CONSTRAINT oc_profile_config_pkey PRIMARY KEY (id);


--
-- Name: oc_properties oc_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_properties
    ADD CONSTRAINT oc_properties_pkey PRIMARY KEY (id);


--
-- Name: oc_ratelimit_entries oc_ratelimit_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_ratelimit_entries
    ADD CONSTRAINT oc_ratelimit_entries_pkey PRIMARY KEY (id);


--
-- Name: oc_reactions oc_reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_reactions
    ADD CONSTRAINT oc_reactions_pkey PRIMARY KEY (id);


--
-- Name: oc_recent_contact oc_recent_contact_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_recent_contact
    ADD CONSTRAINT oc_recent_contact_pkey PRIMARY KEY (id);


--
-- Name: oc_schedulingobjects oc_schedulingobjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_schedulingobjects
    ADD CONSTRAINT oc_schedulingobjects_pkey PRIMARY KEY (id);


--
-- Name: oc_sec_signatory oc_sec_signatory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_sec_signatory
    ADD CONSTRAINT oc_sec_signatory_pkey PRIMARY KEY (id);


--
-- Name: oc_share_external oc_share_external_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_share_external
    ADD CONSTRAINT oc_share_external_pkey PRIMARY KEY (id);


--
-- Name: oc_share oc_share_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_share
    ADD CONSTRAINT oc_share_pkey PRIMARY KEY (id);


--
-- Name: oc_shares_limits oc_shares_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_shares_limits
    ADD CONSTRAINT oc_shares_limits_pkey PRIMARY KEY (id);


--
-- Name: oc_storages_credentials oc_storages_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_storages_credentials
    ADD CONSTRAINT oc_storages_credentials_pkey PRIMARY KEY (id);


--
-- Name: oc_storages oc_storages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_storages
    ADD CONSTRAINT oc_storages_pkey PRIMARY KEY (numeric_id);


--
-- Name: oc_systemtag_group oc_systemtag_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_systemtag_group
    ADD CONSTRAINT oc_systemtag_group_pkey PRIMARY KEY (gid, systemtagid);


--
-- Name: oc_systemtag_object_mapping oc_systemtag_object_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_systemtag_object_mapping
    ADD CONSTRAINT oc_systemtag_object_mapping_pkey PRIMARY KEY (objecttype, objectid, systemtagid);


--
-- Name: oc_systemtag oc_systemtag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_systemtag
    ADD CONSTRAINT oc_systemtag_pkey PRIMARY KEY (id);


--
-- Name: oc_taskprocessing_tasks oc_taskprocessing_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_taskprocessing_tasks
    ADD CONSTRAINT oc_taskprocessing_tasks_pkey PRIMARY KEY (id);


--
-- Name: oc_text2image_tasks oc_text2image_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_text2image_tasks
    ADD CONSTRAINT oc_text2image_tasks_pkey PRIMARY KEY (id);


--
-- Name: oc_text_documents oc_text_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_text_documents
    ADD CONSTRAINT oc_text_documents_pkey PRIMARY KEY (id);


--
-- Name: oc_text_sessions oc_text_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_text_sessions
    ADD CONSTRAINT oc_text_sessions_pkey PRIMARY KEY (id);


--
-- Name: oc_text_steps oc_text_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_text_steps
    ADD CONSTRAINT oc_text_steps_pkey PRIMARY KEY (id);


--
-- Name: oc_textprocessing_tasks oc_textprocessing_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_textprocessing_tasks
    ADD CONSTRAINT oc_textprocessing_tasks_pkey PRIMARY KEY (id);


--
-- Name: oc_trusted_servers oc_trusted_servers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_trusted_servers
    ADD CONSTRAINT oc_trusted_servers_pkey PRIMARY KEY (id);


--
-- Name: oc_twofactor_backupcodes oc_twofactor_backupcodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_twofactor_backupcodes
    ADD CONSTRAINT oc_twofactor_backupcodes_pkey PRIMARY KEY (id);


--
-- Name: oc_twofactor_providers oc_twofactor_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_twofactor_providers
    ADD CONSTRAINT oc_twofactor_providers_pkey PRIMARY KEY (provider_id, uid);


--
-- Name: oc_twofactor_totp_secrets oc_twofactor_totp_secrets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_twofactor_totp_secrets
    ADD CONSTRAINT oc_twofactor_totp_secrets_pkey PRIMARY KEY (id);


--
-- Name: oc_user_status oc_user_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_user_status
    ADD CONSTRAINT oc_user_status_pkey PRIMARY KEY (id);


--
-- Name: oc_user_transfer_owner oc_user_transfer_owner_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_user_transfer_owner
    ADD CONSTRAINT oc_user_transfer_owner_pkey PRIMARY KEY (id);


--
-- Name: oc_users oc_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_users
    ADD CONSTRAINT oc_users_pkey PRIMARY KEY (uid);


--
-- Name: oc_vcategory oc_vcategory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_vcategory
    ADD CONSTRAINT oc_vcategory_pkey PRIMARY KEY (id);


--
-- Name: oc_vcategory_to_object oc_vcategory_to_object_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_vcategory_to_object
    ADD CONSTRAINT oc_vcategory_to_object_pkey PRIMARY KEY (categoryid, objid, type);


--
-- Name: oc_webauthn oc_webauthn_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_webauthn
    ADD CONSTRAINT oc_webauthn_pkey PRIMARY KEY (id);


--
-- Name: oc_webhook_listeners oc_webhook_listeners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_webhook_listeners
    ADD CONSTRAINT oc_webhook_listeners_pkey PRIMARY KEY (id);


--
-- Name: oc_webhook_tokens oc_webhook_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_webhook_tokens
    ADD CONSTRAINT oc_webhook_tokens_pkey PRIMARY KEY (id);


--
-- Name: oc_federated_invites uniq_a2c17d5a5f37a13b; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oc_federated_invites
    ADD CONSTRAINT uniq_a2c17d5a5f37a13b UNIQUE (token);


--
-- Name: ac_lazy_i; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ac_lazy_i ON public.oc_appconfig USING btree (lazy);


--
-- Name: accounts_data_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX accounts_data_name ON public.oc_accounts_data USING btree (name);


--
-- Name: accounts_data_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX accounts_data_uid ON public.oc_accounts_data USING btree (uid);


--
-- Name: accounts_data_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX accounts_data_value ON public.oc_accounts_data USING btree (value);


--
-- Name: activity_filter; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activity_filter ON public.oc_activity USING btree (affecteduser, type, app, "timestamp");


--
-- Name: activity_filter_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activity_filter_by ON public.oc_activity USING btree (affecteduser, "user", "timestamp");


--
-- Name: activity_object; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activity_object ON public.oc_activity USING btree (object_type, object_id);


--
-- Name: activity_object_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activity_object_user ON public.oc_activity USING btree (affecteduser, object_type, object_id, "timestamp");


--
-- Name: activity_user_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activity_user_time ON public.oc_activity USING btree (affecteduser, "timestamp");


--
-- Name: addressbook_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX addressbook_index ON public.oc_addressbooks USING btree (principaluri, uri);


--
-- Name: addressbookid_synctoken; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX addressbookid_synctoken ON public.oc_addressbookchanges USING btree (addressbookid, synctoken);


--
-- Name: admindel_groupid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX admindel_groupid_idx ON public.oc_authorized_groups USING btree (group_id);


--
-- Name: album_collabs_uniq_collab; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX album_collabs_uniq_collab ON public.oc_photos_albums_collabs USING btree (album_id, collaborator_id, collaborator_type);


--
-- Name: amp_latest_send_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX amp_latest_send_time ON public.oc_activity_mq USING btree (amq_latest_send);


--
-- Name: amp_timestamp_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX amp_timestamp_time ON public.oc_activity_mq USING btree (amq_timestamp);


--
-- Name: amp_user_send; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX amp_user_send ON public.oc_activity_mq USING btree (amq_affecteduser, amq_latest_send);


--
-- Name: appconfig_ex__configkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX appconfig_ex__configkey ON public.oc_appconfig_ex USING btree (configkey);


--
-- Name: appconfig_ex__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX appconfig_ex__idx ON public.oc_appconfig_ex USING btree (appid, configkey);


--
-- Name: authtoken_last_activity_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX authtoken_last_activity_idx ON public.oc_authtoken USING btree (last_activity);


--
-- Name: authtoken_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX authtoken_token_index ON public.oc_authtoken USING btree (token);


--
-- Name: authtoken_uid_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX authtoken_uid_index ON public.oc_authtoken USING btree (uid);


--
-- Name: bruteforce_attempts_ip; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bruteforce_attempts_ip ON public.oc_bruteforce_attempts USING btree (ip);


--
-- Name: bruteforce_attempts_subnet; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bruteforce_attempts_subnet ON public.oc_bruteforce_attempts USING btree (subnet);


--
-- Name: calendar_invitation_tokens; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calendar_invitation_tokens ON public.oc_calendar_invitations USING btree (token);


--
-- Name: calendar_reminder_objid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calendar_reminder_objid ON public.oc_calendar_reminders USING btree (object_id);


--
-- Name: calendar_reminder_uidrec; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calendar_reminder_uidrec ON public.oc_calendar_reminders USING btree (uid, recurrence_id);


--
-- Name: calendar_resources_bkdrsc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calendar_resources_bkdrsc ON public.oc_calendar_resources USING btree (backend_id, resource_id);


--
-- Name: calendar_resources_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calendar_resources_email ON public.oc_calendar_resources USING btree (email);


--
-- Name: calendar_resources_md_idk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calendar_resources_md_idk ON public.oc_calendar_resources_md USING btree (resource_id, key);


--
-- Name: calendar_resources_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calendar_resources_name ON public.oc_calendar_resources USING btree (displayname);


--
-- Name: calendar_rooms_bkdrsc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calendar_rooms_bkdrsc ON public.oc_calendar_rooms USING btree (backend_id, resource_id);


--
-- Name: calendar_rooms_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calendar_rooms_email ON public.oc_calendar_rooms USING btree (email);


--
-- Name: calendar_rooms_md_idk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calendar_rooms_md_idk ON public.oc_calendar_rooms_md USING btree (room_id, key);


--
-- Name: calendar_rooms_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calendar_rooms_name ON public.oc_calendar_rooms USING btree (displayname);


--
-- Name: calendarobject_calid_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calendarobject_calid_index ON public.oc_calendarobjects_props USING btree (calendarid, calendartype);


--
-- Name: calendarobject_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calendarobject_index ON public.oc_calendarobjects_props USING btree (objectid, calendartype);


--
-- Name: calendarobject_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calendarobject_name_index ON public.oc_calendarobjects_props USING btree (name, calendartype);


--
-- Name: calendarobject_value_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calendarobject_value_index ON public.oc_calendarobjects_props USING btree (value, calendartype);


--
-- Name: calendars_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX calendars_index ON public.oc_calendars USING btree (principaluri, uri);


--
-- Name: calid_type_synctoken; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calid_type_synctoken ON public.oc_calendarchanges USING btree (calendarid, calendartype, synctoken);


--
-- Name: calobj_clssfction_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calobj_clssfction_index ON public.oc_calendarobjects USING btree (classification);


--
-- Name: calobjects_by_uid_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX calobjects_by_uid_index ON public.oc_calendarobjects USING btree (calendarid, calendartype, uid);


--
-- Name: calobjects_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX calobjects_index ON public.oc_calendarobjects USING btree (calendarid, calendartype, uri);


--
-- Name: cals_princ_del_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cals_princ_del_idx ON public.oc_calendars USING btree (principaluri, deleted_at);


--
-- Name: calsub_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX calsub_index ON public.oc_calendarsubscriptions USING btree (principaluri, uri);


--
-- Name: card_contactid_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX card_contactid_index ON public.oc_cards_properties USING btree (cardid);


--
-- Name: card_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX card_name_index ON public.oc_cards_properties USING btree (name);


--
-- Name: card_value_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX card_value_index ON public.oc_cards_properties USING btree (value);


--
-- Name: cards_abiduri; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cards_abiduri ON public.oc_cards USING btree (addressbookid, uri);


--
-- Name: cards_prop_abid_name_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cards_prop_abid_name_value ON public.oc_cards_properties USING btree (addressbookid, name, value);


--
-- Name: category_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX category_index ON public.oc_vcategory USING btree (category);


--
-- Name: circles_member_cisi; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX circles_member_cisi ON public.oc_circles_member USING btree (circle_id, single_id);


--
-- Name: circles_member_cisiuiutil; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX circles_member_cisiuiutil ON public.oc_circles_member USING btree (circle_id, single_id, user_id, user_type, instance, level);


--
-- Name: circles_membership_ifilci; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX circles_membership_ifilci ON public.oc_circles_membership USING btree (inheritance_first, inheritance_last, circle_id);


--
-- Name: circles_mount_cimipt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX circles_mount_cimipt ON public.oc_circles_mount USING btree (circle_id, mount_id, parent, token);


--
-- Name: circles_mountpoint_ms; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX circles_mountpoint_ms ON public.oc_circles_mountpoint USING btree (mount_id, single_id);


--
-- Name: collres_user_res; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX collres_user_res ON public.oc_collres_accesscache USING btree (user_id, resource_type, resource_id);


--
-- Name: comment_reaction; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comment_reaction ON public.oc_reactions USING btree (reaction);


--
-- Name: comment_reaction_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comment_reaction_parent_id ON public.oc_reactions USING btree (parent_id);


--
-- Name: comment_reaction_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX comment_reaction_unique ON public.oc_reactions USING btree (parent_id, actor_type, actor_id, reaction);


--
-- Name: comments_actor_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_actor_index ON public.oc_comments USING btree (actor_type, actor_id);


--
-- Name: comments_marker_object_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_marker_object_index ON public.oc_comments_read_markers USING btree (object_type, object_id);


--
-- Name: comments_object_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_object_index ON public.oc_comments USING btree (object_type, object_id, creation_timestamp);


--
-- Name: comments_parent_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_parent_id_index ON public.oc_comments USING btree (parent_id);


--
-- Name: comments_topmost_parent_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_topmost_parent_id_idx ON public.oc_comments USING btree (topmost_parent_id);


--
-- Name: dav_absence_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dav_absence_uid_idx ON public.oc_dav_absence USING btree (user_id);


--
-- Name: dav_cal_proxy_ipid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dav_cal_proxy_ipid ON public.oc_dav_cal_proxy USING btree (proxy_id);


--
-- Name: dav_cal_proxy_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dav_cal_proxy_uidx ON public.oc_dav_cal_proxy USING btree (owner_id, proxy_id, permissions);


--
-- Name: dav_shares_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dav_shares_index ON public.oc_dav_shares USING btree (principaluri, resourceid, type, publicuri);


--
-- Name: dav_shares_resourceid_access; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dav_shares_resourceid_access ON public.oc_dav_shares USING btree (resourceid, access);


--
-- Name: dav_shares_resourceid_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dav_shares_resourceid_type ON public.oc_dav_shares USING btree (resourceid, type);


--
-- Name: deploy_options__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX deploy_options__idx ON public.oc_ex_deploy_options USING btree (appid, type);


--
-- Name: direct_edit_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX direct_edit_timestamp ON public.oc_direct_edit USING btree ("timestamp");


--
-- Name: directlink_expiration_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX directlink_expiration_idx ON public.oc_directlink USING btree (expiration);


--
-- Name: directlink_token_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX directlink_token_idx ON public.oc_directlink USING btree (token);


--
-- Name: dname; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dname ON public.oc_circles_circle USING btree (display_name);


--
-- Name: ex_apps__appid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ex_apps__appid ON public.oc_ex_apps USING btree (appid);


--
-- Name: ex_apps_c_port__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ex_apps_c_port__idx ON public.oc_ex_apps USING btree (daemon_config_name, port);


--
-- Name: ex_apps_daemons__name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ex_apps_daemons__name ON public.oc_ex_apps_daemons USING btree (name);


--
-- Name: ex_apps_routes_appid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ex_apps_routes_appid ON public.oc_ex_apps_routes USING btree (appid);


--
-- Name: ex_apps_talk_bots__app_route; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ex_apps_talk_bots__app_route ON public.oc_ex_apps_talk_bots USING btree (appid, route);


--
-- Name: ex_apps_talk_bots__appid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ex_apps_talk_bots__appid ON public.oc_ex_apps_talk_bots USING btree (appid);


--
-- Name: ex_occ_commands__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ex_occ_commands__idx ON public.oc_ex_occ_commands USING btree (appid, name);


--
-- Name: ex_settings_forms__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ex_settings_forms__idx ON public.oc_ex_settings_forms USING btree (appid, formid);


--
-- Name: ex_ui_files_actions__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ex_ui_files_actions__idx ON public.oc_ex_ui_files_actions USING btree (appid, name);


--
-- Name: expire_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX expire_date ON public.oc_comments USING btree (expire_date);


--
-- Name: f_meta_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX f_meta_index ON public.oc_files_metadata_index USING btree (file_id, meta_key, meta_value_string);


--
-- Name: f_meta_index_i; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX f_meta_index_i ON public.oc_files_metadata_index USING btree (file_id, meta_key, meta_value_int);


--
-- Name: fce_ctime_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fce_ctime_idx ON public.oc_filecache_extended USING btree (creation_time);


--
-- Name: fce_utime_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fce_utime_idx ON public.oc_filecache_extended USING btree (upload_time);


--
-- Name: fedcals_last_sync_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fedcals_last_sync_index ON public.oc_calendars_federated USING btree (last_sync);


--
-- Name: fedcals_uris_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fedcals_uris_index ON public.oc_calendars_federated USING btree (principaluri, uri);


--
-- Name: file_source_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX file_source_index ON public.oc_share USING btree (file_source);


--
-- Name: files_meta_fileid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX files_meta_fileid ON public.oc_files_metadata USING btree (file_id);


--
-- Name: files_versions_uniq_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX files_versions_uniq_index ON public.oc_files_versions USING btree (file_id, "timestamp");


--
-- Name: flow_unique_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX flow_unique_hash ON public.oc_flow_checks USING btree (hash);


--
-- Name: flow_unique_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX flow_unique_scope ON public.oc_flow_operations_scope USING btree (operation_id, type, value);


--
-- Name: fs_mtime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fs_mtime ON public.oc_filecache USING btree (mtime);


--
-- Name: fs_name_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fs_name_hash ON public.oc_filecache USING btree (name);


--
-- Name: fs_parent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fs_parent ON public.oc_filecache USING btree (parent);


--
-- Name: fs_parent_name_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fs_parent_name_hash ON public.oc_filecache USING btree (parent, name);


--
-- Name: fs_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fs_size ON public.oc_filecache USING btree (size);


--
-- Name: fs_storage_mimepart; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fs_storage_mimepart ON public.oc_filecache USING btree (storage, mimepart);


--
-- Name: fs_storage_mimetype; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fs_storage_mimetype ON public.oc_filecache USING btree (storage, mimetype);


--
-- Name: fs_storage_path_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX fs_storage_path_hash ON public.oc_filecache USING btree (storage, path_hash);


--
-- Name: fs_storage_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fs_storage_size ON public.oc_filecache USING btree (storage, size, fileid);


--
-- Name: group_admin_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX group_admin_uid ON public.oc_group_admin USING btree (uid);


--
-- Name: gu_uid_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX gu_uid_index ON public.oc_group_user USING btree (uid);


--
-- Name: id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX id_index ON public.oc_files_trash USING btree (id);


--
-- Name: idx_25c66a49e7a1254a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_25c66a49e7a1254a ON public.oc_circles_member USING btree (contact_id);


--
-- Name: idx_4d5afeca5f37a13b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_4d5afeca5f37a13b ON public.oc_direct_edit USING btree (token);


--
-- Name: idx_67dc472793cb796c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_67dc472793cb796c ON public.oc_previews USING btree (file_id);


--
-- Name: idx_71b028ea93cb796c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_71b028ea93cb796c ON public.oc_files_lock USING btree (file_id);


--
-- Name: idx_8195f5484230b1de; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_8195f5484230b1de ON public.oc_circles_circle USING btree (instance);


--
-- Name: idx_8195f5485f8a7f73; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_8195f5485f8a7f73 ON public.oc_circles_circle USING btree (source);


--
-- Name: idx_8195f548c317b362; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_8195f548c317b362 ON public.oc_circles_circle USING btree (sanitized_name);


--
-- Name: idx_8195f548d48a2f7c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_8195f548d48a2f7c ON public.oc_circles_circle USING btree (config);


--
-- Name: idx_8fc816eae7c1d92b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_8fc816eae7c1d92b ON public.oc_circles_membership USING btree (single_id);


--
-- Name: idx_f94ef8334f8e741; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_f94ef8334f8e741 ON public.oc_circles_remote USING btree (href);


--
-- Name: idx_f94ef83539b0606; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_f94ef83539b0606 ON public.oc_circles_remote USING btree (uid);


--
-- Name: initiator_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX initiator_index ON public.oc_share USING btree (uid_initiator);


--
-- Name: item_share_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX item_share_type_index ON public.oc_share USING btree (item_type, share_type);


--
-- Name: job_argument_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_argument_hash ON public.oc_jobs USING btree (class, argument_hash);


--
-- Name: job_class_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_class_index ON public.oc_jobs USING btree (class);


--
-- Name: job_lastcheck_reserved; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX job_lastcheck_reserved ON public.oc_jobs USING btree (last_checked, reserved_at);


--
-- Name: jobs_time_sensitive; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX jobs_time_sensitive ON public.oc_jobs USING btree (time_sensitive);


--
-- Name: ku_known_to; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ku_known_to ON public.oc_known_users USING btree (known_to);


--
-- Name: ku_known_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ku_known_user ON public.oc_known_users USING btree (known_user);


--
-- Name: lock_key_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lock_key_index ON public.oc_file_locks USING btree (key);


--
-- Name: lock_ttl_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lock_ttl_index ON public.oc_file_locks USING btree (ttl);


--
-- Name: login_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX login_token ON public.oc_login_flow_v2 USING btree (login_token);


--
-- Name: m_sid_rmt_rid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX m_sid_rmt_rid ON public.oc_circles_mount USING btree (circle_id, remote, remote_id);


--
-- Name: mimetype_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mimetype_id_index ON public.oc_mimetypes USING btree (mimetype);


--
-- Name: mount_user_storage; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mount_user_storage ON public.oc_mounts USING btree (storage_id, user_id);


--
-- Name: mounts_class_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mounts_class_index ON public.oc_mounts USING btree (mount_provider_class);


--
-- Name: mounts_mount_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mounts_mount_id_index ON public.oc_mounts USING btree (mount_id);


--
-- Name: mounts_root_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mounts_root_index ON public.oc_mounts USING btree (root_id);


--
-- Name: mounts_storage_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mounts_storage_index ON public.oc_mounts USING btree (storage_id);


--
-- Name: mounts_user_path_root_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mounts_user_path_root_index ON public.oc_mounts USING btree (user_id, mount_point_hash, root_id);


--
-- Name: mp_sid_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mp_sid_hash ON public.oc_circles_mountpoint USING btree (single_id, mountpoint_hash);


--
-- Name: notifwebpush_endpoint; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifwebpush_endpoint ON public.oc_notifications_webpush USING btree (endpoint);


--
-- Name: notifwebpush_uid_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX notifwebpush_uid_token ON public.oc_notifications_webpush USING btree (uid, token);


--
-- Name: notset_nextsend; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notset_nextsend ON public.oc_notifications_settings USING btree (next_send_time);


--
-- Name: notset_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX notset_user ON public.oc_notifications_settings USING btree (user_id);


--
-- Name: oauth2_access_client_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth2_access_client_id_idx ON public.oc_oauth2_access_tokens USING btree (client_id);


--
-- Name: oauth2_access_hash_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX oauth2_access_hash_idx ON public.oc_oauth2_access_tokens USING btree (hashed_code);


--
-- Name: oauth2_client_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX oauth2_client_id_idx ON public.oc_oauth2_clients USING btree (client_identifier);


--
-- Name: oauth2_tk_c_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth2_tk_c_created_idx ON public.oc_oauth2_access_tokens USING btree (token_count, code_created_at);


--
-- Name: oc_notifications_app; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oc_notifications_app ON public.oc_notifications USING btree (app);


--
-- Name: oc_notifications_object; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oc_notifications_object ON public.oc_notifications USING btree (object_type, object_id);


--
-- Name: oc_notifications_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oc_notifications_timestamp ON public.oc_notifications USING btree ("timestamp");


--
-- Name: oc_notifications_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oc_notifications_user ON public.oc_notifications USING btree ("user");


--
-- Name: oc_npushhash_di; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oc_npushhash_di ON public.oc_notifications_pushhash USING btree (deviceidentifier);


--
-- Name: oc_npushhash_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX oc_npushhash_uid ON public.oc_notifications_pushhash USING btree (uid, token);


--
-- Name: openlocal_user_path_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX openlocal_user_path_token ON public.oc_open_local_editor USING btree (user_id, path_hash, token);


--
-- Name: owner_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX owner_index ON public.oc_share USING btree (uid_owner);


--
-- Name: pa_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pa_user ON public.oc_photos_albums USING btree ("user");


--
-- Name: paf_album_file; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX paf_album_file ON public.oc_photos_albums_files USING btree (album_id, file_id);


--
-- Name: paf_folder; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX paf_folder ON public.oc_photos_albums_files USING btree (album_id);


--
-- Name: parent_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX parent_index ON public.oc_share USING btree (parent);


--
-- Name: poll_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX poll_token ON public.oc_login_flow_v2 USING btree (poll_token);


--
-- Name: preferences_ex__configkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX preferences_ex__configkey ON public.oc_preferences_ex USING btree (configkey);


--
-- Name: preferences_ex__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX preferences_ex__idx ON public.oc_preferences_ex USING btree (userid, appid, configkey);


--
-- Name: prefs_app_key_ind_fl_i; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prefs_app_key_ind_fl_i ON public.oc_preferences USING btree (appid, configkey, indexed, flags);


--
-- Name: prefs_uid_lazy_i; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prefs_uid_lazy_i ON public.oc_preferences USING btree (userid, lazy);


--
-- Name: previews_file_uniq_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX previews_file_uniq_idx ON public.oc_previews USING btree (file_id, width, height, mimetype_id, cropped, version_id);


--
-- Name: profile_config_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX profile_config_user_id_idx ON public.oc_profile_config USING btree (user_id);


--
-- Name: properties_name_path_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX properties_name_path_user ON public.oc_properties USING btree (propertyname, propertypath, userid);


--
-- Name: properties_path_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX properties_path_index ON public.oc_properties USING btree (userid, propertypath);


--
-- Name: properties_pathonly_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX properties_pathonly_index ON public.oc_properties USING btree (propertypath);


--
-- Name: ratelimit_delete_after; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ratelimit_delete_after ON public.oc_ratelimit_entries USING btree (delete_after);


--
-- Name: ratelimit_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ratelimit_hash ON public.oc_ratelimit_entries USING btree (hash);


--
-- Name: rd_session_token_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rd_session_token_idx ON public.oc_text_sessions USING btree (token);


--
-- Name: rd_steps_did_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rd_steps_did_idx ON public.oc_text_steps USING btree (document_id);


--
-- Name: rd_steps_version_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rd_steps_version_idx ON public.oc_text_steps USING btree (version);


--
-- Name: recent_contact_actor_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX recent_contact_actor_uid ON public.oc_recent_contact USING btree (actor_uid);


--
-- Name: recent_contact_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX recent_contact_email ON public.oc_recent_contact USING btree (email);


--
-- Name: recent_contact_fed_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX recent_contact_fed_id ON public.oc_recent_contact USING btree (federated_cloud_id);


--
-- Name: recent_contact_id_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX recent_contact_id_uid ON public.oc_recent_contact USING btree (id, actor_uid);


--
-- Name: recent_contact_last_contact; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX recent_contact_last_contact ON public.oc_recent_contact USING btree (last_contact);


--
-- Name: recent_contact_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX recent_contact_uid ON public.oc_recent_contact USING btree (uid);


--
-- Name: reminders_uniq_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX reminders_uniq_idx ON public.oc_files_reminders USING btree (user_id, file_id, due_date);


--
-- Name: schedulobj_lastmodified_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX schedulobj_lastmodified_idx ON public.oc_schedulingobjects USING btree (lastmodified);


--
-- Name: schedulobj_principuri_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX schedulobj_principuri_index ON public.oc_schedulingobjects USING btree (principaluri);


--
-- Name: sec_sig_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sec_sig_key ON public.oc_sec_signatory USING btree (key_id_sum, provider_id);


--
-- Name: sec_sig_unic; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sec_sig_unic ON public.oc_sec_signatory USING btree (provider_id, host, account);


--
-- Name: sh_external_mp; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sh_external_mp ON public.oc_share_external USING btree ("user", mountpoint_hash);


--
-- Name: share_with_file_target_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX share_with_file_target_index ON public.oc_share USING btree (share_with, file_target);


--
-- Name: share_with_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX share_with_index ON public.oc_share USING btree (share_with);


--
-- Name: sicisimit; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sicisimit ON public.oc_circles_token USING btree (share_id, circle_id, single_id, member_id, token);


--
-- Name: status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX status ON public.oc_job_runs USING btree (status);


--
-- Name: stocred_ui; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX stocred_ui ON public.oc_storages_credentials USING btree ("user", identifier);


--
-- Name: stocred_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stocred_user ON public.oc_storages_credentials USING btree ("user");


--
-- Name: storages_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX storages_id_index ON public.oc_storages USING btree (id);


--
-- Name: systag_by_objectid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX systag_by_objectid ON public.oc_systemtag_object_mapping USING btree (objectid);


--
-- Name: systag_by_tagid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX systag_by_tagid ON public.oc_systemtag_object_mapping USING btree (systemtagid, objecttype);


--
-- Name: systag_objecttype; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX systag_objecttype ON public.oc_systemtag_object_mapping USING btree (objecttype);


--
-- Name: t2i_tasks_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX t2i_tasks_status ON public.oc_text2image_tasks USING btree (status);


--
-- Name: t2i_tasks_uid_appid_ident; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX t2i_tasks_uid_appid_ident ON public.oc_text2image_tasks USING btree (user_id, app_id, identifier);


--
-- Name: t2i_tasks_updated; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX t2i_tasks_updated ON public.oc_text2image_tasks USING btree (last_updated);


--
-- Name: tag_ident; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tag_ident ON public.oc_systemtag USING btree (name, visibility, editable);


--
-- Name: task_processing_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX task_processing_idx ON public.oc_ex_task_processing USING btree (app_id, name, task_type);


--
-- Name: taskp_status_type_upd; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX taskp_status_type_upd ON public.oc_taskprocessing_tasks USING btree (status, type, last_updated);


--
-- Name: taskp_tasks_status_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX taskp_tasks_status_type ON public.oc_taskprocessing_tasks USING btree (status, type);


--
-- Name: taskp_tasks_uid_appid_cid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX taskp_tasks_uid_appid_cid ON public.oc_taskprocessing_tasks USING btree (user_id, app_id, custom_id);


--
-- Name: taskp_tasks_updated; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX taskp_tasks_updated ON public.oc_taskprocessing_tasks USING btree (last_updated);


--
-- Name: textstep_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX textstep_session ON public.oc_text_steps USING btree (session_id);


--
-- Name: timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "timestamp" ON public.oc_login_flow_v2 USING btree ("timestamp");


--
-- Name: timestamp_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX timestamp_index ON public.oc_files_trash USING btree ("timestamp");


--
-- Name: token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX token_index ON public.oc_share USING btree (token);


--
-- Name: totp_secrets_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX totp_secrets_user_id ON public.oc_twofactor_totp_secrets USING btree (user_id);


--
-- Name: tp_tasks_status_type_nonunique; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tp_tasks_status_type_nonunique ON public.oc_textprocessing_tasks USING btree (status, type);


--
-- Name: tp_tasks_uid_appid_ident; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tp_tasks_uid_appid_ident ON public.oc_textprocessing_tasks USING btree (user_id, app_id, identifier);


--
-- Name: tp_tasks_updated; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tp_tasks_updated ON public.oc_textprocessing_tasks USING btree (last_updated);


--
-- Name: ts_docid_lastcontact; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ts_docid_lastcontact ON public.oc_text_sessions USING btree (document_id, last_contact);


--
-- Name: ts_lastcontact; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ts_lastcontact ON public.oc_text_sessions USING btree (last_contact);


--
-- Name: twofactor_backupcodes_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX twofactor_backupcodes_uid ON public.oc_twofactor_backupcodes USING btree (user_id);


--
-- Name: twofactor_providers_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX twofactor_providers_uid ON public.oc_twofactor_providers USING btree (uid);


--
-- Name: type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX type_index ON public.oc_vcategory USING btree (type);


--
-- Name: ui_script__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ui_script__idx ON public.oc_ex_ui_scripts USING btree (appid, type, name, path);


--
-- Name: ui_state__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ui_state__idx ON public.oc_ex_ui_states USING btree (appid, type, name, key);


--
-- Name: ui_style__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ui_style__idx ON public.oc_ex_ui_styles USING btree (appid, type, name, path);


--
-- Name: ui_top_menu__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ui_top_menu__idx ON public.oc_ex_ui_top_menu USING btree (appid, name);


--
-- Name: uid_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX uid_index ON public.oc_vcategory USING btree (uid);


--
-- Name: uniq_337f52f8126f525e70ee2ff6; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_337f52f8126f525e70ee2ff6 ON public.oc_circles_share_lock USING btree (item_id, circle_id);


--
-- Name: uniq_71b028ea5f37a13b; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_71b028ea5f37a13b ON public.oc_files_lock USING btree (token);


--
-- Name: uniq_8195f548e3c68343; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_8195f548e3c68343 ON public.oc_circles_circle USING btree (unique_id);


--
-- Name: uniq_f94ef834230b1de; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_f94ef834230b1de ON public.oc_circles_remote USING btree (instance);


--
-- Name: unique_bucket_store; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_bucket_store ON public.oc_preview_locations USING btree (bucket_name, object_store_name);


--
-- Name: unique_category_per_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_category_per_user ON public.oc_vcategory USING btree (uid, type, category);


--
-- Name: url_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX url_hash ON public.oc_trusted_servers USING btree (url_hash);


--
-- Name: user_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_index ON public.oc_files_trash USING btree ("user");


--
-- Name: user_mountpoint_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_mountpoint_index ON public.oc_share_external USING btree ("user", mountpoint);


--
-- Name: user_status_clr_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_status_clr_ix ON public.oc_user_status USING btree (clear_at);


--
-- Name: user_status_iud_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_status_iud_ix ON public.oc_user_status USING btree (is_user_defined, status);


--
-- Name: user_status_mtstmp_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_status_mtstmp_ix ON public.oc_user_status USING btree (status_message_timestamp);


--
-- Name: user_status_tstmp_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_status_tstmp_ix ON public.oc_user_status USING btree (status_timestamp);


--
-- Name: user_status_uid_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_status_uid_ix ON public.oc_user_status USING btree (user_id);


--
-- Name: user_uid_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_uid_lower ON public.oc_users USING btree (uid_lower);


--
-- Name: vcategory_objectd_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX vcategory_objectd_index ON public.oc_vcategory_to_object USING btree (objid, type);


--
-- Name: webauthn_publickeycredentialid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX webauthn_publickeycredentialid ON public.oc_webauthn USING btree (public_key_credential_id);


--
-- Name: webauthn_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX webauthn_uid ON public.oc_webauthn USING btree (uid);


--
-- PostgreSQL database dump complete
--


