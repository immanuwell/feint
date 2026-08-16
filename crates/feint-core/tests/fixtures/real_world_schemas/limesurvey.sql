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
-- Name: lime_answer_l10ns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_answer_l10ns (
    id integer NOT NULL,
    aid integer NOT NULL,
    answer text NOT NULL,
    language character varying(20) NOT NULL
);


--
-- Name: lime_answer_l10ns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_answer_l10ns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_answer_l10ns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_answer_l10ns_id_seq OWNED BY public.lime_answer_l10ns.id;


--
-- Name: lime_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_answers (
    aid integer NOT NULL,
    qid integer NOT NULL,
    code character varying(5) NOT NULL,
    sortorder integer NOT NULL,
    assessment_value integer DEFAULT 0 NOT NULL,
    scale_id integer DEFAULT 0 NOT NULL
);


--
-- Name: lime_answers_aid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_answers_aid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_answers_aid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_answers_aid_seq OWNED BY public.lime_answers.aid;


--
-- Name: lime_archived_table_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_archived_table_settings (
    id integer NOT NULL,
    survey_id integer NOT NULL,
    user_id integer NOT NULL,
    tbl_name character varying(255) NOT NULL,
    tbl_type character varying(10) NOT NULL,
    created timestamp without time zone NOT NULL,
    properties text NOT NULL,
    attributes text
);


--
-- Name: lime_archived_table_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_archived_table_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_archived_table_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_archived_table_settings_id_seq OWNED BY public.lime_archived_table_settings.id;


--
-- Name: lime_assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_assessments (
    id integer NOT NULL,
    sid integer DEFAULT 0 NOT NULL,
    scope character varying(5) NOT NULL,
    gid integer DEFAULT 0 NOT NULL,
    name text NOT NULL,
    minimum character varying(50) NOT NULL,
    maximum character varying(50) NOT NULL,
    message text NOT NULL,
    language character varying(20) DEFAULT 'en'::character varying NOT NULL
);


--
-- Name: lime_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_assessments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_assessments_id_seq OWNED BY public.lime_assessments.id;


--
-- Name: lime_asset_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_asset_version (
    id integer NOT NULL,
    path text NOT NULL,
    version integer NOT NULL
);


--
-- Name: lime_asset_version_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_asset_version_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_asset_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_asset_version_id_seq OWNED BY public.lime_asset_version.id;


--
-- Name: lime_boxes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_boxes (
    id integer NOT NULL,
    "position" integer,
    url text NOT NULL,
    title text NOT NULL,
    buttontext character varying(255),
    ico character varying(255),
    "desc" text NOT NULL,
    page text NOT NULL,
    usergroup integer NOT NULL
);


--
-- Name: lime_boxes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_boxes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_boxes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_boxes_id_seq OWNED BY public.lime_boxes.id;


--
-- Name: lime_conditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_conditions (
    cid integer NOT NULL,
    qid integer DEFAULT 0 NOT NULL,
    cqid integer DEFAULT 0 NOT NULL,
    cfieldname character varying(50) DEFAULT ''::character varying NOT NULL,
    method character varying(5) DEFAULT ''::character varying NOT NULL,
    value character varying(255) DEFAULT ''::character varying NOT NULL,
    scenario integer DEFAULT 1 NOT NULL
);


--
-- Name: lime_conditions_cid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_conditions_cid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_conditions_cid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_conditions_cid_seq OWNED BY public.lime_conditions.cid;


--
-- Name: lime_defaultvalue_l10ns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_defaultvalue_l10ns (
    id integer NOT NULL,
    dvid integer DEFAULT 0 NOT NULL,
    language character varying(20) NOT NULL,
    defaultvalue text
);


--
-- Name: lime_defaultvalue_l10ns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_defaultvalue_l10ns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_defaultvalue_l10ns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_defaultvalue_l10ns_id_seq OWNED BY public.lime_defaultvalue_l10ns.id;


--
-- Name: lime_defaultvalues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_defaultvalues (
    dvid integer NOT NULL,
    qid integer DEFAULT 0 NOT NULL,
    scale_id integer DEFAULT 0 NOT NULL,
    sqid integer DEFAULT 0 NOT NULL,
    specialtype character varying(20) DEFAULT ''::character varying NOT NULL
);


--
-- Name: lime_defaultvalues_dvid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_defaultvalues_dvid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_defaultvalues_dvid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_defaultvalues_dvid_seq OWNED BY public.lime_defaultvalues.dvid;


--
-- Name: lime_expression_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_expression_errors (
    id integer NOT NULL,
    errortime character varying(50),
    sid integer,
    gid integer,
    qid integer,
    gseq integer,
    qseq integer,
    type character varying(50),
    eqn text,
    prettyprint text
);


--
-- Name: lime_expression_errors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_expression_errors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_expression_errors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_expression_errors_id_seq OWNED BY public.lime_expression_errors.id;


--
-- Name: lime_failed_emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_failed_emails (
    id integer NOT NULL,
    surveyid integer NOT NULL,
    responseid integer NOT NULL,
    email_type character varying(200) NOT NULL,
    recipient character varying(320) NOT NULL,
    language character varying(20) DEFAULT 'en'::character varying NOT NULL,
    error_message text,
    created timestamp without time zone NOT NULL,
    status character varying(20) DEFAULT 'SEND FAILED'::character varying,
    updated timestamp without time zone,
    resend_vars text NOT NULL
);


--
-- Name: lime_failed_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_failed_emails_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_failed_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_failed_emails_id_seq OWNED BY public.lime_failed_emails.id;


--
-- Name: lime_failed_login_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_failed_login_attempts (
    id integer NOT NULL,
    ip character varying(40) NOT NULL,
    last_attempt character varying(20) NOT NULL,
    number_attempts integer NOT NULL,
    is_frontend boolean NOT NULL
);


--
-- Name: lime_failed_login_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_failed_login_attempts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_failed_login_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_failed_login_attempts_id_seq OWNED BY public.lime_failed_login_attempts.id;


--
-- Name: lime_group_l10ns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_group_l10ns (
    id integer NOT NULL,
    gid integer NOT NULL,
    group_name text NOT NULL,
    description text,
    language character varying(20) NOT NULL
);


--
-- Name: lime_group_l10ns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_group_l10ns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_group_l10ns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_group_l10ns_id_seq OWNED BY public.lime_group_l10ns.id;


--
-- Name: lime_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_groups (
    gid integer NOT NULL,
    sid integer DEFAULT 0 NOT NULL,
    group_order integer DEFAULT 0 NOT NULL,
    randomization_group character varying(20) DEFAULT ''::character varying NOT NULL,
    grelevance text
);


--
-- Name: lime_groups_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_groups_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_groups_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_groups_gid_seq OWNED BY public.lime_groups.gid;


--
-- Name: lime_label_l10ns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_label_l10ns (
    id integer NOT NULL,
    label_id integer NOT NULL,
    title text,
    language character varying(20) DEFAULT 'en'::character varying NOT NULL
);


--
-- Name: lime_label_l10ns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_label_l10ns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_label_l10ns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_label_l10ns_id_seq OWNED BY public.lime_label_l10ns.id;


--
-- Name: lime_labels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_labels (
    id integer NOT NULL,
    lid integer DEFAULT 0 NOT NULL,
    code character varying(20) DEFAULT ''::character varying NOT NULL,
    sortorder integer NOT NULL,
    assessment_value integer DEFAULT 0 NOT NULL
);


--
-- Name: lime_labels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_labels_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_labels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_labels_id_seq OWNED BY public.lime_labels.id;


--
-- Name: lime_labelsets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_labelsets (
    lid integer NOT NULL,
    owner_id integer,
    label_name character varying(100) DEFAULT ''::character varying NOT NULL,
    languages character varying(255) NOT NULL
);


--
-- Name: lime_labelsets_lid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_labelsets_lid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_labelsets_lid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_labelsets_lid_seq OWNED BY public.lime_labelsets.lid;


--
-- Name: lime_map_tutorial_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_map_tutorial_users (
    tid integer NOT NULL,
    uid integer NOT NULL,
    taken integer DEFAULT 1
);


--
-- Name: lime_message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_message (
    id integer NOT NULL,
    language character varying(50) DEFAULT ''::character varying NOT NULL,
    translation text
);


--
-- Name: lime_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_notifications (
    id integer NOT NULL,
    entity character varying(15) NOT NULL,
    entity_id integer NOT NULL,
    title character varying(255) NOT NULL,
    message text NOT NULL,
    status character varying(15) DEFAULT 'new'::character varying NOT NULL,
    importance integer DEFAULT 1 NOT NULL,
    display_class character varying(31) DEFAULT 'default'::character varying,
    hash character varying(64),
    created timestamp without time zone,
    first_read timestamp without time zone
);


--
-- Name: lime_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_notifications_id_seq OWNED BY public.lime_notifications.id;


--
-- Name: lime_participant_attribute; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_participant_attribute (
    participant_id character varying(50) NOT NULL,
    attribute_id integer NOT NULL,
    value text NOT NULL
);


--
-- Name: lime_participant_attribute_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_participant_attribute_names (
    attribute_id integer NOT NULL,
    attribute_type character varying(4) NOT NULL,
    defaultname character varying(255) NOT NULL,
    visible character varying(5) NOT NULL,
    encrypted character varying(5) NOT NULL,
    core_attribute character varying(5) NOT NULL
);


--
-- Name: lime_participant_attribute_names_attribute_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_participant_attribute_names_attribute_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_participant_attribute_names_attribute_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_participant_attribute_names_attribute_id_seq OWNED BY public.lime_participant_attribute_names.attribute_id;


--
-- Name: lime_participant_attribute_names_lang; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_participant_attribute_names_lang (
    attribute_id integer NOT NULL,
    attribute_name character varying(255) NOT NULL,
    lang character varying(20) NOT NULL
);


--
-- Name: lime_participant_attribute_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_participant_attribute_values (
    value_id integer NOT NULL,
    attribute_id integer NOT NULL,
    value text NOT NULL
);


--
-- Name: lime_participant_attribute_values_value_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_participant_attribute_values_value_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_participant_attribute_values_value_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_participant_attribute_values_value_id_seq OWNED BY public.lime_participant_attribute_values.value_id;


--
-- Name: lime_participant_shares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_participant_shares (
    participant_id character varying(50) NOT NULL,
    share_uid integer NOT NULL,
    date_added timestamp without time zone NOT NULL,
    can_edit character varying(5) NOT NULL
);


--
-- Name: lime_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_participants (
    participant_id character varying(50) NOT NULL,
    firstname text,
    lastname text,
    email text,
    language character varying(40),
    blacklisted character varying(1) NOT NULL,
    owner_uid integer NOT NULL,
    created_by integer NOT NULL,
    created timestamp without time zone,
    modified timestamp without time zone
);


--
-- Name: lime_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_permissions (
    id integer NOT NULL,
    entity character varying(50) NOT NULL,
    entity_id integer NOT NULL,
    uid integer NOT NULL,
    permission character varying(100) NOT NULL,
    create_p integer DEFAULT 0 NOT NULL,
    read_p integer DEFAULT 0 NOT NULL,
    update_p integer DEFAULT 0 NOT NULL,
    delete_p integer DEFAULT 0 NOT NULL,
    import_p integer DEFAULT 0 NOT NULL,
    export_p integer DEFAULT 0 NOT NULL
);


--
-- Name: lime_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_permissions_id_seq OWNED BY public.lime_permissions.id;


--
-- Name: lime_permissiontemplates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_permissiontemplates (
    ptid integer NOT NULL,
    name character varying(127) NOT NULL,
    description text,
    renewed_last timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    created_by integer NOT NULL
);


--
-- Name: lime_permissiontemplates_ptid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_permissiontemplates_ptid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_permissiontemplates_ptid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_permissiontemplates_ptid_seq OWNED BY public.lime_permissiontemplates.ptid;


--
-- Name: lime_plugin_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_plugin_settings (
    id integer NOT NULL,
    plugin_id integer NOT NULL,
    model character varying(50),
    model_id integer,
    key character varying(50) NOT NULL,
    value text
);


--
-- Name: lime_plugin_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_plugin_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_plugin_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_plugin_settings_id_seq OWNED BY public.lime_plugin_settings.id;


--
-- Name: lime_plugins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_plugins (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    plugin_type character varying(6) DEFAULT 'user'::character varying,
    active integer DEFAULT 0 NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    version character varying(32),
    load_error integer DEFAULT 0,
    load_error_message text
);


--
-- Name: lime_plugins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_plugins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_plugins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_plugins_id_seq OWNED BY public.lime_plugins.id;


--
-- Name: lime_question_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_question_attributes (
    qaid integer NOT NULL,
    qid integer DEFAULT 0 NOT NULL,
    attribute character varying(50),
    value text,
    language character varying(20)
);


--
-- Name: lime_question_attributes_qaid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_question_attributes_qaid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_question_attributes_qaid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_question_attributes_qaid_seq OWNED BY public.lime_question_attributes.qaid;


--
-- Name: lime_question_l10ns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_question_l10ns (
    id integer NOT NULL,
    qid integer NOT NULL,
    question text NOT NULL,
    help text,
    script text,
    language character varying(20) NOT NULL
);


--
-- Name: lime_question_l10ns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_question_l10ns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_question_l10ns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_question_l10ns_id_seq OWNED BY public.lime_question_l10ns.id;


--
-- Name: lime_question_themes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_question_themes (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    visible character varying(1),
    xml_path character varying(255),
    image_path character varying(255),
    title character varying(100) NOT NULL,
    creation_date timestamp without time zone,
    author character varying(150),
    author_email character varying(255),
    author_url character varying(255),
    copyright text,
    license text,
    version character varying(45),
    api_version character varying(45) NOT NULL,
    description text,
    last_update timestamp without time zone,
    owner_id integer,
    theme_type character varying(150),
    question_type character varying(150) NOT NULL,
    core_theme boolean,
    extends character varying(150),
    "group" character varying(150),
    settings text
);


--
-- Name: lime_question_themes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_question_themes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_question_themes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_question_themes_id_seq OWNED BY public.lime_question_themes.id;


--
-- Name: lime_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_questions (
    qid integer NOT NULL,
    parent_qid integer DEFAULT 0 NOT NULL,
    sid integer DEFAULT 0 NOT NULL,
    gid integer DEFAULT 0 NOT NULL,
    type character varying(30) DEFAULT 'T'::character varying NOT NULL,
    title character varying(20) DEFAULT ''::character varying NOT NULL,
    preg text,
    other character varying(1) DEFAULT 'N'::character varying NOT NULL,
    mandatory character varying(1),
    encrypted character varying(1) DEFAULT 'N'::character varying,
    question_order integer NOT NULL,
    scale_id integer DEFAULT 0 NOT NULL,
    same_default integer DEFAULT 0 NOT NULL,
    relevance text,
    question_theme_name character varying(150),
    modulename character varying(255),
    same_script integer DEFAULT 0 NOT NULL
);


--
-- Name: lime_questions_qid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_questions_qid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_questions_qid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_questions_qid_seq OWNED BY public.lime_questions.qid;


--
-- Name: lime_quota; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_quota (
    id integer NOT NULL,
    sid integer,
    name character varying(255),
    qlimit integer,
    action integer,
    active integer DEFAULT 1 NOT NULL,
    autoload_url integer DEFAULT 0 NOT NULL
);


--
-- Name: lime_quota_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_quota_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_quota_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_quota_id_seq OWNED BY public.lime_quota.id;


--
-- Name: lime_quota_languagesettings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_quota_languagesettings (
    quotals_id integer NOT NULL,
    quotals_quota_id integer DEFAULT 0 NOT NULL,
    quotals_language character varying(45) DEFAULT 'en'::character varying NOT NULL,
    quotals_name character varying(255),
    quotals_message text NOT NULL,
    quotals_url character varying(255),
    quotals_urldescrip character varying(255)
);


--
-- Name: lime_quota_languagesettings_quotals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_quota_languagesettings_quotals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_quota_languagesettings_quotals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_quota_languagesettings_quotals_id_seq OWNED BY public.lime_quota_languagesettings.quotals_id;


--
-- Name: lime_quota_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_quota_members (
    id integer NOT NULL,
    sid integer,
    qid integer,
    quota_id integer,
    code character varying(11)
);


--
-- Name: lime_quota_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_quota_members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_quota_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_quota_members_id_seq OWNED BY public.lime_quota_members.id;


--
-- Name: lime_saved_control; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_saved_control (
    scid integer NOT NULL,
    sid integer DEFAULT 0 NOT NULL,
    srid integer DEFAULT 0 NOT NULL,
    identifier text NOT NULL,
    access_code text NOT NULL,
    email character varying(192),
    ip text NOT NULL,
    saved_thisstep text NOT NULL,
    status character varying(1) DEFAULT ''::character varying NOT NULL,
    saved_date timestamp without time zone NOT NULL,
    refurl text
);


--
-- Name: lime_saved_control_scid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_saved_control_scid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_saved_control_scid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_saved_control_scid_seq OWNED BY public.lime_saved_control.scid;


--
-- Name: lime_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_sessions (
    id character varying(32) NOT NULL,
    expire integer,
    data bytea
);


--
-- Name: lime_settings_global; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_settings_global (
    stg_name character varying(50) DEFAULT ''::character varying NOT NULL,
    stg_value text NOT NULL
);


--
-- Name: lime_settings_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_settings_user (
    id integer NOT NULL,
    uid integer NOT NULL,
    entity character varying(15),
    entity_id character varying(31),
    stg_name character varying(63) NOT NULL,
    stg_value text
);


--
-- Name: lime_settings_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_settings_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_settings_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_settings_user_id_seq OWNED BY public.lime_settings_user.id;


--
-- Name: lime_source_message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_source_message (
    id integer NOT NULL,
    category character varying(35),
    message text
);


--
-- Name: lime_source_message_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_source_message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_source_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_source_message_id_seq OWNED BY public.lime_source_message.id;


--
-- Name: lime_survey_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_survey_links (
    participant_id character varying(50) NOT NULL,
    token_id integer NOT NULL,
    survey_id integer NOT NULL,
    date_created timestamp without time zone,
    date_invited timestamp without time zone,
    date_completed timestamp without time zone
);


--
-- Name: lime_survey_url_parameters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_survey_url_parameters (
    id integer NOT NULL,
    sid integer NOT NULL,
    parameter character varying(50) NOT NULL,
    targetqid integer,
    targetsqid integer
);


--
-- Name: lime_survey_url_parameters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_survey_url_parameters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_survey_url_parameters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_survey_url_parameters_id_seq OWNED BY public.lime_survey_url_parameters.id;


--
-- Name: lime_surveymenu; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_surveymenu (
    id integer NOT NULL,
    parent_id integer,
    survey_id integer,
    user_id integer,
    name character varying(128),
    ordering integer DEFAULT 0,
    level integer DEFAULT 0,
    title character varying(168) DEFAULT ''::character varying NOT NULL,
    "position" character varying(192) DEFAULT 'side'::character varying NOT NULL,
    description text,
    showincollapse integer DEFAULT 0,
    active integer DEFAULT 0 NOT NULL,
    changed_at timestamp without time zone,
    changed_by integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    created_by integer DEFAULT 0 NOT NULL
);


--
-- Name: lime_surveymenu_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_surveymenu_entries (
    id integer NOT NULL,
    menu_id integer,
    user_id integer,
    ordering integer DEFAULT 0,
    name character varying(168) DEFAULT ''::character varying,
    title character varying(168) DEFAULT ''::character varying NOT NULL,
    menu_title character varying(168) DEFAULT ''::character varying NOT NULL,
    menu_description text,
    menu_icon character varying(192) DEFAULT ''::character varying NOT NULL,
    menu_icon_type character varying(192) DEFAULT ''::character varying NOT NULL,
    menu_class character varying(192) DEFAULT ''::character varying NOT NULL,
    menu_link character varying(192) DEFAULT ''::character varying NOT NULL,
    action character varying(192) DEFAULT ''::character varying NOT NULL,
    template character varying(192) DEFAULT ''::character varying NOT NULL,
    partial character varying(192) DEFAULT ''::character varying NOT NULL,
    classes character varying(192) DEFAULT ''::character varying NOT NULL,
    permission character varying(192) DEFAULT ''::character varying NOT NULL,
    permission_grade character varying(192),
    data text,
    getdatamethod character varying(192) DEFAULT ''::character varying NOT NULL,
    language character varying(32) DEFAULT 'en-GB'::character varying NOT NULL,
    showincollapse integer DEFAULT 0,
    active integer DEFAULT 0 NOT NULL,
    changed_at timestamp without time zone,
    changed_by integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    created_by integer DEFAULT 0 NOT NULL
);


--
-- Name: lime_surveymenu_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_surveymenu_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_surveymenu_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_surveymenu_entries_id_seq OWNED BY public.lime_surveymenu_entries.id;


--
-- Name: lime_surveymenu_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_surveymenu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_surveymenu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_surveymenu_id_seq OWNED BY public.lime_surveymenu.id;


--
-- Name: lime_surveys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_surveys (
    sid integer NOT NULL,
    owner_id integer NOT NULL,
    gsid integer DEFAULT 1,
    admin character varying(50),
    active character varying(1) DEFAULT 'N'::character varying NOT NULL,
    expires timestamp without time zone,
    startdate timestamp without time zone,
    adminemail character varying(254),
    anonymized character varying(1) DEFAULT 'N'::character varying NOT NULL,
    format character varying(1),
    savetimings character varying(1) DEFAULT 'N'::character varying NOT NULL,
    template character varying(100) DEFAULT 'default'::character varying,
    language character varying(50),
    additional_languages text,
    datestamp character varying(1) DEFAULT 'Y'::character varying NOT NULL,
    usecookie character varying(1) DEFAULT 'N'::character varying NOT NULL,
    allowregister character varying(1) DEFAULT 'N'::character varying NOT NULL,
    allowsave character varying(1) DEFAULT 'Y'::character varying NOT NULL,
    autonumber_start integer DEFAULT 0 NOT NULL,
    autoredirect character varying(1) DEFAULT 'N'::character varying NOT NULL,
    allowprev character varying(1) DEFAULT 'N'::character varying NOT NULL,
    printanswers character varying(1) DEFAULT 'N'::character varying NOT NULL,
    ipaddr character varying(1) DEFAULT 'N'::character varying NOT NULL,
    ipanonymize character varying(1) DEFAULT 'N'::character varying NOT NULL,
    refurl character varying(1) DEFAULT 'N'::character varying NOT NULL,
    datecreated timestamp without time zone,
    showsurveypolicynotice integer DEFAULT 0,
    showregisterpolicy character varying(1) DEFAULT 'I'::character varying NOT NULL,
    showtokenpolicy character varying(1) DEFAULT 'I'::character varying NOT NULL,
    publicstatistics character varying(1) DEFAULT 'N'::character varying NOT NULL,
    publicgraphs character varying(1) DEFAULT 'N'::character varying NOT NULL,
    listpublic character varying(1) DEFAULT 'N'::character varying NOT NULL,
    htmlemail character varying(1) DEFAULT 'Y'::character varying NOT NULL,
    sendconfirmation character varying(1) DEFAULT 'Y'::character varying NOT NULL,
    tokenanswerspersistence character varying(1) DEFAULT 'N'::character varying NOT NULL,
    assessments character varying(1) DEFAULT 'N'::character varying NOT NULL,
    usecaptcha character varying(1) DEFAULT 'N'::character varying NOT NULL,
    usetokens character varying(1) DEFAULT 'N'::character varying NOT NULL,
    bounce_email character varying(254),
    attributedescriptions text,
    emailresponseto text,
    emailnotificationto text,
    tokenlength integer DEFAULT 15 NOT NULL,
    showxquestions character varying(1) DEFAULT 'Y'::character varying,
    showgroupinfo character varying(1) DEFAULT 'B'::character varying,
    shownoanswer character varying(1) DEFAULT 'Y'::character varying,
    showqnumcode character varying(1) DEFAULT 'X'::character varying,
    bouncetime integer,
    bounceprocessing character varying(1) DEFAULT 'N'::character varying,
    bounceaccounttype character varying(4),
    bounceaccounthost character varying(200),
    bounceaccountpass text,
    bounceaccountencryption character varying(3),
    bounceaccountuser character varying(200),
    showwelcome character varying(1) DEFAULT 'Y'::character varying,
    showprogress character varying(1) DEFAULT 'Y'::character varying,
    questionindex integer DEFAULT 0 NOT NULL,
    navigationdelay integer DEFAULT 0 NOT NULL,
    nokeyboard character varying(1) DEFAULT 'N'::character varying,
    alloweditaftercompletion character varying(1) DEFAULT 'N'::character varying,
    googleanalyticsstyle character varying(1),
    googleanalyticsapikey character varying(25),
    tokenencryptionoptions text,
    access_mode character varying(1) DEFAULT 'O'::character varying,
    lastmodified timestamp without time zone NOT NULL
);


--
-- Name: lime_surveys_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_surveys_groups (
    gsid integer NOT NULL,
    name character varying(45) NOT NULL,
    title character varying(100),
    template character varying(128) DEFAULT 'default'::character varying,
    description text,
    sortorder integer NOT NULL,
    owner_id integer,
    parent_id integer,
    alwaysavailable boolean,
    created timestamp without time zone,
    modified timestamp without time zone,
    created_by integer NOT NULL
);


--
-- Name: lime_surveys_groups_gsid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_surveys_groups_gsid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_surveys_groups_gsid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_surveys_groups_gsid_seq OWNED BY public.lime_surveys_groups.gsid;


--
-- Name: lime_surveys_groupsettings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_surveys_groupsettings (
    gsid integer NOT NULL,
    owner_id integer,
    admin character varying(50) DEFAULT NULL::character varying,
    adminemail character varying(254) DEFAULT NULL::character varying,
    anonymized character varying(1) DEFAULT 'N'::character varying NOT NULL,
    format character varying(1) DEFAULT NULL::character varying,
    savetimings character varying(1) DEFAULT 'N'::character varying NOT NULL,
    template character varying(100) DEFAULT 'default'::character varying,
    datestamp character varying(1) DEFAULT 'Y'::character varying NOT NULL,
    usecookie character varying(1) DEFAULT 'N'::character varying NOT NULL,
    allowregister character varying(1) DEFAULT 'N'::character varying NOT NULL,
    allowsave character varying(1) DEFAULT 'Y'::character varying NOT NULL,
    autonumber_start integer DEFAULT 0,
    autoredirect character varying(1) DEFAULT 'N'::character varying NOT NULL,
    allowprev character varying(1) DEFAULT 'N'::character varying NOT NULL,
    printanswers character varying(1) DEFAULT 'N'::character varying NOT NULL,
    ipaddr character varying(1) DEFAULT 'N'::character varying NOT NULL,
    ipanonymize character varying(1) DEFAULT 'N'::character varying NOT NULL,
    refurl character varying(1) DEFAULT 'N'::character varying NOT NULL,
    showsurveypolicynotice integer DEFAULT 0,
    showregisterpolicy character varying(1) DEFAULT 'I'::character varying NOT NULL,
    showtokenpolicy character varying(1) DEFAULT 'I'::character varying NOT NULL,
    publicstatistics character varying(1) DEFAULT 'N'::character varying NOT NULL,
    publicgraphs character varying(1) DEFAULT 'N'::character varying NOT NULL,
    listpublic character varying(1) DEFAULT 'N'::character varying NOT NULL,
    htmlemail character varying(1) DEFAULT 'Y'::character varying NOT NULL,
    sendconfirmation character varying(1) DEFAULT 'Y'::character varying NOT NULL,
    tokenanswerspersistence character varying(1) DEFAULT 'N'::character varying NOT NULL,
    assessments character varying(1) DEFAULT 'N'::character varying NOT NULL,
    usecaptcha character varying(1) DEFAULT 'N'::character varying NOT NULL,
    bounce_email character varying(254) DEFAULT NULL::character varying,
    attributedescriptions text,
    emailresponseto text,
    emailnotificationto text,
    tokenlength integer DEFAULT 15,
    showxquestions character varying(1) DEFAULT 'Y'::character varying,
    showgroupinfo character varying(1) DEFAULT 'B'::character varying,
    shownoanswer character varying(1) DEFAULT 'Y'::character varying,
    showqnumcode character varying(1) DEFAULT 'X'::character varying,
    showwelcome character varying(1) DEFAULT 'Y'::character varying,
    showprogress character varying(1) DEFAULT 'Y'::character varying,
    questionindex integer DEFAULT 0,
    navigationdelay integer DEFAULT 0,
    nokeyboard character varying(1) DEFAULT 'N'::character varying,
    alloweditaftercompletion character varying(1) DEFAULT 'N'::character varying
);


--
-- Name: lime_surveys_languagesettings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_surveys_languagesettings (
    surveyls_survey_id integer NOT NULL,
    surveyls_language character varying(45) DEFAULT 'en'::character varying NOT NULL,
    surveyls_title character varying(200) NOT NULL,
    surveyls_description text,
    surveyls_welcometext text,
    surveyls_endtext text,
    surveyls_policy_notice text,
    surveyls_policy_error text,
    surveyls_policy_notice_label character varying(192),
    surveyls_url text,
    surveyls_urldescription character varying(255),
    surveyls_email_invite_subj character varying(255),
    surveyls_email_invite text,
    surveyls_email_remind_subj character varying(255),
    surveyls_email_remind text,
    surveyls_email_register_subj character varying(255),
    surveyls_email_register text,
    surveyls_email_confirm_subj character varying(255),
    surveyls_email_confirm text,
    surveyls_dateformat integer DEFAULT 1 NOT NULL,
    surveyls_attributecaptions text,
    surveyls_alias character varying(100),
    email_admin_notification_subj character varying(255),
    email_admin_notification text,
    email_admin_responses_subj character varying(255),
    email_admin_responses text,
    surveyls_numberformat integer DEFAULT 0 NOT NULL,
    attachments text
);


--
-- Name: lime_template_configuration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_template_configuration (
    id integer NOT NULL,
    template_name character varying(150) NOT NULL,
    sid integer,
    gsid integer,
    uid integer,
    files_css text,
    files_js text,
    files_print_css text,
    options text,
    cssframework_name character varying(45),
    cssframework_css text,
    cssframework_js text,
    packages_to_load text,
    packages_ltr text,
    packages_rtl text
);


--
-- Name: lime_template_configuration_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_template_configuration_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_template_configuration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_template_configuration_id_seq OWNED BY public.lime_template_configuration.id;


--
-- Name: lime_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_templates (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    folder character varying(45),
    title character varying(100) NOT NULL,
    creation_date timestamp without time zone,
    author character varying(150),
    author_email character varying(255),
    author_url character varying(255),
    copyright text,
    license text,
    version character varying(45),
    api_version character varying(45) NOT NULL,
    view_folder character varying(45) NOT NULL,
    files_folder character varying(45) NOT NULL,
    description text,
    last_update timestamp without time zone,
    owner_id integer,
    extends character varying(150)
);


--
-- Name: lime_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_templates_id_seq OWNED BY public.lime_templates.id;


--
-- Name: lime_tutorial_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_tutorial_entries (
    teid integer NOT NULL,
    ordering integer,
    title text,
    content text,
    settings text
);


--
-- Name: lime_tutorial_entries_teid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_tutorial_entries_teid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_tutorial_entries_teid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_tutorial_entries_teid_seq OWNED BY public.lime_tutorial_entries.teid;


--
-- Name: lime_tutorial_entry_relation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_tutorial_entry_relation (
    teid integer NOT NULL,
    tid integer NOT NULL,
    uid integer,
    sid integer
);


--
-- Name: lime_tutorials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_tutorials (
    tid integer NOT NULL,
    name character varying(128),
    title character varying(192),
    icon character varying(64),
    description text,
    active integer DEFAULT 0,
    settings text,
    permission character varying(128) NOT NULL,
    permission_grade character varying(128) NOT NULL
);


--
-- Name: lime_tutorials_tid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_tutorials_tid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_tutorials_tid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_tutorials_tid_seq OWNED BY public.lime_tutorials.tid;


--
-- Name: lime_user_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_user_groups (
    ugid integer NOT NULL,
    name character varying(20) NOT NULL,
    description text NOT NULL,
    owner_id integer NOT NULL
);


--
-- Name: lime_user_groups_ugid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_user_groups_ugid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_user_groups_ugid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_user_groups_ugid_seq OWNED BY public.lime_user_groups.ugid;


--
-- Name: lime_user_in_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_user_in_groups (
    ugid integer NOT NULL,
    uid integer NOT NULL
);


--
-- Name: lime_user_in_permissionrole; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_user_in_permissionrole (
    ptid integer NOT NULL,
    uid integer NOT NULL
);


--
-- Name: lime_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lime_users (
    uid integer NOT NULL,
    users_name character varying(64) DEFAULT ''::character varying NOT NULL,
    password text NOT NULL,
    full_name character varying(50) NOT NULL,
    parent_id integer NOT NULL,
    lang character varying(20),
    email character varying(192),
    htmleditormode character varying(7) DEFAULT 'default'::character varying,
    templateeditormode character varying(7) DEFAULT 'default'::character varying NOT NULL,
    questionselectormode character varying(7) DEFAULT 'default'::character varying NOT NULL,
    one_time_pw text,
    dateformat integer DEFAULT 1 NOT NULL,
    last_login timestamp without time zone,
    created timestamp without time zone,
    modified timestamp without time zone,
    validation_key character varying(38),
    validation_key_expiration timestamp without time zone,
    last_forgot_email_password timestamp without time zone,
    expires timestamp without time zone,
    user_status integer DEFAULT 1 NOT NULL
);


--
-- Name: lime_users_uid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lime_users_uid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lime_users_uid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lime_users_uid_seq OWNED BY public.lime_users.uid;


--
-- Name: lime_answer_l10ns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_answer_l10ns ALTER COLUMN id SET DEFAULT nextval('public.lime_answer_l10ns_id_seq'::regclass);


--
-- Name: lime_answers aid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_answers ALTER COLUMN aid SET DEFAULT nextval('public.lime_answers_aid_seq'::regclass);


--
-- Name: lime_archived_table_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_archived_table_settings ALTER COLUMN id SET DEFAULT nextval('public.lime_archived_table_settings_id_seq'::regclass);


--
-- Name: lime_assessments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_assessments ALTER COLUMN id SET DEFAULT nextval('public.lime_assessments_id_seq'::regclass);


--
-- Name: lime_asset_version id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_asset_version ALTER COLUMN id SET DEFAULT nextval('public.lime_asset_version_id_seq'::regclass);


--
-- Name: lime_boxes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_boxes ALTER COLUMN id SET DEFAULT nextval('public.lime_boxes_id_seq'::regclass);


--
-- Name: lime_conditions cid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_conditions ALTER COLUMN cid SET DEFAULT nextval('public.lime_conditions_cid_seq'::regclass);


--
-- Name: lime_defaultvalue_l10ns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_defaultvalue_l10ns ALTER COLUMN id SET DEFAULT nextval('public.lime_defaultvalue_l10ns_id_seq'::regclass);


--
-- Name: lime_defaultvalues dvid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_defaultvalues ALTER COLUMN dvid SET DEFAULT nextval('public.lime_defaultvalues_dvid_seq'::regclass);


--
-- Name: lime_expression_errors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_expression_errors ALTER COLUMN id SET DEFAULT nextval('public.lime_expression_errors_id_seq'::regclass);


--
-- Name: lime_failed_emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_failed_emails ALTER COLUMN id SET DEFAULT nextval('public.lime_failed_emails_id_seq'::regclass);


--
-- Name: lime_failed_login_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_failed_login_attempts ALTER COLUMN id SET DEFAULT nextval('public.lime_failed_login_attempts_id_seq'::regclass);


--
-- Name: lime_group_l10ns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_group_l10ns ALTER COLUMN id SET DEFAULT nextval('public.lime_group_l10ns_id_seq'::regclass);


--
-- Name: lime_groups gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_groups ALTER COLUMN gid SET DEFAULT nextval('public.lime_groups_gid_seq'::regclass);


--
-- Name: lime_label_l10ns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_label_l10ns ALTER COLUMN id SET DEFAULT nextval('public.lime_label_l10ns_id_seq'::regclass);


--
-- Name: lime_labels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_labels ALTER COLUMN id SET DEFAULT nextval('public.lime_labels_id_seq'::regclass);


--
-- Name: lime_labelsets lid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_labelsets ALTER COLUMN lid SET DEFAULT nextval('public.lime_labelsets_lid_seq'::regclass);


--
-- Name: lime_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_notifications ALTER COLUMN id SET DEFAULT nextval('public.lime_notifications_id_seq'::regclass);


--
-- Name: lime_participant_attribute_names attribute_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_participant_attribute_names ALTER COLUMN attribute_id SET DEFAULT nextval('public.lime_participant_attribute_names_attribute_id_seq'::regclass);


--
-- Name: lime_participant_attribute_values value_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_participant_attribute_values ALTER COLUMN value_id SET DEFAULT nextval('public.lime_participant_attribute_values_value_id_seq'::regclass);


--
-- Name: lime_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_permissions ALTER COLUMN id SET DEFAULT nextval('public.lime_permissions_id_seq'::regclass);


--
-- Name: lime_permissiontemplates ptid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_permissiontemplates ALTER COLUMN ptid SET DEFAULT nextval('public.lime_permissiontemplates_ptid_seq'::regclass);


--
-- Name: lime_plugin_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_plugin_settings ALTER COLUMN id SET DEFAULT nextval('public.lime_plugin_settings_id_seq'::regclass);


--
-- Name: lime_plugins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_plugins ALTER COLUMN id SET DEFAULT nextval('public.lime_plugins_id_seq'::regclass);


--
-- Name: lime_question_attributes qaid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_question_attributes ALTER COLUMN qaid SET DEFAULT nextval('public.lime_question_attributes_qaid_seq'::regclass);


--
-- Name: lime_question_l10ns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_question_l10ns ALTER COLUMN id SET DEFAULT nextval('public.lime_question_l10ns_id_seq'::regclass);


--
-- Name: lime_question_themes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_question_themes ALTER COLUMN id SET DEFAULT nextval('public.lime_question_themes_id_seq'::regclass);


--
-- Name: lime_questions qid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_questions ALTER COLUMN qid SET DEFAULT nextval('public.lime_questions_qid_seq'::regclass);


--
-- Name: lime_quota id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_quota ALTER COLUMN id SET DEFAULT nextval('public.lime_quota_id_seq'::regclass);


--
-- Name: lime_quota_languagesettings quotals_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_quota_languagesettings ALTER COLUMN quotals_id SET DEFAULT nextval('public.lime_quota_languagesettings_quotals_id_seq'::regclass);


--
-- Name: lime_quota_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_quota_members ALTER COLUMN id SET DEFAULT nextval('public.lime_quota_members_id_seq'::regclass);


--
-- Name: lime_saved_control scid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_saved_control ALTER COLUMN scid SET DEFAULT nextval('public.lime_saved_control_scid_seq'::regclass);


--
-- Name: lime_settings_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_settings_user ALTER COLUMN id SET DEFAULT nextval('public.lime_settings_user_id_seq'::regclass);


--
-- Name: lime_source_message id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_source_message ALTER COLUMN id SET DEFAULT nextval('public.lime_source_message_id_seq'::regclass);


--
-- Name: lime_survey_url_parameters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_survey_url_parameters ALTER COLUMN id SET DEFAULT nextval('public.lime_survey_url_parameters_id_seq'::regclass);


--
-- Name: lime_surveymenu id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_surveymenu ALTER COLUMN id SET DEFAULT nextval('public.lime_surveymenu_id_seq'::regclass);


--
-- Name: lime_surveymenu_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_surveymenu_entries ALTER COLUMN id SET DEFAULT nextval('public.lime_surveymenu_entries_id_seq'::regclass);


--
-- Name: lime_surveys_groups gsid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_surveys_groups ALTER COLUMN gsid SET DEFAULT nextval('public.lime_surveys_groups_gsid_seq'::regclass);


--
-- Name: lime_template_configuration id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_template_configuration ALTER COLUMN id SET DEFAULT nextval('public.lime_template_configuration_id_seq'::regclass);


--
-- Name: lime_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_templates ALTER COLUMN id SET DEFAULT nextval('public.lime_templates_id_seq'::regclass);


--
-- Name: lime_tutorial_entries teid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_tutorial_entries ALTER COLUMN teid SET DEFAULT nextval('public.lime_tutorial_entries_teid_seq'::regclass);


--
-- Name: lime_tutorials tid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_tutorials ALTER COLUMN tid SET DEFAULT nextval('public.lime_tutorials_tid_seq'::regclass);


--
-- Name: lime_user_groups ugid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_user_groups ALTER COLUMN ugid SET DEFAULT nextval('public.lime_user_groups_ugid_seq'::regclass);


--
-- Name: lime_users uid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_users ALTER COLUMN uid SET DEFAULT nextval('public.lime_users_uid_seq'::regclass);


--
-- Name: lime_answer_l10ns lime_answer_l10ns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_answer_l10ns
    ADD CONSTRAINT lime_answer_l10ns_pkey PRIMARY KEY (id);


--
-- Name: lime_answers lime_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_answers
    ADD CONSTRAINT lime_answers_pkey PRIMARY KEY (aid);


--
-- Name: lime_archived_table_settings lime_archived_table_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_archived_table_settings
    ADD CONSTRAINT lime_archived_table_settings_pkey PRIMARY KEY (id);


--
-- Name: lime_assessments lime_assessments_composite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_assessments
    ADD CONSTRAINT lime_assessments_composite_pkey PRIMARY KEY (id, language);


--
-- Name: lime_asset_version lime_asset_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_asset_version
    ADD CONSTRAINT lime_asset_version_pkey PRIMARY KEY (id);


--
-- Name: lime_boxes lime_boxes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_boxes
    ADD CONSTRAINT lime_boxes_pkey PRIMARY KEY (id);


--
-- Name: lime_conditions lime_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_conditions
    ADD CONSTRAINT lime_conditions_pkey PRIMARY KEY (cid);


--
-- Name: lime_defaultvalue_l10ns lime_defaultvalue_l10ns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_defaultvalue_l10ns
    ADD CONSTRAINT lime_defaultvalue_l10ns_pkey PRIMARY KEY (id);


--
-- Name: lime_defaultvalues lime_defaultvalues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_defaultvalues
    ADD CONSTRAINT lime_defaultvalues_pkey PRIMARY KEY (dvid);


--
-- Name: lime_expression_errors lime_expression_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_expression_errors
    ADD CONSTRAINT lime_expression_errors_pkey PRIMARY KEY (id);


--
-- Name: lime_failed_emails lime_failed_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_failed_emails
    ADD CONSTRAINT lime_failed_emails_pkey PRIMARY KEY (id);


--
-- Name: lime_failed_login_attempts lime_failed_login_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_failed_login_attempts
    ADD CONSTRAINT lime_failed_login_attempts_pkey PRIMARY KEY (id);


--
-- Name: lime_group_l10ns lime_group_l10ns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_group_l10ns
    ADD CONSTRAINT lime_group_l10ns_pkey PRIMARY KEY (id);


--
-- Name: lime_groups lime_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_groups
    ADD CONSTRAINT lime_groups_pkey PRIMARY KEY (gid);


--
-- Name: lime_label_l10ns lime_label_l10ns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_label_l10ns
    ADD CONSTRAINT lime_label_l10ns_pkey PRIMARY KEY (id);


--
-- Name: lime_labels lime_labels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_labels
    ADD CONSTRAINT lime_labels_pkey PRIMARY KEY (id);


--
-- Name: lime_labelsets lime_labelsets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_labelsets
    ADD CONSTRAINT lime_labelsets_pkey PRIMARY KEY (lid);


--
-- Name: lime_map_tutorial_users lime_map_tutorial_users_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_map_tutorial_users
    ADD CONSTRAINT lime_map_tutorial_users_pk PRIMARY KEY (uid, tid);


--
-- Name: lime_message lime_message_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_message
    ADD CONSTRAINT lime_message_pk PRIMARY KEY (id, language);


--
-- Name: lime_notifications lime_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_notifications
    ADD CONSTRAINT lime_notifications_pkey PRIMARY KEY (id);


--
-- Name: lime_participant_attribute_names lime_participant_attribute_names_composite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_participant_attribute_names
    ADD CONSTRAINT lime_participant_attribute_names_composite_pkey PRIMARY KEY (attribute_id, attribute_type);


--
-- Name: lime_participant_attribute_names_lang lime_participant_attribute_names_lang_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_participant_attribute_names_lang
    ADD CONSTRAINT lime_participant_attribute_names_lang_pk PRIMARY KEY (attribute_id, lang);


--
-- Name: lime_participant_attribute lime_participant_attribute_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_participant_attribute
    ADD CONSTRAINT lime_participant_attribute_pk PRIMARY KEY (participant_id, attribute_id);


--
-- Name: lime_participant_attribute_values lime_participant_attribute_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_participant_attribute_values
    ADD CONSTRAINT lime_participant_attribute_values_pkey PRIMARY KEY (value_id);


--
-- Name: lime_participants lime_participant_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_participants
    ADD CONSTRAINT lime_participant_pk PRIMARY KEY (participant_id);


--
-- Name: lime_participant_shares lime_participant_shares_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_participant_shares
    ADD CONSTRAINT lime_participant_shares_pk PRIMARY KEY (participant_id, share_uid);


--
-- Name: lime_permissions lime_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_permissions
    ADD CONSTRAINT lime_permissions_pkey PRIMARY KEY (id);


--
-- Name: lime_permissiontemplates lime_permissiontemplates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_permissiontemplates
    ADD CONSTRAINT lime_permissiontemplates_pkey PRIMARY KEY (ptid);


--
-- Name: lime_plugin_settings lime_plugin_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_plugin_settings
    ADD CONSTRAINT lime_plugin_settings_pkey PRIMARY KEY (id);


--
-- Name: lime_plugins lime_plugins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_plugins
    ADD CONSTRAINT lime_plugins_pkey PRIMARY KEY (id);


--
-- Name: lime_question_attributes lime_question_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_question_attributes
    ADD CONSTRAINT lime_question_attributes_pkey PRIMARY KEY (qaid);


--
-- Name: lime_question_l10ns lime_question_l10ns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_question_l10ns
    ADD CONSTRAINT lime_question_l10ns_pkey PRIMARY KEY (id);


--
-- Name: lime_question_themes lime_question_themes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_question_themes
    ADD CONSTRAINT lime_question_themes_pkey PRIMARY KEY (id);


--
-- Name: lime_questions lime_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_questions
    ADD CONSTRAINT lime_questions_pkey PRIMARY KEY (qid);


--
-- Name: lime_quota_languagesettings lime_quota_languagesettings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_quota_languagesettings
    ADD CONSTRAINT lime_quota_languagesettings_pkey PRIMARY KEY (quotals_id);


--
-- Name: lime_quota_members lime_quota_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_quota_members
    ADD CONSTRAINT lime_quota_members_pkey PRIMARY KEY (id);


--
-- Name: lime_quota lime_quota_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_quota
    ADD CONSTRAINT lime_quota_pkey PRIMARY KEY (id);


--
-- Name: lime_saved_control lime_saved_control_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_saved_control
    ADD CONSTRAINT lime_saved_control_pkey PRIMARY KEY (scid);


--
-- Name: lime_sessions lime_sessions_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_sessions
    ADD CONSTRAINT lime_sessions_pk PRIMARY KEY (id);


--
-- Name: lime_settings_global lime_settings_global_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_settings_global
    ADD CONSTRAINT lime_settings_global_pk PRIMARY KEY (stg_name);


--
-- Name: lime_settings_user lime_settings_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_settings_user
    ADD CONSTRAINT lime_settings_user_pkey PRIMARY KEY (id);


--
-- Name: lime_source_message lime_source_message_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_source_message
    ADD CONSTRAINT lime_source_message_pkey PRIMARY KEY (id);


--
-- Name: lime_survey_links lime_survey_links_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_survey_links
    ADD CONSTRAINT lime_survey_links_pk PRIMARY KEY (participant_id, token_id, survey_id);


--
-- Name: lime_survey_url_parameters lime_survey_url_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_survey_url_parameters
    ADD CONSTRAINT lime_survey_url_parameters_pkey PRIMARY KEY (id);


--
-- Name: lime_surveymenu_entries lime_surveymenu_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_surveymenu_entries
    ADD CONSTRAINT lime_surveymenu_entries_pkey PRIMARY KEY (id);


--
-- Name: lime_surveymenu lime_surveymenu_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_surveymenu
    ADD CONSTRAINT lime_surveymenu_pkey PRIMARY KEY (id);


--
-- Name: lime_surveys_groups lime_surveys_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_surveys_groups
    ADD CONSTRAINT lime_surveys_groups_pkey PRIMARY KEY (gsid);


--
-- Name: lime_surveys_groupsettings lime_surveys_groupsettings_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_surveys_groupsettings
    ADD CONSTRAINT lime_surveys_groupsettings_pk PRIMARY KEY (gsid);


--
-- Name: lime_surveys_languagesettings lime_surveys_languagesettings_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_surveys_languagesettings
    ADD CONSTRAINT lime_surveys_languagesettings_pk PRIMARY KEY (surveyls_survey_id, surveyls_language);


--
-- Name: lime_surveys lime_surveys_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_surveys
    ADD CONSTRAINT lime_surveys_pk PRIMARY KEY (sid);


--
-- Name: lime_template_configuration lime_template_configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_template_configuration
    ADD CONSTRAINT lime_template_configuration_pkey PRIMARY KEY (id);


--
-- Name: lime_templates lime_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_templates
    ADD CONSTRAINT lime_templates_pkey PRIMARY KEY (id);


--
-- Name: lime_tutorial_entries lime_tutorial_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_tutorial_entries
    ADD CONSTRAINT lime_tutorial_entries_pkey PRIMARY KEY (teid);


--
-- Name: lime_tutorial_entry_relation lime_tutorial_entry_relation_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_tutorial_entry_relation
    ADD CONSTRAINT lime_tutorial_entry_relation_pk PRIMARY KEY (teid, tid);


--
-- Name: lime_tutorials lime_tutorials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_tutorials
    ADD CONSTRAINT lime_tutorials_pkey PRIMARY KEY (tid);


--
-- Name: lime_user_groups lime_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_user_groups
    ADD CONSTRAINT lime_user_groups_pkey PRIMARY KEY (ugid);


--
-- Name: lime_user_in_groups lime_user_in_groups_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_user_in_groups
    ADD CONSTRAINT lime_user_in_groups_pk PRIMARY KEY (ugid, uid);


--
-- Name: lime_user_in_permissionrole lime_user_in_permissionrole_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_user_in_permissionrole
    ADD CONSTRAINT lime_user_in_permissionrole_pk PRIMARY KEY (ptid, uid);


--
-- Name: lime_users lime_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lime_users
    ADD CONSTRAINT lime_users_pkey PRIMARY KEY (uid);


--
-- Name: lime_answer_l10ns_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lime_answer_l10ns_idx ON public.lime_answer_l10ns USING btree (aid, language);


--
-- Name: lime_answers_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_answers_idx ON public.lime_answers USING btree (qid, code, scale_id);


--
-- Name: lime_answers_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_answers_idx2 ON public.lime_answers USING btree (sortorder);


--
-- Name: lime_assessments_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_assessments_idx2 ON public.lime_assessments USING btree (sid);


--
-- Name: lime_assessments_idx3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_assessments_idx3 ON public.lime_assessments USING btree (gid);


--
-- Name: lime_conditions_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_conditions_idx ON public.lime_conditions USING btree (qid);


--
-- Name: lime_conditions_idx3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_conditions_idx3 ON public.lime_conditions USING btree (cqid);


--
-- Name: lime_idx1_defaultvalue; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_defaultvalue ON public.lime_defaultvalues USING btree (qid, scale_id, sqid, specialtype);


--
-- Name: lime_idx1_defaultvalue_ls; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_defaultvalue_ls ON public.lime_defaultvalue_l10ns USING btree (dvid, language);


--
-- Name: lime_idx1_group_ls; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lime_idx1_group_ls ON public.lime_group_l10ns USING btree (gid, language);


--
-- Name: lime_idx1_groups; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_groups ON public.lime_groups USING btree (sid);


--
-- Name: lime_idx1_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_labels ON public.lime_labels USING btree (code);


--
-- Name: lime_idx1_labelsets; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_labelsets ON public.lime_labelsets USING btree (owner_id);


--
-- Name: lime_idx1_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lime_idx1_name ON public.lime_permissiontemplates USING btree (name);


--
-- Name: lime_idx1_notifications; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_notifications ON public.lime_notifications USING btree (hash);


--
-- Name: lime_idx1_permissions; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lime_idx1_permissions ON public.lime_permissions USING btree (entity_id, entity, permission, uid);


--
-- Name: lime_idx1_question_attributes; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_question_attributes ON public.lime_question_attributes USING btree (qid);


--
-- Name: lime_idx1_question_ls; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lime_idx1_question_ls ON public.lime_question_l10ns USING btree (qid, language);


--
-- Name: lime_idx1_question_themes; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_question_themes ON public.lime_question_themes USING btree (name);


--
-- Name: lime_idx1_questions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_questions ON public.lime_questions USING btree (sid);


--
-- Name: lime_idx1_quota; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_quota ON public.lime_quota USING btree (sid);


--
-- Name: lime_idx1_quota_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_quota_id ON public.lime_quota_languagesettings USING btree (quotals_quota_id);


--
-- Name: lime_idx1_quota_members; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lime_idx1_quota_members ON public.lime_quota_members USING btree (sid, qid, quota_id, code);


--
-- Name: lime_idx1_saved_control; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_saved_control ON public.lime_saved_control USING btree (sid);


--
-- Name: lime_idx1_settings_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_settings_user ON public.lime_settings_user USING btree (uid);


--
-- Name: lime_idx1_surveymenu_entries; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_surveymenu_entries ON public.lime_surveymenu_entries USING btree (menu_id);


--
-- Name: lime_idx1_surveys; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_surveys ON public.lime_surveys USING btree (owner_id);


--
-- Name: lime_idx1_surveys_groups; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_surveys_groups ON public.lime_surveys_groups USING btree (name);


--
-- Name: lime_idx1_surveys_languagesettings; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_surveys_languagesettings ON public.lime_surveys_languagesettings USING btree (surveyls_title);


--
-- Name: lime_idx1_template_configuration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_template_configuration ON public.lime_template_configuration USING btree (template_name);


--
-- Name: lime_idx1_templates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_templates ON public.lime_templates USING btree (name);


--
-- Name: lime_idx1_tutorial_entry_relation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx1_tutorial_entry_relation ON public.lime_tutorial_entry_relation USING btree (uid);


--
-- Name: lime_idx1_tutorials; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lime_idx1_tutorials ON public.lime_tutorials USING btree (name);


--
-- Name: lime_idx1_user_groups; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lime_idx1_user_groups ON public.lime_user_groups USING btree (name);


--
-- Name: lime_idx1_users; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lime_idx1_users ON public.lime_users USING btree (users_name);


--
-- Name: lime_idx2_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx2_labels ON public.lime_labels USING btree (sortorder);


--
-- Name: lime_idx2_labelsets; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx2_labelsets ON public.lime_labelsets USING btree (lid, owner_id);


--
-- Name: lime_idx2_question_attributes; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx2_question_attributes ON public.lime_question_attributes USING btree (attribute);


--
-- Name: lime_idx2_questions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx2_questions ON public.lime_questions USING btree (gid);


--
-- Name: lime_idx2_quota_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx2_quota_id ON public.lime_quota_members USING btree (quota_id);


--
-- Name: lime_idx2_saved_control; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx2_saved_control ON public.lime_saved_control USING btree (srid);


--
-- Name: lime_idx2_settings_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx2_settings_user ON public.lime_settings_user USING btree (entity);


--
-- Name: lime_idx2_surveymenu; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx2_surveymenu ON public.lime_surveymenu USING btree (title);


--
-- Name: lime_idx2_surveys; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx2_surveys ON public.lime_surveys USING btree (gsid);


--
-- Name: lime_idx2_surveys_groups; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx2_surveys_groups ON public.lime_surveys_groups USING btree (title);


--
-- Name: lime_idx2_template_configuration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx2_template_configuration ON public.lime_template_configuration USING btree (sid);


--
-- Name: lime_idx2_templates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx2_templates ON public.lime_templates USING btree (title);


--
-- Name: lime_idx2_tutorial_entry_relation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx2_tutorial_entry_relation ON public.lime_tutorial_entry_relation USING btree (sid);


--
-- Name: lime_idx2_users; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx2_users ON public.lime_users USING btree (email);


--
-- Name: lime_idx3_participants; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx3_participants ON public.lime_participants USING btree (language);


--
-- Name: lime_idx3_questions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx3_questions ON public.lime_questions USING btree (type);


--
-- Name: lime_idx3_settings_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx3_settings_user ON public.lime_settings_user USING btree (entity_id);


--
-- Name: lime_idx3_template_configuration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx3_template_configuration ON public.lime_template_configuration USING btree (gsid);


--
-- Name: lime_idx3_templates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx3_templates ON public.lime_templates USING btree (owner_id);


--
-- Name: lime_idx4_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx4_labels ON public.lime_labels USING btree (lid, sortorder);


--
-- Name: lime_idx4_questions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx4_questions ON public.lime_questions USING btree (title);


--
-- Name: lime_idx4_settings_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx4_settings_user ON public.lime_settings_user USING btree (stg_name);


--
-- Name: lime_idx4_template_configuration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx4_template_configuration ON public.lime_template_configuration USING btree (uid);


--
-- Name: lime_idx4_templates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx4_templates ON public.lime_templates USING btree (extends);


--
-- Name: lime_idx5_labels; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lime_idx5_labels ON public.lime_labels USING btree (lid, code);


--
-- Name: lime_idx5_questions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx5_questions ON public.lime_questions USING btree (parent_qid);


--
-- Name: lime_idx5_surveymenu_entries; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx5_surveymenu_entries ON public.lime_surveymenu_entries USING btree (menu_title);


--
-- Name: lime_idx_participant_attribute_names; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_idx_participant_attribute_names ON public.lime_participant_attribute_names USING btree (attribute_id, attribute_type);


--
-- Name: lime_notifications_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lime_notifications_pk ON public.lime_notifications USING btree (entity, entity_id, status);


--
-- Name: lime_surveymenu_entries_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lime_surveymenu_entries_name ON public.lime_surveymenu_entries USING btree (name);


--
-- Name: lime_surveymenu_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lime_surveymenu_name ON public.lime_surveymenu USING btree (name);


--
-- Name: sess_expire; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sess_expire ON public.lime_sessions USING btree (expire);


--
-- PostgreSQL database dump complete
--


