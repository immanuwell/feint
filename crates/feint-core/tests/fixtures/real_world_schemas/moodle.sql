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
-- Name: mdl_adminpresets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_adminpresets (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    comments text,
    site character varying(255) DEFAULT ''::character varying NOT NULL,
    author character varying(255),
    moodleversion character varying(20) DEFAULT ''::character varying NOT NULL,
    moodlerelease character varying(255) DEFAULT ''::character varying NOT NULL,
    iscore smallint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timeimported bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_adminpresets; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_adminpresets IS 'Table to store presets data';


--
-- Name: mdl_adminpresets_app; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_adminpresets_app (
    id bigint NOT NULL,
    adminpresetid bigint NOT NULL,
    userid bigint NOT NULL,
    "time" bigint NOT NULL
);


--
-- Name: TABLE mdl_adminpresets_app; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_adminpresets_app IS 'Applied presets';


--
-- Name: mdl_adminpresets_app_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_adminpresets_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_adminpresets_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_adminpresets_app_id_seq OWNED BY public.mdl_adminpresets_app.id;


--
-- Name: mdl_adminpresets_app_it; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_adminpresets_app_it (
    id bigint NOT NULL,
    adminpresetapplyid bigint NOT NULL,
    configlogid bigint NOT NULL
);


--
-- Name: TABLE mdl_adminpresets_app_it; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_adminpresets_app_it IS 'Admin presets applied items. To maintain the relation with config_log';


--
-- Name: mdl_adminpresets_app_it_a; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_adminpresets_app_it_a (
    id bigint NOT NULL,
    adminpresetapplyid bigint NOT NULL,
    configlogid bigint NOT NULL,
    itemname character varying(100)
);


--
-- Name: TABLE mdl_adminpresets_app_it_a; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_adminpresets_app_it_a IS 'Attributes of the applied items';


--
-- Name: mdl_adminpresets_app_it_a_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_adminpresets_app_it_a_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_adminpresets_app_it_a_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_adminpresets_app_it_a_id_seq OWNED BY public.mdl_adminpresets_app_it_a.id;


--
-- Name: mdl_adminpresets_app_it_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_adminpresets_app_it_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_adminpresets_app_it_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_adminpresets_app_it_id_seq OWNED BY public.mdl_adminpresets_app_it.id;


--
-- Name: mdl_adminpresets_app_plug; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_adminpresets_app_plug (
    id bigint NOT NULL,
    adminpresetapplyid bigint NOT NULL,
    plugin character varying(100),
    name character varying(100) DEFAULT ''::character varying NOT NULL,
    value smallint DEFAULT 0 NOT NULL,
    oldvalue smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_adminpresets_app_plug; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_adminpresets_app_plug IS 'Admin presets plugins applied';


--
-- Name: mdl_adminpresets_app_plug_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_adminpresets_app_plug_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_adminpresets_app_plug_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_adminpresets_app_plug_id_seq OWNED BY public.mdl_adminpresets_app_plug.id;


--
-- Name: mdl_adminpresets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_adminpresets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_adminpresets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_adminpresets_id_seq OWNED BY public.mdl_adminpresets.id;


--
-- Name: mdl_adminpresets_it; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_adminpresets_it (
    id bigint NOT NULL,
    adminpresetid bigint NOT NULL,
    plugin character varying(100),
    name character varying(100) DEFAULT ''::character varying NOT NULL,
    value text
);


--
-- Name: TABLE mdl_adminpresets_it; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_adminpresets_it IS 'Table to store settings';


--
-- Name: mdl_adminpresets_it_a; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_adminpresets_it_a (
    id bigint NOT NULL,
    itemid bigint NOT NULL,
    name character varying(100) DEFAULT ''::character varying NOT NULL,
    value text
);


--
-- Name: TABLE mdl_adminpresets_it_a; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_adminpresets_it_a IS 'Admin presets items attributes. For settings with attributes (extra values like ''advanced'')';


--
-- Name: mdl_adminpresets_it_a_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_adminpresets_it_a_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_adminpresets_it_a_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_adminpresets_it_a_id_seq OWNED BY public.mdl_adminpresets_it_a.id;


--
-- Name: mdl_adminpresets_it_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_adminpresets_it_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_adminpresets_it_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_adminpresets_it_id_seq OWNED BY public.mdl_adminpresets_it.id;


--
-- Name: mdl_adminpresets_plug; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_adminpresets_plug (
    id bigint NOT NULL,
    adminpresetid bigint NOT NULL,
    plugin character varying(100),
    name character varying(100) DEFAULT ''::character varying NOT NULL,
    enabled smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_adminpresets_plug; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_adminpresets_plug IS 'Admin presets plugins status, to store information about whether they are enabled or not';


--
-- Name: mdl_adminpresets_plug_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_adminpresets_plug_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_adminpresets_plug_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_adminpresets_plug_id_seq OWNED BY public.mdl_adminpresets_plug.id;


--
-- Name: mdl_ai_action_generate_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_ai_action_generate_image (
    id bigint NOT NULL,
    prompt text,
    numberimages bigint NOT NULL,
    quality character varying(21) DEFAULT ''::character varying NOT NULL,
    aspectratio character varying(20),
    style character varying(20),
    sourceurl text,
    revisedprompt text
);


--
-- Name: TABLE mdl_ai_action_generate_image; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_ai_action_generate_image IS 'Stores specific data about generate image actions';


--
-- Name: mdl_ai_action_generate_image_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_ai_action_generate_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_ai_action_generate_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_ai_action_generate_image_id_seq OWNED BY public.mdl_ai_action_generate_image.id;


--
-- Name: mdl_ai_action_generate_text; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_ai_action_generate_text (
    id bigint NOT NULL,
    prompt text,
    responseid character varying(128),
    fingerprint character varying(128),
    generatedcontent text,
    finishreason character varying(128),
    prompttokens bigint,
    completiontoken bigint
);


--
-- Name: TABLE mdl_ai_action_generate_text; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_ai_action_generate_text IS 'Stores specific data about generate text actions.';


--
-- Name: mdl_ai_action_generate_text_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_ai_action_generate_text_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_ai_action_generate_text_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_ai_action_generate_text_id_seq OWNED BY public.mdl_ai_action_generate_text.id;


--
-- Name: mdl_ai_action_register; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_ai_action_register (
    id bigint NOT NULL,
    actionname character varying(100) DEFAULT ''::character varying NOT NULL,
    actionid bigint NOT NULL,
    success smallint DEFAULT 0 NOT NULL,
    userid bigint NOT NULL,
    contextid bigint NOT NULL,
    provider character varying(100) DEFAULT ''::character varying NOT NULL,
    errorcode smallint,
    errormessage text,
    timecreated bigint NOT NULL,
    timecompleted bigint
);


--
-- Name: TABLE mdl_ai_action_register; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_ai_action_register IS 'Stores information about processed ai actions.';


--
-- Name: mdl_ai_action_register_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_ai_action_register_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_ai_action_register_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_ai_action_register_id_seq OWNED BY public.mdl_ai_action_register.id;


--
-- Name: mdl_ai_action_summarise_text; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_ai_action_summarise_text (
    id bigint NOT NULL,
    prompt text,
    responseid character varying(128),
    fingerprint character varying(128),
    generatedcontent text,
    finishreason character varying(128),
    prompttokens bigint,
    completiontoken bigint
);


--
-- Name: TABLE mdl_ai_action_summarise_text; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_ai_action_summarise_text IS 'Stores specific data about summarise text actions.';


--
-- Name: mdl_ai_action_summarise_text_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_ai_action_summarise_text_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_ai_action_summarise_text_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_ai_action_summarise_text_id_seq OWNED BY public.mdl_ai_action_summarise_text.id;


--
-- Name: mdl_ai_policy_register; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_ai_policy_register (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    contextid bigint NOT NULL,
    timeaccepted bigint NOT NULL
);


--
-- Name: TABLE mdl_ai_policy_register; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_ai_policy_register IS 'Register of users who have accepted this sites AI usage policy';


--
-- Name: mdl_ai_policy_register_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_ai_policy_register_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_ai_policy_register_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_ai_policy_register_id_seq OWNED BY public.mdl_ai_policy_register.id;


--
-- Name: mdl_analytics_indicator_calc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_analytics_indicator_calc (
    id bigint NOT NULL,
    starttime bigint NOT NULL,
    endtime bigint NOT NULL,
    contextid bigint NOT NULL,
    sampleorigin character varying(255) DEFAULT ''::character varying NOT NULL,
    sampleid bigint NOT NULL,
    indicator character varying(255) DEFAULT ''::character varying NOT NULL,
    value numeric(10,2),
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_analytics_indicator_calc; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_analytics_indicator_calc IS 'Stored indicator calculations';


--
-- Name: mdl_analytics_indicator_calc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_analytics_indicator_calc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_analytics_indicator_calc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_analytics_indicator_calc_id_seq OWNED BY public.mdl_analytics_indicator_calc.id;


--
-- Name: mdl_analytics_models; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_analytics_models (
    id bigint NOT NULL,
    enabled smallint DEFAULT 0 NOT NULL,
    trained smallint DEFAULT 0 NOT NULL,
    name character varying(1333),
    target character varying(255) DEFAULT ''::character varying NOT NULL,
    indicators text NOT NULL,
    timesplitting character varying(255),
    predictionsprocessor character varying(255),
    version bigint NOT NULL,
    contextids text,
    timecreated bigint,
    timemodified bigint NOT NULL,
    usermodified bigint NOT NULL
);


--
-- Name: TABLE mdl_analytics_models; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_analytics_models IS 'Analytic models.';


--
-- Name: mdl_analytics_models_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_analytics_models_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_analytics_models_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_analytics_models_id_seq OWNED BY public.mdl_analytics_models.id;


--
-- Name: mdl_analytics_models_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_analytics_models_log (
    id bigint NOT NULL,
    modelid bigint NOT NULL,
    version bigint NOT NULL,
    evaluationmode character varying(50) DEFAULT ''::character varying NOT NULL,
    target character varying(255) DEFAULT ''::character varying NOT NULL,
    indicators text NOT NULL,
    timesplitting character varying(255),
    score numeric(10,5) DEFAULT 0 NOT NULL,
    info text,
    dir text NOT NULL,
    timecreated bigint NOT NULL,
    usermodified bigint NOT NULL
);


--
-- Name: TABLE mdl_analytics_models_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_analytics_models_log IS 'Analytic models changes during evaluation.';


--
-- Name: mdl_analytics_models_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_analytics_models_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_analytics_models_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_analytics_models_log_id_seq OWNED BY public.mdl_analytics_models_log.id;


--
-- Name: mdl_analytics_predict_samples; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_analytics_predict_samples (
    id bigint NOT NULL,
    modelid bigint NOT NULL,
    analysableid bigint NOT NULL,
    timesplitting character varying(255) DEFAULT ''::character varying NOT NULL,
    rangeindex bigint NOT NULL,
    sampleids text NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_analytics_predict_samples; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_analytics_predict_samples IS 'Samples already used for predictions.';


--
-- Name: mdl_analytics_predict_samples_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_analytics_predict_samples_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_analytics_predict_samples_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_analytics_predict_samples_id_seq OWNED BY public.mdl_analytics_predict_samples.id;


--
-- Name: mdl_analytics_prediction_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_analytics_prediction_actions (
    id bigint NOT NULL,
    predictionid bigint NOT NULL,
    userid bigint NOT NULL,
    actionname character varying(255) DEFAULT ''::character varying NOT NULL,
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_analytics_prediction_actions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_analytics_prediction_actions IS 'Register of user actions over predictions.';


--
-- Name: mdl_analytics_prediction_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_analytics_prediction_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_analytics_prediction_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_analytics_prediction_actions_id_seq OWNED BY public.mdl_analytics_prediction_actions.id;


--
-- Name: mdl_analytics_predictions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_analytics_predictions (
    id bigint NOT NULL,
    modelid bigint NOT NULL,
    contextid bigint NOT NULL,
    sampleid bigint NOT NULL,
    rangeindex integer NOT NULL,
    prediction numeric(10,2) NOT NULL,
    predictionscore numeric(10,5) NOT NULL,
    calculations text NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timestart bigint,
    timeend bigint
);


--
-- Name: TABLE mdl_analytics_predictions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_analytics_predictions IS 'Predictions';


--
-- Name: mdl_analytics_predictions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_analytics_predictions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_analytics_predictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_analytics_predictions_id_seq OWNED BY public.mdl_analytics_predictions.id;


--
-- Name: mdl_analytics_train_samples; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_analytics_train_samples (
    id bigint NOT NULL,
    modelid bigint NOT NULL,
    analysableid bigint NOT NULL,
    timesplitting character varying(255) DEFAULT ''::character varying NOT NULL,
    sampleids text NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_analytics_train_samples; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_analytics_train_samples IS 'Samples used for training';


--
-- Name: mdl_analytics_train_samples_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_analytics_train_samples_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_analytics_train_samples_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_analytics_train_samples_id_seq OWNED BY public.mdl_analytics_train_samples.id;


--
-- Name: mdl_analytics_used_analysables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_analytics_used_analysables (
    id bigint NOT NULL,
    modelid bigint NOT NULL,
    action character varying(50) DEFAULT ''::character varying NOT NULL,
    analysableid bigint NOT NULL,
    firstanalysis bigint NOT NULL,
    timeanalysed bigint NOT NULL
);


--
-- Name: TABLE mdl_analytics_used_analysables; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_analytics_used_analysables IS 'List of analysables used by each model';


--
-- Name: mdl_analytics_used_analysables_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_analytics_used_analysables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_analytics_used_analysables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_analytics_used_analysables_id_seq OWNED BY public.mdl_analytics_used_analysables.id;


--
-- Name: mdl_analytics_used_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_analytics_used_files (
    id bigint NOT NULL,
    modelid bigint DEFAULT 0 NOT NULL,
    fileid bigint DEFAULT 0 NOT NULL,
    action character varying(50) DEFAULT ''::character varying NOT NULL,
    "time" bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_analytics_used_files; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_analytics_used_files IS 'Files that have already been used for training and prediction.';


--
-- Name: mdl_analytics_used_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_analytics_used_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_analytics_used_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_analytics_used_files_id_seq OWNED BY public.mdl_analytics_used_files.id;


--
-- Name: mdl_assign; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_assign (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text NOT NULL,
    introformat smallint DEFAULT 0 NOT NULL,
    alwaysshowdescription smallint DEFAULT 0 NOT NULL,
    nosubmissions smallint DEFAULT 0 NOT NULL,
    submissiondrafts smallint DEFAULT 0 NOT NULL,
    sendnotifications smallint DEFAULT 0 NOT NULL,
    sendlatenotifications smallint DEFAULT 0 NOT NULL,
    duedate bigint DEFAULT 0 NOT NULL,
    allowsubmissionsfromdate bigint DEFAULT 0 NOT NULL,
    grade bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    requiresubmissionstatement smallint DEFAULT 0 NOT NULL,
    completionsubmit smallint DEFAULT 0 NOT NULL,
    cutoffdate bigint DEFAULT 0 NOT NULL,
    gradingduedate bigint DEFAULT 0 NOT NULL,
    teamsubmission smallint DEFAULT 0 NOT NULL,
    requireallteammemberssubmit smallint DEFAULT 0 NOT NULL,
    teamsubmissiongroupingid bigint DEFAULT 0 NOT NULL,
    blindmarking smallint DEFAULT 0 NOT NULL,
    hidegrader smallint DEFAULT 0 NOT NULL,
    revealidentities smallint DEFAULT 0 NOT NULL,
    attemptreopenmethod character varying(10) DEFAULT 'untilpass'::character varying NOT NULL,
    maxattempts integer DEFAULT 1 NOT NULL,
    markingworkflow smallint DEFAULT 0 NOT NULL,
    markingallocation smallint DEFAULT 0 NOT NULL,
    markinganonymous smallint DEFAULT 0 NOT NULL,
    sendstudentnotifications smallint DEFAULT 1 NOT NULL,
    preventsubmissionnotingroup smallint DEFAULT 0 NOT NULL,
    activity text,
    activityformat smallint DEFAULT 0 NOT NULL,
    timelimit bigint DEFAULT 0 NOT NULL,
    submissionattachments smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_assign; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_assign IS 'This table saves information about an instance of mod_assign in a course.';


--
-- Name: mdl_assign_grades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_assign_grades (
    id bigint NOT NULL,
    assignment bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    grader bigint DEFAULT 0 NOT NULL,
    grade numeric(10,5) DEFAULT 0,
    attemptnumber bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_assign_grades; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_assign_grades IS 'Grading information about a single assignment submission.';


--
-- Name: mdl_assign_grades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_assign_grades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_assign_grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_assign_grades_id_seq OWNED BY public.mdl_assign_grades.id;


--
-- Name: mdl_assign_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_assign_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_assign_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_assign_id_seq OWNED BY public.mdl_assign.id;


--
-- Name: mdl_assign_overrides; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_assign_overrides (
    id bigint NOT NULL,
    assignid bigint DEFAULT 0 NOT NULL,
    groupid bigint,
    userid bigint,
    sortorder bigint,
    allowsubmissionsfromdate bigint,
    duedate bigint,
    cutoffdate bigint,
    timelimit bigint
);


--
-- Name: TABLE mdl_assign_overrides; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_assign_overrides IS 'The overrides to assign settings.';


--
-- Name: mdl_assign_overrides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_assign_overrides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_assign_overrides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_assign_overrides_id_seq OWNED BY public.mdl_assign_overrides.id;


--
-- Name: mdl_assign_plugin_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_assign_plugin_config (
    id bigint NOT NULL,
    assignment bigint DEFAULT 0 NOT NULL,
    plugin character varying(28) DEFAULT ''::character varying NOT NULL,
    subtype character varying(28) DEFAULT ''::character varying NOT NULL,
    name character varying(28) DEFAULT ''::character varying NOT NULL,
    value text
);


--
-- Name: TABLE mdl_assign_plugin_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_assign_plugin_config IS 'Config data for an instance of a plugin in an assignment.';


--
-- Name: mdl_assign_plugin_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_assign_plugin_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_assign_plugin_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_assign_plugin_config_id_seq OWNED BY public.mdl_assign_plugin_config.id;


--
-- Name: mdl_assign_submission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_assign_submission (
    id bigint NOT NULL,
    assignment bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    timestarted bigint,
    status character varying(10),
    groupid bigint DEFAULT 0 NOT NULL,
    attemptnumber bigint DEFAULT 0 NOT NULL,
    latest smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_assign_submission; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_assign_submission IS 'This table keeps information about student interactions with the mod/assign. This is limited to metadata about a student submission but does not include the submission itself which is stored by plugins.';


--
-- Name: mdl_assign_submission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_assign_submission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_assign_submission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_assign_submission_id_seq OWNED BY public.mdl_assign_submission.id;


--
-- Name: mdl_assign_user_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_assign_user_flags (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    assignment bigint DEFAULT 0 NOT NULL,
    locked bigint DEFAULT 0 NOT NULL,
    mailed smallint DEFAULT 0 NOT NULL,
    extensionduedate bigint DEFAULT 0 NOT NULL,
    workflowstate character varying(20),
    allocatedmarker bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_assign_user_flags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_assign_user_flags IS 'List of flags that can be set for a single user in a single assignment.';


--
-- Name: mdl_assign_user_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_assign_user_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_assign_user_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_assign_user_flags_id_seq OWNED BY public.mdl_assign_user_flags.id;


--
-- Name: mdl_assign_user_mapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_assign_user_mapping (
    id bigint NOT NULL,
    assignment bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_assign_user_mapping; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_assign_user_mapping IS 'Map an assignment specific id number to a user';


--
-- Name: mdl_assign_user_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_assign_user_mapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_assign_user_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_assign_user_mapping_id_seq OWNED BY public.mdl_assign_user_mapping.id;


--
-- Name: mdl_assignfeedback_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_assignfeedback_comments (
    id bigint NOT NULL,
    assignment bigint DEFAULT 0 NOT NULL,
    grade bigint DEFAULT 0 NOT NULL,
    commenttext text,
    commentformat smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_assignfeedback_comments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_assignfeedback_comments IS 'Text feedback for submitted assignments';


--
-- Name: mdl_assignfeedback_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_assignfeedback_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_assignfeedback_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_assignfeedback_comments_id_seq OWNED BY public.mdl_assignfeedback_comments.id;


--
-- Name: mdl_assignfeedback_editpdf_annot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_assignfeedback_editpdf_annot (
    id bigint NOT NULL,
    gradeid bigint DEFAULT 0 NOT NULL,
    pageno bigint DEFAULT 0 NOT NULL,
    x bigint DEFAULT 0,
    y bigint DEFAULT 0,
    endx bigint DEFAULT 0,
    endy bigint DEFAULT 0,
    path text,
    type character varying(10) DEFAULT 'line'::character varying,
    colour character varying(10) DEFAULT 'black'::character varying,
    draft smallint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_assignfeedback_editpdf_annot; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_assignfeedback_editpdf_annot IS 'stores annotations added to pdfs submitted by students';


--
-- Name: mdl_assignfeedback_editpdf_annot_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_assignfeedback_editpdf_annot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_assignfeedback_editpdf_annot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_assignfeedback_editpdf_annot_id_seq OWNED BY public.mdl_assignfeedback_editpdf_annot.id;


--
-- Name: mdl_assignfeedback_editpdf_cmnt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_assignfeedback_editpdf_cmnt (
    id bigint NOT NULL,
    gradeid bigint DEFAULT 0 NOT NULL,
    x bigint DEFAULT 0,
    y bigint DEFAULT 0,
    width bigint DEFAULT 120,
    rawtext text,
    pageno bigint DEFAULT 0 NOT NULL,
    colour character varying(10) DEFAULT 'black'::character varying,
    draft smallint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_assignfeedback_editpdf_cmnt; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_assignfeedback_editpdf_cmnt IS 'Stores comments added to pdfs';


--
-- Name: mdl_assignfeedback_editpdf_cmnt_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_assignfeedback_editpdf_cmnt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_assignfeedback_editpdf_cmnt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_assignfeedback_editpdf_cmnt_id_seq OWNED BY public.mdl_assignfeedback_editpdf_cmnt.id;


--
-- Name: mdl_assignfeedback_editpdf_quick; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_assignfeedback_editpdf_quick (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    rawtext text NOT NULL,
    width bigint DEFAULT 120 NOT NULL,
    colour character varying(10) DEFAULT 'yellow'::character varying
);


--
-- Name: TABLE mdl_assignfeedback_editpdf_quick; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_assignfeedback_editpdf_quick IS 'Stores teacher specified quicklist comments';


--
-- Name: mdl_assignfeedback_editpdf_quick_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_assignfeedback_editpdf_quick_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_assignfeedback_editpdf_quick_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_assignfeedback_editpdf_quick_id_seq OWNED BY public.mdl_assignfeedback_editpdf_quick.id;


--
-- Name: mdl_assignfeedback_editpdf_rot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_assignfeedback_editpdf_rot (
    id bigint NOT NULL,
    gradeid bigint DEFAULT 0 NOT NULL,
    pageno bigint DEFAULT 0 NOT NULL,
    pathnamehash text NOT NULL,
    isrotated smallint DEFAULT 0 NOT NULL,
    degree bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_assignfeedback_editpdf_rot; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_assignfeedback_editpdf_rot IS 'Stores rotation information of a page.';


--
-- Name: mdl_assignfeedback_editpdf_rot_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_assignfeedback_editpdf_rot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_assignfeedback_editpdf_rot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_assignfeedback_editpdf_rot_id_seq OWNED BY public.mdl_assignfeedback_editpdf_rot.id;


--
-- Name: mdl_assignfeedback_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_assignfeedback_file (
    id bigint NOT NULL,
    assignment bigint DEFAULT 0 NOT NULL,
    grade bigint DEFAULT 0 NOT NULL,
    numfiles bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_assignfeedback_file; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_assignfeedback_file IS 'Stores info about the number of files submitted by a student.';


--
-- Name: mdl_assignfeedback_file_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_assignfeedback_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_assignfeedback_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_assignfeedback_file_id_seq OWNED BY public.mdl_assignfeedback_file.id;


--
-- Name: mdl_assignsubmission_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_assignsubmission_file (
    id bigint NOT NULL,
    assignment bigint DEFAULT 0 NOT NULL,
    submission bigint DEFAULT 0 NOT NULL,
    numfiles bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_assignsubmission_file; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_assignsubmission_file IS 'Info about file submissions for assignments';


--
-- Name: mdl_assignsubmission_file_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_assignsubmission_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_assignsubmission_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_assignsubmission_file_id_seq OWNED BY public.mdl_assignsubmission_file.id;


--
-- Name: mdl_assignsubmission_onlinetext; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_assignsubmission_onlinetext (
    id bigint NOT NULL,
    assignment bigint DEFAULT 0 NOT NULL,
    submission bigint DEFAULT 0 NOT NULL,
    onlinetext text,
    onlineformat smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_assignsubmission_onlinetext; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_assignsubmission_onlinetext IS 'Info about onlinetext submission';


--
-- Name: mdl_assignsubmission_onlinetext_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_assignsubmission_onlinetext_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_assignsubmission_onlinetext_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_assignsubmission_onlinetext_id_seq OWNED BY public.mdl_assignsubmission_onlinetext.id;


--
-- Name: mdl_auth_lti_linked_login; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_auth_lti_linked_login (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    issuer text NOT NULL,
    issuer256 character varying(64) DEFAULT ''::character varying NOT NULL,
    sub character varying(255) DEFAULT ''::character varying NOT NULL,
    sub256 character varying(64) DEFAULT ''::character varying NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_auth_lti_linked_login; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_auth_lti_linked_login IS 'Accounts linked to a users Moodle account.';


--
-- Name: mdl_auth_lti_linked_login_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_auth_lti_linked_login_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_auth_lti_linked_login_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_auth_lti_linked_login_id_seq OWNED BY public.mdl_auth_lti_linked_login.id;


--
-- Name: mdl_auth_oauth2_linked_login; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_auth_oauth2_linked_login (
    id bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint NOT NULL,
    userid bigint NOT NULL,
    issuerid bigint NOT NULL,
    username character varying(255) DEFAULT ''::character varying NOT NULL,
    email text NOT NULL,
    confirmtoken character varying(64) DEFAULT ''::character varying NOT NULL,
    confirmtokenexpires bigint
);


--
-- Name: TABLE mdl_auth_oauth2_linked_login; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_auth_oauth2_linked_login IS 'Accounts linked to a users Moodle account.';


--
-- Name: mdl_auth_oauth2_linked_login_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_auth_oauth2_linked_login_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_auth_oauth2_linked_login_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_auth_oauth2_linked_login_id_seq OWNED BY public.mdl_auth_oauth2_linked_login.id;


--
-- Name: mdl_backup_controllers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_backup_controllers (
    id bigint NOT NULL,
    backupid character varying(32) DEFAULT ''::character varying NOT NULL,
    operation character varying(20) DEFAULT 'backup'::character varying NOT NULL,
    type character varying(10) DEFAULT ''::character varying NOT NULL,
    itemid bigint NOT NULL,
    format character varying(20) DEFAULT ''::character varying NOT NULL,
    interactive smallint NOT NULL,
    purpose smallint NOT NULL,
    userid bigint NOT NULL,
    status smallint NOT NULL,
    execution smallint NOT NULL,
    executiontime bigint NOT NULL,
    checksum character varying(32) DEFAULT ''::character varying NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    progress numeric(15,14) DEFAULT 0 NOT NULL,
    controller text NOT NULL
);


--
-- Name: TABLE mdl_backup_controllers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_backup_controllers IS 'To store the backup_controllers as they are used';


--
-- Name: mdl_backup_controllers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_backup_controllers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_backup_controllers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_backup_controllers_id_seq OWNED BY public.mdl_backup_controllers.id;


--
-- Name: mdl_backup_courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_backup_courses (
    id bigint NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL,
    laststarttime bigint DEFAULT 0 NOT NULL,
    lastendtime bigint DEFAULT 0 NOT NULL,
    laststatus character varying(1) DEFAULT '5'::character varying NOT NULL,
    nextstarttime bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_backup_courses; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_backup_courses IS 'To store every course backup status';


--
-- Name: mdl_backup_courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_backup_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_backup_courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_backup_courses_id_seq OWNED BY public.mdl_backup_courses.id;


--
-- Name: mdl_backup_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_backup_logs (
    id bigint NOT NULL,
    backupid character varying(32) DEFAULT ''::character varying NOT NULL,
    loglevel smallint NOT NULL,
    message text NOT NULL,
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_backup_logs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_backup_logs IS 'To store all the logs from backup and restore operations (by db logger)';


--
-- Name: mdl_backup_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_backup_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_backup_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_backup_logs_id_seq OWNED BY public.mdl_backup_logs.id;


--
-- Name: mdl_badge; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_badge (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    description text,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    usercreated bigint NOT NULL,
    usermodified bigint NOT NULL,
    issuername character varying(255) DEFAULT ''::character varying NOT NULL,
    issuerurl character varying(255) DEFAULT ''::character varying NOT NULL,
    issuercontact character varying(255),
    expiredate bigint,
    expireperiod bigint,
    type smallint DEFAULT 1 NOT NULL,
    courseid bigint,
    message text NOT NULL,
    messagesubject text NOT NULL,
    attachment smallint DEFAULT 1 NOT NULL,
    notification smallint DEFAULT 1 NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    nextcron bigint,
    version character varying(255),
    language character varying(255),
    imageauthorname character varying(255),
    imageauthoremail character varying(255),
    imageauthorurl character varying(255),
    imagecaption text
);


--
-- Name: TABLE mdl_badge; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_badge IS 'Defines badge';


--
-- Name: mdl_badge_alignment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_badge_alignment (
    id bigint NOT NULL,
    badgeid bigint DEFAULT 0 NOT NULL,
    targetname character varying(255) DEFAULT ''::character varying NOT NULL,
    targeturl character varying(255) DEFAULT ''::character varying NOT NULL,
    targetdescription text,
    targetframework character varying(255),
    targetcode character varying(255)
);


--
-- Name: TABLE mdl_badge_alignment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_badge_alignment IS 'Defines alignment for badges';


--
-- Name: mdl_badge_alignment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_badge_alignment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_badge_alignment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_badge_alignment_id_seq OWNED BY public.mdl_badge_alignment.id;


--
-- Name: mdl_badge_backpack; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_badge_backpack (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    email character varying(100) DEFAULT ''::character varying NOT NULL,
    backpackuid bigint NOT NULL,
    autosync smallint DEFAULT 0 NOT NULL,
    password character varying(50),
    externalbackpackid bigint
);


--
-- Name: TABLE mdl_badge_backpack; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_badge_backpack IS 'Defines settings for connecting external backpack';


--
-- Name: mdl_badge_backpack_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_badge_backpack_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_badge_backpack_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_badge_backpack_id_seq OWNED BY public.mdl_badge_backpack.id;


--
-- Name: mdl_badge_backpack_oauth2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_badge_backpack_oauth2 (
    id bigint NOT NULL,
    usermodified bigint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    userid bigint NOT NULL,
    issuerid bigint NOT NULL,
    externalbackpackid bigint NOT NULL,
    token text NOT NULL,
    refreshtoken text NOT NULL,
    expires bigint,
    scope text
);


--
-- Name: TABLE mdl_badge_backpack_oauth2; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_badge_backpack_oauth2 IS 'Default comment for the table, please edit me';


--
-- Name: mdl_badge_backpack_oauth2_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_badge_backpack_oauth2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_badge_backpack_oauth2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_badge_backpack_oauth2_id_seq OWNED BY public.mdl_badge_backpack_oauth2.id;


--
-- Name: mdl_badge_criteria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_badge_criteria (
    id bigint NOT NULL,
    badgeid bigint DEFAULT 0 NOT NULL,
    criteriatype bigint,
    method smallint DEFAULT 1 NOT NULL,
    description text,
    descriptionformat smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_badge_criteria; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_badge_criteria IS 'Defines criteria for issuing badges';


--
-- Name: mdl_badge_criteria_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_badge_criteria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_badge_criteria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_badge_criteria_id_seq OWNED BY public.mdl_badge_criteria.id;


--
-- Name: mdl_badge_criteria_met; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_badge_criteria_met (
    id bigint NOT NULL,
    issuedid bigint,
    critid bigint NOT NULL,
    userid bigint NOT NULL,
    datemet bigint NOT NULL
);


--
-- Name: TABLE mdl_badge_criteria_met; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_badge_criteria_met IS 'Defines criteria that were met for an issued badge';


--
-- Name: mdl_badge_criteria_met_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_badge_criteria_met_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_badge_criteria_met_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_badge_criteria_met_id_seq OWNED BY public.mdl_badge_criteria_met.id;


--
-- Name: mdl_badge_criteria_param; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_badge_criteria_param (
    id bigint NOT NULL,
    critid bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    value character varying(255)
);


--
-- Name: TABLE mdl_badge_criteria_param; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_badge_criteria_param IS 'Defines parameters for badges criteria';


--
-- Name: mdl_badge_criteria_param_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_badge_criteria_param_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_badge_criteria_param_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_badge_criteria_param_id_seq OWNED BY public.mdl_badge_criteria_param.id;


--
-- Name: mdl_badge_endorsement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_badge_endorsement (
    id bigint NOT NULL,
    badgeid bigint DEFAULT 0 NOT NULL,
    issuername character varying(255) DEFAULT ''::character varying NOT NULL,
    issuerurl character varying(255) DEFAULT ''::character varying NOT NULL,
    issueremail character varying(255) DEFAULT ''::character varying NOT NULL,
    claimid character varying(255),
    claimcomment text,
    dateissued bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_badge_endorsement; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_badge_endorsement IS 'Defines endorsement for badge';


--
-- Name: mdl_badge_endorsement_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_badge_endorsement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_badge_endorsement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_badge_endorsement_id_seq OWNED BY public.mdl_badge_endorsement.id;


--
-- Name: mdl_badge_external; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_badge_external (
    id bigint NOT NULL,
    backpackid bigint NOT NULL,
    collectionid bigint NOT NULL,
    entityid character varying(255),
    assertion text
);


--
-- Name: TABLE mdl_badge_external; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_badge_external IS 'Setting for external badges display';


--
-- Name: mdl_badge_external_backpack; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_badge_external_backpack (
    id bigint NOT NULL,
    backpackapiurl character varying(255) DEFAULT ''::character varying NOT NULL,
    backpackweburl character varying(255) DEFAULT ''::character varying NOT NULL,
    apiversion character varying(12) DEFAULT '1.0'::character varying NOT NULL,
    sortorder bigint DEFAULT 0 NOT NULL,
    oauth2_issuerid bigint
);


--
-- Name: TABLE mdl_badge_external_backpack; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_badge_external_backpack IS 'Defines settings for site level backpacks that a user can connect to.';


--
-- Name: mdl_badge_external_backpack_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_badge_external_backpack_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_badge_external_backpack_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_badge_external_backpack_id_seq OWNED BY public.mdl_badge_external_backpack.id;


--
-- Name: mdl_badge_external_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_badge_external_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_badge_external_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_badge_external_id_seq OWNED BY public.mdl_badge_external.id;


--
-- Name: mdl_badge_external_identifier; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_badge_external_identifier (
    id bigint NOT NULL,
    sitebackpackid bigint NOT NULL,
    internalid character varying(128) DEFAULT ''::character varying NOT NULL,
    externalid character varying(128) DEFAULT ''::character varying NOT NULL,
    type character varying(16) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_badge_external_identifier; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_badge_external_identifier IS 'Setting for external badges mappings';


--
-- Name: mdl_badge_external_identifier_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_badge_external_identifier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_badge_external_identifier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_badge_external_identifier_id_seq OWNED BY public.mdl_badge_external_identifier.id;


--
-- Name: mdl_badge_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_badge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_badge_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_badge_id_seq OWNED BY public.mdl_badge.id;


--
-- Name: mdl_badge_issued; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_badge_issued (
    id bigint NOT NULL,
    badgeid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    uniquehash text NOT NULL,
    dateissued bigint DEFAULT 0 NOT NULL,
    dateexpire bigint,
    visible smallint DEFAULT 0 NOT NULL,
    issuernotified bigint
);


--
-- Name: TABLE mdl_badge_issued; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_badge_issued IS 'Defines issued badges';


--
-- Name: mdl_badge_issued_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_badge_issued_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_badge_issued_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_badge_issued_id_seq OWNED BY public.mdl_badge_issued.id;


--
-- Name: mdl_badge_manual_award; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_badge_manual_award (
    id bigint NOT NULL,
    badgeid bigint NOT NULL,
    recipientid bigint NOT NULL,
    issuerid bigint NOT NULL,
    issuerrole bigint NOT NULL,
    datemet bigint NOT NULL
);


--
-- Name: TABLE mdl_badge_manual_award; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_badge_manual_award IS 'Track manual award criteria for badges';


--
-- Name: mdl_badge_manual_award_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_badge_manual_award_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_badge_manual_award_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_badge_manual_award_id_seq OWNED BY public.mdl_badge_manual_award.id;


--
-- Name: mdl_badge_related; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_badge_related (
    id bigint NOT NULL,
    badgeid bigint DEFAULT 0 NOT NULL,
    relatedbadgeid bigint
);


--
-- Name: TABLE mdl_badge_related; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_badge_related IS 'Defines badge related for badges';


--
-- Name: mdl_badge_related_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_badge_related_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_badge_related_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_badge_related_id_seq OWNED BY public.mdl_badge_related.id;


--
-- Name: mdl_bigbluebuttonbn; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_bigbluebuttonbn (
    id bigint NOT NULL,
    type smallint DEFAULT 0 NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text,
    introformat smallint DEFAULT 1 NOT NULL,
    meetingid character varying(255) DEFAULT ''::character varying NOT NULL,
    moderatorpass character varying(255) DEFAULT ''::character varying NOT NULL,
    viewerpass character varying(255) DEFAULT ''::character varying NOT NULL,
    wait smallint DEFAULT 0 NOT NULL,
    record smallint DEFAULT 0 NOT NULL,
    recordallfromstart smallint DEFAULT 0 NOT NULL,
    recordhidebutton smallint DEFAULT 0 NOT NULL,
    welcome text,
    voicebridge integer DEFAULT 0 NOT NULL,
    openingtime bigint DEFAULT 0 NOT NULL,
    closingtime bigint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    presentation text,
    participants text,
    userlimit smallint DEFAULT 0 NOT NULL,
    recordings_html smallint DEFAULT 0 NOT NULL,
    recordings_deleted smallint DEFAULT 1 NOT NULL,
    recordings_imported smallint DEFAULT 0 NOT NULL,
    recordings_preview smallint DEFAULT 0 NOT NULL,
    clienttype smallint DEFAULT 0 NOT NULL,
    muteonstart smallint DEFAULT 0 NOT NULL,
    disablecam smallint DEFAULT 0 NOT NULL,
    disablemic smallint DEFAULT 0 NOT NULL,
    disableprivatechat smallint DEFAULT 0 NOT NULL,
    disablepublicchat smallint DEFAULT 0 NOT NULL,
    disablenote smallint DEFAULT 0 NOT NULL,
    hideuserlist smallint DEFAULT 0 NOT NULL,
    completionattendance integer DEFAULT 0 NOT NULL,
    completionengagementchats integer DEFAULT 0 NOT NULL,
    completionengagementtalks integer DEFAULT 0 NOT NULL,
    completionengagementraisehand integer DEFAULT 0 NOT NULL,
    completionengagementpollvotes integer DEFAULT 0 NOT NULL,
    completionengagementemojis integer DEFAULT 0 NOT NULL,
    guestallowed smallint DEFAULT 0,
    mustapproveuser smallint DEFAULT 1,
    guestlinkuid character varying(1024),
    guestpassword character varying(255),
    showpresentation smallint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_bigbluebuttonbn; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_bigbluebuttonbn IS 'The bigbluebuttonbn table to store information about a meeting activities.';


--
-- Name: mdl_bigbluebuttonbn_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_bigbluebuttonbn_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_bigbluebuttonbn_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_bigbluebuttonbn_id_seq OWNED BY public.mdl_bigbluebuttonbn.id;


--
-- Name: mdl_bigbluebuttonbn_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_bigbluebuttonbn_logs (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    bigbluebuttonbnid bigint NOT NULL,
    userid bigint,
    timecreated bigint DEFAULT 0 NOT NULL,
    meetingid character varying(256) DEFAULT ''::character varying NOT NULL,
    log character varying(32) DEFAULT ''::character varying NOT NULL,
    meta text
);


--
-- Name: TABLE mdl_bigbluebuttonbn_logs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_bigbluebuttonbn_logs IS 'The bigbluebuttonbn table to store meeting activity events';


--
-- Name: mdl_bigbluebuttonbn_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_bigbluebuttonbn_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_bigbluebuttonbn_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_bigbluebuttonbn_logs_id_seq OWNED BY public.mdl_bigbluebuttonbn_logs.id;


--
-- Name: mdl_bigbluebuttonbn_recordings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_bigbluebuttonbn_recordings (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    bigbluebuttonbnid bigint NOT NULL,
    groupid bigint,
    recordingid character varying(64) DEFAULT ''::character varying NOT NULL,
    headless smallint DEFAULT 0 NOT NULL,
    imported smallint DEFAULT 0 NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    importeddata text,
    timecreated bigint DEFAULT 0 NOT NULL,
    usermodified bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_bigbluebuttonbn_recordings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_bigbluebuttonbn_recordings IS 'The bigbluebuttonbn table to store references to recordings';


--
-- Name: mdl_bigbluebuttonbn_recordings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_bigbluebuttonbn_recordings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_bigbluebuttonbn_recordings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_bigbluebuttonbn_recordings_id_seq OWNED BY public.mdl_bigbluebuttonbn_recordings.id;


--
-- Name: mdl_block; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_block (
    id bigint NOT NULL,
    name character varying(40) DEFAULT ''::character varying NOT NULL,
    cron bigint DEFAULT 0 NOT NULL,
    lastcron bigint DEFAULT 0 NOT NULL,
    visible smallint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_block; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_block IS 'contains all installed blocks';


--
-- Name: mdl_block_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_block_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_block_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_block_id_seq OWNED BY public.mdl_block.id;


--
-- Name: mdl_block_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_block_instances (
    id bigint NOT NULL,
    blockname character varying(40) DEFAULT ''::character varying NOT NULL,
    parentcontextid bigint NOT NULL,
    showinsubcontexts smallint NOT NULL,
    requiredbytheme smallint DEFAULT 0 NOT NULL,
    pagetypepattern character varying(64) DEFAULT ''::character varying NOT NULL,
    subpagepattern character varying(16),
    defaultregion character varying(16) DEFAULT ''::character varying NOT NULL,
    defaultweight bigint NOT NULL,
    configdata text,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_block_instances; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_block_instances IS 'This table stores block instances. The type of block this is is given by the blockname column. The places this block instance appears is controlled by the parentcontexid, showinsubcontexts, pagetypepattern and subpagepattern fields. Where the block a';


--
-- Name: mdl_block_instances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_block_instances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_block_instances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_block_instances_id_seq OWNED BY public.mdl_block_instances.id;


--
-- Name: mdl_block_positions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_block_positions (
    id bigint NOT NULL,
    blockinstanceid bigint NOT NULL,
    contextid bigint NOT NULL,
    pagetype character varying(64) DEFAULT ''::character varying NOT NULL,
    subpage character varying(16) DEFAULT ''::character varying NOT NULL,
    visible smallint NOT NULL,
    region character varying(16) DEFAULT ''::character varying NOT NULL,
    weight bigint NOT NULL
);


--
-- Name: TABLE mdl_block_positions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_block_positions IS 'Stores the position of a sticky block_instance on a another page than the one where it was added.';


--
-- Name: mdl_block_positions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_block_positions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_block_positions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_block_positions_id_seq OWNED BY public.mdl_block_positions.id;


--
-- Name: mdl_block_recent_activity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_block_recent_activity (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    cmid bigint NOT NULL,
    timecreated bigint NOT NULL,
    userid bigint NOT NULL,
    action smallint NOT NULL,
    modname character varying(20)
);


--
-- Name: TABLE mdl_block_recent_activity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_block_recent_activity IS 'Recent activity block';


--
-- Name: mdl_block_recent_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_block_recent_activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_block_recent_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_block_recent_activity_id_seq OWNED BY public.mdl_block_recent_activity.id;


--
-- Name: mdl_block_recentlyaccesseditems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_block_recentlyaccesseditems (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    cmid bigint NOT NULL,
    userid bigint NOT NULL,
    timeaccess bigint NOT NULL
);


--
-- Name: TABLE mdl_block_recentlyaccesseditems; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_block_recentlyaccesseditems IS 'Most recently accessed items accessed by a user';


--
-- Name: mdl_block_recentlyaccesseditems_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_block_recentlyaccesseditems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_block_recentlyaccesseditems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_block_recentlyaccesseditems_id_seq OWNED BY public.mdl_block_recentlyaccesseditems.id;


--
-- Name: mdl_block_rss_client; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_block_rss_client (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    title text NOT NULL,
    preferredtitle character varying(64) DEFAULT ''::character varying NOT NULL,
    description text NOT NULL,
    shared smallint DEFAULT 0 NOT NULL,
    url character varying(255) DEFAULT ''::character varying NOT NULL,
    skiptime bigint DEFAULT 0 NOT NULL,
    skipuntil bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_block_rss_client; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_block_rss_client IS 'Remote news feed information. Contains the news feed id, the userid of the user who added the feed, the title of the feed itself and a description of the feed contents along with the url used to access the remote feed. Preferredtitle is a field for f';


--
-- Name: mdl_block_rss_client_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_block_rss_client_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_block_rss_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_block_rss_client_id_seq OWNED BY public.mdl_block_rss_client.id;


--
-- Name: mdl_blog_association; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_blog_association (
    id bigint NOT NULL,
    contextid bigint NOT NULL,
    blogid bigint NOT NULL
);


--
-- Name: TABLE mdl_blog_association; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_blog_association IS 'Associations of blog entries with courses and module instances';


--
-- Name: mdl_blog_association_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_blog_association_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_blog_association_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_blog_association_id_seq OWNED BY public.mdl_blog_association.id;


--
-- Name: mdl_blog_external; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_blog_external (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    description text,
    url text NOT NULL,
    filtertags character varying(255),
    failedlastsync smallint DEFAULT 0 NOT NULL,
    timemodified bigint,
    timefetched bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_blog_external; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_blog_external IS 'External blog links used for RSS copying of blog entries to Moodle user blogs';


--
-- Name: mdl_blog_external_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_blog_external_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_blog_external_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_blog_external_id_seq OWNED BY public.mdl_blog_external.id;


--
-- Name: mdl_book; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_book (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text,
    introformat smallint DEFAULT 0 NOT NULL,
    numbering smallint DEFAULT 0 NOT NULL,
    navstyle smallint DEFAULT 1 NOT NULL,
    customtitles smallint DEFAULT 0 NOT NULL,
    revision bigint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_book; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_book IS 'Defines book';


--
-- Name: mdl_book_chapters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_book_chapters (
    id bigint NOT NULL,
    bookid bigint DEFAULT 0 NOT NULL,
    pagenum bigint DEFAULT 0 NOT NULL,
    subchapter bigint DEFAULT 0 NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    content text NOT NULL,
    contentformat smallint DEFAULT 0 NOT NULL,
    hidden smallint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    importsrc character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_book_chapters; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_book_chapters IS 'Defines book_chapters';


--
-- Name: mdl_book_chapters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_book_chapters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_book_chapters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_book_chapters_id_seq OWNED BY public.mdl_book_chapters.id;


--
-- Name: mdl_book_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_book_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_book_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_book_id_seq OWNED BY public.mdl_book.id;


--
-- Name: mdl_cache_filters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_cache_filters (
    id bigint NOT NULL,
    filter character varying(32) DEFAULT ''::character varying NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    md5key character varying(32) DEFAULT ''::character varying NOT NULL,
    rawtext text NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_cache_filters; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_cache_filters IS 'For keeping information about cached data';


--
-- Name: mdl_cache_filters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_cache_filters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_cache_filters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_cache_filters_id_seq OWNED BY public.mdl_cache_filters.id;


--
-- Name: mdl_cache_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_cache_flags (
    id bigint NOT NULL,
    flagtype character varying(255) DEFAULT ''::character varying NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    value text NOT NULL,
    expiry bigint NOT NULL
);


--
-- Name: TABLE mdl_cache_flags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_cache_flags IS 'Cache of time-sensitive flags';


--
-- Name: mdl_cache_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_cache_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_cache_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_cache_flags_id_seq OWNED BY public.mdl_cache_flags.id;


--
-- Name: mdl_capabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_capabilities (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    captype character varying(50) DEFAULT ''::character varying NOT NULL,
    contextlevel bigint DEFAULT 0 NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    riskbitmask bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_capabilities; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_capabilities IS 'this defines all capabilities';


--
-- Name: mdl_capabilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_capabilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_capabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_capabilities_id_seq OWNED BY public.mdl_capabilities.id;


--
-- Name: mdl_chat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_chat (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text NOT NULL,
    introformat smallint DEFAULT 0 NOT NULL,
    keepdays bigint DEFAULT 0 NOT NULL,
    studentlogs smallint DEFAULT 0 NOT NULL,
    chattime bigint DEFAULT 0 NOT NULL,
    schedule smallint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_chat; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_chat IS 'Each of these is a chat room';


--
-- Name: mdl_chat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_chat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_chat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_chat_id_seq OWNED BY public.mdl_chat.id;


--
-- Name: mdl_chat_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_chat_messages (
    id bigint NOT NULL,
    chatid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    groupid bigint DEFAULT 0 NOT NULL,
    issystem smallint DEFAULT 0 NOT NULL,
    message text NOT NULL,
    "timestamp" bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_chat_messages; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_chat_messages IS 'Stores all the actual chat messages';


--
-- Name: mdl_chat_messages_current; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_chat_messages_current (
    id bigint NOT NULL,
    chatid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    groupid bigint DEFAULT 0 NOT NULL,
    issystem smallint DEFAULT 0 NOT NULL,
    message text NOT NULL,
    "timestamp" bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_chat_messages_current; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_chat_messages_current IS 'Stores current session';


--
-- Name: mdl_chat_messages_current_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_chat_messages_current_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_chat_messages_current_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_chat_messages_current_id_seq OWNED BY public.mdl_chat_messages_current.id;


--
-- Name: mdl_chat_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_chat_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_chat_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_chat_messages_id_seq OWNED BY public.mdl_chat_messages.id;


--
-- Name: mdl_chat_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_chat_users (
    id bigint NOT NULL,
    chatid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    groupid bigint DEFAULT 0 NOT NULL,
    version character varying(16) DEFAULT ''::character varying NOT NULL,
    ip character varying(45) DEFAULT ''::character varying NOT NULL,
    firstping bigint DEFAULT 0 NOT NULL,
    lastping bigint DEFAULT 0 NOT NULL,
    lastmessageping bigint DEFAULT 0 NOT NULL,
    sid character varying(32) DEFAULT ''::character varying NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    lang character varying(30) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_chat_users; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_chat_users IS 'Keeps track of which users are in which chat rooms';


--
-- Name: mdl_chat_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_chat_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_chat_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_chat_users_id_seq OWNED BY public.mdl_chat_users.id;


--
-- Name: mdl_choice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_choice (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text NOT NULL,
    introformat smallint DEFAULT 0 NOT NULL,
    publish smallint DEFAULT 0 NOT NULL,
    showresults smallint DEFAULT 0 NOT NULL,
    display smallint DEFAULT 0 NOT NULL,
    allowupdate smallint DEFAULT 0 NOT NULL,
    allowmultiple smallint DEFAULT 0 NOT NULL,
    showunanswered smallint DEFAULT 0 NOT NULL,
    includeinactive smallint DEFAULT 1 NOT NULL,
    limitanswers smallint DEFAULT 0 NOT NULL,
    timeopen bigint DEFAULT 0 NOT NULL,
    timeclose bigint DEFAULT 0 NOT NULL,
    showpreview smallint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    completionsubmit smallint DEFAULT 0 NOT NULL,
    showavailable smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_choice; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_choice IS 'Available choices are stored here';


--
-- Name: mdl_choice_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_choice_answers (
    id bigint NOT NULL,
    choiceid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    optionid bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_choice_answers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_choice_answers IS 'choices performed by users';


--
-- Name: mdl_choice_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_choice_answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_choice_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_choice_answers_id_seq OWNED BY public.mdl_choice_answers.id;


--
-- Name: mdl_choice_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_choice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_choice_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_choice_id_seq OWNED BY public.mdl_choice.id;


--
-- Name: mdl_choice_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_choice_options (
    id bigint NOT NULL,
    choiceid bigint DEFAULT 0 NOT NULL,
    text text,
    maxanswers bigint DEFAULT 0,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_choice_options; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_choice_options IS 'available options to choice';


--
-- Name: mdl_choice_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_choice_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_choice_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_choice_options_id_seq OWNED BY public.mdl_choice_options.id;


--
-- Name: mdl_cohort; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_cohort (
    id bigint NOT NULL,
    contextid bigint NOT NULL,
    name character varying(254) DEFAULT ''::character varying NOT NULL,
    idnumber character varying(100),
    description text,
    descriptionformat smallint NOT NULL,
    visible smallint DEFAULT 1 NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    theme character varying(50)
);


--
-- Name: TABLE mdl_cohort; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_cohort IS 'Each record represents one cohort (aka site-wide group).';


--
-- Name: mdl_cohort_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_cohort_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_cohort_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_cohort_id_seq OWNED BY public.mdl_cohort.id;


--
-- Name: mdl_cohort_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_cohort_members (
    id bigint NOT NULL,
    cohortid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    timeadded bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_cohort_members; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_cohort_members IS 'Link a user to a cohort.';


--
-- Name: mdl_cohort_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_cohort_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_cohort_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_cohort_members_id_seq OWNED BY public.mdl_cohort_members.id;


--
-- Name: mdl_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_comments (
    id bigint NOT NULL,
    contextid bigint NOT NULL,
    component character varying(255),
    commentarea character varying(255) DEFAULT ''::character varying NOT NULL,
    itemid bigint NOT NULL,
    content text NOT NULL,
    format smallint DEFAULT 0 NOT NULL,
    userid bigint NOT NULL,
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_comments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_comments IS 'moodle comments module';


--
-- Name: mdl_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_comments_id_seq OWNED BY public.mdl_comments.id;


--
-- Name: mdl_communication; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_communication (
    id bigint NOT NULL,
    contextid bigint NOT NULL,
    instanceid bigint NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    instancetype character varying(100) DEFAULT ''::character varying NOT NULL,
    provider character varying(100) DEFAULT ''::character varying NOT NULL,
    roomname character varying(255),
    avatarfilename character varying(100),
    active smallint DEFAULT 1 NOT NULL,
    avatarsynced smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_communication; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_communication IS 'Communication records';


--
-- Name: mdl_communication_customlink; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_communication_customlink (
    id bigint NOT NULL,
    commid bigint NOT NULL,
    url character varying(255)
);


--
-- Name: TABLE mdl_communication_customlink; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_communication_customlink IS 'Stores the link associated with a custom link communication instance.';


--
-- Name: mdl_communication_customlink_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_communication_customlink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_communication_customlink_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_communication_customlink_id_seq OWNED BY public.mdl_communication_customlink.id;


--
-- Name: mdl_communication_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_communication_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_communication_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_communication_id_seq OWNED BY public.mdl_communication.id;


--
-- Name: mdl_communication_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_communication_user (
    id bigint NOT NULL,
    commid bigint NOT NULL,
    userid bigint NOT NULL,
    synced smallint DEFAULT 0 NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_communication_user; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_communication_user IS 'Communication user records mapping';


--
-- Name: mdl_communication_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_communication_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_communication_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_communication_user_id_seq OWNED BY public.mdl_communication_user.id;


--
-- Name: mdl_competency; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency (
    id bigint NOT NULL,
    shortname character varying(100),
    description text,
    descriptionformat smallint DEFAULT 0 NOT NULL,
    idnumber character varying(100),
    competencyframeworkid bigint NOT NULL,
    parentid bigint DEFAULT 0 NOT NULL,
    path character varying(255) DEFAULT ''::character varying NOT NULL,
    sortorder bigint NOT NULL,
    ruletype character varying(100),
    ruleoutcome smallint DEFAULT 0 NOT NULL,
    ruleconfig text,
    scaleid bigint,
    scaleconfiguration text,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint
);


--
-- Name: TABLE mdl_competency; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency IS 'This table contains the master record of each competency in a framework';


--
-- Name: mdl_competency_coursecomp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency_coursecomp (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    competencyid bigint NOT NULL,
    ruleoutcome smallint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint NOT NULL,
    sortorder bigint NOT NULL
);


--
-- Name: TABLE mdl_competency_coursecomp; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency_coursecomp IS 'Link a competency to a course.';


--
-- Name: mdl_competency_coursecomp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_coursecomp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_coursecomp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_coursecomp_id_seq OWNED BY public.mdl_competency_coursecomp.id;


--
-- Name: mdl_competency_coursecompsetting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency_coursecompsetting (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    pushratingstouserplans smallint,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint
);


--
-- Name: TABLE mdl_competency_coursecompsetting; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency_coursecompsetting IS 'This table contains the course specific settings for competencies.';


--
-- Name: mdl_competency_coursecompsetting_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_coursecompsetting_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_coursecompsetting_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_coursecompsetting_id_seq OWNED BY public.mdl_competency_coursecompsetting.id;


--
-- Name: mdl_competency_evidence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency_evidence (
    id bigint NOT NULL,
    usercompetencyid bigint NOT NULL,
    contextid bigint NOT NULL,
    action smallint NOT NULL,
    actionuserid bigint,
    descidentifier character varying(255) DEFAULT ''::character varying NOT NULL,
    desccomponent character varying(255) DEFAULT ''::character varying NOT NULL,
    desca text,
    url character varying(255),
    grade bigint,
    note text,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint NOT NULL
);


--
-- Name: TABLE mdl_competency_evidence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency_evidence IS 'The evidence linked to a user competency';


--
-- Name: mdl_competency_evidence_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_evidence_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_evidence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_evidence_id_seq OWNED BY public.mdl_competency_evidence.id;


--
-- Name: mdl_competency_framework; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency_framework (
    id bigint NOT NULL,
    shortname character varying(100),
    contextid bigint NOT NULL,
    idnumber character varying(100),
    description text,
    descriptionformat smallint DEFAULT 0 NOT NULL,
    scaleid bigint,
    scaleconfiguration text NOT NULL,
    visible smallint DEFAULT 1 NOT NULL,
    taxonomies character varying(255) DEFAULT ''::character varying NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint
);


--
-- Name: TABLE mdl_competency_framework; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency_framework IS 'List of competency frameworks.';


--
-- Name: mdl_competency_framework_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_framework_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_framework_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_framework_id_seq OWNED BY public.mdl_competency_framework.id;


--
-- Name: mdl_competency_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_id_seq OWNED BY public.mdl_competency.id;


--
-- Name: mdl_competency_modulecomp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency_modulecomp (
    id bigint NOT NULL,
    cmid bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint NOT NULL,
    sortorder bigint NOT NULL,
    competencyid bigint NOT NULL,
    ruleoutcome smallint NOT NULL,
    overridegrade smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_competency_modulecomp; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency_modulecomp IS 'Link a competency to a module.';


--
-- Name: mdl_competency_modulecomp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_modulecomp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_modulecomp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_modulecomp_id_seq OWNED BY public.mdl_competency_modulecomp.id;


--
-- Name: mdl_competency_plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency_plan (
    id bigint NOT NULL,
    name character varying(100) DEFAULT ''::character varying NOT NULL,
    description text,
    descriptionformat smallint DEFAULT 0 NOT NULL,
    userid bigint NOT NULL,
    templateid bigint,
    origtemplateid bigint,
    status smallint NOT NULL,
    duedate bigint DEFAULT 0,
    reviewerid bigint,
    timecreated bigint NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    usermodified bigint NOT NULL
);


--
-- Name: TABLE mdl_competency_plan; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency_plan IS 'Learning plans';


--
-- Name: mdl_competency_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_plan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_plan_id_seq OWNED BY public.mdl_competency_plan.id;


--
-- Name: mdl_competency_plancomp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency_plancomp (
    id bigint NOT NULL,
    planid bigint NOT NULL,
    competencyid bigint NOT NULL,
    sortorder bigint,
    timecreated bigint NOT NULL,
    timemodified bigint,
    usermodified bigint NOT NULL
);


--
-- Name: TABLE mdl_competency_plancomp; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency_plancomp IS 'Plan competencies';


--
-- Name: mdl_competency_plancomp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_plancomp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_plancomp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_plancomp_id_seq OWNED BY public.mdl_competency_plancomp.id;


--
-- Name: mdl_competency_relatedcomp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency_relatedcomp (
    id bigint NOT NULL,
    competencyid bigint NOT NULL,
    relatedcompetencyid bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint,
    usermodified bigint NOT NULL
);


--
-- Name: TABLE mdl_competency_relatedcomp; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency_relatedcomp IS 'Related competencies';


--
-- Name: mdl_competency_relatedcomp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_relatedcomp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_relatedcomp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_relatedcomp_id_seq OWNED BY public.mdl_competency_relatedcomp.id;


--
-- Name: mdl_competency_template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency_template (
    id bigint NOT NULL,
    shortname character varying(100),
    contextid bigint NOT NULL,
    description text,
    descriptionformat smallint DEFAULT 0 NOT NULL,
    visible smallint DEFAULT 1 NOT NULL,
    duedate bigint,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint
);


--
-- Name: TABLE mdl_competency_template; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency_template IS 'Learning plan templates.';


--
-- Name: mdl_competency_template_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_template_id_seq OWNED BY public.mdl_competency_template.id;


--
-- Name: mdl_competency_templatecohort; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency_templatecohort (
    id bigint NOT NULL,
    templateid bigint NOT NULL,
    cohortid bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint NOT NULL
);


--
-- Name: TABLE mdl_competency_templatecohort; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency_templatecohort IS 'Default comment for the table, please edit me';


--
-- Name: mdl_competency_templatecohort_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_templatecohort_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_templatecohort_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_templatecohort_id_seq OWNED BY public.mdl_competency_templatecohort.id;


--
-- Name: mdl_competency_templatecomp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency_templatecomp (
    id bigint NOT NULL,
    templateid bigint NOT NULL,
    competencyid bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint NOT NULL,
    sortorder bigint
);


--
-- Name: TABLE mdl_competency_templatecomp; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency_templatecomp IS 'Link a competency to a learning plan template.';


--
-- Name: mdl_competency_templatecomp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_templatecomp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_templatecomp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_templatecomp_id_seq OWNED BY public.mdl_competency_templatecomp.id;


--
-- Name: mdl_competency_usercomp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency_usercomp (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    competencyid bigint NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    reviewerid bigint,
    proficiency smallint,
    grade bigint,
    timecreated bigint NOT NULL,
    timemodified bigint,
    usermodified bigint NOT NULL
);


--
-- Name: TABLE mdl_competency_usercomp; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency_usercomp IS 'User competencies';


--
-- Name: mdl_competency_usercomp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_usercomp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_usercomp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_usercomp_id_seq OWNED BY public.mdl_competency_usercomp.id;


--
-- Name: mdl_competency_usercompcourse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency_usercompcourse (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    courseid bigint NOT NULL,
    competencyid bigint NOT NULL,
    proficiency smallint,
    grade bigint,
    timecreated bigint NOT NULL,
    timemodified bigint,
    usermodified bigint NOT NULL
);


--
-- Name: TABLE mdl_competency_usercompcourse; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency_usercompcourse IS 'User competencies in a course';


--
-- Name: mdl_competency_usercompcourse_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_usercompcourse_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_usercompcourse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_usercompcourse_id_seq OWNED BY public.mdl_competency_usercompcourse.id;


--
-- Name: mdl_competency_usercompplan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency_usercompplan (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    competencyid bigint NOT NULL,
    planid bigint NOT NULL,
    proficiency smallint,
    grade bigint,
    sortorder bigint,
    timecreated bigint NOT NULL,
    timemodified bigint,
    usermodified bigint NOT NULL
);


--
-- Name: TABLE mdl_competency_usercompplan; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency_usercompplan IS 'User competencies plans';


--
-- Name: mdl_competency_usercompplan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_usercompplan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_usercompplan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_usercompplan_id_seq OWNED BY public.mdl_competency_usercompplan.id;


--
-- Name: mdl_competency_userevidence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency_userevidence (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    name character varying(100) DEFAULT ''::character varying NOT NULL,
    description text NOT NULL,
    descriptionformat smallint NOT NULL,
    url text NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint NOT NULL
);


--
-- Name: TABLE mdl_competency_userevidence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency_userevidence IS 'The evidence of prior learning';


--
-- Name: mdl_competency_userevidence_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_userevidence_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_userevidence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_userevidence_id_seq OWNED BY public.mdl_competency_userevidence.id;


--
-- Name: mdl_competency_userevidencecomp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_competency_userevidencecomp (
    id bigint NOT NULL,
    userevidenceid bigint NOT NULL,
    competencyid bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint NOT NULL
);


--
-- Name: TABLE mdl_competency_userevidencecomp; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_competency_userevidencecomp IS 'Relationship between user evidence and competencies';


--
-- Name: mdl_competency_userevidencecomp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_competency_userevidencecomp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_competency_userevidencecomp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_competency_userevidencecomp_id_seq OWNED BY public.mdl_competency_userevidencecomp.id;


--
-- Name: mdl_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_config (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    value text NOT NULL
);


--
-- Name: TABLE mdl_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_config IS 'Moodle configuration variables';


--
-- Name: mdl_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_config_id_seq OWNED BY public.mdl_config.id;


--
-- Name: mdl_config_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_config_log (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    timemodified bigint NOT NULL,
    plugin character varying(100),
    name character varying(100) DEFAULT ''::character varying NOT NULL,
    value text,
    oldvalue text
);


--
-- Name: TABLE mdl_config_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_config_log IS 'Changes done in server configuration through admin UI';


--
-- Name: mdl_config_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_config_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_config_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_config_log_id_seq OWNED BY public.mdl_config_log.id;


--
-- Name: mdl_config_plugins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_config_plugins (
    id bigint NOT NULL,
    plugin character varying(100) DEFAULT 'core'::character varying NOT NULL,
    name character varying(100) DEFAULT ''::character varying NOT NULL,
    value text NOT NULL
);


--
-- Name: TABLE mdl_config_plugins; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_config_plugins IS 'Moodle modules and plugins configuration variables';


--
-- Name: mdl_config_plugins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_config_plugins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_config_plugins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_config_plugins_id_seq OWNED BY public.mdl_config_plugins.id;


--
-- Name: mdl_contentbank_content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_contentbank_content (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    contenttype character varying(100) DEFAULT ''::character varying NOT NULL,
    contextid bigint NOT NULL,
    visibility smallint DEFAULT 1 NOT NULL,
    instanceid bigint,
    configdata text,
    usercreated bigint NOT NULL,
    usermodified bigint,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0
);


--
-- Name: TABLE mdl_contentbank_content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_contentbank_content IS 'This table stores content data in the content bank.';


--
-- Name: mdl_contentbank_content_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_contentbank_content_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_contentbank_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_contentbank_content_id_seq OWNED BY public.mdl_contentbank_content.id;


--
-- Name: mdl_context; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_context (
    id bigint NOT NULL,
    contextlevel bigint DEFAULT 0 NOT NULL,
    instanceid bigint DEFAULT 0 NOT NULL,
    path character varying(255),
    depth smallint DEFAULT 0 NOT NULL,
    locked smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_context; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_context IS 'one of these must be set';


--
-- Name: mdl_context_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_context_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_context_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_context_id_seq OWNED BY public.mdl_context.id;


--
-- Name: mdl_context_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_context_temp (
    id bigint NOT NULL,
    path character varying(255) DEFAULT ''::character varying NOT NULL,
    depth smallint NOT NULL,
    locked smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_context_temp; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_context_temp IS 'Used by build_context_path() in upgrade and cron to keep context depths and paths in sync.';


--
-- Name: mdl_course; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_course (
    id bigint NOT NULL,
    category bigint DEFAULT 0 NOT NULL,
    sortorder bigint DEFAULT 0 NOT NULL,
    fullname character varying(254) DEFAULT ''::character varying NOT NULL,
    shortname character varying(255) DEFAULT ''::character varying NOT NULL,
    idnumber character varying(100) DEFAULT ''::character varying NOT NULL,
    summary text,
    summaryformat smallint DEFAULT 0 NOT NULL,
    format character varying(21) DEFAULT 'topics'::character varying NOT NULL,
    showgrades smallint DEFAULT 1 NOT NULL,
    newsitems integer DEFAULT 1 NOT NULL,
    startdate bigint DEFAULT 0 NOT NULL,
    enddate bigint DEFAULT 0 NOT NULL,
    relativedatesmode smallint DEFAULT 0 NOT NULL,
    marker bigint DEFAULT 0 NOT NULL,
    maxbytes bigint DEFAULT 0 NOT NULL,
    legacyfiles smallint DEFAULT 0 NOT NULL,
    showreports smallint DEFAULT 0 NOT NULL,
    visible smallint DEFAULT 1 NOT NULL,
    visibleold smallint DEFAULT 1 NOT NULL,
    downloadcontent smallint,
    groupmode smallint DEFAULT 0 NOT NULL,
    groupmodeforce smallint DEFAULT 0 NOT NULL,
    defaultgroupingid bigint DEFAULT 0 NOT NULL,
    lang character varying(30) DEFAULT ''::character varying NOT NULL,
    calendartype character varying(30) DEFAULT ''::character varying NOT NULL,
    theme character varying(50) DEFAULT ''::character varying NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    requested smallint DEFAULT 0 NOT NULL,
    enablecompletion smallint DEFAULT 0 NOT NULL,
    completionnotify smallint DEFAULT 0 NOT NULL,
    cacherev bigint DEFAULT 0 NOT NULL,
    originalcourseid bigint,
    showactivitydates smallint DEFAULT 0 NOT NULL,
    showcompletionconditions smallint,
    pdfexportfont character varying(50)
);


--
-- Name: TABLE mdl_course; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_course IS 'Central course table';


--
-- Name: mdl_course_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_course_categories (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    idnumber character varying(100),
    description text,
    descriptionformat smallint DEFAULT 0 NOT NULL,
    parent bigint DEFAULT 0 NOT NULL,
    sortorder bigint DEFAULT 0 NOT NULL,
    coursecount bigint DEFAULT 0 NOT NULL,
    visible smallint DEFAULT 1 NOT NULL,
    visibleold smallint DEFAULT 1 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    depth bigint DEFAULT 0 NOT NULL,
    path character varying(255) DEFAULT ''::character varying NOT NULL,
    theme character varying(50)
);


--
-- Name: TABLE mdl_course_categories; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_course_categories IS 'Course categories';


--
-- Name: mdl_course_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_course_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_course_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_course_categories_id_seq OWNED BY public.mdl_course_categories.id;


--
-- Name: mdl_course_completion_aggr_methd; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_course_completion_aggr_methd (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    criteriatype bigint,
    method smallint DEFAULT 0 NOT NULL,
    value numeric(10,5)
);


--
-- Name: TABLE mdl_course_completion_aggr_methd; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_course_completion_aggr_methd IS 'Course completion aggregation methods for criteria';


--
-- Name: mdl_course_completion_aggr_methd_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_course_completion_aggr_methd_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_course_completion_aggr_methd_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_course_completion_aggr_methd_id_seq OWNED BY public.mdl_course_completion_aggr_methd.id;


--
-- Name: mdl_course_completion_crit_compl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_course_completion_crit_compl (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    criteriaid bigint DEFAULT 0 NOT NULL,
    gradefinal numeric(10,5),
    unenroled bigint,
    timecompleted bigint
);


--
-- Name: TABLE mdl_course_completion_crit_compl; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_course_completion_crit_compl IS 'Course completion user records';


--
-- Name: mdl_course_completion_crit_compl_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_course_completion_crit_compl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_course_completion_crit_compl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_course_completion_crit_compl_id_seq OWNED BY public.mdl_course_completion_crit_compl.id;


--
-- Name: mdl_course_completion_criteria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_course_completion_criteria (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    criteriatype bigint DEFAULT 0 NOT NULL,
    module character varying(100),
    moduleinstance bigint,
    courseinstance bigint,
    enrolperiod bigint,
    timeend bigint,
    gradepass numeric(10,5),
    role bigint
);


--
-- Name: TABLE mdl_course_completion_criteria; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_course_completion_criteria IS 'Course completion criteria';


--
-- Name: mdl_course_completion_criteria_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_course_completion_criteria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_course_completion_criteria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_course_completion_criteria_id_seq OWNED BY public.mdl_course_completion_criteria.id;


--
-- Name: mdl_course_completion_defaults; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_course_completion_defaults (
    id bigint NOT NULL,
    course bigint NOT NULL,
    module bigint NOT NULL,
    completion smallint DEFAULT 0 NOT NULL,
    completionview smallint DEFAULT 0 NOT NULL,
    completionusegrade smallint DEFAULT 0 NOT NULL,
    completionpassgrade smallint DEFAULT 0 NOT NULL,
    completionexpected bigint DEFAULT 0 NOT NULL,
    customrules text
);


--
-- Name: TABLE mdl_course_completion_defaults; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_course_completion_defaults IS 'Default settings for activities completion';


--
-- Name: mdl_course_completion_defaults_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_course_completion_defaults_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_course_completion_defaults_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_course_completion_defaults_id_seq OWNED BY public.mdl_course_completion_defaults.id;


--
-- Name: mdl_course_completions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_course_completions (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    timeenrolled bigint DEFAULT 0 NOT NULL,
    timestarted bigint DEFAULT 0 NOT NULL,
    timecompleted bigint,
    reaggregate bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_course_completions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_course_completions IS 'Course completion records';


--
-- Name: mdl_course_completions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_course_completions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_course_completions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_course_completions_id_seq OWNED BY public.mdl_course_completions.id;


--
-- Name: mdl_course_format_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_course_format_options (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    format character varying(21) DEFAULT ''::character varying NOT NULL,
    sectionid bigint DEFAULT 0 NOT NULL,
    name character varying(100) DEFAULT ''::character varying NOT NULL,
    value text
);


--
-- Name: TABLE mdl_course_format_options; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_course_format_options IS 'Stores format-specific options for the course or course section';


--
-- Name: mdl_course_format_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_course_format_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_course_format_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_course_format_options_id_seq OWNED BY public.mdl_course_format_options.id;


--
-- Name: mdl_course_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_course_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_course_id_seq OWNED BY public.mdl_course.id;


--
-- Name: mdl_course_modules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_course_modules (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    module bigint DEFAULT 0 NOT NULL,
    instance bigint DEFAULT 0 NOT NULL,
    section bigint DEFAULT 0 NOT NULL,
    idnumber character varying(100),
    added bigint DEFAULT 0 NOT NULL,
    score smallint DEFAULT 0 NOT NULL,
    indent integer DEFAULT 0 NOT NULL,
    visible smallint DEFAULT 1 NOT NULL,
    visibleoncoursepage smallint DEFAULT 1 NOT NULL,
    visibleold smallint DEFAULT 1 NOT NULL,
    groupmode smallint DEFAULT 0 NOT NULL,
    groupingid bigint DEFAULT 0 NOT NULL,
    completion smallint DEFAULT 0 NOT NULL,
    completiongradeitemnumber bigint,
    completionview smallint DEFAULT 0 NOT NULL,
    completionexpected bigint DEFAULT 0 NOT NULL,
    completionpassgrade smallint DEFAULT 0 NOT NULL,
    showdescription smallint DEFAULT 0 NOT NULL,
    availability text,
    deletioninprogress smallint DEFAULT 0 NOT NULL,
    downloadcontent smallint DEFAULT 1,
    lang character varying(30)
);


--
-- Name: TABLE mdl_course_modules; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_course_modules IS 'course_modules table retrofitted from MySQL';


--
-- Name: mdl_course_modules_completion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_course_modules_completion (
    id bigint NOT NULL,
    coursemoduleid bigint NOT NULL,
    userid bigint NOT NULL,
    completionstate smallint NOT NULL,
    overrideby bigint,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_course_modules_completion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_course_modules_completion IS 'Stores the completion state (completed or not completed, etc) of each user on each activity.';


--
-- Name: mdl_course_modules_completion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_course_modules_completion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_course_modules_completion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_course_modules_completion_id_seq OWNED BY public.mdl_course_modules_completion.id;


--
-- Name: mdl_course_modules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_course_modules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_course_modules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_course_modules_id_seq OWNED BY public.mdl_course_modules.id;


--
-- Name: mdl_course_modules_viewed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_course_modules_viewed (
    id bigint NOT NULL,
    coursemoduleid bigint NOT NULL,
    userid bigint NOT NULL,
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_course_modules_viewed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_course_modules_viewed IS 'Tracks the completion viewed (viewed with cmid/userid and otherwise no row) of each user on each activity.';


--
-- Name: mdl_course_modules_viewed_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_course_modules_viewed_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_course_modules_viewed_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_course_modules_viewed_id_seq OWNED BY public.mdl_course_modules_viewed.id;


--
-- Name: mdl_course_published; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_course_published (
    id bigint NOT NULL,
    huburl character varying(255),
    courseid bigint NOT NULL,
    timepublished bigint NOT NULL,
    enrollable smallint DEFAULT 1 NOT NULL,
    hubcourseid bigint NOT NULL,
    status smallint DEFAULT 0,
    timechecked bigint
);


--
-- Name: TABLE mdl_course_published; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_course_published IS 'Information about how and when an local courses were published to hubs';


--
-- Name: mdl_course_published_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_course_published_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_course_published_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_course_published_id_seq OWNED BY public.mdl_course_published.id;


--
-- Name: mdl_course_request; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_course_request (
    id bigint NOT NULL,
    fullname character varying(254) DEFAULT ''::character varying NOT NULL,
    shortname character varying(100) DEFAULT ''::character varying NOT NULL,
    summary text NOT NULL,
    summaryformat smallint DEFAULT 0 NOT NULL,
    category bigint DEFAULT 0 NOT NULL,
    reason text NOT NULL,
    requester bigint DEFAULT 0 NOT NULL,
    password character varying(50) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_course_request; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_course_request IS 'course requests';


--
-- Name: mdl_course_request_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_course_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_course_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_course_request_id_seq OWNED BY public.mdl_course_request.id;


--
-- Name: mdl_course_sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_course_sections (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    section bigint DEFAULT 0 NOT NULL,
    name character varying(255),
    summary text,
    summaryformat smallint DEFAULT 0 NOT NULL,
    sequence text,
    visible smallint DEFAULT 1 NOT NULL,
    availability text,
    component character varying(100),
    itemid bigint,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_course_sections; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_course_sections IS 'to define the sections for each course';


--
-- Name: mdl_course_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_course_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_course_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_course_sections_id_seq OWNED BY public.mdl_course_sections.id;


--
-- Name: mdl_customfield_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_customfield_category (
    id bigint NOT NULL,
    name character varying(400) DEFAULT ''::character varying NOT NULL,
    description text,
    descriptionformat bigint,
    sortorder bigint,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    area character varying(100) DEFAULT ''::character varying NOT NULL,
    itemid bigint DEFAULT 0 NOT NULL,
    contextid bigint
);


--
-- Name: TABLE mdl_customfield_category; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_customfield_category IS 'core_customfield category table';


--
-- Name: mdl_customfield_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_customfield_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_customfield_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_customfield_category_id_seq OWNED BY public.mdl_customfield_category.id;


--
-- Name: mdl_customfield_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_customfield_data (
    id bigint NOT NULL,
    fieldid bigint NOT NULL,
    instanceid bigint NOT NULL,
    intvalue bigint,
    decvalue numeric(10,5),
    shortcharvalue character varying(255),
    charvalue character varying(1333),
    value text NOT NULL,
    valueformat bigint NOT NULL,
    valuetrust smallint DEFAULT 0 NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    contextid bigint
);


--
-- Name: TABLE mdl_customfield_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_customfield_data IS 'core_customfield data table';


--
-- Name: mdl_customfield_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_customfield_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_customfield_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_customfield_data_id_seq OWNED BY public.mdl_customfield_data.id;


--
-- Name: mdl_customfield_field; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_customfield_field (
    id bigint NOT NULL,
    shortname character varying(100) DEFAULT ''::character varying NOT NULL,
    name character varying(400) DEFAULT ''::character varying NOT NULL,
    type character varying(100) DEFAULT ''::character varying NOT NULL,
    description text,
    descriptionformat bigint,
    sortorder bigint,
    categoryid bigint,
    configdata text,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_customfield_field; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_customfield_field IS 'core_customfield field table';


--
-- Name: mdl_customfield_field_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_customfield_field_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_customfield_field_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_customfield_field_id_seq OWNED BY public.mdl_customfield_field.id;


--
-- Name: mdl_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_data (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text NOT NULL,
    introformat smallint DEFAULT 0 NOT NULL,
    comments smallint DEFAULT 0 NOT NULL,
    timeavailablefrom bigint DEFAULT 0 NOT NULL,
    timeavailableto bigint DEFAULT 0 NOT NULL,
    timeviewfrom bigint DEFAULT 0 NOT NULL,
    timeviewto bigint DEFAULT 0 NOT NULL,
    requiredentries integer DEFAULT 0 NOT NULL,
    requiredentriestoview integer DEFAULT 0 NOT NULL,
    maxentries integer DEFAULT 0 NOT NULL,
    rssarticles smallint DEFAULT 0 NOT NULL,
    singletemplate text,
    listtemplate text,
    listtemplateheader text,
    listtemplatefooter text,
    addtemplate text,
    rsstemplate text,
    rsstitletemplate text,
    csstemplate text,
    jstemplate text,
    asearchtemplate text,
    approval smallint DEFAULT 0 NOT NULL,
    manageapproved smallint DEFAULT 1 NOT NULL,
    scale bigint DEFAULT 0 NOT NULL,
    assessed bigint DEFAULT 0 NOT NULL,
    assesstimestart bigint DEFAULT 0 NOT NULL,
    assesstimefinish bigint DEFAULT 0 NOT NULL,
    defaultsort bigint DEFAULT 0 NOT NULL,
    defaultsortdir smallint DEFAULT 0 NOT NULL,
    editany smallint DEFAULT 0 NOT NULL,
    notification bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    config text,
    completionentries bigint DEFAULT 0
);


--
-- Name: TABLE mdl_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_data IS 'all database activities';


--
-- Name: mdl_data_content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_data_content (
    id bigint NOT NULL,
    fieldid bigint DEFAULT 0 NOT NULL,
    recordid bigint DEFAULT 0 NOT NULL,
    content text,
    content1 text,
    content2 text,
    content3 text,
    content4 text
);


--
-- Name: TABLE mdl_data_content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_data_content IS 'the content introduced in each record/fields';


--
-- Name: mdl_data_content_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_data_content_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_data_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_data_content_id_seq OWNED BY public.mdl_data_content.id;


--
-- Name: mdl_data_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_data_fields (
    id bigint NOT NULL,
    dataid bigint DEFAULT 0 NOT NULL,
    type character varying(255) DEFAULT ''::character varying NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    description text NOT NULL,
    required smallint DEFAULT 0 NOT NULL,
    param1 text,
    param2 text,
    param3 text,
    param4 text,
    param5 text,
    param6 text,
    param7 text,
    param8 text,
    param9 text,
    param10 text
);


--
-- Name: TABLE mdl_data_fields; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_data_fields IS 'every field available';


--
-- Name: mdl_data_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_data_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_data_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_data_fields_id_seq OWNED BY public.mdl_data_fields.id;


--
-- Name: mdl_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_data_id_seq OWNED BY public.mdl_data.id;


--
-- Name: mdl_data_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_data_records (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    groupid bigint DEFAULT 0 NOT NULL,
    dataid bigint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    approved smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_data_records; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_data_records IS 'every record introduced';


--
-- Name: mdl_data_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_data_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_data_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_data_records_id_seq OWNED BY public.mdl_data_records.id;


--
-- Name: mdl_editor_atto_autosave; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_editor_atto_autosave (
    id bigint NOT NULL,
    elementid character varying(255) DEFAULT ''::character varying NOT NULL,
    contextid bigint NOT NULL,
    pagehash character varying(64) DEFAULT ''::character varying NOT NULL,
    userid bigint NOT NULL,
    drafttext text NOT NULL,
    draftid bigint,
    pageinstance character varying(64) DEFAULT ''::character varying NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_editor_atto_autosave; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_editor_atto_autosave IS 'Draft text that is auto-saved every 5 seconds while an editor is open.';


--
-- Name: mdl_editor_atto_autosave_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_editor_atto_autosave_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_editor_atto_autosave_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_editor_atto_autosave_id_seq OWNED BY public.mdl_editor_atto_autosave.id;


--
-- Name: mdl_enrol; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol (
    id bigint NOT NULL,
    enrol character varying(20) DEFAULT ''::character varying NOT NULL,
    status bigint DEFAULT 0 NOT NULL,
    courseid bigint NOT NULL,
    sortorder bigint DEFAULT 0 NOT NULL,
    name character varying(255),
    enrolperiod bigint DEFAULT 0,
    enrolstartdate bigint DEFAULT 0,
    enrolenddate bigint DEFAULT 0,
    expirynotify smallint DEFAULT 0,
    expirythreshold bigint DEFAULT 0,
    notifyall smallint DEFAULT 0,
    password character varying(50),
    cost character varying(20),
    currency character varying(3),
    roleid bigint DEFAULT 0,
    customint1 bigint,
    customint2 bigint,
    customint3 bigint,
    customint4 bigint,
    customint5 bigint,
    customint6 bigint,
    customint7 bigint,
    customint8 bigint,
    customchar1 character varying(255),
    customchar2 character varying(255),
    customchar3 character varying(1333),
    customdec1 numeric(12,7),
    customdec2 numeric(12,7),
    customtext1 text,
    customtext2 text,
    customtext3 text,
    customtext4 text,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_enrol; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol IS 'Instances of enrolment plugins used in courses, fields marked as custom have a plugin defined meaning, core does not touch them. Create a new linked table if you need even more custom fields.';


--
-- Name: mdl_enrol_flatfile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_flatfile (
    id bigint NOT NULL,
    action character varying(30) DEFAULT ''::character varying NOT NULL,
    roleid bigint NOT NULL,
    userid bigint NOT NULL,
    courseid bigint NOT NULL,
    timestart bigint DEFAULT 0 NOT NULL,
    timeend bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_enrol_flatfile; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_flatfile IS 'enrol_flatfile table retrofitted from MySQL';


--
-- Name: mdl_enrol_flatfile_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_flatfile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_flatfile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_flatfile_id_seq OWNED BY public.mdl_enrol_flatfile.id;


--
-- Name: mdl_enrol_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_id_seq OWNED BY public.mdl_enrol.id;


--
-- Name: mdl_enrol_lti_app_registration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_lti_app_registration (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    platformid text,
    clientid character varying(1333),
    uniqueid character varying(255) DEFAULT ''::character varying NOT NULL,
    platformclienthash character varying(64),
    platformuniqueidhash character varying(64),
    authenticationrequesturl text,
    jwksurl text,
    accesstokenurl text,
    status smallint DEFAULT 0 NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_enrol_lti_app_registration; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_lti_app_registration IS 'Details of each application that has been registered with the tool';


--
-- Name: mdl_enrol_lti_app_registration_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_lti_app_registration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_lti_app_registration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_lti_app_registration_id_seq OWNED BY public.mdl_enrol_lti_app_registration.id;


--
-- Name: mdl_enrol_lti_context; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_lti_context (
    id bigint NOT NULL,
    contextid character varying(255) DEFAULT ''::character varying NOT NULL,
    ltideploymentid bigint NOT NULL,
    type text,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_enrol_lti_context; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_lti_context IS 'Each row represents a context in the platform, where resource links are added within a deployment.';


--
-- Name: mdl_enrol_lti_context_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_lti_context_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_lti_context_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_lti_context_id_seq OWNED BY public.mdl_enrol_lti_context.id;


--
-- Name: mdl_enrol_lti_deployment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_lti_deployment (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    deploymentid character varying(255) DEFAULT ''::character varying NOT NULL,
    platformid bigint NOT NULL,
    legacyconsumerkey character varying(255),
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_enrol_lti_deployment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_lti_deployment IS 'Each row represents a deployment of a tool within a platform.';


--
-- Name: mdl_enrol_lti_deployment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_lti_deployment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_lti_deployment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_lti_deployment_id_seq OWNED BY public.mdl_enrol_lti_deployment.id;


--
-- Name: mdl_enrol_lti_lti2_consumer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_lti_lti2_consumer (
    id bigint NOT NULL,
    name character varying(50) DEFAULT ''::character varying NOT NULL,
    consumerkey256 character varying(255) DEFAULT ''::character varying NOT NULL,
    consumerkey text,
    secret character varying(1024) DEFAULT ''::character varying NOT NULL,
    ltiversion character varying(10),
    consumername character varying(255),
    consumerversion character varying(255),
    consumerguid character varying(1024),
    profile text,
    toolproxy text,
    settings text,
    protected smallint NOT NULL,
    enabled smallint NOT NULL,
    enablefrom bigint,
    enableuntil bigint,
    lastaccess bigint,
    created bigint NOT NULL,
    updated bigint NOT NULL
);


--
-- Name: TABLE mdl_enrol_lti_lti2_consumer; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_lti_lti2_consumer IS 'LTI consumers interacting with moodle';


--
-- Name: mdl_enrol_lti_lti2_consumer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_lti_lti2_consumer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_lti_lti2_consumer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_lti_lti2_consumer_id_seq OWNED BY public.mdl_enrol_lti_lti2_consumer.id;


--
-- Name: mdl_enrol_lti_lti2_context; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_lti_lti2_context (
    id bigint NOT NULL,
    consumerid bigint NOT NULL,
    lticontextkey character varying(255) DEFAULT ''::character varying NOT NULL,
    type character varying(100),
    settings text,
    created bigint NOT NULL,
    updated bigint NOT NULL
);


--
-- Name: TABLE mdl_enrol_lti_lti2_context; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_lti_lti2_context IS 'Information about a specific LTI contexts from the consumers';


--
-- Name: mdl_enrol_lti_lti2_context_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_lti_lti2_context_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_lti_lti2_context_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_lti_lti2_context_id_seq OWNED BY public.mdl_enrol_lti_lti2_context.id;


--
-- Name: mdl_enrol_lti_lti2_nonce; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_lti_lti2_nonce (
    id bigint NOT NULL,
    consumerid bigint NOT NULL,
    value character varying(64) DEFAULT ''::character varying NOT NULL,
    expires bigint NOT NULL
);


--
-- Name: TABLE mdl_enrol_lti_lti2_nonce; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_lti_lti2_nonce IS 'Nonce used for authentication between moodle and a consumer';


--
-- Name: mdl_enrol_lti_lti2_nonce_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_lti_lti2_nonce_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_lti_lti2_nonce_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_lti_lti2_nonce_id_seq OWNED BY public.mdl_enrol_lti_lti2_nonce.id;


--
-- Name: mdl_enrol_lti_lti2_resource_link; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_lti_lti2_resource_link (
    id bigint NOT NULL,
    contextid bigint,
    consumerid bigint,
    ltiresourcelinkkey character varying(255) DEFAULT ''::character varying NOT NULL,
    settings text,
    primaryresourcelinkid bigint,
    shareapproved smallint,
    created bigint NOT NULL,
    updated bigint NOT NULL
);


--
-- Name: TABLE mdl_enrol_lti_lti2_resource_link; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_lti_lti2_resource_link IS 'Link from the consumer to the tool';


--
-- Name: mdl_enrol_lti_lti2_resource_link_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_lti_lti2_resource_link_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_lti_lti2_resource_link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_lti_lti2_resource_link_id_seq OWNED BY public.mdl_enrol_lti_lti2_resource_link.id;


--
-- Name: mdl_enrol_lti_lti2_share_key; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_lti_lti2_share_key (
    id bigint NOT NULL,
    sharekey character varying(32) DEFAULT ''::character varying NOT NULL,
    resourcelinkid bigint NOT NULL,
    autoapprove smallint NOT NULL,
    expires bigint NOT NULL
);


--
-- Name: TABLE mdl_enrol_lti_lti2_share_key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_lti_lti2_share_key IS 'Resource link share key';


--
-- Name: mdl_enrol_lti_lti2_share_key_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_lti_lti2_share_key_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_lti_lti2_share_key_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_lti_lti2_share_key_id_seq OWNED BY public.mdl_enrol_lti_lti2_share_key.id;


--
-- Name: mdl_enrol_lti_lti2_tool_proxy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_lti_lti2_tool_proxy (
    id bigint NOT NULL,
    toolproxykey character varying(32) DEFAULT ''::character varying NOT NULL,
    consumerid bigint NOT NULL,
    toolproxy text NOT NULL,
    created bigint NOT NULL,
    updated bigint NOT NULL
);


--
-- Name: TABLE mdl_enrol_lti_lti2_tool_proxy; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_lti_lti2_tool_proxy IS 'A tool proxy between moodle and a consumer';


--
-- Name: mdl_enrol_lti_lti2_tool_proxy_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_lti_lti2_tool_proxy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_lti_lti2_tool_proxy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_lti_lti2_tool_proxy_id_seq OWNED BY public.mdl_enrol_lti_lti2_tool_proxy.id;


--
-- Name: mdl_enrol_lti_lti2_user_result; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_lti_lti2_user_result (
    id bigint NOT NULL,
    resourcelinkid bigint NOT NULL,
    ltiuserkey character varying(255) DEFAULT ''::character varying NOT NULL,
    ltiresultsourcedid character varying(1024) DEFAULT ''::character varying NOT NULL,
    created bigint NOT NULL,
    updated bigint NOT NULL
);


--
-- Name: TABLE mdl_enrol_lti_lti2_user_result; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_lti_lti2_user_result IS 'Results for each user for each resource link';


--
-- Name: mdl_enrol_lti_lti2_user_result_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_lti_lti2_user_result_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_lti_lti2_user_result_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_lti_lti2_user_result_id_seq OWNED BY public.mdl_enrol_lti_lti2_user_result.id;


--
-- Name: mdl_enrol_lti_resource_link; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_lti_resource_link (
    id bigint NOT NULL,
    resourcelinkid character varying(255) DEFAULT ''::character varying NOT NULL,
    ltideploymentid bigint NOT NULL,
    resourceid bigint NOT NULL,
    lticontextid bigint,
    lineitemsservice character varying(1333),
    lineitemservice character varying(1333),
    lineitemscope character varying(255),
    resultscope character varying(255),
    scorescope character varying(255),
    contextmembershipsurl character varying(1333),
    nrpsserviceversions character varying(255),
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_enrol_lti_resource_link; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_lti_resource_link IS 'Each row represents a resource link for a platform and deployment';


--
-- Name: mdl_enrol_lti_resource_link_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_lti_resource_link_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_lti_resource_link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_lti_resource_link_id_seq OWNED BY public.mdl_enrol_lti_resource_link.id;


--
-- Name: mdl_enrol_lti_tool_consumer_map; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_lti_tool_consumer_map (
    id bigint NOT NULL,
    toolid bigint NOT NULL,
    consumerid bigint NOT NULL
);


--
-- Name: TABLE mdl_enrol_lti_tool_consumer_map; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_lti_tool_consumer_map IS 'Table that maps the published tool to tool consumers.';


--
-- Name: mdl_enrol_lti_tool_consumer_map_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_lti_tool_consumer_map_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_lti_tool_consumer_map_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_lti_tool_consumer_map_id_seq OWNED BY public.mdl_enrol_lti_tool_consumer_map.id;


--
-- Name: mdl_enrol_lti_tools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_lti_tools (
    id bigint NOT NULL,
    enrolid bigint NOT NULL,
    contextid bigint NOT NULL,
    ltiversion character varying(15) DEFAULT 'LTI-1p3'::character varying NOT NULL,
    institution character varying(40) DEFAULT ''::character varying NOT NULL,
    lang character varying(30) DEFAULT 'en'::character varying NOT NULL,
    timezone character varying(100) DEFAULT '99'::character varying NOT NULL,
    maxenrolled bigint DEFAULT 0 NOT NULL,
    maildisplay smallint DEFAULT 2 NOT NULL,
    city character varying(120) DEFAULT ''::character varying NOT NULL,
    country character varying(2) DEFAULT ''::character varying NOT NULL,
    gradesync smallint DEFAULT 0 NOT NULL,
    gradesynccompletion smallint DEFAULT 0 NOT NULL,
    membersync smallint DEFAULT 0 NOT NULL,
    membersyncmode smallint DEFAULT 0 NOT NULL,
    roleinstructor bigint NOT NULL,
    rolelearner bigint NOT NULL,
    secret text,
    uuid character varying(36),
    provisioningmodelearner smallint,
    provisioningmodeinstructor smallint,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_enrol_lti_tools; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_lti_tools IS 'List of tools provided to the remote system';


--
-- Name: mdl_enrol_lti_tools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_lti_tools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_lti_tools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_lti_tools_id_seq OWNED BY public.mdl_enrol_lti_tools.id;


--
-- Name: mdl_enrol_lti_user_resource_link; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_lti_user_resource_link (
    id bigint NOT NULL,
    ltiuserid bigint NOT NULL,
    resourcelinkid bigint NOT NULL
);


--
-- Name: TABLE mdl_enrol_lti_user_resource_link; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_lti_user_resource_link IS 'Join table mapping users to resource links as this is a many:many relationship';


--
-- Name: mdl_enrol_lti_user_resource_link_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_lti_user_resource_link_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_lti_user_resource_link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_lti_user_resource_link_id_seq OWNED BY public.mdl_enrol_lti_user_resource_link.id;


--
-- Name: mdl_enrol_lti_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_lti_users (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    toolid bigint NOT NULL,
    serviceurl text,
    sourceid text,
    ltideploymentid bigint,
    consumerkey text,
    consumersecret text,
    membershipsurl text,
    membershipsid text,
    lastgrade numeric(10,5),
    lastaccess bigint,
    timecreated bigint
);


--
-- Name: TABLE mdl_enrol_lti_users; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_lti_users IS 'User access log and gradeback data';


--
-- Name: mdl_enrol_lti_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_lti_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_lti_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_lti_users_id_seq OWNED BY public.mdl_enrol_lti_users.id;


--
-- Name: mdl_enrol_paypal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_enrol_paypal (
    id bigint NOT NULL,
    business character varying(255) DEFAULT ''::character varying NOT NULL,
    receiver_email character varying(255) DEFAULT ''::character varying NOT NULL,
    receiver_id character varying(255) DEFAULT ''::character varying NOT NULL,
    item_name character varying(255) DEFAULT ''::character varying NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    instanceid bigint DEFAULT 0 NOT NULL,
    memo character varying(255) DEFAULT ''::character varying NOT NULL,
    tax character varying(255) DEFAULT ''::character varying NOT NULL,
    option_name1 character varying(255) DEFAULT ''::character varying NOT NULL,
    option_selection1_x character varying(255) DEFAULT ''::character varying NOT NULL,
    option_name2 character varying(255) DEFAULT ''::character varying NOT NULL,
    option_selection2_x character varying(255) DEFAULT ''::character varying NOT NULL,
    payment_status character varying(255) DEFAULT ''::character varying NOT NULL,
    pending_reason character varying(255) DEFAULT ''::character varying NOT NULL,
    reason_code character varying(30) DEFAULT ''::character varying NOT NULL,
    txn_id character varying(255) DEFAULT ''::character varying NOT NULL,
    parent_txn_id character varying(255) DEFAULT ''::character varying NOT NULL,
    payment_type character varying(30) DEFAULT ''::character varying NOT NULL,
    timeupdated bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_enrol_paypal; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_enrol_paypal IS 'Holds all known information about PayPal transactions';


--
-- Name: mdl_enrol_paypal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_enrol_paypal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_enrol_paypal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_enrol_paypal_id_seq OWNED BY public.mdl_enrol_paypal.id;


--
-- Name: mdl_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_event (
    id bigint NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    format smallint DEFAULT 0 NOT NULL,
    categoryid bigint DEFAULT 0 NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL,
    groupid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    repeatid bigint DEFAULT 0 NOT NULL,
    component character varying(100),
    modulename character varying(20) DEFAULT ''::character varying NOT NULL,
    instance bigint DEFAULT 0 NOT NULL,
    type smallint DEFAULT 0 NOT NULL,
    eventtype character varying(20) DEFAULT ''::character varying NOT NULL,
    timestart bigint DEFAULT 0 NOT NULL,
    timeduration bigint DEFAULT 0 NOT NULL,
    timesort bigint,
    visible smallint DEFAULT 1 NOT NULL,
    uuid character varying(255) DEFAULT ''::character varying NOT NULL,
    sequence bigint DEFAULT 1 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    subscriptionid bigint,
    priority bigint,
    location text
);


--
-- Name: TABLE mdl_event; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_event IS 'For everything with a time associated to it';


--
-- Name: mdl_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_event_id_seq OWNED BY public.mdl_event.id;


--
-- Name: mdl_event_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_event_subscriptions (
    id bigint NOT NULL,
    url character varying(255) DEFAULT ''::character varying NOT NULL,
    categoryid bigint DEFAULT 0 NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL,
    groupid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    eventtype character varying(20) DEFAULT ''::character varying NOT NULL,
    pollinterval bigint DEFAULT 0 NOT NULL,
    lastupdated bigint,
    name character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_event_subscriptions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_event_subscriptions IS 'Tracks subscriptions to remote calendars.';


--
-- Name: mdl_event_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_event_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_event_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_event_subscriptions_id_seq OWNED BY public.mdl_event_subscriptions.id;


--
-- Name: mdl_events_handlers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_events_handlers (
    id bigint NOT NULL,
    eventname character varying(166) DEFAULT ''::character varying NOT NULL,
    component character varying(166) DEFAULT ''::character varying NOT NULL,
    handlerfile character varying(255) DEFAULT ''::character varying NOT NULL,
    handlerfunction text,
    schedule character varying(255),
    status bigint DEFAULT 0 NOT NULL,
    internal smallint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_events_handlers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_events_handlers IS 'This table is for storing which components requests what type of event, and the location of the responsible handlers. For example, the assignment registers ''grade_updated'' event with a function assignment_grade_handler() that should be called event t';


--
-- Name: mdl_events_handlers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_events_handlers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_events_handlers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_events_handlers_id_seq OWNED BY public.mdl_events_handlers.id;


--
-- Name: mdl_events_queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_events_queue (
    id bigint NOT NULL,
    eventdata text NOT NULL,
    stackdump text,
    userid bigint,
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_events_queue; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_events_queue IS 'This table is for storing queued events. It stores only one copy of the eventdata here, and entries from this table are being references by the event_queue_handlers table.';


--
-- Name: mdl_events_queue_handlers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_events_queue_handlers (
    id bigint NOT NULL,
    queuedeventid bigint NOT NULL,
    handlerid bigint NOT NULL,
    status bigint,
    errormessage text,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_events_queue_handlers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_events_queue_handlers IS 'This is the list of queued handlers for processing. The event object is retrieved from the events_queue table. When no further reference is made to the event_queues table, the corresponding entry in the events_queue table should be deleted. Entry sho';


--
-- Name: mdl_events_queue_handlers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_events_queue_handlers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_events_queue_handlers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_events_queue_handlers_id_seq OWNED BY public.mdl_events_queue_handlers.id;


--
-- Name: mdl_events_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_events_queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_events_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_events_queue_id_seq OWNED BY public.mdl_events_queue.id;


--
-- Name: mdl_external_functions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_external_functions (
    id bigint NOT NULL,
    name character varying(200) DEFAULT ''::character varying NOT NULL,
    classname character varying(100) DEFAULT ''::character varying NOT NULL,
    methodname character varying(100) DEFAULT ''::character varying NOT NULL,
    classpath character varying(255),
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    capabilities character varying(255),
    services character varying(1333)
);


--
-- Name: TABLE mdl_external_functions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_external_functions IS 'list of all external functions';


--
-- Name: mdl_external_functions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_external_functions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_external_functions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_external_functions_id_seq OWNED BY public.mdl_external_functions.id;


--
-- Name: mdl_external_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_external_services (
    id bigint NOT NULL,
    name character varying(200) DEFAULT ''::character varying NOT NULL,
    enabled smallint NOT NULL,
    requiredcapability character varying(150),
    restrictedusers smallint NOT NULL,
    component character varying(100),
    timecreated bigint NOT NULL,
    timemodified bigint,
    shortname character varying(255),
    downloadfiles smallint DEFAULT 0 NOT NULL,
    uploadfiles smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_external_services; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_external_services IS 'built in and custom external services';


--
-- Name: mdl_external_services_functions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_external_services_functions (
    id bigint NOT NULL,
    externalserviceid bigint NOT NULL,
    functionname character varying(200) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_external_services_functions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_external_services_functions IS 'lists functions available in each service group';


--
-- Name: mdl_external_services_functions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_external_services_functions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_external_services_functions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_external_services_functions_id_seq OWNED BY public.mdl_external_services_functions.id;


--
-- Name: mdl_external_services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_external_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_external_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_external_services_id_seq OWNED BY public.mdl_external_services.id;


--
-- Name: mdl_external_services_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_external_services_users (
    id bigint NOT NULL,
    externalserviceid bigint NOT NULL,
    userid bigint NOT NULL,
    iprestriction character varying(255),
    validuntil bigint,
    timecreated bigint
);


--
-- Name: TABLE mdl_external_services_users; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_external_services_users IS 'users allowed to use services with restricted users flag';


--
-- Name: mdl_external_services_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_external_services_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_external_services_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_external_services_users_id_seq OWNED BY public.mdl_external_services_users.id;


--
-- Name: mdl_external_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_external_tokens (
    id bigint NOT NULL,
    token character varying(128) DEFAULT ''::character varying NOT NULL,
    privatetoken character varying(64),
    tokentype smallint NOT NULL,
    userid bigint NOT NULL,
    externalserviceid bigint NOT NULL,
    sid character varying(128),
    contextid bigint NOT NULL,
    creatorid bigint DEFAULT 1 NOT NULL,
    iprestriction character varying(255),
    validuntil bigint,
    timecreated bigint NOT NULL,
    lastaccess bigint,
    name character varying(255)
);


--
-- Name: TABLE mdl_external_tokens; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_external_tokens IS 'Security tokens for accessing of external services';


--
-- Name: mdl_external_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_external_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_external_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_external_tokens_id_seq OWNED BY public.mdl_external_tokens.id;


--
-- Name: mdl_favourite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_favourite (
    id bigint NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    itemtype character varying(100) DEFAULT ''::character varying NOT NULL,
    itemid bigint NOT NULL,
    contextid bigint NOT NULL,
    userid bigint NOT NULL,
    ordering bigint,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_favourite; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_favourite IS 'Stores the relationship between an arbitrary item (itemtype, itemid), and a context area (component, contextid) for a specific user. Used by the favourites subsystem.';


--
-- Name: mdl_favourite_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_favourite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_favourite_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_favourite_id_seq OWNED BY public.mdl_favourite.id;


--
-- Name: mdl_feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_feedback (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text NOT NULL,
    introformat smallint DEFAULT 0 NOT NULL,
    anonymous smallint DEFAULT 1 NOT NULL,
    email_notification smallint DEFAULT 1 NOT NULL,
    multiple_submit smallint DEFAULT 1 NOT NULL,
    autonumbering smallint DEFAULT 1 NOT NULL,
    site_after_submit character varying(255) DEFAULT ''::character varying NOT NULL,
    page_after_submit text NOT NULL,
    page_after_submitformat smallint DEFAULT 0 NOT NULL,
    publish_stats smallint DEFAULT 0 NOT NULL,
    timeopen bigint DEFAULT 0 NOT NULL,
    timeclose bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    completionsubmit smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_feedback; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_feedback IS 'all feedbacks';


--
-- Name: mdl_feedback_completed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_feedback_completed (
    id bigint NOT NULL,
    feedback bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    random_response bigint DEFAULT 0 NOT NULL,
    anonymous_response smallint DEFAULT 0 NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_feedback_completed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_feedback_completed IS 'filled out feedback';


--
-- Name: mdl_feedback_completed_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_feedback_completed_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_feedback_completed_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_feedback_completed_id_seq OWNED BY public.mdl_feedback_completed.id;


--
-- Name: mdl_feedback_completedtmp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_feedback_completedtmp (
    id bigint NOT NULL,
    feedback bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    guestid character varying(255) DEFAULT ''::character varying NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    random_response bigint DEFAULT 0 NOT NULL,
    anonymous_response smallint DEFAULT 0 NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_feedback_completedtmp; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_feedback_completedtmp IS 'filled out feedback';


--
-- Name: mdl_feedback_completedtmp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_feedback_completedtmp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_feedback_completedtmp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_feedback_completedtmp_id_seq OWNED BY public.mdl_feedback_completedtmp.id;


--
-- Name: mdl_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_feedback_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_feedback_id_seq OWNED BY public.mdl_feedback.id;


--
-- Name: mdl_feedback_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_feedback_item (
    id bigint NOT NULL,
    feedback bigint DEFAULT 0 NOT NULL,
    template bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    label character varying(255) DEFAULT ''::character varying NOT NULL,
    presentation text NOT NULL,
    typ character varying(255) DEFAULT ''::character varying NOT NULL,
    hasvalue smallint DEFAULT 0 NOT NULL,
    "position" smallint DEFAULT 0 NOT NULL,
    required smallint DEFAULT 0 NOT NULL,
    dependitem bigint DEFAULT 0 NOT NULL,
    dependvalue character varying(255) DEFAULT ''::character varying NOT NULL,
    options character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_feedback_item; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_feedback_item IS 'feedback_items';


--
-- Name: mdl_feedback_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_feedback_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_feedback_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_feedback_item_id_seq OWNED BY public.mdl_feedback_item.id;


--
-- Name: mdl_feedback_sitecourse_map; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_feedback_sitecourse_map (
    id bigint NOT NULL,
    feedbackid bigint DEFAULT 0 NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_feedback_sitecourse_map; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_feedback_sitecourse_map IS 'feedback sitecourse map';


--
-- Name: mdl_feedback_sitecourse_map_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_feedback_sitecourse_map_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_feedback_sitecourse_map_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_feedback_sitecourse_map_id_seq OWNED BY public.mdl_feedback_sitecourse_map.id;


--
-- Name: mdl_feedback_template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_feedback_template (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    ispublic smallint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_feedback_template; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_feedback_template IS 'templates of feedbackstructures';


--
-- Name: mdl_feedback_template_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_feedback_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_feedback_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_feedback_template_id_seq OWNED BY public.mdl_feedback_template.id;


--
-- Name: mdl_feedback_value; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_feedback_value (
    id bigint NOT NULL,
    course_id bigint DEFAULT 0 NOT NULL,
    item bigint DEFAULT 0 NOT NULL,
    completed bigint DEFAULT 0 NOT NULL,
    tmp_completed bigint DEFAULT 0 NOT NULL,
    value text NOT NULL
);


--
-- Name: TABLE mdl_feedback_value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_feedback_value IS 'values of the completeds';


--
-- Name: mdl_feedback_value_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_feedback_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_feedback_value_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_feedback_value_id_seq OWNED BY public.mdl_feedback_value.id;


--
-- Name: mdl_feedback_valuetmp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_feedback_valuetmp (
    id bigint NOT NULL,
    course_id bigint DEFAULT 0 NOT NULL,
    item bigint DEFAULT 0 NOT NULL,
    completed bigint DEFAULT 0 NOT NULL,
    tmp_completed bigint DEFAULT 0 NOT NULL,
    value text NOT NULL
);


--
-- Name: TABLE mdl_feedback_valuetmp; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_feedback_valuetmp IS 'values of the completedstmp';


--
-- Name: mdl_feedback_valuetmp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_feedback_valuetmp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_feedback_valuetmp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_feedback_valuetmp_id_seq OWNED BY public.mdl_feedback_valuetmp.id;


--
-- Name: mdl_file_conversion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_file_conversion (
    id bigint NOT NULL,
    usermodified bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    sourcefileid bigint NOT NULL,
    targetformat character varying(100) DEFAULT ''::character varying NOT NULL,
    status bigint DEFAULT 0,
    statusmessage text,
    converter character varying(255),
    destfileid bigint,
    data text
);


--
-- Name: TABLE mdl_file_conversion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_file_conversion IS 'Table to track file conversions.';


--
-- Name: mdl_file_conversion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_file_conversion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_file_conversion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_file_conversion_id_seq OWNED BY public.mdl_file_conversion.id;


--
-- Name: mdl_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_files (
    id bigint NOT NULL,
    contenthash character varying(40) DEFAULT ''::character varying NOT NULL,
    pathnamehash character varying(40) DEFAULT ''::character varying NOT NULL,
    contextid bigint NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    filearea character varying(50) DEFAULT ''::character varying NOT NULL,
    itemid bigint NOT NULL,
    filepath character varying(255) DEFAULT ''::character varying NOT NULL,
    filename character varying(255) DEFAULT ''::character varying NOT NULL,
    userid bigint,
    filesize bigint NOT NULL,
    mimetype character varying(100),
    status bigint DEFAULT 0 NOT NULL,
    source text,
    author character varying(255),
    license character varying(255),
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    sortorder bigint DEFAULT 0 NOT NULL,
    referencefileid bigint
);


--
-- Name: TABLE mdl_files; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_files IS 'description of files, content is stored in sha1 file pool';


--
-- Name: mdl_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_files_id_seq OWNED BY public.mdl_files.id;


--
-- Name: mdl_files_reference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_files_reference (
    id bigint NOT NULL,
    repositoryid bigint NOT NULL,
    lastsync bigint,
    reference text,
    referencehash character varying(40) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_files_reference; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_files_reference IS 'Store files references';


--
-- Name: mdl_files_reference_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_files_reference_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_files_reference_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_files_reference_id_seq OWNED BY public.mdl_files_reference.id;


--
-- Name: mdl_filter_active; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_filter_active (
    id bigint NOT NULL,
    filter character varying(32) DEFAULT ''::character varying NOT NULL,
    contextid bigint NOT NULL,
    active smallint NOT NULL,
    sortorder bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_filter_active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_filter_active IS 'Stores information about which filters are active in which contexts. Also the filter sort order. See get_active_filters in lib/filterlib.php for how this data is used.';


--
-- Name: mdl_filter_active_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_filter_active_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_filter_active_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_filter_active_id_seq OWNED BY public.mdl_filter_active.id;


--
-- Name: mdl_filter_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_filter_config (
    id bigint NOT NULL,
    filter character varying(32) DEFAULT ''::character varying NOT NULL,
    contextid bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    value text
);


--
-- Name: TABLE mdl_filter_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_filter_config IS 'Stores per-context configuration settings for filters which have them.';


--
-- Name: mdl_filter_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_filter_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_filter_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_filter_config_id_seq OWNED BY public.mdl_filter_config.id;


--
-- Name: mdl_folder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_folder (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text,
    introformat smallint DEFAULT 0 NOT NULL,
    revision bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    display smallint DEFAULT 0 NOT NULL,
    showexpanded smallint DEFAULT 1 NOT NULL,
    showdownloadfolder smallint DEFAULT 1 NOT NULL,
    forcedownload smallint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_folder; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_folder IS 'each record is one folder resource';


--
-- Name: mdl_folder_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_folder_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_folder_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_folder_id_seq OWNED BY public.mdl_folder.id;


--
-- Name: mdl_forum; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_forum (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    type character varying(20) DEFAULT 'general'::character varying NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text NOT NULL,
    introformat smallint DEFAULT 0 NOT NULL,
    duedate bigint DEFAULT 0 NOT NULL,
    cutoffdate bigint DEFAULT 0 NOT NULL,
    assessed bigint DEFAULT 0 NOT NULL,
    assesstimestart bigint DEFAULT 0 NOT NULL,
    assesstimefinish bigint DEFAULT 0 NOT NULL,
    scale bigint DEFAULT 0 NOT NULL,
    grade_forum bigint DEFAULT 0 NOT NULL,
    grade_forum_notify smallint DEFAULT 0 NOT NULL,
    maxbytes bigint DEFAULT 0 NOT NULL,
    maxattachments bigint DEFAULT 1 NOT NULL,
    forcesubscribe smallint DEFAULT 0 NOT NULL,
    trackingtype smallint DEFAULT 1 NOT NULL,
    rsstype smallint DEFAULT 0 NOT NULL,
    rssarticles smallint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    warnafter bigint DEFAULT 0 NOT NULL,
    blockafter bigint DEFAULT 0 NOT NULL,
    blockperiod bigint DEFAULT 0 NOT NULL,
    completiondiscussions integer DEFAULT 0 NOT NULL,
    completionreplies integer DEFAULT 0 NOT NULL,
    completionposts integer DEFAULT 0 NOT NULL,
    displaywordcount smallint DEFAULT 0 NOT NULL,
    lockdiscussionafter bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_forum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_forum IS 'Forums contain and structure discussion';


--
-- Name: mdl_forum_digests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_forum_digests (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    forum bigint NOT NULL,
    maildigest smallint DEFAULT '-1'::integer NOT NULL
);


--
-- Name: TABLE mdl_forum_digests; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_forum_digests IS 'Keeps track of user mail delivery preferences for each forum';


--
-- Name: mdl_forum_digests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_forum_digests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_forum_digests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_forum_digests_id_seq OWNED BY public.mdl_forum_digests.id;


--
-- Name: mdl_forum_discussion_subs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_forum_discussion_subs (
    id bigint NOT NULL,
    forum bigint NOT NULL,
    userid bigint NOT NULL,
    discussion bigint NOT NULL,
    preference bigint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_forum_discussion_subs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_forum_discussion_subs IS 'Users may choose to subscribe and unsubscribe from specific discussions.';


--
-- Name: mdl_forum_discussion_subs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_forum_discussion_subs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_forum_discussion_subs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_forum_discussion_subs_id_seq OWNED BY public.mdl_forum_discussion_subs.id;


--
-- Name: mdl_forum_discussions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_forum_discussions (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    forum bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    firstpost bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    groupid bigint DEFAULT '-1'::integer NOT NULL,
    assessed smallint DEFAULT 1 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    usermodified bigint DEFAULT 0 NOT NULL,
    timestart bigint DEFAULT 0 NOT NULL,
    timeend bigint DEFAULT 0 NOT NULL,
    pinned smallint DEFAULT 0 NOT NULL,
    timelocked bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_forum_discussions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_forum_discussions IS 'Forums are composed of discussions';


--
-- Name: mdl_forum_discussions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_forum_discussions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_forum_discussions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_forum_discussions_id_seq OWNED BY public.mdl_forum_discussions.id;


--
-- Name: mdl_forum_grades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_forum_grades (
    id bigint NOT NULL,
    forum bigint NOT NULL,
    itemnumber bigint NOT NULL,
    userid bigint NOT NULL,
    grade numeric(10,5),
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_forum_grades; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_forum_grades IS 'Grading data for forum instances';


--
-- Name: mdl_forum_grades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_forum_grades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_forum_grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_forum_grades_id_seq OWNED BY public.mdl_forum_grades.id;


--
-- Name: mdl_forum_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_forum_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_forum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_forum_id_seq OWNED BY public.mdl_forum.id;


--
-- Name: mdl_forum_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_forum_posts (
    id bigint NOT NULL,
    discussion bigint DEFAULT 0 NOT NULL,
    parent bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    created bigint DEFAULT 0 NOT NULL,
    modified bigint DEFAULT 0 NOT NULL,
    mailed smallint DEFAULT 0 NOT NULL,
    subject character varying(255) DEFAULT ''::character varying NOT NULL,
    message text NOT NULL,
    messageformat smallint DEFAULT 0 NOT NULL,
    messagetrust smallint DEFAULT 0 NOT NULL,
    attachment character varying(100) DEFAULT ''::character varying NOT NULL,
    totalscore smallint DEFAULT 0 NOT NULL,
    mailnow bigint DEFAULT 0 NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    privatereplyto bigint DEFAULT 0 NOT NULL,
    wordcount bigint,
    charcount bigint
);


--
-- Name: TABLE mdl_forum_posts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_forum_posts IS 'All posts are stored in this table';


--
-- Name: mdl_forum_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_forum_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_forum_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_forum_posts_id_seq OWNED BY public.mdl_forum_posts.id;


--
-- Name: mdl_forum_queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_forum_queue (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    discussionid bigint DEFAULT 0 NOT NULL,
    postid bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_forum_queue; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_forum_queue IS 'For keeping track of posts that will be mailed in digest form';


--
-- Name: mdl_forum_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_forum_queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_forum_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_forum_queue_id_seq OWNED BY public.mdl_forum_queue.id;


--
-- Name: mdl_forum_read; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_forum_read (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    forumid bigint DEFAULT 0 NOT NULL,
    discussionid bigint DEFAULT 0 NOT NULL,
    postid bigint DEFAULT 0 NOT NULL,
    firstread bigint DEFAULT 0 NOT NULL,
    lastread bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_forum_read; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_forum_read IS 'Tracks each users read posts';


--
-- Name: mdl_forum_read_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_forum_read_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_forum_read_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_forum_read_id_seq OWNED BY public.mdl_forum_read.id;


--
-- Name: mdl_forum_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_forum_subscriptions (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    forum bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_forum_subscriptions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_forum_subscriptions IS 'Keeps track of who is subscribed to what forum';


--
-- Name: mdl_forum_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_forum_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_forum_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_forum_subscriptions_id_seq OWNED BY public.mdl_forum_subscriptions.id;


--
-- Name: mdl_forum_track_prefs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_forum_track_prefs (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    forumid bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_forum_track_prefs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_forum_track_prefs IS 'Tracks each users untracked forums';


--
-- Name: mdl_forum_track_prefs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_forum_track_prefs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_forum_track_prefs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_forum_track_prefs_id_seq OWNED BY public.mdl_forum_track_prefs.id;


--
-- Name: mdl_glossary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_glossary (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text NOT NULL,
    introformat smallint DEFAULT 0 NOT NULL,
    allowduplicatedentries smallint DEFAULT 0 NOT NULL,
    displayformat character varying(50) DEFAULT 'dictionary'::character varying NOT NULL,
    mainglossary smallint DEFAULT 0 NOT NULL,
    showspecial smallint DEFAULT 1 NOT NULL,
    showalphabet smallint DEFAULT 1 NOT NULL,
    showall smallint DEFAULT 1 NOT NULL,
    allowcomments smallint DEFAULT 0 NOT NULL,
    allowprintview smallint DEFAULT 1 NOT NULL,
    usedynalink smallint DEFAULT 1 NOT NULL,
    defaultapproval smallint DEFAULT 1 NOT NULL,
    approvaldisplayformat character varying(50) DEFAULT 'default'::character varying NOT NULL,
    globalglossary smallint DEFAULT 0 NOT NULL,
    entbypage smallint DEFAULT 10 NOT NULL,
    editalways smallint DEFAULT 0 NOT NULL,
    rsstype smallint DEFAULT 0 NOT NULL,
    rssarticles smallint DEFAULT 0 NOT NULL,
    assessed bigint DEFAULT 0 NOT NULL,
    assesstimestart bigint DEFAULT 0 NOT NULL,
    assesstimefinish bigint DEFAULT 0 NOT NULL,
    scale bigint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    completionentries integer DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_glossary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_glossary IS 'all glossaries';


--
-- Name: mdl_glossary_alias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_glossary_alias (
    id bigint NOT NULL,
    entryid bigint DEFAULT 0 NOT NULL,
    alias character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_glossary_alias; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_glossary_alias IS 'entries alias';


--
-- Name: mdl_glossary_alias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_glossary_alias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_glossary_alias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_glossary_alias_id_seq OWNED BY public.mdl_glossary_alias.id;


--
-- Name: mdl_glossary_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_glossary_categories (
    id bigint NOT NULL,
    glossaryid bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    usedynalink smallint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_glossary_categories; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_glossary_categories IS 'all categories for glossary entries';


--
-- Name: mdl_glossary_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_glossary_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_glossary_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_glossary_categories_id_seq OWNED BY public.mdl_glossary_categories.id;


--
-- Name: mdl_glossary_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_glossary_entries (
    id bigint NOT NULL,
    glossaryid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    concept character varying(255) DEFAULT ''::character varying NOT NULL,
    definition text NOT NULL,
    definitionformat smallint DEFAULT 0 NOT NULL,
    definitiontrust smallint DEFAULT 0 NOT NULL,
    attachment character varying(100) DEFAULT ''::character varying NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    teacherentry smallint DEFAULT 0 NOT NULL,
    sourceglossaryid bigint DEFAULT 0 NOT NULL,
    usedynalink smallint DEFAULT 1 NOT NULL,
    casesensitive smallint DEFAULT 0 NOT NULL,
    fullmatch smallint DEFAULT 1 NOT NULL,
    approved smallint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_glossary_entries; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_glossary_entries IS 'all glossary entries';


--
-- Name: mdl_glossary_entries_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_glossary_entries_categories (
    id bigint NOT NULL,
    categoryid bigint DEFAULT 0 NOT NULL,
    entryid bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_glossary_entries_categories; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_glossary_entries_categories IS 'categories of each glossary entry';


--
-- Name: mdl_glossary_entries_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_glossary_entries_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_glossary_entries_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_glossary_entries_categories_id_seq OWNED BY public.mdl_glossary_entries_categories.id;


--
-- Name: mdl_glossary_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_glossary_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_glossary_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_glossary_entries_id_seq OWNED BY public.mdl_glossary_entries.id;


--
-- Name: mdl_glossary_formats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_glossary_formats (
    id bigint NOT NULL,
    name character varying(50) DEFAULT ''::character varying NOT NULL,
    popupformatname character varying(50) DEFAULT ''::character varying NOT NULL,
    visible smallint DEFAULT 1 NOT NULL,
    showgroup smallint DEFAULT 1 NOT NULL,
    showtabs character varying(100),
    defaultmode character varying(50) DEFAULT ''::character varying NOT NULL,
    defaulthook character varying(50) DEFAULT ''::character varying NOT NULL,
    sortkey character varying(50) DEFAULT ''::character varying NOT NULL,
    sortorder character varying(50) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_glossary_formats; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_glossary_formats IS 'Setting of the display formats';


--
-- Name: mdl_glossary_formats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_glossary_formats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_glossary_formats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_glossary_formats_id_seq OWNED BY public.mdl_glossary_formats.id;


--
-- Name: mdl_glossary_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_glossary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_glossary_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_glossary_id_seq OWNED BY public.mdl_glossary.id;


--
-- Name: mdl_grade_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_grade_categories (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    parent bigint,
    depth bigint DEFAULT 0 NOT NULL,
    path character varying(255),
    fullname character varying(255) DEFAULT ''::character varying NOT NULL,
    aggregation bigint DEFAULT 0 NOT NULL,
    keephigh bigint DEFAULT 0 NOT NULL,
    droplow bigint DEFAULT 0 NOT NULL,
    aggregateonlygraded smallint DEFAULT 0 NOT NULL,
    aggregateoutcomes smallint DEFAULT 0 NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    hidden bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_grade_categories; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_grade_categories IS 'This table keeps information about categories, used for grouping items.';


--
-- Name: mdl_grade_categories_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_grade_categories_history (
    id bigint NOT NULL,
    action bigint DEFAULT 0 NOT NULL,
    oldid bigint NOT NULL,
    source character varying(255),
    timemodified bigint,
    loggeduser bigint,
    courseid bigint NOT NULL,
    parent bigint,
    depth bigint DEFAULT 0 NOT NULL,
    path character varying(255),
    fullname character varying(255) DEFAULT ''::character varying NOT NULL,
    aggregation bigint DEFAULT 0 NOT NULL,
    keephigh bigint DEFAULT 0 NOT NULL,
    droplow bigint DEFAULT 0 NOT NULL,
    aggregateonlygraded smallint DEFAULT 0 NOT NULL,
    aggregateoutcomes smallint DEFAULT 0 NOT NULL,
    aggregatesubcats smallint DEFAULT 0 NOT NULL,
    hidden bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_grade_categories_history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_grade_categories_history IS 'History of grade_categories';


--
-- Name: mdl_grade_categories_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_grade_categories_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_grade_categories_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_grade_categories_history_id_seq OWNED BY public.mdl_grade_categories_history.id;


--
-- Name: mdl_grade_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_grade_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_grade_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_grade_categories_id_seq OWNED BY public.mdl_grade_categories.id;


--
-- Name: mdl_grade_grades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_grade_grades (
    id bigint NOT NULL,
    itemid bigint NOT NULL,
    userid bigint NOT NULL,
    rawgrade numeric(10,5),
    rawgrademax numeric(10,5) DEFAULT 100 NOT NULL,
    rawgrademin numeric(10,5) DEFAULT 0 NOT NULL,
    rawscaleid bigint,
    usermodified bigint,
    finalgrade numeric(10,5),
    hidden bigint DEFAULT 0 NOT NULL,
    locked bigint DEFAULT 0 NOT NULL,
    locktime bigint DEFAULT 0 NOT NULL,
    exported bigint DEFAULT 0 NOT NULL,
    overridden bigint DEFAULT 0 NOT NULL,
    excluded bigint DEFAULT 0 NOT NULL,
    feedback text,
    feedbackformat bigint DEFAULT 0 NOT NULL,
    information text,
    informationformat bigint DEFAULT 0 NOT NULL,
    timecreated bigint,
    timemodified bigint,
    aggregationstatus character varying(10) DEFAULT 'unknown'::character varying NOT NULL,
    aggregationweight numeric(10,5)
);


--
-- Name: TABLE mdl_grade_grades; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_grade_grades IS 'grade_grades  This table keeps individual grades for each user and each item, exactly as imported or submitted by modules. The rawgrademax/min and rawscaleid are stored here to record the values at the time the grade was stored, because teachers migh';


--
-- Name: mdl_grade_grades_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_grade_grades_history (
    id bigint NOT NULL,
    action bigint DEFAULT 0 NOT NULL,
    oldid bigint NOT NULL,
    source character varying(255),
    timemodified bigint,
    loggeduser bigint,
    itemid bigint NOT NULL,
    userid bigint NOT NULL,
    rawgrade numeric(10,5),
    rawgrademax numeric(10,5) DEFAULT 100 NOT NULL,
    rawgrademin numeric(10,5) DEFAULT 0 NOT NULL,
    rawscaleid bigint,
    usermodified bigint,
    finalgrade numeric(10,5),
    hidden bigint DEFAULT 0 NOT NULL,
    locked bigint DEFAULT 0 NOT NULL,
    locktime bigint DEFAULT 0 NOT NULL,
    exported bigint DEFAULT 0 NOT NULL,
    overridden bigint DEFAULT 0 NOT NULL,
    excluded bigint DEFAULT 0 NOT NULL,
    feedback text,
    feedbackformat bigint DEFAULT 0 NOT NULL,
    information text,
    informationformat bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_grade_grades_history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_grade_grades_history IS 'History table';


--
-- Name: mdl_grade_grades_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_grade_grades_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_grade_grades_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_grade_grades_history_id_seq OWNED BY public.mdl_grade_grades_history.id;


--
-- Name: mdl_grade_grades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_grade_grades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_grade_grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_grade_grades_id_seq OWNED BY public.mdl_grade_grades.id;


--
-- Name: mdl_grade_import_newitem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_grade_import_newitem (
    id bigint NOT NULL,
    itemname character varying(255) DEFAULT ''::character varying NOT NULL,
    importcode bigint NOT NULL,
    importer bigint NOT NULL
);


--
-- Name: TABLE mdl_grade_import_newitem; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_grade_import_newitem IS 'temporary table for storing new grade_item names from grade import';


--
-- Name: mdl_grade_import_newitem_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_grade_import_newitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_grade_import_newitem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_grade_import_newitem_id_seq OWNED BY public.mdl_grade_import_newitem.id;


--
-- Name: mdl_grade_import_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_grade_import_values (
    id bigint NOT NULL,
    itemid bigint,
    newgradeitem bigint,
    userid bigint NOT NULL,
    finalgrade numeric(10,5),
    feedback text,
    importcode bigint NOT NULL,
    importer bigint,
    importonlyfeedback smallint DEFAULT 0
);


--
-- Name: TABLE mdl_grade_import_values; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_grade_import_values IS 'Temporary table for importing grades';


--
-- Name: mdl_grade_import_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_grade_import_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_grade_import_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_grade_import_values_id_seq OWNED BY public.mdl_grade_import_values.id;


--
-- Name: mdl_grade_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_grade_items (
    id bigint NOT NULL,
    courseid bigint,
    categoryid bigint,
    itemname character varying(255),
    itemtype character varying(30) DEFAULT ''::character varying NOT NULL,
    itemmodule character varying(30),
    iteminstance bigint,
    itemnumber bigint,
    iteminfo text,
    idnumber character varying(255),
    calculation text,
    gradetype smallint DEFAULT 1 NOT NULL,
    grademax numeric(10,5) DEFAULT 100 NOT NULL,
    grademin numeric(10,5) DEFAULT 0 NOT NULL,
    scaleid bigint,
    outcomeid bigint,
    gradepass numeric(10,5) DEFAULT 0 NOT NULL,
    multfactor numeric(10,5) DEFAULT 1.0 NOT NULL,
    plusfactor numeric(10,5) DEFAULT 0 NOT NULL,
    aggregationcoef numeric(10,5) DEFAULT 0 NOT NULL,
    aggregationcoef2 numeric(10,5) DEFAULT 0 NOT NULL,
    sortorder bigint DEFAULT 0 NOT NULL,
    display bigint DEFAULT 0 NOT NULL,
    decimals smallint,
    hidden bigint DEFAULT 0 NOT NULL,
    locked bigint DEFAULT 0 NOT NULL,
    locktime bigint DEFAULT 0 NOT NULL,
    needsupdate bigint DEFAULT 0 NOT NULL,
    weightoverride smallint DEFAULT 0 NOT NULL,
    timecreated bigint,
    timemodified bigint
);


--
-- Name: TABLE mdl_grade_items; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_grade_items IS 'This table keeps information about gradeable items (ie columns). If an activity (eg an assignment or quiz) has multiple grade_items associated with it (eg several outcomes or numerical grades), then there will be a corresponding multiple number of ro';


--
-- Name: mdl_grade_items_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_grade_items_history (
    id bigint NOT NULL,
    action bigint DEFAULT 0 NOT NULL,
    oldid bigint NOT NULL,
    source character varying(255),
    timemodified bigint,
    loggeduser bigint,
    courseid bigint,
    categoryid bigint,
    itemname character varying(255),
    itemtype character varying(30) DEFAULT ''::character varying NOT NULL,
    itemmodule character varying(30),
    iteminstance bigint,
    itemnumber bigint,
    iteminfo text,
    idnumber character varying(255),
    calculation text,
    gradetype smallint DEFAULT 1 NOT NULL,
    grademax numeric(10,5) DEFAULT 100 NOT NULL,
    grademin numeric(10,5) DEFAULT 0 NOT NULL,
    scaleid bigint,
    outcomeid bigint,
    gradepass numeric(10,5) DEFAULT 0 NOT NULL,
    multfactor numeric(10,5) DEFAULT 1.0 NOT NULL,
    plusfactor numeric(10,5) DEFAULT 0 NOT NULL,
    aggregationcoef numeric(10,5) DEFAULT 0 NOT NULL,
    aggregationcoef2 numeric(10,5) DEFAULT 0 NOT NULL,
    sortorder bigint DEFAULT 0 NOT NULL,
    hidden bigint DEFAULT 0 NOT NULL,
    locked bigint DEFAULT 0 NOT NULL,
    locktime bigint DEFAULT 0 NOT NULL,
    needsupdate bigint DEFAULT 0 NOT NULL,
    display bigint DEFAULT 0 NOT NULL,
    decimals smallint,
    weightoverride smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_grade_items_history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_grade_items_history IS 'History of grade_items';


--
-- Name: mdl_grade_items_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_grade_items_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_grade_items_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_grade_items_history_id_seq OWNED BY public.mdl_grade_items_history.id;


--
-- Name: mdl_grade_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_grade_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_grade_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_grade_items_id_seq OWNED BY public.mdl_grade_items.id;


--
-- Name: mdl_grade_letters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_grade_letters (
    id bigint NOT NULL,
    contextid bigint NOT NULL,
    lowerboundary numeric(10,5) NOT NULL,
    letter character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_grade_letters; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_grade_letters IS 'Repository for grade letters, for courses and other moodle entities that use grades.';


--
-- Name: mdl_grade_letters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_grade_letters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_grade_letters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_grade_letters_id_seq OWNED BY public.mdl_grade_letters.id;


--
-- Name: mdl_grade_outcomes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_grade_outcomes (
    id bigint NOT NULL,
    courseid bigint,
    shortname character varying(255) DEFAULT ''::character varying NOT NULL,
    fullname text NOT NULL,
    scaleid bigint,
    description text,
    descriptionformat smallint DEFAULT 0 NOT NULL,
    timecreated bigint,
    timemodified bigint,
    usermodified bigint
);


--
-- Name: TABLE mdl_grade_outcomes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_grade_outcomes IS 'This table describes the outcomes used in the system. An outcome is a statement tied to a rubric scale from low to high, such as âNot met, Borderline, Metâ (stored as 0,1 or 2)';


--
-- Name: mdl_grade_outcomes_courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_grade_outcomes_courses (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    outcomeid bigint NOT NULL
);


--
-- Name: TABLE mdl_grade_outcomes_courses; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_grade_outcomes_courses IS 'stores what outcomes are used in what courses.';


--
-- Name: mdl_grade_outcomes_courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_grade_outcomes_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_grade_outcomes_courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_grade_outcomes_courses_id_seq OWNED BY public.mdl_grade_outcomes_courses.id;


--
-- Name: mdl_grade_outcomes_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_grade_outcomes_history (
    id bigint NOT NULL,
    action bigint DEFAULT 0 NOT NULL,
    oldid bigint NOT NULL,
    source character varying(255),
    timemodified bigint,
    loggeduser bigint,
    courseid bigint,
    shortname character varying(255) DEFAULT ''::character varying NOT NULL,
    fullname text NOT NULL,
    scaleid bigint,
    description text,
    descriptionformat smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_grade_outcomes_history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_grade_outcomes_history IS 'History table';


--
-- Name: mdl_grade_outcomes_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_grade_outcomes_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_grade_outcomes_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_grade_outcomes_history_id_seq OWNED BY public.mdl_grade_outcomes_history.id;


--
-- Name: mdl_grade_outcomes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_grade_outcomes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_grade_outcomes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_grade_outcomes_id_seq OWNED BY public.mdl_grade_outcomes.id;


--
-- Name: mdl_grade_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_grade_settings (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    value text
);


--
-- Name: TABLE mdl_grade_settings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_grade_settings IS 'gradebook settings';


--
-- Name: mdl_grade_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_grade_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_grade_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_grade_settings_id_seq OWNED BY public.mdl_grade_settings.id;


--
-- Name: mdl_grading_areas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_grading_areas (
    id bigint NOT NULL,
    contextid bigint NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    areaname character varying(100) DEFAULT ''::character varying NOT NULL,
    activemethod character varying(100)
);


--
-- Name: TABLE mdl_grading_areas; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_grading_areas IS 'Identifies gradable areas where advanced grading can happen. For each area, the current active plugin can be set.';


--
-- Name: mdl_grading_areas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_grading_areas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_grading_areas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_grading_areas_id_seq OWNED BY public.mdl_grading_areas.id;


--
-- Name: mdl_grading_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_grading_definitions (
    id bigint NOT NULL,
    areaid bigint NOT NULL,
    method character varying(100) DEFAULT ''::character varying NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    description text,
    descriptionformat smallint,
    status bigint DEFAULT 0 NOT NULL,
    copiedfromid bigint,
    timecreated bigint NOT NULL,
    usercreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint NOT NULL,
    timecopied bigint DEFAULT 0,
    options text
);


--
-- Name: TABLE mdl_grading_definitions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_grading_definitions IS 'Contains the basic information about an advanced grading form defined in the given gradable area';


--
-- Name: mdl_grading_definitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_grading_definitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_grading_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_grading_definitions_id_seq OWNED BY public.mdl_grading_definitions.id;


--
-- Name: mdl_grading_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_grading_instances (
    id bigint NOT NULL,
    definitionid bigint NOT NULL,
    raterid bigint NOT NULL,
    itemid bigint,
    rawgrade numeric(10,5),
    status bigint DEFAULT 0 NOT NULL,
    feedback text,
    feedbackformat smallint,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_grading_instances; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_grading_instances IS 'Grading form instance is an assessment record for one gradable item assessed by one rater';


--
-- Name: mdl_grading_instances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_grading_instances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_grading_instances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_grading_instances_id_seq OWNED BY public.mdl_grading_instances.id;


--
-- Name: mdl_gradingform_guide_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_gradingform_guide_comments (
    id bigint NOT NULL,
    definitionid bigint NOT NULL,
    sortorder bigint NOT NULL,
    description text,
    descriptionformat smallint
);


--
-- Name: TABLE mdl_gradingform_guide_comments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_gradingform_guide_comments IS 'frequently used comments used in marking guide';


--
-- Name: mdl_gradingform_guide_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_gradingform_guide_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_gradingform_guide_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_gradingform_guide_comments_id_seq OWNED BY public.mdl_gradingform_guide_comments.id;


--
-- Name: mdl_gradingform_guide_criteria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_gradingform_guide_criteria (
    id bigint NOT NULL,
    definitionid bigint NOT NULL,
    sortorder bigint NOT NULL,
    shortname character varying(255) DEFAULT ''::character varying NOT NULL,
    description text,
    descriptionformat smallint,
    descriptionmarkers text,
    descriptionmarkersformat smallint,
    maxscore numeric(10,5) NOT NULL
);


--
-- Name: TABLE mdl_gradingform_guide_criteria; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_gradingform_guide_criteria IS 'Stores the rows of the criteria grid.';


--
-- Name: mdl_gradingform_guide_criteria_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_gradingform_guide_criteria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_gradingform_guide_criteria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_gradingform_guide_criteria_id_seq OWNED BY public.mdl_gradingform_guide_criteria.id;


--
-- Name: mdl_gradingform_guide_fillings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_gradingform_guide_fillings (
    id bigint NOT NULL,
    instanceid bigint NOT NULL,
    criterionid bigint NOT NULL,
    remark text,
    remarkformat smallint,
    score numeric(10,5) NOT NULL
);


--
-- Name: TABLE mdl_gradingform_guide_fillings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_gradingform_guide_fillings IS 'Stores the data of how the guide is filled by a particular rater';


--
-- Name: mdl_gradingform_guide_fillings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_gradingform_guide_fillings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_gradingform_guide_fillings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_gradingform_guide_fillings_id_seq OWNED BY public.mdl_gradingform_guide_fillings.id;


--
-- Name: mdl_gradingform_rubric_criteria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_gradingform_rubric_criteria (
    id bigint NOT NULL,
    definitionid bigint NOT NULL,
    sortorder bigint NOT NULL,
    description text,
    descriptionformat smallint
);


--
-- Name: TABLE mdl_gradingform_rubric_criteria; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_gradingform_rubric_criteria IS 'Stores the rows of the rubric grid.';


--
-- Name: mdl_gradingform_rubric_criteria_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_gradingform_rubric_criteria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_gradingform_rubric_criteria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_gradingform_rubric_criteria_id_seq OWNED BY public.mdl_gradingform_rubric_criteria.id;


--
-- Name: mdl_gradingform_rubric_fillings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_gradingform_rubric_fillings (
    id bigint NOT NULL,
    instanceid bigint NOT NULL,
    criterionid bigint NOT NULL,
    levelid bigint,
    remark text,
    remarkformat smallint
);


--
-- Name: TABLE mdl_gradingform_rubric_fillings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_gradingform_rubric_fillings IS 'Stores the data of how the rubric is filled by a particular rater';


--
-- Name: mdl_gradingform_rubric_fillings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_gradingform_rubric_fillings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_gradingform_rubric_fillings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_gradingform_rubric_fillings_id_seq OWNED BY public.mdl_gradingform_rubric_fillings.id;


--
-- Name: mdl_gradingform_rubric_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_gradingform_rubric_levels (
    id bigint NOT NULL,
    criterionid bigint NOT NULL,
    score numeric(10,5) NOT NULL,
    definition text,
    definitionformat bigint
);


--
-- Name: TABLE mdl_gradingform_rubric_levels; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_gradingform_rubric_levels IS 'Stores the columns of the rubric grid.';


--
-- Name: mdl_gradingform_rubric_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_gradingform_rubric_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_gradingform_rubric_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_gradingform_rubric_levels_id_seq OWNED BY public.mdl_gradingform_rubric_levels.id;


--
-- Name: mdl_groupings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_groupings (
    id bigint NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    idnumber character varying(100) DEFAULT ''::character varying NOT NULL,
    description text,
    descriptionformat smallint DEFAULT 0 NOT NULL,
    configdata text,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_groupings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_groupings IS 'A grouping is a collection of groups. WAS: groups_groupings';


--
-- Name: mdl_groupings_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_groupings_groups (
    id bigint NOT NULL,
    groupingid bigint DEFAULT 0 NOT NULL,
    groupid bigint DEFAULT 0 NOT NULL,
    timeadded bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_groupings_groups; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_groupings_groups IS 'Link a grouping to a group (note, groups can be in multiple groupings ONLY in a course). WAS: groups_groupings_groups';


--
-- Name: mdl_groupings_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_groupings_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_groupings_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_groupings_groups_id_seq OWNED BY public.mdl_groupings_groups.id;


--
-- Name: mdl_groupings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_groupings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_groupings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_groupings_id_seq OWNED BY public.mdl_groupings.id;


--
-- Name: mdl_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_groups (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    idnumber character varying(100) DEFAULT ''::character varying NOT NULL,
    name character varying(254) DEFAULT ''::character varying NOT NULL,
    description text,
    descriptionformat smallint DEFAULT 0 NOT NULL,
    enrolmentkey character varying(50),
    picture bigint DEFAULT 0 NOT NULL,
    visibility smallint DEFAULT 0 NOT NULL,
    participation smallint DEFAULT 1 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_groups; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_groups IS 'Each record represents a group.';


--
-- Name: mdl_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_groups_id_seq OWNED BY public.mdl_groups.id;


--
-- Name: mdl_groups_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_groups_members (
    id bigint NOT NULL,
    groupid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    timeadded bigint DEFAULT 0 NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    itemid bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_groups_members; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_groups_members IS 'Link a user to a group.';


--
-- Name: mdl_groups_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_groups_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_groups_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_groups_members_id_seq OWNED BY public.mdl_groups_members.id;


--
-- Name: mdl_h5p; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_h5p (
    id bigint NOT NULL,
    jsoncontent text NOT NULL,
    mainlibraryid bigint NOT NULL,
    displayoptions smallint,
    pathnamehash character varying(40) DEFAULT ''::character varying NOT NULL,
    contenthash character varying(40) DEFAULT ''::character varying NOT NULL,
    filtered text,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_h5p; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_h5p IS 'Stores H5P content information';


--
-- Name: mdl_h5p_contents_libraries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_h5p_contents_libraries (
    id bigint NOT NULL,
    h5pid bigint NOT NULL,
    libraryid bigint NOT NULL,
    dependencytype character varying(10) DEFAULT ''::character varying NOT NULL,
    dropcss smallint NOT NULL,
    weight bigint NOT NULL
);


--
-- Name: TABLE mdl_h5p_contents_libraries; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_h5p_contents_libraries IS 'Store which library is used in which content.';


--
-- Name: mdl_h5p_contents_libraries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_h5p_contents_libraries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_h5p_contents_libraries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_h5p_contents_libraries_id_seq OWNED BY public.mdl_h5p_contents_libraries.id;


--
-- Name: mdl_h5p_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_h5p_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_h5p_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_h5p_id_seq OWNED BY public.mdl_h5p.id;


--
-- Name: mdl_h5p_libraries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_h5p_libraries (
    id bigint NOT NULL,
    machinename character varying(255) DEFAULT ''::character varying NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    majorversion smallint NOT NULL,
    minorversion smallint NOT NULL,
    patchversion smallint NOT NULL,
    runnable smallint NOT NULL,
    fullscreen smallint DEFAULT 0 NOT NULL,
    embedtypes character varying(255) DEFAULT ''::character varying NOT NULL,
    preloadedjs text,
    preloadedcss text,
    droplibrarycss text,
    semantics text,
    addto text,
    coremajor smallint,
    coreminor smallint,
    metadatasettings text,
    tutorial text,
    example text,
    enabled smallint DEFAULT 1
);


--
-- Name: TABLE mdl_h5p_libraries; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_h5p_libraries IS 'Stores information about libraries used by H5P content.';


--
-- Name: mdl_h5p_libraries_cachedassets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_h5p_libraries_cachedassets (
    id bigint NOT NULL,
    libraryid bigint NOT NULL,
    hash character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_h5p_libraries_cachedassets; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_h5p_libraries_cachedassets IS 'H5P cached library assets';


--
-- Name: mdl_h5p_libraries_cachedassets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_h5p_libraries_cachedassets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_h5p_libraries_cachedassets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_h5p_libraries_cachedassets_id_seq OWNED BY public.mdl_h5p_libraries_cachedassets.id;


--
-- Name: mdl_h5p_libraries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_h5p_libraries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_h5p_libraries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_h5p_libraries_id_seq OWNED BY public.mdl_h5p_libraries.id;


--
-- Name: mdl_h5p_library_dependencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_h5p_library_dependencies (
    id bigint NOT NULL,
    libraryid bigint NOT NULL,
    requiredlibraryid bigint NOT NULL,
    dependencytype character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_h5p_library_dependencies; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_h5p_library_dependencies IS 'Stores H5P library dependencies';


--
-- Name: mdl_h5p_library_dependencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_h5p_library_dependencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_h5p_library_dependencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_h5p_library_dependencies_id_seq OWNED BY public.mdl_h5p_library_dependencies.id;


--
-- Name: mdl_h5pactivity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_h5pactivity (
    id bigint NOT NULL,
    course bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    intro text,
    introformat smallint DEFAULT 0 NOT NULL,
    grade bigint DEFAULT 0,
    displayoptions smallint DEFAULT 0 NOT NULL,
    enabletracking smallint DEFAULT 1 NOT NULL,
    grademethod smallint DEFAULT 1 NOT NULL,
    reviewmode smallint DEFAULT 1
);


--
-- Name: TABLE mdl_h5pactivity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_h5pactivity IS 'Stores the h5pactivity activity module instances.';


--
-- Name: mdl_h5pactivity_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_h5pactivity_attempts (
    id bigint NOT NULL,
    h5pactivityid bigint NOT NULL,
    userid bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    attempt integer DEFAULT 1 NOT NULL,
    rawscore bigint DEFAULT 0,
    maxscore bigint DEFAULT 0,
    scaled numeric(10,5) DEFAULT 0 NOT NULL,
    duration bigint DEFAULT 0,
    completion smallint,
    success smallint
);


--
-- Name: TABLE mdl_h5pactivity_attempts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_h5pactivity_attempts IS 'Users attempts inside H5P activities';


--
-- Name: mdl_h5pactivity_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_h5pactivity_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_h5pactivity_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_h5pactivity_attempts_id_seq OWNED BY public.mdl_h5pactivity_attempts.id;


--
-- Name: mdl_h5pactivity_attempts_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_h5pactivity_attempts_results (
    id bigint NOT NULL,
    attemptid bigint NOT NULL,
    subcontent character varying(128),
    timecreated bigint NOT NULL,
    interactiontype character varying(128),
    description text,
    correctpattern text,
    response text NOT NULL,
    additionals text,
    rawscore bigint DEFAULT 0 NOT NULL,
    maxscore bigint DEFAULT 0 NOT NULL,
    duration bigint DEFAULT 0,
    completion smallint,
    success smallint
);


--
-- Name: TABLE mdl_h5pactivity_attempts_results; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_h5pactivity_attempts_results IS 'H5Pactivities_attempts tracking info';


--
-- Name: mdl_h5pactivity_attempts_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_h5pactivity_attempts_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_h5pactivity_attempts_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_h5pactivity_attempts_results_id_seq OWNED BY public.mdl_h5pactivity_attempts_results.id;


--
-- Name: mdl_h5pactivity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_h5pactivity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_h5pactivity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_h5pactivity_id_seq OWNED BY public.mdl_h5pactivity.id;


--
-- Name: mdl_imscp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_imscp (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text,
    introformat smallint DEFAULT 0 NOT NULL,
    revision bigint DEFAULT 0 NOT NULL,
    keepold bigint DEFAULT '-1'::integer NOT NULL,
    structure text,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_imscp; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_imscp IS 'each record is one imscp resource';


--
-- Name: mdl_imscp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_imscp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_imscp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_imscp_id_seq OWNED BY public.mdl_imscp.id;


--
-- Name: mdl_infected_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_infected_files (
    id bigint NOT NULL,
    filename text NOT NULL,
    quarantinedfile text,
    userid bigint NOT NULL,
    reason text NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_infected_files; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_infected_files IS 'Table to store infected file details.';


--
-- Name: mdl_infected_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_infected_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_infected_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_infected_files_id_seq OWNED BY public.mdl_infected_files.id;


--
-- Name: mdl_label; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_label (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text NOT NULL,
    introformat smallint DEFAULT 0,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_label; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_label IS 'Defines labels';


--
-- Name: mdl_label_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_label_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_label_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_label_id_seq OWNED BY public.mdl_label.id;


--
-- Name: mdl_lesson; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lesson (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text,
    introformat smallint DEFAULT 0 NOT NULL,
    practice smallint DEFAULT 0 NOT NULL,
    modattempts smallint DEFAULT 0 NOT NULL,
    usepassword smallint DEFAULT 0 NOT NULL,
    password character varying(32) DEFAULT ''::character varying NOT NULL,
    dependency bigint DEFAULT 0 NOT NULL,
    conditions text NOT NULL,
    grade bigint DEFAULT 0 NOT NULL,
    custom smallint DEFAULT 0 NOT NULL,
    ongoing smallint DEFAULT 0 NOT NULL,
    usemaxgrade smallint DEFAULT 0 NOT NULL,
    maxanswers smallint DEFAULT 4 NOT NULL,
    maxattempts smallint DEFAULT 5 NOT NULL,
    review smallint DEFAULT 0 NOT NULL,
    nextpagedefault smallint DEFAULT 0 NOT NULL,
    feedback smallint DEFAULT 1 NOT NULL,
    minquestions smallint DEFAULT 0 NOT NULL,
    maxpages smallint DEFAULT 0 NOT NULL,
    timelimit bigint DEFAULT 0 NOT NULL,
    retake smallint DEFAULT 1 NOT NULL,
    activitylink bigint DEFAULT 0 NOT NULL,
    mediafile character varying(255) DEFAULT ''::character varying NOT NULL,
    mediaheight bigint DEFAULT 100 NOT NULL,
    mediawidth bigint DEFAULT 650 NOT NULL,
    mediaclose smallint DEFAULT 0 NOT NULL,
    slideshow smallint DEFAULT 0 NOT NULL,
    width bigint DEFAULT 640 NOT NULL,
    height bigint DEFAULT 480 NOT NULL,
    bgcolor character varying(7) DEFAULT '#FFFFFF'::character varying NOT NULL,
    displayleft smallint DEFAULT 0 NOT NULL,
    displayleftif smallint DEFAULT 0 NOT NULL,
    progressbar smallint DEFAULT 0 NOT NULL,
    available bigint DEFAULT 0 NOT NULL,
    deadline bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    completionendreached smallint DEFAULT 0,
    completiontimespent bigint DEFAULT 0,
    allowofflineattempts smallint DEFAULT 0
);


--
-- Name: TABLE mdl_lesson; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lesson IS 'Defines lesson';


--
-- Name: mdl_lesson_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lesson_answers (
    id bigint NOT NULL,
    lessonid bigint DEFAULT 0 NOT NULL,
    pageid bigint DEFAULT 0 NOT NULL,
    jumpto bigint DEFAULT 0 NOT NULL,
    grade smallint DEFAULT 0 NOT NULL,
    score bigint DEFAULT 0 NOT NULL,
    flags smallint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    answer text,
    answerformat smallint DEFAULT 0 NOT NULL,
    response text,
    responseformat smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_lesson_answers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lesson_answers IS 'Defines lesson_answers';


--
-- Name: mdl_lesson_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lesson_answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lesson_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lesson_answers_id_seq OWNED BY public.mdl_lesson_answers.id;


--
-- Name: mdl_lesson_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lesson_attempts (
    id bigint NOT NULL,
    lessonid bigint DEFAULT 0 NOT NULL,
    pageid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    answerid bigint DEFAULT 0 NOT NULL,
    retry smallint DEFAULT 0 NOT NULL,
    correct bigint DEFAULT 0 NOT NULL,
    useranswer text,
    timeseen bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_lesson_attempts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lesson_attempts IS 'Defines lesson_attempts';


--
-- Name: mdl_lesson_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lesson_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lesson_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lesson_attempts_id_seq OWNED BY public.mdl_lesson_attempts.id;


--
-- Name: mdl_lesson_branch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lesson_branch (
    id bigint NOT NULL,
    lessonid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    pageid bigint DEFAULT 0 NOT NULL,
    retry bigint DEFAULT 0 NOT NULL,
    flag smallint DEFAULT 0 NOT NULL,
    timeseen bigint DEFAULT 0 NOT NULL,
    nextpageid bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_lesson_branch; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lesson_branch IS 'branches for each lesson/user';


--
-- Name: mdl_lesson_branch_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lesson_branch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lesson_branch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lesson_branch_id_seq OWNED BY public.mdl_lesson_branch.id;


--
-- Name: mdl_lesson_grades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lesson_grades (
    id bigint NOT NULL,
    lessonid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    grade double precision DEFAULT 0 NOT NULL,
    late smallint DEFAULT 0 NOT NULL,
    completed bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_lesson_grades; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lesson_grades IS 'Defines lesson_grades';


--
-- Name: mdl_lesson_grades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lesson_grades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lesson_grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lesson_grades_id_seq OWNED BY public.mdl_lesson_grades.id;


--
-- Name: mdl_lesson_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lesson_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lesson_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lesson_id_seq OWNED BY public.mdl_lesson.id;


--
-- Name: mdl_lesson_overrides; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lesson_overrides (
    id bigint NOT NULL,
    lessonid bigint DEFAULT 0 NOT NULL,
    groupid bigint,
    userid bigint,
    available bigint,
    deadline bigint,
    timelimit bigint,
    review smallint,
    maxattempts smallint,
    retake smallint,
    password character varying(32)
);


--
-- Name: TABLE mdl_lesson_overrides; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lesson_overrides IS 'The overrides to lesson settings.';


--
-- Name: mdl_lesson_overrides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lesson_overrides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lesson_overrides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lesson_overrides_id_seq OWNED BY public.mdl_lesson_overrides.id;


--
-- Name: mdl_lesson_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lesson_pages (
    id bigint NOT NULL,
    lessonid bigint DEFAULT 0 NOT NULL,
    prevpageid bigint DEFAULT 0 NOT NULL,
    nextpageid bigint DEFAULT 0 NOT NULL,
    qtype smallint DEFAULT 0 NOT NULL,
    qoption smallint DEFAULT 0 NOT NULL,
    layout smallint DEFAULT 1 NOT NULL,
    display smallint DEFAULT 1 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    contents text NOT NULL,
    contentsformat smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_lesson_pages; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lesson_pages IS 'Defines lesson_pages';


--
-- Name: mdl_lesson_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lesson_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lesson_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lesson_pages_id_seq OWNED BY public.mdl_lesson_pages.id;


--
-- Name: mdl_lesson_timer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lesson_timer (
    id bigint NOT NULL,
    lessonid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    starttime bigint DEFAULT 0 NOT NULL,
    lessontime bigint DEFAULT 0 NOT NULL,
    completed smallint DEFAULT 0,
    timemodifiedoffline bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_lesson_timer; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lesson_timer IS 'lesson timer for each lesson';


--
-- Name: mdl_lesson_timer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lesson_timer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lesson_timer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lesson_timer_id_seq OWNED BY public.mdl_lesson_timer.id;


--
-- Name: mdl_license; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_license (
    id bigint NOT NULL,
    shortname character varying(255),
    fullname text,
    source character varying(255),
    enabled smallint DEFAULT 1 NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    custom smallint DEFAULT 0 NOT NULL,
    sortorder integer DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_license; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_license IS 'store licenses used by moodle';


--
-- Name: mdl_license_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_license_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_license_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_license_id_seq OWNED BY public.mdl_license.id;


--
-- Name: mdl_lock_db; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lock_db (
    id bigint NOT NULL,
    resourcekey character varying(255) DEFAULT ''::character varying NOT NULL,
    expires bigint,
    owner character varying(36)
);


--
-- Name: TABLE mdl_lock_db; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lock_db IS 'Stores active and inactive lock types for db locking method.';


--
-- Name: mdl_lock_db_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lock_db_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lock_db_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lock_db_id_seq OWNED BY public.mdl_lock_db.id;


--
-- Name: mdl_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_log (
    id bigint NOT NULL,
    "time" bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    ip character varying(45) DEFAULT ''::character varying NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    module character varying(20) DEFAULT ''::character varying NOT NULL,
    cmid bigint DEFAULT 0 NOT NULL,
    action character varying(40) DEFAULT ''::character varying NOT NULL,
    url character varying(100) DEFAULT ''::character varying NOT NULL,
    info character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_log IS 'Every action is logged as far as possible';


--
-- Name: mdl_log_display; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_log_display (
    id bigint NOT NULL,
    module character varying(20) DEFAULT ''::character varying NOT NULL,
    action character varying(40) DEFAULT ''::character varying NOT NULL,
    mtable character varying(30) DEFAULT ''::character varying NOT NULL,
    field character varying(200) DEFAULT ''::character varying NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_log_display; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_log_display IS 'For a particular module/action, specifies a moodle table/field';


--
-- Name: mdl_log_display_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_log_display_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_log_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_log_display_id_seq OWNED BY public.mdl_log_display.id;


--
-- Name: mdl_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_log_id_seq OWNED BY public.mdl_log.id;


--
-- Name: mdl_log_queries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_log_queries (
    id bigint NOT NULL,
    qtype integer NOT NULL,
    sqltext text NOT NULL,
    sqlparams text,
    error integer DEFAULT 0 NOT NULL,
    info text,
    backtrace text,
    exectime numeric(10,5) NOT NULL,
    timelogged bigint NOT NULL
);


--
-- Name: TABLE mdl_log_queries; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_log_queries IS 'Logged database queries.';


--
-- Name: mdl_log_queries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_log_queries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_log_queries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_log_queries_id_seq OWNED BY public.mdl_log_queries.id;


--
-- Name: mdl_logstore_standard_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_logstore_standard_log (
    id bigint NOT NULL,
    eventname character varying(255) DEFAULT ''::character varying NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    action character varying(100) DEFAULT ''::character varying NOT NULL,
    target character varying(100) DEFAULT ''::character varying NOT NULL,
    objecttable character varying(50),
    objectid bigint,
    crud character varying(1) DEFAULT ''::character varying NOT NULL,
    edulevel smallint NOT NULL,
    contextid bigint NOT NULL,
    contextlevel bigint NOT NULL,
    contextinstanceid bigint NOT NULL,
    userid bigint NOT NULL,
    courseid bigint,
    relateduserid bigint,
    anonymous smallint DEFAULT 0 NOT NULL,
    other text,
    timecreated bigint NOT NULL,
    origin character varying(10),
    ip character varying(45),
    realuserid bigint
);


--
-- Name: TABLE mdl_logstore_standard_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_logstore_standard_log IS 'Standard log table';


--
-- Name: mdl_logstore_standard_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_logstore_standard_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_logstore_standard_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_logstore_standard_log_id_seq OWNED BY public.mdl_logstore_standard_log.id;


--
-- Name: mdl_lti; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lti (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text,
    introformat smallint DEFAULT 0,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    typeid bigint,
    toolurl text NOT NULL,
    securetoolurl text,
    instructorchoicesendname smallint,
    instructorchoicesendemailaddr smallint,
    instructorchoiceallowroster smallint,
    instructorchoiceallowsetting smallint,
    instructorcustomparameters text,
    instructorchoiceacceptgrades smallint,
    grade bigint DEFAULT 100 NOT NULL,
    launchcontainer smallint DEFAULT 1 NOT NULL,
    resourcekey character varying(255),
    password character varying(255),
    debuglaunch smallint DEFAULT 0 NOT NULL,
    showtitlelaunch smallint DEFAULT 0 NOT NULL,
    showdescriptionlaunch smallint DEFAULT 0 NOT NULL,
    servicesalt character varying(40),
    icon text,
    secureicon text
);


--
-- Name: TABLE mdl_lti; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lti IS 'This table contains Basic LTI activities instances';


--
-- Name: mdl_lti_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lti_access_tokens (
    id bigint NOT NULL,
    typeid bigint NOT NULL,
    scope text NOT NULL,
    token character varying(128) DEFAULT ''::character varying NOT NULL,
    validuntil bigint NOT NULL,
    timecreated bigint NOT NULL,
    lastaccess bigint
);


--
-- Name: TABLE mdl_lti_access_tokens; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lti_access_tokens IS 'Security tokens for accessing of LTI services';


--
-- Name: mdl_lti_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lti_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lti_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lti_access_tokens_id_seq OWNED BY public.mdl_lti_access_tokens.id;


--
-- Name: mdl_lti_coursevisible; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lti_coursevisible (
    id bigint NOT NULL,
    typeid bigint NOT NULL,
    courseid bigint NOT NULL,
    coursevisible smallint NOT NULL
);


--
-- Name: TABLE mdl_lti_coursevisible; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lti_coursevisible IS 'Table to store coursevisible setting for site tool on course level';


--
-- Name: mdl_lti_coursevisible_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lti_coursevisible_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lti_coursevisible_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lti_coursevisible_id_seq OWNED BY public.mdl_lti_coursevisible.id;


--
-- Name: mdl_lti_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lti_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lti_id_seq OWNED BY public.mdl_lti.id;


--
-- Name: mdl_lti_submission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lti_submission (
    id bigint NOT NULL,
    ltiid bigint NOT NULL,
    userid bigint NOT NULL,
    datesubmitted bigint NOT NULL,
    dateupdated bigint NOT NULL,
    gradepercent numeric(10,5) NOT NULL,
    originalgrade numeric(10,5) NOT NULL,
    launchid bigint NOT NULL,
    state smallint NOT NULL
);


--
-- Name: TABLE mdl_lti_submission; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lti_submission IS 'Keeps track of individual submissions for LTI activities.';


--
-- Name: mdl_lti_submission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lti_submission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lti_submission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lti_submission_id_seq OWNED BY public.mdl_lti_submission.id;


--
-- Name: mdl_lti_tool_proxies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lti_tool_proxies (
    id bigint NOT NULL,
    name character varying(255) DEFAULT 'Tool Provider'::character varying NOT NULL,
    regurl text,
    state smallint DEFAULT 1 NOT NULL,
    guid character varying(255),
    secret character varying(255),
    vendorcode character varying(255),
    capabilityoffered text NOT NULL,
    serviceoffered text NOT NULL,
    toolproxy text,
    createdby bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_lti_tool_proxies; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lti_tool_proxies IS 'LTI tool proxy registrations';


--
-- Name: mdl_lti_tool_proxies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lti_tool_proxies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lti_tool_proxies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lti_tool_proxies_id_seq OWNED BY public.mdl_lti_tool_proxies.id;


--
-- Name: mdl_lti_tool_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lti_tool_settings (
    id bigint NOT NULL,
    toolproxyid bigint NOT NULL,
    typeid bigint,
    course bigint,
    coursemoduleid bigint,
    settings text NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_lti_tool_settings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lti_tool_settings IS 'LTI tool setting values';


--
-- Name: mdl_lti_tool_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lti_tool_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lti_tool_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lti_tool_settings_id_seq OWNED BY public.mdl_lti_tool_settings.id;


--
-- Name: mdl_lti_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lti_types (
    id bigint NOT NULL,
    name character varying(255) DEFAULT 'basiclti Activity'::character varying NOT NULL,
    baseurl text NOT NULL,
    tooldomain character varying(255) DEFAULT ''::character varying NOT NULL,
    state smallint DEFAULT 2 NOT NULL,
    course bigint NOT NULL,
    coursevisible smallint DEFAULT 0 NOT NULL,
    ltiversion character varying(10) DEFAULT ''::character varying NOT NULL,
    clientid character varying(255),
    toolproxyid bigint,
    enabledcapability text,
    parameter text,
    icon text,
    secureicon text,
    createdby bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    description text
);


--
-- Name: TABLE mdl_lti_types; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lti_types IS 'Basic LTI pre-configured activities';


--
-- Name: mdl_lti_types_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lti_types_categories (
    id bigint NOT NULL,
    typeid bigint NOT NULL,
    categoryid bigint NOT NULL
);


--
-- Name: TABLE mdl_lti_types_categories; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lti_types_categories IS 'Link LTI types to course categories';


--
-- Name: mdl_lti_types_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lti_types_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lti_types_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lti_types_categories_id_seq OWNED BY public.mdl_lti_types_categories.id;


--
-- Name: mdl_lti_types_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_lti_types_config (
    id bigint NOT NULL,
    typeid bigint NOT NULL,
    name character varying(100) DEFAULT ''::character varying NOT NULL,
    value text NOT NULL
);


--
-- Name: TABLE mdl_lti_types_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_lti_types_config IS 'Basic LTI types configuration';


--
-- Name: mdl_lti_types_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lti_types_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lti_types_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lti_types_config_id_seq OWNED BY public.mdl_lti_types_config.id;


--
-- Name: mdl_lti_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_lti_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_lti_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_lti_types_id_seq OWNED BY public.mdl_lti_types.id;


--
-- Name: mdl_ltiservice_gradebookservices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_ltiservice_gradebookservices (
    id bigint NOT NULL,
    gradeitemid bigint NOT NULL,
    courseid bigint NOT NULL,
    toolproxyid bigint,
    typeid bigint,
    baseurl text,
    ltilinkid bigint,
    resourceid character varying(512),
    tag character varying(255),
    subreviewurl text,
    subreviewparams text
);


--
-- Name: TABLE mdl_ltiservice_gradebookservices; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_ltiservice_gradebookservices IS 'This file records the grade items created by the LTI Gradebook Services service';


--
-- Name: mdl_ltiservice_gradebookservices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_ltiservice_gradebookservices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_ltiservice_gradebookservices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_ltiservice_gradebookservices_id_seq OWNED BY public.mdl_ltiservice_gradebookservices.id;


--
-- Name: mdl_matrix_room; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_matrix_room (
    id bigint NOT NULL,
    commid bigint NOT NULL,
    roomid character varying(255),
    topic character varying(255)
);


--
-- Name: TABLE mdl_matrix_room; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_matrix_room IS 'Stores the matrix room information associated with the communication instance.';


--
-- Name: mdl_matrix_room_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_matrix_room_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_matrix_room_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_matrix_room_id_seq OWNED BY public.mdl_matrix_room.id;


--
-- Name: mdl_message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_message (
    id bigint NOT NULL,
    useridfrom bigint DEFAULT 0 NOT NULL,
    useridto bigint DEFAULT 0 NOT NULL,
    subject text,
    fullmessage text,
    fullmessageformat smallint DEFAULT 0,
    fullmessagehtml text,
    smallmessage text,
    notification smallint DEFAULT 0,
    contexturl text,
    contexturlname text,
    timecreated bigint DEFAULT 0 NOT NULL,
    timeuserfromdeleted bigint DEFAULT 0 NOT NULL,
    timeusertodeleted bigint DEFAULT 0 NOT NULL,
    component character varying(100),
    eventtype character varying(100),
    customdata text
);


--
-- Name: TABLE mdl_message; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_message IS 'Stores all unread messages';


--
-- Name: mdl_message_airnotifier_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_message_airnotifier_devices (
    id bigint NOT NULL,
    userdeviceid bigint NOT NULL,
    enable smallint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_message_airnotifier_devices; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_message_airnotifier_devices IS 'Store information about the devices registered in Airnotifier for PUSH notifications';


--
-- Name: mdl_message_airnotifier_devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_message_airnotifier_devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_message_airnotifier_devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_message_airnotifier_devices_id_seq OWNED BY public.mdl_message_airnotifier_devices.id;


--
-- Name: mdl_message_contact_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_message_contact_requests (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    requesteduserid bigint NOT NULL,
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_message_contact_requests; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_message_contact_requests IS 'Maintains list of contact requests between users';


--
-- Name: mdl_message_contact_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_message_contact_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_message_contact_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_message_contact_requests_id_seq OWNED BY public.mdl_message_contact_requests.id;


--
-- Name: mdl_message_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_message_contacts (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    contactid bigint NOT NULL,
    timecreated bigint
);


--
-- Name: TABLE mdl_message_contacts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_message_contacts IS 'Maintains lists of contacts between users';


--
-- Name: mdl_message_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_message_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_message_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_message_contacts_id_seq OWNED BY public.mdl_message_contacts.id;


--
-- Name: mdl_message_conversation_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_message_conversation_actions (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    conversationid bigint NOT NULL,
    action bigint NOT NULL,
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_message_conversation_actions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_message_conversation_actions IS 'Stores all per-user actions on individual conversations';


--
-- Name: mdl_message_conversation_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_message_conversation_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_message_conversation_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_message_conversation_actions_id_seq OWNED BY public.mdl_message_conversation_actions.id;


--
-- Name: mdl_message_conversation_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_message_conversation_members (
    id bigint NOT NULL,
    conversationid bigint NOT NULL,
    userid bigint NOT NULL,
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_message_conversation_members; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_message_conversation_members IS 'Stores all members in a conversations';


--
-- Name: mdl_message_conversation_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_message_conversation_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_message_conversation_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_message_conversation_members_id_seq OWNED BY public.mdl_message_conversation_members.id;


--
-- Name: mdl_message_conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_message_conversations (
    id bigint NOT NULL,
    type bigint DEFAULT 1 NOT NULL,
    name character varying(255),
    convhash character varying(40),
    component character varying(100),
    itemtype character varying(100),
    itemid bigint,
    contextid bigint,
    enabled smallint DEFAULT 0 NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint
);


--
-- Name: TABLE mdl_message_conversations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_message_conversations IS 'Stores all message conversations';


--
-- Name: mdl_message_conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_message_conversations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_message_conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_message_conversations_id_seq OWNED BY public.mdl_message_conversations.id;


--
-- Name: mdl_message_email_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_message_email_messages (
    id bigint NOT NULL,
    useridto bigint NOT NULL,
    conversationid bigint NOT NULL,
    messageid bigint NOT NULL
);


--
-- Name: TABLE mdl_message_email_messages; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_message_email_messages IS 'Keeps track of what emails to send in an email digest';


--
-- Name: mdl_message_email_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_message_email_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_message_email_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_message_email_messages_id_seq OWNED BY public.mdl_message_email_messages.id;


--
-- Name: mdl_message_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_message_id_seq OWNED BY public.mdl_message.id;


--
-- Name: mdl_message_popup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_message_popup (
    id bigint NOT NULL,
    messageid bigint NOT NULL,
    isread smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_message_popup; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_message_popup IS 'Keep state of notifications for the popup message processor';


--
-- Name: mdl_message_popup_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_message_popup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_message_popup_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_message_popup_id_seq OWNED BY public.mdl_message_popup.id;


--
-- Name: mdl_message_popup_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_message_popup_notifications (
    id bigint NOT NULL,
    notificationid bigint NOT NULL
);


--
-- Name: TABLE mdl_message_popup_notifications; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_message_popup_notifications IS 'List of notifications to display in the message output popup';


--
-- Name: mdl_message_popup_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_message_popup_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_message_popup_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_message_popup_notifications_id_seq OWNED BY public.mdl_message_popup_notifications.id;


--
-- Name: mdl_message_processors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_message_processors (
    id bigint NOT NULL,
    name character varying(166) DEFAULT ''::character varying NOT NULL,
    enabled smallint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_message_processors; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_message_processors IS 'List of message output plugins';


--
-- Name: mdl_message_processors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_message_processors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_message_processors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_message_processors_id_seq OWNED BY public.mdl_message_processors.id;


--
-- Name: mdl_message_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_message_providers (
    id bigint NOT NULL,
    name character varying(100) DEFAULT ''::character varying NOT NULL,
    component character varying(200) DEFAULT ''::character varying NOT NULL,
    capability character varying(255)
);


--
-- Name: TABLE mdl_message_providers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_message_providers IS 'This table stores the message providers (modules and core systems)';


--
-- Name: mdl_message_providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_message_providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_message_providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_message_providers_id_seq OWNED BY public.mdl_message_providers.id;


--
-- Name: mdl_message_read; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_message_read (
    id bigint NOT NULL,
    useridfrom bigint DEFAULT 0 NOT NULL,
    useridto bigint DEFAULT 0 NOT NULL,
    subject text,
    fullmessage text,
    fullmessageformat smallint DEFAULT 0,
    fullmessagehtml text,
    smallmessage text,
    notification smallint DEFAULT 0,
    contexturl text,
    contexturlname text,
    timecreated bigint DEFAULT 0 NOT NULL,
    timeread bigint DEFAULT 0 NOT NULL,
    timeuserfromdeleted bigint DEFAULT 0 NOT NULL,
    timeusertodeleted bigint DEFAULT 0 NOT NULL,
    component character varying(100),
    eventtype character varying(100)
);


--
-- Name: TABLE mdl_message_read; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_message_read IS 'Stores all messages that have been read';


--
-- Name: mdl_message_read_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_message_read_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_message_read_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_message_read_id_seq OWNED BY public.mdl_message_read.id;


--
-- Name: mdl_message_user_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_message_user_actions (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    messageid bigint NOT NULL,
    action bigint NOT NULL,
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_message_user_actions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_message_user_actions IS 'Stores all per-user actions on individual messages';


--
-- Name: mdl_message_user_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_message_user_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_message_user_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_message_user_actions_id_seq OWNED BY public.mdl_message_user_actions.id;


--
-- Name: mdl_message_users_blocked; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_message_users_blocked (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    blockeduserid bigint NOT NULL,
    timecreated bigint
);


--
-- Name: TABLE mdl_message_users_blocked; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_message_users_blocked IS 'Maintains lists of blocked users';


--
-- Name: mdl_message_users_blocked_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_message_users_blocked_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_message_users_blocked_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_message_users_blocked_id_seq OWNED BY public.mdl_message_users_blocked.id;


--
-- Name: mdl_messageinbound_datakeys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_messageinbound_datakeys (
    id bigint NOT NULL,
    handler bigint NOT NULL,
    datavalue bigint NOT NULL,
    datakey character varying(64),
    timecreated bigint NOT NULL,
    expires bigint
);


--
-- Name: TABLE mdl_messageinbound_datakeys; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_messageinbound_datakeys IS 'Inbound Message data item secret keys.';


--
-- Name: mdl_messageinbound_datakeys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_messageinbound_datakeys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_messageinbound_datakeys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_messageinbound_datakeys_id_seq OWNED BY public.mdl_messageinbound_datakeys.id;


--
-- Name: mdl_messageinbound_handlers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_messageinbound_handlers (
    id bigint NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    classname character varying(255) DEFAULT ''::character varying NOT NULL,
    defaultexpiration bigint DEFAULT 86400 NOT NULL,
    validateaddress smallint DEFAULT 1 NOT NULL,
    enabled smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_messageinbound_handlers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_messageinbound_handlers IS 'Inbound Message Handler definitions.';


--
-- Name: mdl_messageinbound_handlers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_messageinbound_handlers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_messageinbound_handlers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_messageinbound_handlers_id_seq OWNED BY public.mdl_messageinbound_handlers.id;


--
-- Name: mdl_messageinbound_messagelist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_messageinbound_messagelist (
    id bigint NOT NULL,
    messageid text NOT NULL,
    userid bigint NOT NULL,
    address text NOT NULL,
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_messageinbound_messagelist; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_messageinbound_messagelist IS 'A list of message IDs for existing replies';


--
-- Name: mdl_messageinbound_messagelist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_messageinbound_messagelist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_messageinbound_messagelist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_messageinbound_messagelist_id_seq OWNED BY public.mdl_messageinbound_messagelist.id;


--
-- Name: mdl_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_messages (
    id bigint NOT NULL,
    useridfrom bigint NOT NULL,
    conversationid bigint NOT NULL,
    subject text,
    fullmessage text,
    fullmessageformat smallint DEFAULT 0 NOT NULL,
    fullmessagehtml text,
    smallmessage text,
    timecreated bigint NOT NULL,
    fullmessagetrust smallint DEFAULT 0 NOT NULL,
    customdata text
);


--
-- Name: TABLE mdl_messages; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_messages IS 'Stores all messages';


--
-- Name: mdl_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_messages_id_seq OWNED BY public.mdl_messages.id;


--
-- Name: mdl_mnet_application; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_mnet_application (
    id bigint NOT NULL,
    name character varying(50) DEFAULT ''::character varying NOT NULL,
    display_name character varying(50) DEFAULT ''::character varying NOT NULL,
    xmlrpc_server_url character varying(255) DEFAULT ''::character varying NOT NULL,
    sso_land_url character varying(255) DEFAULT ''::character varying NOT NULL,
    sso_jump_url character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_mnet_application; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_mnet_application IS 'Information about applications on remote hosts';


--
-- Name: mdl_mnet_application_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_mnet_application_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_mnet_application_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_mnet_application_id_seq OWNED BY public.mdl_mnet_application.id;


--
-- Name: mdl_mnet_host; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_mnet_host (
    id bigint NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    wwwroot character varying(255) DEFAULT ''::character varying NOT NULL,
    ip_address character varying(45) DEFAULT ''::character varying NOT NULL,
    name character varying(80) DEFAULT ''::character varying NOT NULL,
    public_key text NOT NULL,
    public_key_expires bigint DEFAULT 0 NOT NULL,
    transport smallint DEFAULT 0 NOT NULL,
    portno integer DEFAULT 0 NOT NULL,
    last_connect_time bigint DEFAULT 0 NOT NULL,
    last_log_id bigint DEFAULT 0 NOT NULL,
    force_theme smallint DEFAULT 0 NOT NULL,
    theme character varying(100),
    applicationid bigint DEFAULT 1 NOT NULL,
    sslverification smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_mnet_host; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_mnet_host IS 'Information about the local and remote hosts for RPC';


--
-- Name: mdl_mnet_host2service; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_mnet_host2service (
    id bigint NOT NULL,
    hostid bigint DEFAULT 0 NOT NULL,
    serviceid bigint DEFAULT 0 NOT NULL,
    publish smallint DEFAULT 0 NOT NULL,
    subscribe smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_mnet_host2service; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_mnet_host2service IS 'Information about the services for a given host';


--
-- Name: mdl_mnet_host2service_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_mnet_host2service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_mnet_host2service_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_mnet_host2service_id_seq OWNED BY public.mdl_mnet_host2service.id;


--
-- Name: mdl_mnet_host_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_mnet_host_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_mnet_host_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_mnet_host_id_seq OWNED BY public.mdl_mnet_host.id;


--
-- Name: mdl_mnet_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_mnet_log (
    id bigint NOT NULL,
    hostid bigint DEFAULT 0 NOT NULL,
    remoteid bigint DEFAULT 0 NOT NULL,
    "time" bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    ip character varying(45) DEFAULT ''::character varying NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    coursename character varying(40) DEFAULT ''::character varying NOT NULL,
    module character varying(20) DEFAULT ''::character varying NOT NULL,
    cmid bigint DEFAULT 0 NOT NULL,
    action character varying(40) DEFAULT ''::character varying NOT NULL,
    url character varying(100) DEFAULT ''::character varying NOT NULL,
    info character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_mnet_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_mnet_log IS 'Store session data from users migrating to other sites';


--
-- Name: mdl_mnet_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_mnet_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_mnet_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_mnet_log_id_seq OWNED BY public.mdl_mnet_log.id;


--
-- Name: mdl_mnet_remote_rpc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_mnet_remote_rpc (
    id bigint NOT NULL,
    functionname character varying(40) DEFAULT ''::character varying NOT NULL,
    xmlrpcpath character varying(80) DEFAULT ''::character varying NOT NULL,
    plugintype character varying(20) DEFAULT ''::character varying NOT NULL,
    pluginname character varying(20) DEFAULT ''::character varying NOT NULL,
    enabled smallint NOT NULL
);


--
-- Name: TABLE mdl_mnet_remote_rpc; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_mnet_remote_rpc IS 'This table describes functions that might be called remotely (we have less information about them than local functions)';


--
-- Name: mdl_mnet_remote_rpc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_mnet_remote_rpc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_mnet_remote_rpc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_mnet_remote_rpc_id_seq OWNED BY public.mdl_mnet_remote_rpc.id;


--
-- Name: mdl_mnet_remote_service2rpc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_mnet_remote_service2rpc (
    id bigint NOT NULL,
    serviceid bigint DEFAULT 0 NOT NULL,
    rpcid bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_mnet_remote_service2rpc; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_mnet_remote_service2rpc IS 'Group functions or methods under a service';


--
-- Name: mdl_mnet_remote_service2rpc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_mnet_remote_service2rpc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_mnet_remote_service2rpc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_mnet_remote_service2rpc_id_seq OWNED BY public.mdl_mnet_remote_service2rpc.id;


--
-- Name: mdl_mnet_rpc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_mnet_rpc (
    id bigint NOT NULL,
    functionname character varying(40) DEFAULT ''::character varying NOT NULL,
    xmlrpcpath character varying(80) DEFAULT ''::character varying NOT NULL,
    plugintype character varying(20) DEFAULT ''::character varying NOT NULL,
    pluginname character varying(20) DEFAULT ''::character varying NOT NULL,
    enabled smallint DEFAULT 0 NOT NULL,
    help text NOT NULL,
    profile text NOT NULL,
    filename character varying(100) DEFAULT ''::character varying NOT NULL,
    classname character varying(150),
    static smallint
);


--
-- Name: TABLE mdl_mnet_rpc; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_mnet_rpc IS 'Functions or methods that we may publish or subscribe to';


--
-- Name: mdl_mnet_rpc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_mnet_rpc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_mnet_rpc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_mnet_rpc_id_seq OWNED BY public.mdl_mnet_rpc.id;


--
-- Name: mdl_mnet_service; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_mnet_service (
    id bigint NOT NULL,
    name character varying(40) DEFAULT ''::character varying NOT NULL,
    description character varying(40) DEFAULT ''::character varying NOT NULL,
    apiversion character varying(10) DEFAULT ''::character varying NOT NULL,
    offer smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_mnet_service; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_mnet_service IS 'A service is a group of functions';


--
-- Name: mdl_mnet_service2rpc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_mnet_service2rpc (
    id bigint NOT NULL,
    serviceid bigint DEFAULT 0 NOT NULL,
    rpcid bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_mnet_service2rpc; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_mnet_service2rpc IS 'Group functions or methods under a service';


--
-- Name: mdl_mnet_service2rpc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_mnet_service2rpc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_mnet_service2rpc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_mnet_service2rpc_id_seq OWNED BY public.mdl_mnet_service2rpc.id;


--
-- Name: mdl_mnet_service_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_mnet_service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_mnet_service_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_mnet_service_id_seq OWNED BY public.mdl_mnet_service.id;


--
-- Name: mdl_mnet_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_mnet_session (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    username character varying(100) DEFAULT ''::character varying NOT NULL,
    token character varying(40) DEFAULT ''::character varying NOT NULL,
    mnethostid bigint DEFAULT 0 NOT NULL,
    useragent character varying(40) DEFAULT ''::character varying NOT NULL,
    confirm_timeout bigint DEFAULT 0 NOT NULL,
    session_id character varying(40) DEFAULT ''::character varying NOT NULL,
    expires bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_mnet_session; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_mnet_session IS 'Store session data from users migrating to other sites';


--
-- Name: mdl_mnet_session_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_mnet_session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_mnet_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_mnet_session_id_seq OWNED BY public.mdl_mnet_session.id;


--
-- Name: mdl_mnet_sso_access_control; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_mnet_sso_access_control (
    id bigint NOT NULL,
    username character varying(100) DEFAULT ''::character varying NOT NULL,
    mnet_host_id bigint DEFAULT 0 NOT NULL,
    accessctrl character varying(20) DEFAULT 'allow'::character varying NOT NULL
);


--
-- Name: TABLE mdl_mnet_sso_access_control; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_mnet_sso_access_control IS 'Users by host permitted (or not) to login from a remote provider';


--
-- Name: mdl_mnet_sso_access_control_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_mnet_sso_access_control_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_mnet_sso_access_control_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_mnet_sso_access_control_id_seq OWNED BY public.mdl_mnet_sso_access_control.id;


--
-- Name: mdl_mnetservice_enrol_courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_mnetservice_enrol_courses (
    id bigint NOT NULL,
    hostid bigint NOT NULL,
    remoteid bigint NOT NULL,
    categoryid bigint NOT NULL,
    categoryname character varying(255) DEFAULT ''::character varying NOT NULL,
    sortorder bigint DEFAULT 0 NOT NULL,
    fullname character varying(254) DEFAULT ''::character varying NOT NULL,
    shortname character varying(100) DEFAULT ''::character varying NOT NULL,
    idnumber character varying(100) DEFAULT ''::character varying NOT NULL,
    summary text NOT NULL,
    summaryformat smallint DEFAULT 0,
    startdate bigint NOT NULL,
    roleid bigint NOT NULL,
    rolename character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_mnetservice_enrol_courses; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_mnetservice_enrol_courses IS 'Caches the information fetched via XML-RPC about courses on remote hosts that are offered for our users';


--
-- Name: mdl_mnetservice_enrol_courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_mnetservice_enrol_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_mnetservice_enrol_courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_mnetservice_enrol_courses_id_seq OWNED BY public.mdl_mnetservice_enrol_courses.id;


--
-- Name: mdl_mnetservice_enrol_enrolments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_mnetservice_enrol_enrolments (
    id bigint NOT NULL,
    hostid bigint NOT NULL,
    userid bigint NOT NULL,
    remotecourseid bigint NOT NULL,
    rolename character varying(255) DEFAULT ''::character varying NOT NULL,
    enroltime bigint DEFAULT 0 NOT NULL,
    enroltype character varying(20) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_mnetservice_enrol_enrolments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_mnetservice_enrol_enrolments IS 'Caches the information about enrolments of our local users in courses on remote hosts';


--
-- Name: mdl_mnetservice_enrol_enrolments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_mnetservice_enrol_enrolments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_mnetservice_enrol_enrolments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_mnetservice_enrol_enrolments_id_seq OWNED BY public.mdl_mnetservice_enrol_enrolments.id;


--
-- Name: mdl_modules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_modules (
    id bigint NOT NULL,
    name character varying(20) DEFAULT ''::character varying NOT NULL,
    cron bigint DEFAULT 0 NOT NULL,
    lastcron bigint DEFAULT 0 NOT NULL,
    search character varying(255) DEFAULT ''::character varying NOT NULL,
    visible smallint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_modules; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_modules IS 'modules available in the site';


--
-- Name: mdl_modules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_modules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_modules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_modules_id_seq OWNED BY public.mdl_modules.id;


--
-- Name: mdl_moodlenet_share_progress; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_moodlenet_share_progress (
    id bigint NOT NULL,
    type smallint NOT NULL,
    courseid bigint NOT NULL,
    cmid bigint,
    userid bigint NOT NULL,
    timecreated bigint NOT NULL,
    resourceurl character varying(255),
    status smallint
);


--
-- Name: TABLE mdl_moodlenet_share_progress; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_moodlenet_share_progress IS 'Records MoodleNet share progress';


--
-- Name: mdl_moodlenet_share_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_moodlenet_share_progress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_moodlenet_share_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_moodlenet_share_progress_id_seq OWNED BY public.mdl_moodlenet_share_progress.id;


--
-- Name: mdl_my_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_my_pages (
    id bigint NOT NULL,
    userid bigint DEFAULT 0,
    name character varying(200) DEFAULT ''::character varying NOT NULL,
    private smallint DEFAULT 1 NOT NULL,
    sortorder integer DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_my_pages; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_my_pages IS 'Extra user pages for the My Moodle system';


--
-- Name: mdl_my_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_my_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_my_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_my_pages_id_seq OWNED BY public.mdl_my_pages.id;


--
-- Name: mdl_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_notifications (
    id bigint NOT NULL,
    useridfrom bigint NOT NULL,
    useridto bigint NOT NULL,
    subject text,
    fullmessage text,
    fullmessageformat smallint DEFAULT 0 NOT NULL,
    fullmessagehtml text,
    smallmessage text,
    component character varying(100),
    eventtype character varying(100),
    contexturl text,
    contexturlname text,
    timeread bigint,
    timecreated bigint NOT NULL,
    customdata text
);


--
-- Name: TABLE mdl_notifications; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_notifications IS 'Stores all notifications';


--
-- Name: mdl_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_notifications_id_seq OWNED BY public.mdl_notifications.id;


--
-- Name: mdl_oauth2_access_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_oauth2_access_token (
    id bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint NOT NULL,
    issuerid bigint NOT NULL,
    token text NOT NULL,
    expires bigint NOT NULL,
    scope text NOT NULL
);


--
-- Name: TABLE mdl_oauth2_access_token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_oauth2_access_token IS 'Stores access tokens for system accounts in order to be able to use a single token across multiple sessions';


--
-- Name: mdl_oauth2_access_token_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_oauth2_access_token_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_oauth2_access_token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_oauth2_access_token_id_seq OWNED BY public.mdl_oauth2_access_token.id;


--
-- Name: mdl_oauth2_endpoint; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_oauth2_endpoint (
    id bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    url text NOT NULL,
    issuerid bigint NOT NULL
);


--
-- Name: TABLE mdl_oauth2_endpoint; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_oauth2_endpoint IS 'Describes the named endpoint for an oauth2 service.';


--
-- Name: mdl_oauth2_endpoint_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_oauth2_endpoint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_oauth2_endpoint_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_oauth2_endpoint_id_seq OWNED BY public.mdl_oauth2_endpoint.id;


--
-- Name: mdl_oauth2_issuer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_oauth2_issuer (
    id bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    image text NOT NULL,
    baseurl text NOT NULL,
    clientid text NOT NULL,
    clientsecret text NOT NULL,
    loginscopes text NOT NULL,
    loginscopesoffline text NOT NULL,
    loginparams text NOT NULL,
    loginparamsoffline text NOT NULL,
    alloweddomains text NOT NULL,
    scopessupported text,
    enabled smallint DEFAULT 1 NOT NULL,
    showonloginpage smallint DEFAULT 1 NOT NULL,
    basicauth smallint DEFAULT 0 NOT NULL,
    sortorder bigint NOT NULL,
    requireconfirmation smallint DEFAULT 1 NOT NULL,
    servicetype character varying(255),
    loginpagename character varying(255),
    systememail character varying(100)
);


--
-- Name: TABLE mdl_oauth2_issuer; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_oauth2_issuer IS 'Details for an oauth 2 connect identity issuer.';


--
-- Name: mdl_oauth2_issuer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_oauth2_issuer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_oauth2_issuer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_oauth2_issuer_id_seq OWNED BY public.mdl_oauth2_issuer.id;


--
-- Name: mdl_oauth2_refresh_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_oauth2_refresh_token (
    id bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    userid bigint NOT NULL,
    issuerid bigint NOT NULL,
    token text NOT NULL,
    scopehash character varying(40) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_oauth2_refresh_token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_oauth2_refresh_token IS 'Stores refresh tokens which can be exchanged for access tokens';


--
-- Name: mdl_oauth2_refresh_token_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_oauth2_refresh_token_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_oauth2_refresh_token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_oauth2_refresh_token_id_seq OWNED BY public.mdl_oauth2_refresh_token.id;


--
-- Name: mdl_oauth2_system_account; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_oauth2_system_account (
    id bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint NOT NULL,
    issuerid bigint NOT NULL,
    refreshtoken text NOT NULL,
    grantedscopes text NOT NULL,
    email text,
    username text NOT NULL
);


--
-- Name: TABLE mdl_oauth2_system_account; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_oauth2_system_account IS 'Stored details used to get an access token as a system user for this oauth2 service.';


--
-- Name: mdl_oauth2_system_account_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_oauth2_system_account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_oauth2_system_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_oauth2_system_account_id_seq OWNED BY public.mdl_oauth2_system_account.id;


--
-- Name: mdl_oauth2_user_field_mapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_oauth2_user_field_mapping (
    id bigint NOT NULL,
    timemodified bigint NOT NULL,
    timecreated bigint NOT NULL,
    usermodified bigint NOT NULL,
    issuerid bigint NOT NULL,
    externalfield character varying(500) DEFAULT ''::character varying NOT NULL,
    internalfield character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_oauth2_user_field_mapping; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_oauth2_user_field_mapping IS 'Mapping of oauth user fields to moodle fields.';


--
-- Name: mdl_oauth2_user_field_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_oauth2_user_field_mapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_oauth2_user_field_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_oauth2_user_field_mapping_id_seq OWNED BY public.mdl_oauth2_user_field_mapping.id;


--
-- Name: mdl_page; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_page (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text,
    introformat smallint DEFAULT 0 NOT NULL,
    content text,
    contentformat smallint DEFAULT 0 NOT NULL,
    legacyfiles smallint DEFAULT 0 NOT NULL,
    legacyfileslast bigint,
    display smallint DEFAULT 0 NOT NULL,
    displayoptions text,
    revision bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_page; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_page IS 'Each record is one page and its config data';


--
-- Name: mdl_page_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_page_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_page_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_page_id_seq OWNED BY public.mdl_page.id;


--
-- Name: mdl_paygw_paypal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_paygw_paypal (
    id bigint NOT NULL,
    paymentid bigint NOT NULL,
    pp_orderid character varying(255) DEFAULT 'The ID of the order in PayPal'::character varying NOT NULL
);


--
-- Name: TABLE mdl_paygw_paypal; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_paygw_paypal IS 'Stores PayPal related information';


--
-- Name: mdl_paygw_paypal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_paygw_paypal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_paygw_paypal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_paygw_paypal_id_seq OWNED BY public.mdl_paygw_paypal.id;


--
-- Name: mdl_payment_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_payment_accounts (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    idnumber character varying(100),
    contextid bigint NOT NULL,
    enabled smallint DEFAULT 0 NOT NULL,
    archived smallint DEFAULT 0 NOT NULL,
    timecreated bigint,
    timemodified bigint
);


--
-- Name: TABLE mdl_payment_accounts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_payment_accounts IS 'Payment accounts';


--
-- Name: mdl_payment_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_payment_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_payment_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_payment_accounts_id_seq OWNED BY public.mdl_payment_accounts.id;


--
-- Name: mdl_payment_gateways; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_payment_gateways (
    id bigint NOT NULL,
    accountid bigint NOT NULL,
    gateway character varying(100) DEFAULT ''::character varying NOT NULL,
    enabled smallint DEFAULT 1 NOT NULL,
    config text,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_payment_gateways; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_payment_gateways IS 'Configuration for one gateway for one payment account';


--
-- Name: mdl_payment_gateways_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_payment_gateways_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_payment_gateways_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_payment_gateways_id_seq OWNED BY public.mdl_payment_gateways.id;


--
-- Name: mdl_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_payments (
    id bigint NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    paymentarea character varying(50) DEFAULT ''::character varying NOT NULL,
    itemid bigint NOT NULL,
    userid bigint NOT NULL,
    amount character varying(20) DEFAULT ''::character varying NOT NULL,
    currency character varying(3) DEFAULT ''::character varying NOT NULL,
    accountid bigint NOT NULL,
    gateway character varying(100) DEFAULT ''::character varying NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_payments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_payments IS 'Stores information about payments';


--
-- Name: mdl_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_payments_id_seq OWNED BY public.mdl_payments.id;


--
-- Name: mdl_portfolio_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_portfolio_instance (
    id bigint NOT NULL,
    plugin character varying(50) DEFAULT ''::character varying NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    visible smallint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_portfolio_instance; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_portfolio_instance IS 'base table (not including config data) for instances of portfolio plugins.';


--
-- Name: mdl_portfolio_instance_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_portfolio_instance_config (
    id bigint NOT NULL,
    instance bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    value text
);


--
-- Name: TABLE mdl_portfolio_instance_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_portfolio_instance_config IS 'config for portfolio plugin instances';


--
-- Name: mdl_portfolio_instance_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_portfolio_instance_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_portfolio_instance_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_portfolio_instance_config_id_seq OWNED BY public.mdl_portfolio_instance_config.id;


--
-- Name: mdl_portfolio_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_portfolio_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_portfolio_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_portfolio_instance_id_seq OWNED BY public.mdl_portfolio_instance.id;


--
-- Name: mdl_portfolio_instance_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_portfolio_instance_user (
    id bigint NOT NULL,
    instance bigint NOT NULL,
    userid bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    value text
);


--
-- Name: TABLE mdl_portfolio_instance_user; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_portfolio_instance_user IS 'user data for portfolio instances.';


--
-- Name: mdl_portfolio_instance_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_portfolio_instance_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_portfolio_instance_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_portfolio_instance_user_id_seq OWNED BY public.mdl_portfolio_instance_user.id;


--
-- Name: mdl_portfolio_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_portfolio_log (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    "time" bigint NOT NULL,
    portfolio bigint NOT NULL,
    caller_class character varying(150) DEFAULT ''::character varying NOT NULL,
    caller_file character varying(255) DEFAULT ''::character varying NOT NULL,
    caller_component character varying(255),
    caller_sha1 character varying(255) DEFAULT ''::character varying NOT NULL,
    tempdataid bigint DEFAULT 0 NOT NULL,
    returnurl character varying(255) DEFAULT ''::character varying NOT NULL,
    continueurl character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_portfolio_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_portfolio_log IS 'log of portfolio transfers (used to later check for duplicates)';


--
-- Name: mdl_portfolio_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_portfolio_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_portfolio_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_portfolio_log_id_seq OWNED BY public.mdl_portfolio_log.id;


--
-- Name: mdl_portfolio_mahara_queue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_portfolio_mahara_queue (
    id bigint NOT NULL,
    transferid bigint NOT NULL,
    token character varying(50) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_portfolio_mahara_queue; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_portfolio_mahara_queue IS 'maps mahara tokens to transfer ids';


--
-- Name: mdl_portfolio_mahara_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_portfolio_mahara_queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_portfolio_mahara_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_portfolio_mahara_queue_id_seq OWNED BY public.mdl_portfolio_mahara_queue.id;


--
-- Name: mdl_portfolio_tempdata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_portfolio_tempdata (
    id bigint NOT NULL,
    data text,
    expirytime bigint NOT NULL,
    userid bigint NOT NULL,
    instance bigint DEFAULT 0,
    queued smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_portfolio_tempdata; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_portfolio_tempdata IS 'stores temporary data for portfolio exports. the id of this table is used for the itemid for the temporary files area.  cron can clean up stale records (and associated file data) after expirytime.';


--
-- Name: mdl_portfolio_tempdata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_portfolio_tempdata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_portfolio_tempdata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_portfolio_tempdata_id_seq OWNED BY public.mdl_portfolio_tempdata.id;


--
-- Name: mdl_post; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_post (
    id bigint NOT NULL,
    module character varying(20) DEFAULT ''::character varying NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL,
    groupid bigint DEFAULT 0 NOT NULL,
    moduleid bigint DEFAULT 0 NOT NULL,
    coursemoduleid bigint DEFAULT 0 NOT NULL,
    subject character varying(128) DEFAULT ''::character varying NOT NULL,
    summary text,
    content text,
    uniquehash character varying(255) DEFAULT ''::character varying NOT NULL,
    rating bigint DEFAULT 0 NOT NULL,
    format bigint DEFAULT 0 NOT NULL,
    summaryformat smallint DEFAULT 0 NOT NULL,
    attachment character varying(100),
    publishstate character varying(20) DEFAULT 'draft'::character varying NOT NULL,
    lastmodified bigint DEFAULT 0 NOT NULL,
    created bigint DEFAULT 0 NOT NULL,
    usermodified bigint
);


--
-- Name: TABLE mdl_post; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_post IS 'Generic post table to hold data blog entries etc in different modules';


--
-- Name: mdl_post_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_post_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_post_id_seq OWNED BY public.mdl_post.id;


--
-- Name: mdl_profiling; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_profiling (
    id bigint NOT NULL,
    runid character varying(32) DEFAULT ''::character varying NOT NULL,
    url character varying(255) DEFAULT ''::character varying NOT NULL,
    data text NOT NULL,
    totalexecutiontime bigint NOT NULL,
    totalcputime bigint NOT NULL,
    totalcalls bigint NOT NULL,
    totalmemory bigint NOT NULL,
    runreference smallint DEFAULT 0 NOT NULL,
    runcomment character varying(255) DEFAULT ''::character varying NOT NULL,
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_profiling; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_profiling IS 'Stores the results of all the profiling runs';


--
-- Name: mdl_profiling_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_profiling_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_profiling_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_profiling_id_seq OWNED BY public.mdl_profiling.id;


--
-- Name: mdl_qtype_ddimageortext; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_qtype_ddimageortext (
    id bigint NOT NULL,
    questionid bigint DEFAULT 0 NOT NULL,
    shuffleanswers smallint DEFAULT 1 NOT NULL,
    correctfeedback text NOT NULL,
    correctfeedbackformat smallint DEFAULT 0 NOT NULL,
    partiallycorrectfeedback text NOT NULL,
    partiallycorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    incorrectfeedback text NOT NULL,
    incorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    shownumcorrect smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_qtype_ddimageortext; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_qtype_ddimageortext IS 'Defines drag and drop (text or images onto a background image) questions';


--
-- Name: mdl_qtype_ddimageortext_drags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_qtype_ddimageortext_drags (
    id bigint NOT NULL,
    questionid bigint DEFAULT 0 NOT NULL,
    no bigint DEFAULT 0 NOT NULL,
    draggroup bigint DEFAULT 0 NOT NULL,
    infinite smallint DEFAULT 0 NOT NULL,
    label text NOT NULL
);


--
-- Name: TABLE mdl_qtype_ddimageortext_drags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_qtype_ddimageortext_drags IS 'Images to drag. Actual file names are not stored here we use the file names as found in the file storage area.';


--
-- Name: mdl_qtype_ddimageortext_drags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_qtype_ddimageortext_drags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_qtype_ddimageortext_drags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_qtype_ddimageortext_drags_id_seq OWNED BY public.mdl_qtype_ddimageortext_drags.id;


--
-- Name: mdl_qtype_ddimageortext_drops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_qtype_ddimageortext_drops (
    id bigint NOT NULL,
    questionid bigint DEFAULT 0 NOT NULL,
    no bigint DEFAULT 0 NOT NULL,
    xleft bigint DEFAULT 0 NOT NULL,
    ytop bigint DEFAULT 0 NOT NULL,
    choice bigint DEFAULT 0 NOT NULL,
    label text NOT NULL
);


--
-- Name: TABLE mdl_qtype_ddimageortext_drops; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_qtype_ddimageortext_drops IS 'Drop boxes';


--
-- Name: mdl_qtype_ddimageortext_drops_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_qtype_ddimageortext_drops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_qtype_ddimageortext_drops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_qtype_ddimageortext_drops_id_seq OWNED BY public.mdl_qtype_ddimageortext_drops.id;


--
-- Name: mdl_qtype_ddimageortext_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_qtype_ddimageortext_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_qtype_ddimageortext_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_qtype_ddimageortext_id_seq OWNED BY public.mdl_qtype_ddimageortext.id;


--
-- Name: mdl_qtype_ddmarker; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_qtype_ddmarker (
    id bigint NOT NULL,
    questionid bigint DEFAULT 0 NOT NULL,
    shuffleanswers smallint DEFAULT 1 NOT NULL,
    correctfeedback text NOT NULL,
    correctfeedbackformat smallint DEFAULT 0 NOT NULL,
    partiallycorrectfeedback text NOT NULL,
    partiallycorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    incorrectfeedback text NOT NULL,
    incorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    shownumcorrect smallint DEFAULT 0 NOT NULL,
    showmisplaced smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_qtype_ddmarker; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_qtype_ddmarker IS 'Defines drag and drop (text or images onto a background image) questions';


--
-- Name: mdl_qtype_ddmarker_drags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_qtype_ddmarker_drags (
    id bigint NOT NULL,
    questionid bigint DEFAULT 0 NOT NULL,
    no bigint DEFAULT 0 NOT NULL,
    label text NOT NULL,
    infinite smallint DEFAULT 0 NOT NULL,
    noofdrags bigint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_qtype_ddmarker_drags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_qtype_ddmarker_drags IS 'Labels for markers to drag.';


--
-- Name: mdl_qtype_ddmarker_drags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_qtype_ddmarker_drags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_qtype_ddmarker_drags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_qtype_ddmarker_drags_id_seq OWNED BY public.mdl_qtype_ddmarker_drags.id;


--
-- Name: mdl_qtype_ddmarker_drops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_qtype_ddmarker_drops (
    id bigint NOT NULL,
    questionid bigint DEFAULT 0 NOT NULL,
    no bigint DEFAULT 0 NOT NULL,
    shape character varying(255),
    coords text NOT NULL,
    choice bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_qtype_ddmarker_drops; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_qtype_ddmarker_drops IS 'drop regions';


--
-- Name: mdl_qtype_ddmarker_drops_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_qtype_ddmarker_drops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_qtype_ddmarker_drops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_qtype_ddmarker_drops_id_seq OWNED BY public.mdl_qtype_ddmarker_drops.id;


--
-- Name: mdl_qtype_ddmarker_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_qtype_ddmarker_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_qtype_ddmarker_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_qtype_ddmarker_id_seq OWNED BY public.mdl_qtype_ddmarker.id;


--
-- Name: mdl_qtype_essay_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_qtype_essay_options (
    id bigint NOT NULL,
    questionid bigint NOT NULL,
    responseformat character varying(16) DEFAULT 'editor'::character varying NOT NULL,
    responserequired smallint DEFAULT 1 NOT NULL,
    responsefieldlines smallint DEFAULT 15 NOT NULL,
    minwordlimit bigint,
    maxwordlimit bigint,
    attachments smallint DEFAULT 0 NOT NULL,
    attachmentsrequired smallint DEFAULT 0 NOT NULL,
    graderinfo text,
    graderinfoformat smallint DEFAULT 0 NOT NULL,
    responsetemplate text,
    responsetemplateformat smallint DEFAULT 0 NOT NULL,
    maxbytes bigint DEFAULT 0 NOT NULL,
    filetypeslist text
);


--
-- Name: TABLE mdl_qtype_essay_options; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_qtype_essay_options IS 'Extra options for essay questions.';


--
-- Name: mdl_qtype_essay_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_qtype_essay_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_qtype_essay_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_qtype_essay_options_id_seq OWNED BY public.mdl_qtype_essay_options.id;


--
-- Name: mdl_qtype_match_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_qtype_match_options (
    id bigint NOT NULL,
    questionid bigint DEFAULT 0 NOT NULL,
    shuffleanswers smallint DEFAULT 1 NOT NULL,
    correctfeedback text NOT NULL,
    correctfeedbackformat smallint DEFAULT 0 NOT NULL,
    partiallycorrectfeedback text NOT NULL,
    partiallycorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    incorrectfeedback text NOT NULL,
    incorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    shownumcorrect smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_qtype_match_options; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_qtype_match_options IS 'Defines the question-type specific options for matching questions';


--
-- Name: mdl_qtype_match_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_qtype_match_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_qtype_match_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_qtype_match_options_id_seq OWNED BY public.mdl_qtype_match_options.id;


--
-- Name: mdl_qtype_match_subquestions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_qtype_match_subquestions (
    id bigint NOT NULL,
    questionid bigint DEFAULT 0 NOT NULL,
    questiontext text NOT NULL,
    questiontextformat smallint DEFAULT 0 NOT NULL,
    answertext character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_qtype_match_subquestions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_qtype_match_subquestions IS 'The subquestions that make up a matching question';


--
-- Name: mdl_qtype_match_subquestions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_qtype_match_subquestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_qtype_match_subquestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_qtype_match_subquestions_id_seq OWNED BY public.mdl_qtype_match_subquestions.id;


--
-- Name: mdl_qtype_multichoice_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_qtype_multichoice_options (
    id bigint NOT NULL,
    questionid bigint DEFAULT 0 NOT NULL,
    layout smallint DEFAULT 0 NOT NULL,
    single smallint DEFAULT 0 NOT NULL,
    shuffleanswers smallint DEFAULT 1 NOT NULL,
    correctfeedback text NOT NULL,
    correctfeedbackformat smallint DEFAULT 0 NOT NULL,
    partiallycorrectfeedback text NOT NULL,
    partiallycorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    incorrectfeedback text NOT NULL,
    incorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    answernumbering character varying(10) DEFAULT 'abc'::character varying NOT NULL,
    shownumcorrect smallint DEFAULT 0 NOT NULL,
    showstandardinstruction smallint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_qtype_multichoice_options; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_qtype_multichoice_options IS 'Options for multiple choice questions';


--
-- Name: mdl_qtype_multichoice_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_qtype_multichoice_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_qtype_multichoice_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_qtype_multichoice_options_id_seq OWNED BY public.mdl_qtype_multichoice_options.id;


--
-- Name: mdl_qtype_ordering_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_qtype_ordering_options (
    id bigint NOT NULL,
    questionid bigint DEFAULT 0 NOT NULL,
    layouttype smallint DEFAULT 0 NOT NULL,
    selecttype smallint DEFAULT 0 NOT NULL,
    selectcount smallint DEFAULT 2 NOT NULL,
    gradingtype smallint DEFAULT 0 NOT NULL,
    showgrading smallint DEFAULT 0 NOT NULL,
    numberingstyle character varying(10) DEFAULT 'none'::character varying NOT NULL,
    correctfeedback text,
    correctfeedbackformat smallint DEFAULT 0 NOT NULL,
    incorrectfeedback text,
    incorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    partiallycorrectfeedback text,
    partiallycorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    shownumcorrect smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_qtype_ordering_options; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_qtype_ordering_options IS 'Options for ordering questions';


--
-- Name: mdl_qtype_ordering_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_qtype_ordering_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_qtype_ordering_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_qtype_ordering_options_id_seq OWNED BY public.mdl_qtype_ordering_options.id;


--
-- Name: mdl_qtype_randomsamatch_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_qtype_randomsamatch_options (
    id bigint NOT NULL,
    questionid bigint DEFAULT 0 NOT NULL,
    choose bigint DEFAULT 4 NOT NULL,
    subcats smallint DEFAULT 1 NOT NULL,
    correctfeedback text NOT NULL,
    correctfeedbackformat smallint DEFAULT 0 NOT NULL,
    partiallycorrectfeedback text NOT NULL,
    partiallycorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    incorrectfeedback text NOT NULL,
    incorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    shownumcorrect smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_qtype_randomsamatch_options; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_qtype_randomsamatch_options IS 'Info about a random short-answer matching question';


--
-- Name: mdl_qtype_randomsamatch_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_qtype_randomsamatch_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_qtype_randomsamatch_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_qtype_randomsamatch_options_id_seq OWNED BY public.mdl_qtype_randomsamatch_options.id;


--
-- Name: mdl_qtype_shortanswer_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_qtype_shortanswer_options (
    id bigint NOT NULL,
    questionid bigint DEFAULT 0 NOT NULL,
    usecase smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_qtype_shortanswer_options; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_qtype_shortanswer_options IS 'Options for short answer questions';


--
-- Name: mdl_qtype_shortanswer_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_qtype_shortanswer_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_qtype_shortanswer_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_qtype_shortanswer_options_id_seq OWNED BY public.mdl_qtype_shortanswer_options.id;


--
-- Name: mdl_question; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question (
    id bigint NOT NULL,
    parent bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    questiontext text NOT NULL,
    questiontextformat smallint DEFAULT 0 NOT NULL,
    generalfeedback text NOT NULL,
    generalfeedbackformat smallint DEFAULT 0 NOT NULL,
    defaultmark numeric(12,7) DEFAULT 1 NOT NULL,
    penalty numeric(12,7) DEFAULT 0.3333333 NOT NULL,
    qtype character varying(20) DEFAULT ''::character varying NOT NULL,
    length bigint DEFAULT 1 NOT NULL,
    stamp character varying(255) DEFAULT ''::character varying NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    createdby bigint,
    modifiedby bigint
);


--
-- Name: TABLE mdl_question; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question IS 'This table stores the definition of one version of a question.';


--
-- Name: mdl_question_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_answers (
    id bigint NOT NULL,
    question bigint DEFAULT 0 NOT NULL,
    answer text NOT NULL,
    answerformat smallint DEFAULT 0 NOT NULL,
    fraction numeric(12,7) DEFAULT 0 NOT NULL,
    feedback text NOT NULL,
    feedbackformat smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_question_answers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_answers IS 'Answers, with a fractional grade (0-1) and feedback';


--
-- Name: mdl_question_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_answers_id_seq OWNED BY public.mdl_question_answers.id;


--
-- Name: mdl_question_attempt_step_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_attempt_step_data (
    id bigint NOT NULL,
    attemptstepid bigint NOT NULL,
    name character varying(32) DEFAULT ''::character varying NOT NULL,
    value text
);


--
-- Name: TABLE mdl_question_attempt_step_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_attempt_step_data IS 'Each question_attempt_step has an associative array of the data that was submitted by the user in the POST request. It can also contain extra data from the question type or behaviour to avoid re-computation. The convention is that names belonging to ';


--
-- Name: mdl_question_attempt_step_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_attempt_step_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_attempt_step_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_attempt_step_data_id_seq OWNED BY public.mdl_question_attempt_step_data.id;


--
-- Name: mdl_question_attempt_steps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_attempt_steps (
    id bigint NOT NULL,
    questionattemptid bigint NOT NULL,
    sequencenumber bigint NOT NULL,
    state character varying(13) DEFAULT ''::character varying NOT NULL,
    fraction numeric(12,7),
    timecreated bigint NOT NULL,
    userid bigint
);


--
-- Name: TABLE mdl_question_attempt_steps; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_attempt_steps IS 'Stores one step in in a question attempt. As well as the data here, the step will have some data in the question_attempt_step_data table.';


--
-- Name: mdl_question_attempt_steps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_attempt_steps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_attempt_steps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_attempt_steps_id_seq OWNED BY public.mdl_question_attempt_steps.id;


--
-- Name: mdl_question_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_attempts (
    id bigint NOT NULL,
    questionusageid bigint NOT NULL,
    slot bigint NOT NULL,
    behaviour character varying(32) DEFAULT ''::character varying NOT NULL,
    questionid bigint NOT NULL,
    variant bigint DEFAULT 1 NOT NULL,
    maxmark numeric(12,7) NOT NULL,
    minfraction numeric(12,7) NOT NULL,
    maxfraction numeric(12,7) DEFAULT 1 NOT NULL,
    flagged smallint DEFAULT 0 NOT NULL,
    questionsummary text,
    rightanswer text,
    responsesummary text,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_question_attempts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_attempts IS 'Each row here corresponds to an attempt at one question, as part of a question_usage. A question_attempt will have some question_attempt_steps';


--
-- Name: mdl_question_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_attempts_id_seq OWNED BY public.mdl_question_attempts.id;


--
-- Name: mdl_question_bank_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_bank_entries (
    id bigint NOT NULL,
    questioncategoryid bigint DEFAULT 0 NOT NULL,
    idnumber character varying(100),
    ownerid bigint
);


--
-- Name: TABLE mdl_question_bank_entries; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_bank_entries IS 'Each question bank entry. This table has one row for each question that appears in the question bank.';


--
-- Name: mdl_question_bank_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_bank_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_bank_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_bank_entries_id_seq OWNED BY public.mdl_question_bank_entries.id;


--
-- Name: mdl_question_calculated; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_calculated (
    id bigint NOT NULL,
    question bigint DEFAULT 0 NOT NULL,
    answer bigint DEFAULT 0 NOT NULL,
    tolerance character varying(20) DEFAULT '0.0'::character varying NOT NULL,
    tolerancetype bigint DEFAULT 1 NOT NULL,
    correctanswerlength bigint DEFAULT 2 NOT NULL,
    correctanswerformat bigint DEFAULT 2 NOT NULL
);


--
-- Name: TABLE mdl_question_calculated; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_calculated IS 'Options for questions of type calculated';


--
-- Name: mdl_question_calculated_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_calculated_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_calculated_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_calculated_id_seq OWNED BY public.mdl_question_calculated.id;


--
-- Name: mdl_question_calculated_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_calculated_options (
    id bigint NOT NULL,
    question bigint DEFAULT 0 NOT NULL,
    synchronize smallint DEFAULT 0 NOT NULL,
    single smallint DEFAULT 0 NOT NULL,
    shuffleanswers smallint DEFAULT 0 NOT NULL,
    correctfeedback text,
    correctfeedbackformat smallint DEFAULT 0 NOT NULL,
    partiallycorrectfeedback text,
    partiallycorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    incorrectfeedback text,
    incorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    answernumbering character varying(10) DEFAULT 'abc'::character varying NOT NULL,
    shownumcorrect smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_question_calculated_options; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_calculated_options IS 'Options for questions of type calculated';


--
-- Name: mdl_question_calculated_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_calculated_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_calculated_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_calculated_options_id_seq OWNED BY public.mdl_question_calculated_options.id;


--
-- Name: mdl_question_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_categories (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    contextid bigint DEFAULT 0 NOT NULL,
    info text NOT NULL,
    infoformat smallint DEFAULT 0 NOT NULL,
    stamp character varying(255) DEFAULT ''::character varying NOT NULL,
    parent bigint DEFAULT 0 NOT NULL,
    sortorder bigint DEFAULT 999 NOT NULL,
    idnumber character varying(100)
);


--
-- Name: TABLE mdl_question_categories; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_categories IS 'Categories are for grouping questions';


--
-- Name: mdl_question_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_categories_id_seq OWNED BY public.mdl_question_categories.id;


--
-- Name: mdl_question_dataset_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_dataset_definitions (
    id bigint NOT NULL,
    category bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    type bigint DEFAULT 0 NOT NULL,
    options character varying(255) DEFAULT ''::character varying NOT NULL,
    itemcount bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_question_dataset_definitions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_dataset_definitions IS 'Organises and stores properties for dataset items';


--
-- Name: mdl_question_dataset_definitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_dataset_definitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_dataset_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_dataset_definitions_id_seq OWNED BY public.mdl_question_dataset_definitions.id;


--
-- Name: mdl_question_dataset_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_dataset_items (
    id bigint NOT NULL,
    definition bigint DEFAULT 0 NOT NULL,
    itemnumber bigint DEFAULT 0 NOT NULL,
    value character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_question_dataset_items; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_dataset_items IS 'Individual dataset items';


--
-- Name: mdl_question_dataset_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_dataset_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_dataset_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_dataset_items_id_seq OWNED BY public.mdl_question_dataset_items.id;


--
-- Name: mdl_question_datasets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_datasets (
    id bigint NOT NULL,
    question bigint DEFAULT 0 NOT NULL,
    datasetdefinition bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_question_datasets; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_datasets IS 'Many-many relation between questions and dataset definitions';


--
-- Name: mdl_question_datasets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_datasets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_datasets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_datasets_id_seq OWNED BY public.mdl_question_datasets.id;


--
-- Name: mdl_question_ddwtos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_ddwtos (
    id bigint NOT NULL,
    questionid bigint DEFAULT 0 NOT NULL,
    shuffleanswers smallint DEFAULT 1 NOT NULL,
    correctfeedback text NOT NULL,
    correctfeedbackformat smallint DEFAULT 0 NOT NULL,
    partiallycorrectfeedback text NOT NULL,
    partiallycorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    incorrectfeedback text NOT NULL,
    incorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    shownumcorrect smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_question_ddwtos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_ddwtos IS 'Defines drag and drop (words into sentences) questions';


--
-- Name: mdl_question_ddwtos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_ddwtos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_ddwtos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_ddwtos_id_seq OWNED BY public.mdl_question_ddwtos.id;


--
-- Name: mdl_question_gapselect; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_gapselect (
    id bigint NOT NULL,
    questionid bigint DEFAULT 0 NOT NULL,
    shuffleanswers smallint DEFAULT 1 NOT NULL,
    correctfeedback text NOT NULL,
    correctfeedbackformat smallint DEFAULT 0 NOT NULL,
    partiallycorrectfeedback text NOT NULL,
    partiallycorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    incorrectfeedback text NOT NULL,
    incorrectfeedbackformat smallint DEFAULT 0 NOT NULL,
    shownumcorrect smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_question_gapselect; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_gapselect IS 'Defines select missing words questions';


--
-- Name: mdl_question_gapselect_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_gapselect_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_gapselect_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_gapselect_id_seq OWNED BY public.mdl_question_gapselect.id;


--
-- Name: mdl_question_hints; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_hints (
    id bigint NOT NULL,
    questionid bigint NOT NULL,
    hint text NOT NULL,
    hintformat smallint DEFAULT 0 NOT NULL,
    shownumcorrect smallint,
    clearwrong smallint,
    options character varying(255)
);


--
-- Name: TABLE mdl_question_hints; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_hints IS 'Stores the the part of the question definition that gives different feedback after each try in interactive and similar behaviours.';


--
-- Name: mdl_question_hints_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_hints_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_hints_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_hints_id_seq OWNED BY public.mdl_question_hints.id;


--
-- Name: mdl_question_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_id_seq OWNED BY public.mdl_question.id;


--
-- Name: mdl_question_multianswer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_multianswer (
    id bigint NOT NULL,
    question bigint DEFAULT 0 NOT NULL,
    sequence text NOT NULL
);


--
-- Name: TABLE mdl_question_multianswer; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_multianswer IS 'Options for multianswer questions';


--
-- Name: mdl_question_multianswer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_multianswer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_multianswer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_multianswer_id_seq OWNED BY public.mdl_question_multianswer.id;


--
-- Name: mdl_question_numerical; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_numerical (
    id bigint NOT NULL,
    question bigint DEFAULT 0 NOT NULL,
    answer bigint DEFAULT 0 NOT NULL,
    tolerance character varying(255) DEFAULT '0.0'::character varying NOT NULL
);


--
-- Name: TABLE mdl_question_numerical; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_numerical IS 'Options for numerical questions.';


--
-- Name: mdl_question_numerical_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_numerical_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_numerical_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_numerical_id_seq OWNED BY public.mdl_question_numerical.id;


--
-- Name: mdl_question_numerical_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_numerical_options (
    id bigint NOT NULL,
    question bigint DEFAULT 0 NOT NULL,
    showunits smallint DEFAULT 0 NOT NULL,
    unitsleft smallint DEFAULT 0 NOT NULL,
    unitgradingtype smallint DEFAULT 0 NOT NULL,
    unitpenalty numeric(12,7) DEFAULT 0.1 NOT NULL
);


--
-- Name: TABLE mdl_question_numerical_options; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_numerical_options IS 'Options for questions of type numerical This table is also used by the calculated question type';


--
-- Name: mdl_question_numerical_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_numerical_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_numerical_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_numerical_options_id_seq OWNED BY public.mdl_question_numerical_options.id;


--
-- Name: mdl_question_numerical_units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_numerical_units (
    id bigint NOT NULL,
    question bigint DEFAULT 0 NOT NULL,
    multiplier numeric(38,19) DEFAULT 1.00000000000000000000 NOT NULL,
    unit character varying(50) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_question_numerical_units; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_numerical_units IS 'Optional unit options for numerical questions. This table is also used by the calculated question type.';


--
-- Name: mdl_question_numerical_units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_numerical_units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_numerical_units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_numerical_units_id_seq OWNED BY public.mdl_question_numerical_units.id;


--
-- Name: mdl_question_references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_references (
    id bigint NOT NULL,
    usingcontextid bigint DEFAULT 0 NOT NULL,
    component character varying(100),
    questionarea character varying(50),
    itemid bigint,
    questionbankentryid bigint DEFAULT 0 NOT NULL,
    version bigint
);


--
-- Name: TABLE mdl_question_references; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_references IS 'Records where a specific question is used.';


--
-- Name: mdl_question_references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_references_id_seq OWNED BY public.mdl_question_references.id;


--
-- Name: mdl_question_response_analysis; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_response_analysis (
    id bigint NOT NULL,
    hashcode character varying(40) DEFAULT ''::character varying NOT NULL,
    whichtries character varying(255) DEFAULT ''::character varying NOT NULL,
    timemodified bigint NOT NULL,
    questionid bigint NOT NULL,
    variant bigint,
    subqid character varying(100) DEFAULT ''::character varying NOT NULL,
    aid character varying(100),
    response text,
    credit numeric(15,5) NOT NULL
);


--
-- Name: TABLE mdl_question_response_analysis; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_response_analysis IS 'Analysis of student responses given to questions.';


--
-- Name: mdl_question_response_analysis_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_response_analysis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_response_analysis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_response_analysis_id_seq OWNED BY public.mdl_question_response_analysis.id;


--
-- Name: mdl_question_response_count; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_response_count (
    id bigint NOT NULL,
    analysisid bigint NOT NULL,
    try bigint NOT NULL,
    rcount bigint NOT NULL
);


--
-- Name: TABLE mdl_question_response_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_response_count IS 'Count for each responses for each try at a question.';


--
-- Name: mdl_question_response_count_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_response_count_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_response_count_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_response_count_id_seq OWNED BY public.mdl_question_response_count.id;


--
-- Name: mdl_question_set_references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_set_references (
    id bigint NOT NULL,
    usingcontextid bigint DEFAULT 0 NOT NULL,
    component character varying(100),
    questionarea character varying(50),
    itemid bigint,
    questionscontextid bigint DEFAULT 0 NOT NULL,
    filtercondition text
);


--
-- Name: TABLE mdl_question_set_references; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_set_references IS 'Records where groups of questions are used.';


--
-- Name: mdl_question_set_references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_set_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_set_references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_set_references_id_seq OWNED BY public.mdl_question_set_references.id;


--
-- Name: mdl_question_statistics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_statistics (
    id bigint NOT NULL,
    hashcode character varying(40) DEFAULT ''::character varying NOT NULL,
    timemodified bigint NOT NULL,
    questionid bigint NOT NULL,
    slot bigint,
    subquestion smallint NOT NULL,
    variant bigint,
    s bigint DEFAULT 0 NOT NULL,
    effectiveweight numeric(15,5),
    negcovar smallint DEFAULT 0 NOT NULL,
    discriminationindex numeric(15,5),
    discriminativeefficiency numeric(15,5),
    sd numeric(15,10),
    facility numeric(15,10),
    subquestions text,
    maxmark numeric(12,7),
    positions text,
    randomguessscore numeric(12,7)
);


--
-- Name: TABLE mdl_question_statistics; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_statistics IS 'Statistics for individual questions used in an activity.';


--
-- Name: mdl_question_statistics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_statistics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_statistics_id_seq OWNED BY public.mdl_question_statistics.id;


--
-- Name: mdl_question_truefalse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_truefalse (
    id bigint NOT NULL,
    question bigint DEFAULT 0 NOT NULL,
    trueanswer bigint DEFAULT 0 NOT NULL,
    falseanswer bigint DEFAULT 0 NOT NULL,
    showstandardinstruction smallint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_question_truefalse; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_truefalse IS 'Options for True-False questions';


--
-- Name: mdl_question_truefalse_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_truefalse_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_truefalse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_truefalse_id_seq OWNED BY public.mdl_question_truefalse.id;


--
-- Name: mdl_question_usages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_usages (
    id bigint NOT NULL,
    contextid bigint NOT NULL,
    component character varying(255) DEFAULT ''::character varying NOT NULL,
    preferredbehaviour character varying(32) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_question_usages; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_usages IS 'This table''s main purpose it to assign a unique id to each attempt at a set of questions by some part of Moodle. A question usage is made up of a number of question_attempts.';


--
-- Name: mdl_question_usages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_usages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_usages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_usages_id_seq OWNED BY public.mdl_question_usages.id;


--
-- Name: mdl_question_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_question_versions (
    id bigint NOT NULL,
    questionbankentryid bigint DEFAULT 0 NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    questionid bigint DEFAULT 0 NOT NULL,
    status character varying(10) DEFAULT 'ready'::character varying NOT NULL
);


--
-- Name: TABLE mdl_question_versions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_question_versions IS 'A join table linking the different question version definitions in the question table to the question_bank_entires.';


--
-- Name: mdl_question_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_question_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_question_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_question_versions_id_seq OWNED BY public.mdl_question_versions.id;


--
-- Name: mdl_quiz; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_quiz (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text NOT NULL,
    introformat smallint DEFAULT 0 NOT NULL,
    timeopen bigint DEFAULT 0 NOT NULL,
    timeclose bigint DEFAULT 0 NOT NULL,
    timelimit bigint DEFAULT 0 NOT NULL,
    overduehandling character varying(16) DEFAULT 'autoabandon'::character varying NOT NULL,
    graceperiod bigint DEFAULT 0 NOT NULL,
    preferredbehaviour character varying(32) DEFAULT ''::character varying NOT NULL,
    canredoquestions smallint DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    attemptonlast smallint DEFAULT 0 NOT NULL,
    grademethod smallint DEFAULT 1 NOT NULL,
    decimalpoints smallint DEFAULT 2 NOT NULL,
    questiondecimalpoints smallint DEFAULT '-1'::integer NOT NULL,
    reviewattempt integer DEFAULT 0 NOT NULL,
    reviewcorrectness integer DEFAULT 0 NOT NULL,
    reviewmaxmarks integer DEFAULT 0 NOT NULL,
    reviewmarks integer DEFAULT 0 NOT NULL,
    reviewspecificfeedback integer DEFAULT 0 NOT NULL,
    reviewgeneralfeedback integer DEFAULT 0 NOT NULL,
    reviewrightanswer integer DEFAULT 0 NOT NULL,
    reviewoverallfeedback integer DEFAULT 0 NOT NULL,
    questionsperpage bigint DEFAULT 0 NOT NULL,
    navmethod character varying(16) DEFAULT 'free'::character varying NOT NULL,
    shuffleanswers smallint DEFAULT 0 NOT NULL,
    sumgrades numeric(10,5) DEFAULT 0 NOT NULL,
    grade numeric(10,5) DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    password character varying(255) DEFAULT ''::character varying NOT NULL,
    subnet character varying(255) DEFAULT ''::character varying NOT NULL,
    browsersecurity character varying(32) DEFAULT ''::character varying NOT NULL,
    delay1 bigint DEFAULT 0 NOT NULL,
    delay2 bigint DEFAULT 0 NOT NULL,
    showuserpicture smallint DEFAULT 0 NOT NULL,
    showblocks smallint DEFAULT 0 NOT NULL,
    completionattemptsexhausted smallint DEFAULT 0,
    completionminattempts bigint DEFAULT 0 NOT NULL,
    allowofflineattempts smallint DEFAULT 0
);


--
-- Name: TABLE mdl_quiz; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_quiz IS 'The settings for each quiz.';


--
-- Name: mdl_quiz_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_quiz_attempts (
    id bigint NOT NULL,
    quiz bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    attempt integer DEFAULT 0 NOT NULL,
    uniqueid bigint DEFAULT 0 NOT NULL,
    layout text NOT NULL,
    currentpage bigint DEFAULT 0 NOT NULL,
    preview smallint DEFAULT 0 NOT NULL,
    state character varying(16) DEFAULT 'inprogress'::character varying NOT NULL,
    timestart bigint DEFAULT 0 NOT NULL,
    timefinish bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    timemodifiedoffline bigint DEFAULT 0 NOT NULL,
    timecheckstate bigint DEFAULT 0,
    sumgrades numeric(10,5),
    gradednotificationsenttime bigint
);


--
-- Name: TABLE mdl_quiz_attempts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_quiz_attempts IS 'Stores users attempts at quizzes.';


--
-- Name: mdl_quiz_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_quiz_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_quiz_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_quiz_attempts_id_seq OWNED BY public.mdl_quiz_attempts.id;


--
-- Name: mdl_quiz_feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_quiz_feedback (
    id bigint NOT NULL,
    quizid bigint DEFAULT 0 NOT NULL,
    feedbacktext text NOT NULL,
    feedbacktextformat smallint DEFAULT 0 NOT NULL,
    mingrade numeric(10,5) DEFAULT 0 NOT NULL,
    maxgrade numeric(10,5) DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_quiz_feedback; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_quiz_feedback IS 'Feedback given to students based on which grade band their overall score lies.';


--
-- Name: mdl_quiz_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_quiz_feedback_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_quiz_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_quiz_feedback_id_seq OWNED BY public.mdl_quiz_feedback.id;


--
-- Name: mdl_quiz_grade_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_quiz_grade_items (
    id bigint NOT NULL,
    quizid bigint NOT NULL,
    sortorder bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_quiz_grade_items; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_quiz_grade_items IS 'Where a quiz supports mulitple grades, this table stores what those grade items are.';


--
-- Name: mdl_quiz_grade_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_quiz_grade_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_quiz_grade_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_quiz_grade_items_id_seq OWNED BY public.mdl_quiz_grade_items.id;


--
-- Name: mdl_quiz_grades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_quiz_grades (
    id bigint NOT NULL,
    quiz bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    grade numeric(10,5) DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_quiz_grades; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_quiz_grades IS 'Stores the overall grade for each user on the quiz, based on their various attempts and the quiz.grademethod setting.';


--
-- Name: mdl_quiz_grades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_quiz_grades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_quiz_grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_quiz_grades_id_seq OWNED BY public.mdl_quiz_grades.id;


--
-- Name: mdl_quiz_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_quiz_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_quiz_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_quiz_id_seq OWNED BY public.mdl_quiz.id;


--
-- Name: mdl_quiz_overrides; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_quiz_overrides (
    id bigint NOT NULL,
    quiz bigint DEFAULT 0 NOT NULL,
    groupid bigint,
    userid bigint,
    timeopen bigint,
    timeclose bigint,
    timelimit bigint,
    attempts integer,
    password character varying(255)
);


--
-- Name: TABLE mdl_quiz_overrides; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_quiz_overrides IS 'The overrides to quiz settings on a per-user and per-group basis.';


--
-- Name: mdl_quiz_overrides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_quiz_overrides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_quiz_overrides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_quiz_overrides_id_seq OWNED BY public.mdl_quiz_overrides.id;


--
-- Name: mdl_quiz_overview_regrades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_quiz_overview_regrades (
    id bigint NOT NULL,
    questionusageid bigint NOT NULL,
    slot bigint NOT NULL,
    newfraction numeric(12,7),
    oldfraction numeric(12,7),
    regraded smallint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_quiz_overview_regrades; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_quiz_overview_regrades IS 'This table records which question attempts need regrading and the grade they will be regraded to.';


--
-- Name: mdl_quiz_overview_regrades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_quiz_overview_regrades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_quiz_overview_regrades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_quiz_overview_regrades_id_seq OWNED BY public.mdl_quiz_overview_regrades.id;


--
-- Name: mdl_quiz_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_quiz_reports (
    id bigint NOT NULL,
    name character varying(255),
    displayorder bigint NOT NULL,
    capability character varying(255)
);


--
-- Name: TABLE mdl_quiz_reports; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_quiz_reports IS 'Lists all the installed quiz reports and their display order and so on. No need to worry about deleting old records. Only records with an equivalent directory are displayed.';


--
-- Name: mdl_quiz_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_quiz_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_quiz_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_quiz_reports_id_seq OWNED BY public.mdl_quiz_reports.id;


--
-- Name: mdl_quiz_sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_quiz_sections (
    id bigint NOT NULL,
    quizid bigint NOT NULL,
    firstslot bigint NOT NULL,
    heading character varying(1333),
    shufflequestions smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_quiz_sections; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_quiz_sections IS 'Stores sections of a quiz with section name (heading), from slot-number N and whether the question order should be shuffled.';


--
-- Name: mdl_quiz_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_quiz_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_quiz_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_quiz_sections_id_seq OWNED BY public.mdl_quiz_sections.id;


--
-- Name: mdl_quiz_slots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_quiz_slots (
    id bigint NOT NULL,
    slot bigint NOT NULL,
    quizid bigint DEFAULT 0 NOT NULL,
    page bigint NOT NULL,
    displaynumber character varying(16),
    requireprevious smallint DEFAULT 0 NOT NULL,
    maxmark numeric(12,7) DEFAULT 0 NOT NULL,
    quizgradeitemid bigint
);


--
-- Name: TABLE mdl_quiz_slots; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_quiz_slots IS 'Stores the question used in a quiz, with the order, and for each question, which page it appears on, and the maximum mark (weight).';


--
-- Name: mdl_quiz_slots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_quiz_slots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_quiz_slots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_quiz_slots_id_seq OWNED BY public.mdl_quiz_slots.id;


--
-- Name: mdl_quiz_statistics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_quiz_statistics (
    id bigint NOT NULL,
    hashcode character varying(40) DEFAULT ''::character varying NOT NULL,
    whichattempts smallint NOT NULL,
    timemodified bigint NOT NULL,
    firstattemptscount bigint NOT NULL,
    highestattemptscount bigint NOT NULL,
    lastattemptscount bigint NOT NULL,
    allattemptscount bigint NOT NULL,
    firstattemptsavg numeric(15,5),
    highestattemptsavg numeric(15,5),
    lastattemptsavg numeric(15,5),
    allattemptsavg numeric(15,5),
    median numeric(15,5),
    standarddeviation numeric(15,5),
    skewness numeric(15,10),
    kurtosis numeric(15,5),
    cic numeric(15,10),
    errorratio numeric(15,10),
    standarderror numeric(15,10)
);


--
-- Name: TABLE mdl_quiz_statistics; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_quiz_statistics IS 'table to cache results from analysis done in statistics report for quizzes.';


--
-- Name: mdl_quiz_statistics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_quiz_statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_quiz_statistics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_quiz_statistics_id_seq OWNED BY public.mdl_quiz_statistics.id;


--
-- Name: mdl_quizaccess_seb_quizsettings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_quizaccess_seb_quizsettings (
    id bigint NOT NULL,
    quizid bigint NOT NULL,
    cmid bigint NOT NULL,
    templateid bigint NOT NULL,
    requiresafeexambrowser smallint NOT NULL,
    showsebtaskbar smallint,
    showwificontrol smallint,
    showreloadbutton smallint,
    showtime smallint,
    showkeyboardlayout smallint,
    allowuserquitseb smallint,
    quitpassword text,
    linkquitseb text,
    userconfirmquit smallint,
    enableaudiocontrol smallint,
    muteonstartup smallint,
    allowcapturecamera smallint,
    allowcapturemicrophone smallint,
    allowspellchecking smallint,
    allowreloadinexam smallint,
    activateurlfiltering smallint,
    filterembeddedcontent smallint,
    expressionsallowed text,
    regexallowed text,
    expressionsblocked text,
    regexblocked text,
    allowedbrowserexamkeys text,
    showsebdownloadlink smallint,
    usermodified bigint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_quizaccess_seb_quizsettings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_quizaccess_seb_quizsettings IS 'Stores the quiz level Safe Exam Browser configuration.';


--
-- Name: mdl_quizaccess_seb_quizsettings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_quizaccess_seb_quizsettings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_quizaccess_seb_quizsettings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_quizaccess_seb_quizsettings_id_seq OWNED BY public.mdl_quizaccess_seb_quizsettings.id;


--
-- Name: mdl_quizaccess_seb_template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_quizaccess_seb_template (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    description text NOT NULL,
    content text NOT NULL,
    enabled smallint NOT NULL,
    sortorder bigint NOT NULL,
    usermodified bigint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_quizaccess_seb_template; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_quizaccess_seb_template IS 'Templates for Safe Exam Browser configuration.';


--
-- Name: mdl_quizaccess_seb_template_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_quizaccess_seb_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_quizaccess_seb_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_quizaccess_seb_template_id_seq OWNED BY public.mdl_quizaccess_seb_template.id;


--
-- Name: mdl_rating; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_rating (
    id bigint NOT NULL,
    contextid bigint NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    ratingarea character varying(50) DEFAULT ''::character varying NOT NULL,
    itemid bigint NOT NULL,
    scaleid bigint NOT NULL,
    rating bigint NOT NULL,
    userid bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_rating; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_rating IS 'moodle ratings';


--
-- Name: mdl_rating_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_rating_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_rating_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_rating_id_seq OWNED BY public.mdl_rating.id;


--
-- Name: mdl_registration_hubs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_registration_hubs (
    id bigint NOT NULL,
    token character varying(255) DEFAULT ''::character varying NOT NULL,
    hubname character varying(255) DEFAULT ''::character varying NOT NULL,
    huburl character varying(255) DEFAULT ''::character varying NOT NULL,
    confirmed smallint DEFAULT 0 NOT NULL,
    secret character varying(255),
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_registration_hubs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_registration_hubs IS 'hub where the site is registered on with their associated token';


--
-- Name: mdl_registration_hubs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_registration_hubs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_registration_hubs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_registration_hubs_id_seq OWNED BY public.mdl_registration_hubs.id;


--
-- Name: mdl_reportbuilder_audience; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_reportbuilder_audience (
    id bigint NOT NULL,
    reportid bigint NOT NULL,
    heading character varying(255),
    classname character varying(255) DEFAULT ''::character varying NOT NULL,
    configdata text NOT NULL,
    usercreated bigint DEFAULT 0 NOT NULL,
    usermodified bigint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_reportbuilder_audience; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_reportbuilder_audience IS 'Defines report audience';


--
-- Name: mdl_reportbuilder_audience_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_reportbuilder_audience_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_reportbuilder_audience_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_reportbuilder_audience_id_seq OWNED BY public.mdl_reportbuilder_audience.id;


--
-- Name: mdl_reportbuilder_column; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_reportbuilder_column (
    id bigint NOT NULL,
    reportid bigint DEFAULT 0 NOT NULL,
    uniqueidentifier character varying(255) DEFAULT ''::character varying NOT NULL,
    aggregation character varying(32),
    heading character varying(255),
    columnorder bigint NOT NULL,
    sortenabled smallint DEFAULT 0 NOT NULL,
    sortdirection smallint NOT NULL,
    sortorder bigint,
    usercreated bigint DEFAULT 0 NOT NULL,
    usermodified bigint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_reportbuilder_column; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_reportbuilder_column IS 'Table to represent a report column';


--
-- Name: mdl_reportbuilder_column_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_reportbuilder_column_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_reportbuilder_column_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_reportbuilder_column_id_seq OWNED BY public.mdl_reportbuilder_column.id;


--
-- Name: mdl_reportbuilder_filter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_reportbuilder_filter (
    id bigint NOT NULL,
    reportid bigint DEFAULT 0 NOT NULL,
    uniqueidentifier character varying(255) DEFAULT ''::character varying NOT NULL,
    heading character varying(255),
    iscondition smallint DEFAULT 0 NOT NULL,
    filterorder bigint NOT NULL,
    usercreated bigint DEFAULT 0 NOT NULL,
    usermodified bigint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_reportbuilder_filter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_reportbuilder_filter IS 'Table to represent a report filter/condition';


--
-- Name: mdl_reportbuilder_filter_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_reportbuilder_filter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_reportbuilder_filter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_reportbuilder_filter_id_seq OWNED BY public.mdl_reportbuilder_filter.id;


--
-- Name: mdl_reportbuilder_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_reportbuilder_report (
    id bigint NOT NULL,
    name character varying(255),
    source character varying(255) DEFAULT ''::character varying NOT NULL,
    type smallint DEFAULT 0 NOT NULL,
    uniquerows smallint DEFAULT 0 NOT NULL,
    conditiondata text,
    settingsdata text,
    contextid bigint NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    area character varying(100) DEFAULT ''::character varying NOT NULL,
    itemid bigint DEFAULT 0 NOT NULL,
    usercreated bigint DEFAULT 0 NOT NULL,
    usermodified bigint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_reportbuilder_report; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_reportbuilder_report IS 'Table to represent a report';


--
-- Name: mdl_reportbuilder_report_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_reportbuilder_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_reportbuilder_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_reportbuilder_report_id_seq OWNED BY public.mdl_reportbuilder_report.id;


--
-- Name: mdl_reportbuilder_schedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_reportbuilder_schedule (
    id bigint NOT NULL,
    reportid bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    enabled smallint DEFAULT 1 NOT NULL,
    audiences text NOT NULL,
    format character varying(255) DEFAULT ''::character varying NOT NULL,
    subject character varying(255) DEFAULT ''::character varying NOT NULL,
    message text NOT NULL,
    messageformat bigint NOT NULL,
    userviewas bigint DEFAULT 0 NOT NULL,
    timescheduled bigint DEFAULT 0 NOT NULL,
    recurrence bigint DEFAULT 0 NOT NULL,
    reportempty bigint DEFAULT 0 NOT NULL,
    timelastsent bigint DEFAULT 0 NOT NULL,
    timenextsend bigint DEFAULT 0 NOT NULL,
    usercreated bigint DEFAULT 0 NOT NULL,
    usermodified bigint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_reportbuilder_schedule; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_reportbuilder_schedule IS 'Table to represent a report schedule';


--
-- Name: mdl_reportbuilder_schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_reportbuilder_schedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_reportbuilder_schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_reportbuilder_schedule_id_seq OWNED BY public.mdl_reportbuilder_schedule.id;


--
-- Name: mdl_repository; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_repository (
    id bigint NOT NULL,
    type character varying(255) DEFAULT ''::character varying NOT NULL,
    visible smallint DEFAULT 1,
    sortorder bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_repository; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_repository IS 'This table contains one entry for every configured external repository instance.';


--
-- Name: mdl_repository_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_repository_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_repository_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_repository_id_seq OWNED BY public.mdl_repository.id;


--
-- Name: mdl_repository_instance_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_repository_instance_config (
    id bigint NOT NULL,
    instanceid bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    value text
);


--
-- Name: TABLE mdl_repository_instance_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_repository_instance_config IS 'The config for intances';


--
-- Name: mdl_repository_instance_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_repository_instance_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_repository_instance_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_repository_instance_config_id_seq OWNED BY public.mdl_repository_instance_config.id;


--
-- Name: mdl_repository_instances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_repository_instances (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    typeid bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    contextid bigint NOT NULL,
    username character varying(255),
    password character varying(255),
    timecreated bigint,
    timemodified bigint,
    readonly smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_repository_instances; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_repository_instances IS 'This table contains one entry for every configured external repository instance.';


--
-- Name: mdl_repository_instances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_repository_instances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_repository_instances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_repository_instances_id_seq OWNED BY public.mdl_repository_instances.id;


--
-- Name: mdl_repository_onedrive_access; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_repository_onedrive_access (
    id bigint NOT NULL,
    timemodified bigint NOT NULL,
    timecreated bigint NOT NULL,
    usermodified bigint NOT NULL,
    permissionid character varying(255) DEFAULT ''::character varying NOT NULL,
    itemid character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_repository_onedrive_access; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_repository_onedrive_access IS 'List of temporary access grants.';


--
-- Name: mdl_repository_onedrive_access_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_repository_onedrive_access_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_repository_onedrive_access_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_repository_onedrive_access_id_seq OWNED BY public.mdl_repository_onedrive_access.id;


--
-- Name: mdl_resource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_resource (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text,
    introformat smallint DEFAULT 0 NOT NULL,
    tobemigrated smallint DEFAULT 0 NOT NULL,
    legacyfiles smallint DEFAULT 0 NOT NULL,
    legacyfileslast bigint,
    display smallint DEFAULT 0 NOT NULL,
    displayoptions text,
    filterfiles smallint DEFAULT 0 NOT NULL,
    revision bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_resource; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_resource IS 'Each record is one resource and its config data';


--
-- Name: mdl_resource_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_resource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_resource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_resource_id_seq OWNED BY public.mdl_resource.id;


--
-- Name: mdl_resource_old; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_resource_old (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    type character varying(30) DEFAULT ''::character varying NOT NULL,
    reference character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text,
    introformat smallint DEFAULT 0 NOT NULL,
    alltext text NOT NULL,
    popup text NOT NULL,
    options character varying(255) DEFAULT ''::character varying NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    oldid bigint NOT NULL,
    cmid bigint,
    newmodule character varying(50),
    newid bigint,
    migrated bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_resource_old; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_resource_old IS 'backup of all old resource instances from 1.9';


--
-- Name: mdl_resource_old_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_resource_old_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_resource_old_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_resource_old_id_seq OWNED BY public.mdl_resource_old.id;


--
-- Name: mdl_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_role (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    shortname character varying(100) DEFAULT ''::character varying NOT NULL,
    description text NOT NULL,
    sortorder bigint DEFAULT 0 NOT NULL,
    archetype character varying(30) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_role; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_role IS 'moodle roles';


--
-- Name: mdl_role_allow_assign; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_role_allow_assign (
    id bigint NOT NULL,
    roleid bigint DEFAULT 0 NOT NULL,
    allowassign bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_role_allow_assign; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_role_allow_assign IS 'this defines what role can assign what role';


--
-- Name: mdl_role_allow_assign_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_role_allow_assign_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_role_allow_assign_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_role_allow_assign_id_seq OWNED BY public.mdl_role_allow_assign.id;


--
-- Name: mdl_role_allow_override; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_role_allow_override (
    id bigint NOT NULL,
    roleid bigint DEFAULT 0 NOT NULL,
    allowoverride bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_role_allow_override; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_role_allow_override IS 'this defines what role can override what role';


--
-- Name: mdl_role_allow_override_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_role_allow_override_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_role_allow_override_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_role_allow_override_id_seq OWNED BY public.mdl_role_allow_override.id;


--
-- Name: mdl_role_allow_switch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_role_allow_switch (
    id bigint NOT NULL,
    roleid bigint NOT NULL,
    allowswitch bigint NOT NULL
);


--
-- Name: TABLE mdl_role_allow_switch; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_role_allow_switch IS 'This table stores which which other roles a user is allowed to switch to if they have one role.';


--
-- Name: mdl_role_allow_switch_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_role_allow_switch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_role_allow_switch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_role_allow_switch_id_seq OWNED BY public.mdl_role_allow_switch.id;


--
-- Name: mdl_role_allow_view; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_role_allow_view (
    id bigint NOT NULL,
    roleid bigint NOT NULL,
    allowview bigint NOT NULL
);


--
-- Name: TABLE mdl_role_allow_view; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_role_allow_view IS 'This table stores which which other roles a user is allowed to view to if they have one role.';


--
-- Name: mdl_role_allow_view_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_role_allow_view_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_role_allow_view_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_role_allow_view_id_seq OWNED BY public.mdl_role_allow_view.id;


--
-- Name: mdl_role_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_role_assignments (
    id bigint NOT NULL,
    roleid bigint DEFAULT 0 NOT NULL,
    contextid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    modifierid bigint DEFAULT 0 NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    itemid bigint DEFAULT 0 NOT NULL,
    sortorder bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_role_assignments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_role_assignments IS 'assigning roles in different context';


--
-- Name: mdl_role_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_role_assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_role_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_role_assignments_id_seq OWNED BY public.mdl_role_assignments.id;


--
-- Name: mdl_role_capabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_role_capabilities (
    id bigint NOT NULL,
    contextid bigint DEFAULT 0 NOT NULL,
    roleid bigint DEFAULT 0 NOT NULL,
    capability character varying(255) DEFAULT ''::character varying NOT NULL,
    permission bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    modifierid bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_role_capabilities; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_role_capabilities IS 'permission has to be signed, overriding a capability for a particular role in a particular context';


--
-- Name: mdl_role_capabilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_role_capabilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_role_capabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_role_capabilities_id_seq OWNED BY public.mdl_role_capabilities.id;


--
-- Name: mdl_role_context_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_role_context_levels (
    id bigint NOT NULL,
    roleid bigint NOT NULL,
    contextlevel bigint NOT NULL
);


--
-- Name: TABLE mdl_role_context_levels; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_role_context_levels IS 'Lists which roles can be assigned at which context levels. The assignment is allowed in the corresponding row is present in this table.';


--
-- Name: mdl_role_context_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_role_context_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_role_context_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_role_context_levels_id_seq OWNED BY public.mdl_role_context_levels.id;


--
-- Name: mdl_role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_role_id_seq OWNED BY public.mdl_role.id;


--
-- Name: mdl_role_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_role_names (
    id bigint NOT NULL,
    roleid bigint DEFAULT 0 NOT NULL,
    contextid bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_role_names; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_role_names IS 'role names in native strings';


--
-- Name: mdl_role_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_role_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_role_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_role_names_id_seq OWNED BY public.mdl_role_names.id;


--
-- Name: mdl_scale; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_scale (
    id bigint NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    scale text NOT NULL,
    description text NOT NULL,
    descriptionformat smallint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_scale; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_scale IS 'Defines grading scales';


--
-- Name: mdl_scale_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_scale_history (
    id bigint NOT NULL,
    action bigint DEFAULT 0 NOT NULL,
    oldid bigint NOT NULL,
    source character varying(255),
    timemodified bigint,
    loggeduser bigint,
    courseid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    scale text NOT NULL,
    description text NOT NULL
);


--
-- Name: TABLE mdl_scale_history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_scale_history IS 'History table';


--
-- Name: mdl_scale_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_scale_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_scale_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_scale_history_id_seq OWNED BY public.mdl_scale_history.id;


--
-- Name: mdl_scale_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_scale_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_scale_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_scale_id_seq OWNED BY public.mdl_scale.id;


--
-- Name: mdl_scorm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_scorm (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    scormtype character varying(50) DEFAULT 'local'::character varying NOT NULL,
    reference character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text NOT NULL,
    introformat smallint DEFAULT 0 NOT NULL,
    version character varying(9) DEFAULT ''::character varying NOT NULL,
    maxgrade double precision DEFAULT 0 NOT NULL,
    grademethod smallint DEFAULT 0 NOT NULL,
    whatgrade bigint DEFAULT 0 NOT NULL,
    maxattempt bigint DEFAULT 1 NOT NULL,
    forcecompleted smallint DEFAULT 0 NOT NULL,
    forcenewattempt smallint DEFAULT 0 NOT NULL,
    lastattemptlock smallint DEFAULT 0 NOT NULL,
    masteryoverride smallint DEFAULT 1 NOT NULL,
    displayattemptstatus smallint DEFAULT 1 NOT NULL,
    displaycoursestructure smallint DEFAULT 0 NOT NULL,
    updatefreq smallint DEFAULT 0 NOT NULL,
    sha1hash character varying(40),
    md5hash character varying(32) DEFAULT ''::character varying NOT NULL,
    revision bigint DEFAULT 0 NOT NULL,
    launch bigint DEFAULT 0 NOT NULL,
    skipview smallint DEFAULT 1 NOT NULL,
    hidebrowse smallint DEFAULT 0 NOT NULL,
    hidetoc smallint DEFAULT 0 NOT NULL,
    nav smallint DEFAULT 1 NOT NULL,
    navpositionleft bigint DEFAULT '-100'::integer,
    navpositiontop bigint DEFAULT '-100'::integer,
    auto smallint DEFAULT 0 NOT NULL,
    popup smallint DEFAULT 0 NOT NULL,
    options character varying(255) DEFAULT ''::character varying NOT NULL,
    width bigint DEFAULT 100 NOT NULL,
    height bigint DEFAULT 600 NOT NULL,
    timeopen bigint DEFAULT 0 NOT NULL,
    timeclose bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    completionstatusrequired smallint,
    completionscorerequired bigint,
    completionstatusallscos smallint,
    autocommit smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_scorm; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_scorm IS 'each table is one SCORM module and its configuration';


--
-- Name: mdl_scorm_aicc_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_scorm_aicc_session (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    scormid bigint DEFAULT 0 NOT NULL,
    hacpsession character varying(255) DEFAULT ''::character varying NOT NULL,
    scoid bigint DEFAULT 0,
    scormmode character varying(50),
    scormstatus character varying(255),
    attempt bigint,
    lessonstatus character varying(255),
    sessiontime character varying(255),
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_scorm_aicc_session; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_scorm_aicc_session IS 'Used by AICC HACP to store session information';


--
-- Name: mdl_scorm_aicc_session_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_scorm_aicc_session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_scorm_aicc_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_scorm_aicc_session_id_seq OWNED BY public.mdl_scorm_aicc_session.id;


--
-- Name: mdl_scorm_attempt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_scorm_attempt (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    scormid bigint NOT NULL,
    attempt bigint DEFAULT 1 NOT NULL
);


--
-- Name: TABLE mdl_scorm_attempt; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_scorm_attempt IS 'List of SCORM attempts made by user.';


--
-- Name: mdl_scorm_attempt_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_scorm_attempt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_scorm_attempt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_scorm_attempt_id_seq OWNED BY public.mdl_scorm_attempt.id;


--
-- Name: mdl_scorm_element; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_scorm_element (
    id bigint NOT NULL,
    element character varying(255) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_scorm_element; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_scorm_element IS 'List of scorm elements.';


--
-- Name: mdl_scorm_element_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_scorm_element_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_scorm_element_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_scorm_element_id_seq OWNED BY public.mdl_scorm_element.id;


--
-- Name: mdl_scorm_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_scorm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_scorm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_scorm_id_seq OWNED BY public.mdl_scorm.id;


--
-- Name: mdl_scorm_scoes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_scorm_scoes (
    id bigint NOT NULL,
    scorm bigint DEFAULT 0 NOT NULL,
    manifest character varying(255) DEFAULT ''::character varying NOT NULL,
    organization character varying(255) DEFAULT ''::character varying NOT NULL,
    parent character varying(255) DEFAULT ''::character varying NOT NULL,
    identifier character varying(255) DEFAULT ''::character varying NOT NULL,
    launch text NOT NULL,
    scormtype character varying(5) DEFAULT ''::character varying NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    sortorder bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_scorm_scoes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_scorm_scoes IS 'each SCO part of the SCORM module';


--
-- Name: mdl_scorm_scoes_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_scorm_scoes_data (
    id bigint NOT NULL,
    scoid bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    value text NOT NULL
);


--
-- Name: TABLE mdl_scorm_scoes_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_scorm_scoes_data IS 'Contains variable data get from packages';


--
-- Name: mdl_scorm_scoes_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_scorm_scoes_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_scorm_scoes_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_scorm_scoes_data_id_seq OWNED BY public.mdl_scorm_scoes_data.id;


--
-- Name: mdl_scorm_scoes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_scorm_scoes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_scorm_scoes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_scorm_scoes_id_seq OWNED BY public.mdl_scorm_scoes.id;


--
-- Name: mdl_scorm_scoes_value; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_scorm_scoes_value (
    id bigint NOT NULL,
    scoid bigint NOT NULL,
    attemptid bigint NOT NULL,
    elementid bigint NOT NULL,
    value text NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_scorm_scoes_value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_scorm_scoes_value IS 'Values passed from SCORM package';


--
-- Name: mdl_scorm_scoes_value_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_scorm_scoes_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_scorm_scoes_value_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_scorm_scoes_value_id_seq OWNED BY public.mdl_scorm_scoes_value.id;


--
-- Name: mdl_scorm_seq_mapinfo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_scorm_seq_mapinfo (
    id bigint NOT NULL,
    scoid bigint DEFAULT 0 NOT NULL,
    objectiveid bigint DEFAULT 0 NOT NULL,
    targetobjectiveid bigint DEFAULT 0 NOT NULL,
    readsatisfiedstatus smallint DEFAULT 1 NOT NULL,
    readnormalizedmeasure smallint DEFAULT 1 NOT NULL,
    writesatisfiedstatus smallint DEFAULT 0 NOT NULL,
    writenormalizedmeasure smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_scorm_seq_mapinfo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_scorm_seq_mapinfo IS 'SCORM2004 objective mapinfo description';


--
-- Name: mdl_scorm_seq_mapinfo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_scorm_seq_mapinfo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_scorm_seq_mapinfo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_scorm_seq_mapinfo_id_seq OWNED BY public.mdl_scorm_seq_mapinfo.id;


--
-- Name: mdl_scorm_seq_objective; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_scorm_seq_objective (
    id bigint NOT NULL,
    scoid bigint DEFAULT 0 NOT NULL,
    primaryobj smallint DEFAULT 0 NOT NULL,
    objectiveid character varying(255) DEFAULT ''::character varying NOT NULL,
    satisfiedbymeasure smallint DEFAULT 1 NOT NULL,
    minnormalizedmeasure real DEFAULT 0.0000 NOT NULL
);


--
-- Name: TABLE mdl_scorm_seq_objective; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_scorm_seq_objective IS 'SCORM2004 objective description';


--
-- Name: mdl_scorm_seq_objective_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_scorm_seq_objective_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_scorm_seq_objective_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_scorm_seq_objective_id_seq OWNED BY public.mdl_scorm_seq_objective.id;


--
-- Name: mdl_scorm_seq_rolluprule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_scorm_seq_rolluprule (
    id bigint NOT NULL,
    scoid bigint DEFAULT 0 NOT NULL,
    childactivityset character varying(15) DEFAULT ''::character varying NOT NULL,
    minimumcount bigint DEFAULT 0 NOT NULL,
    minimumpercent real DEFAULT 0.0000 NOT NULL,
    conditioncombination character varying(3) DEFAULT 'all'::character varying NOT NULL,
    action character varying(15) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_scorm_seq_rolluprule; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_scorm_seq_rolluprule IS 'SCORM2004 sequencing rule';


--
-- Name: mdl_scorm_seq_rolluprule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_scorm_seq_rolluprule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_scorm_seq_rolluprule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_scorm_seq_rolluprule_id_seq OWNED BY public.mdl_scorm_seq_rolluprule.id;


--
-- Name: mdl_scorm_seq_rolluprulecond; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_scorm_seq_rolluprulecond (
    id bigint NOT NULL,
    scoid bigint DEFAULT 0 NOT NULL,
    rollupruleid bigint DEFAULT 0 NOT NULL,
    operator character varying(5) DEFAULT 'noOp'::character varying NOT NULL,
    cond character varying(25) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_scorm_seq_rolluprulecond; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_scorm_seq_rolluprulecond IS 'SCORM2004 sequencing rule';


--
-- Name: mdl_scorm_seq_rolluprulecond_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_scorm_seq_rolluprulecond_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_scorm_seq_rolluprulecond_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_scorm_seq_rolluprulecond_id_seq OWNED BY public.mdl_scorm_seq_rolluprulecond.id;


--
-- Name: mdl_scorm_seq_rulecond; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_scorm_seq_rulecond (
    id bigint NOT NULL,
    scoid bigint DEFAULT 0 NOT NULL,
    ruleconditionsid bigint DEFAULT 0 NOT NULL,
    refrencedobjective character varying(255) DEFAULT ''::character varying NOT NULL,
    measurethreshold real DEFAULT 0.0000 NOT NULL,
    operator character varying(5) DEFAULT 'noOp'::character varying NOT NULL,
    cond character varying(30) DEFAULT 'always'::character varying NOT NULL
);


--
-- Name: TABLE mdl_scorm_seq_rulecond; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_scorm_seq_rulecond IS 'SCORM2004 rule condition';


--
-- Name: mdl_scorm_seq_rulecond_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_scorm_seq_rulecond_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_scorm_seq_rulecond_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_scorm_seq_rulecond_id_seq OWNED BY public.mdl_scorm_seq_rulecond.id;


--
-- Name: mdl_scorm_seq_ruleconds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_scorm_seq_ruleconds (
    id bigint NOT NULL,
    scoid bigint DEFAULT 0 NOT NULL,
    conditioncombination character varying(3) DEFAULT 'all'::character varying NOT NULL,
    ruletype smallint DEFAULT 0 NOT NULL,
    action character varying(25) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_scorm_seq_ruleconds; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_scorm_seq_ruleconds IS 'SCORM2004 rule conditions';


--
-- Name: mdl_scorm_seq_ruleconds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_scorm_seq_ruleconds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_scorm_seq_ruleconds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_scorm_seq_ruleconds_id_seq OWNED BY public.mdl_scorm_seq_ruleconds.id;


--
-- Name: mdl_search_index_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_search_index_requests (
    id bigint NOT NULL,
    contextid bigint NOT NULL,
    searcharea character varying(255) DEFAULT ''::character varying NOT NULL,
    timerequested bigint NOT NULL,
    partialarea character varying(255) DEFAULT ''::character varying NOT NULL,
    partialtime bigint NOT NULL,
    indexpriority bigint NOT NULL
);


--
-- Name: TABLE mdl_search_index_requests; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_search_index_requests IS 'Records requests for (re)indexing of specific contexts. Entries will be removed from this table when indexing of that context is complete. (This table is not used for normal time-based indexing of new content.)';


--
-- Name: mdl_search_index_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_search_index_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_search_index_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_search_index_requests_id_seq OWNED BY public.mdl_search_index_requests.id;


--
-- Name: mdl_search_simpledb_index; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_search_simpledb_index (
    id bigint NOT NULL,
    docid character varying(255) DEFAULT ''::character varying NOT NULL,
    itemid bigint NOT NULL,
    title text,
    content text,
    contextid bigint NOT NULL,
    areaid character varying(255) DEFAULT ''::character varying NOT NULL,
    type smallint NOT NULL,
    courseid bigint NOT NULL,
    owneruserid bigint,
    modified bigint NOT NULL,
    userid bigint,
    description1 text,
    description2 text
);


--
-- Name: TABLE mdl_search_simpledb_index; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_search_simpledb_index IS 'search_simpledb table containing the index data.';


--
-- Name: mdl_search_simpledb_index_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_search_simpledb_index_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_search_simpledb_index_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_search_simpledb_index_id_seq OWNED BY public.mdl_search_simpledb_index.id;


--
-- Name: mdl_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_sessions (
    id bigint NOT NULL,
    state bigint DEFAULT 0 NOT NULL,
    sid character varying(128) DEFAULT ''::character varying NOT NULL,
    userid bigint NOT NULL,
    sessdata text,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    firstip character varying(45),
    lastip character varying(45)
);


--
-- Name: TABLE mdl_sessions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_sessions IS 'Database based session storage - now recommended';


--
-- Name: mdl_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_sessions_id_seq OWNED BY public.mdl_sessions.id;


--
-- Name: mdl_sms_gateways; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_sms_gateways (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    gateway character varying(255) DEFAULT ''::character varying NOT NULL,
    enabled smallint DEFAULT 1 NOT NULL,
    config text NOT NULL
);


--
-- Name: TABLE mdl_sms_gateways; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_sms_gateways IS 'Instances of SMS gateways';


--
-- Name: mdl_sms_gateways_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_sms_gateways_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_sms_gateways_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_sms_gateways_id_seq OWNED BY public.mdl_sms_gateways.id;


--
-- Name: mdl_sms_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_sms_messages (
    id bigint NOT NULL,
    recipientnumber character varying(30) DEFAULT ''::character varying NOT NULL,
    content text,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    messagetype character varying(100) DEFAULT ''::character varying NOT NULL,
    recipientuserid bigint,
    issensitive smallint DEFAULT 0 NOT NULL,
    gatewayid bigint,
    status character varying(100),
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_sms_messages; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_sms_messages IS 'SMS Messages sent via the SMS subsystem';


--
-- Name: mdl_sms_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_sms_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_sms_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_sms_messages_id_seq OWNED BY public.mdl_sms_messages.id;


--
-- Name: mdl_stats_daily; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_stats_daily (
    id bigint NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL,
    timeend bigint DEFAULT 0 NOT NULL,
    roleid bigint DEFAULT 0 NOT NULL,
    stattype character varying(20) DEFAULT 'activity'::character varying NOT NULL,
    stat1 bigint DEFAULT 0 NOT NULL,
    stat2 bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_stats_daily; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_stats_daily IS 'to accumulate daily stats';


--
-- Name: mdl_stats_daily_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_stats_daily_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_stats_daily_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_stats_daily_id_seq OWNED BY public.mdl_stats_daily.id;


--
-- Name: mdl_stats_monthly; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_stats_monthly (
    id bigint NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL,
    timeend bigint DEFAULT 0 NOT NULL,
    roleid bigint DEFAULT 0 NOT NULL,
    stattype character varying(20) DEFAULT 'activity'::character varying NOT NULL,
    stat1 bigint DEFAULT 0 NOT NULL,
    stat2 bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_stats_monthly; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_stats_monthly IS 'To accumulate monthly stats';


--
-- Name: mdl_stats_monthly_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_stats_monthly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_stats_monthly_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_stats_monthly_id_seq OWNED BY public.mdl_stats_monthly.id;


--
-- Name: mdl_stats_user_daily; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_stats_user_daily (
    id bigint NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    roleid bigint DEFAULT 0 NOT NULL,
    timeend bigint DEFAULT 0 NOT NULL,
    statsreads bigint DEFAULT 0 NOT NULL,
    statswrites bigint DEFAULT 0 NOT NULL,
    stattype character varying(30) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_stats_user_daily; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_stats_user_daily IS 'To accumulate daily stats per course/user';


--
-- Name: mdl_stats_user_daily_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_stats_user_daily_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_stats_user_daily_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_stats_user_daily_id_seq OWNED BY public.mdl_stats_user_daily.id;


--
-- Name: mdl_stats_user_monthly; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_stats_user_monthly (
    id bigint NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    roleid bigint DEFAULT 0 NOT NULL,
    timeend bigint DEFAULT 0 NOT NULL,
    statsreads bigint DEFAULT 0 NOT NULL,
    statswrites bigint DEFAULT 0 NOT NULL,
    stattype character varying(30) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_stats_user_monthly; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_stats_user_monthly IS 'To accumulate monthly stats per course/user';


--
-- Name: mdl_stats_user_monthly_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_stats_user_monthly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_stats_user_monthly_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_stats_user_monthly_id_seq OWNED BY public.mdl_stats_user_monthly.id;


--
-- Name: mdl_stats_user_weekly; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_stats_user_weekly (
    id bigint NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    roleid bigint DEFAULT 0 NOT NULL,
    timeend bigint DEFAULT 0 NOT NULL,
    statsreads bigint DEFAULT 0 NOT NULL,
    statswrites bigint DEFAULT 0 NOT NULL,
    stattype character varying(30) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_stats_user_weekly; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_stats_user_weekly IS 'To accumulate weekly stats per course/user';


--
-- Name: mdl_stats_user_weekly_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_stats_user_weekly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_stats_user_weekly_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_stats_user_weekly_id_seq OWNED BY public.mdl_stats_user_weekly.id;


--
-- Name: mdl_stats_weekly; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_stats_weekly (
    id bigint NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL,
    timeend bigint DEFAULT 0 NOT NULL,
    roleid bigint DEFAULT 0 NOT NULL,
    stattype character varying(20) DEFAULT 'activity'::character varying NOT NULL,
    stat1 bigint DEFAULT 0 NOT NULL,
    stat2 bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_stats_weekly; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_stats_weekly IS 'To accumulate weekly stats';


--
-- Name: mdl_stats_weekly_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_stats_weekly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_stats_weekly_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_stats_weekly_id_seq OWNED BY public.mdl_stats_weekly.id;


--
-- Name: mdl_stored_progress; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_stored_progress (
    id bigint NOT NULL,
    idnumber character varying(255) DEFAULT ''::character varying NOT NULL,
    timestart bigint,
    lastupdate bigint,
    percentcompleted numeric(5,2) DEFAULT 0,
    message character varying(255),
    haserrored smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_stored_progress; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_stored_progress IS 'Records for any long running tasks we want to poll for progress';


--
-- Name: mdl_stored_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_stored_progress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_stored_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_stored_progress_id_seq OWNED BY public.mdl_stored_progress.id;


--
-- Name: mdl_subsection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_subsection (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_subsection; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_subsection IS 'Stores the delegated subsection instances.';


--
-- Name: mdl_subsection_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_subsection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_subsection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_subsection_id_seq OWNED BY public.mdl_subsection.id;


--
-- Name: mdl_survey; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_survey (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    template bigint DEFAULT 0 NOT NULL,
    days integer DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text NOT NULL,
    introformat smallint DEFAULT 0 NOT NULL,
    questions character varying(255) DEFAULT ''::character varying NOT NULL,
    completionsubmit smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_survey; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_survey IS 'Each record is one SURVEY module with its configuration';


--
-- Name: mdl_survey_analysis; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_survey_analysis (
    id bigint NOT NULL,
    survey bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    notes text NOT NULL
);


--
-- Name: TABLE mdl_survey_analysis; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_survey_analysis IS 'text about each survey submission';


--
-- Name: mdl_survey_analysis_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_survey_analysis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_survey_analysis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_survey_analysis_id_seq OWNED BY public.mdl_survey_analysis.id;


--
-- Name: mdl_survey_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_survey_answers (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    survey bigint DEFAULT 0 NOT NULL,
    question bigint DEFAULT 0 NOT NULL,
    "time" bigint DEFAULT 0 NOT NULL,
    answer1 text NOT NULL,
    answer2 text NOT NULL
);


--
-- Name: TABLE mdl_survey_answers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_survey_answers IS 'the answers to each questions filled by the users';


--
-- Name: mdl_survey_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_survey_answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_survey_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_survey_answers_id_seq OWNED BY public.mdl_survey_answers.id;


--
-- Name: mdl_survey_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_survey_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_survey_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_survey_id_seq OWNED BY public.mdl_survey.id;


--
-- Name: mdl_survey_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_survey_questions (
    id bigint NOT NULL,
    text character varying(255) DEFAULT ''::character varying NOT NULL,
    shorttext character varying(30) DEFAULT ''::character varying NOT NULL,
    multi character varying(100) DEFAULT ''::character varying NOT NULL,
    intro character varying(50) DEFAULT ''::character varying NOT NULL,
    type smallint DEFAULT 0 NOT NULL,
    options text
);


--
-- Name: TABLE mdl_survey_questions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_survey_questions IS 'the questions conforming one survey';


--
-- Name: mdl_survey_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_survey_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_survey_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_survey_questions_id_seq OWNED BY public.mdl_survey_questions.id;


--
-- Name: mdl_tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tag (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    tagcollid bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    rawname character varying(255) DEFAULT ''::character varying NOT NULL,
    isstandard smallint DEFAULT 0 NOT NULL,
    description text,
    descriptionformat smallint DEFAULT 0 NOT NULL,
    flag smallint DEFAULT 0,
    timemodified bigint
);


--
-- Name: TABLE mdl_tag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tag IS 'Tag table - this generic table will replace the old "tags" table.';


--
-- Name: mdl_tag_area; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tag_area (
    id bigint NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    itemtype character varying(100) DEFAULT ''::character varying NOT NULL,
    enabled smallint DEFAULT 1 NOT NULL,
    tagcollid bigint NOT NULL,
    callback character varying(100),
    callbackfile character varying(100),
    showstandard smallint DEFAULT 0 NOT NULL,
    multiplecontexts smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_tag_area; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tag_area IS 'Defines various tag areas, one area is identified by component and itemtype';


--
-- Name: mdl_tag_area_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tag_area_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tag_area_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tag_area_id_seq OWNED BY public.mdl_tag_area.id;


--
-- Name: mdl_tag_coll; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tag_coll (
    id bigint NOT NULL,
    name character varying(255),
    isdefault smallint DEFAULT 0 NOT NULL,
    component character varying(100),
    sortorder integer DEFAULT 0 NOT NULL,
    searchable smallint DEFAULT 1 NOT NULL,
    customurl character varying(255)
);


--
-- Name: TABLE mdl_tag_coll; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tag_coll IS 'Defines different set of tags';


--
-- Name: mdl_tag_coll_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tag_coll_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tag_coll_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tag_coll_id_seq OWNED BY public.mdl_tag_coll.id;


--
-- Name: mdl_tag_correlation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tag_correlation (
    id bigint NOT NULL,
    tagid bigint NOT NULL,
    correlatedtags text NOT NULL
);


--
-- Name: TABLE mdl_tag_correlation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tag_correlation IS 'The rationale for the ''tag_correlation'' table is performance.   It works as a cache for a potentially heavy load query done at the ''tag_instance'' table.   So, the ''tag_correlation'' table stores redundant information derived from the ''tag_instance'' ta';


--
-- Name: mdl_tag_correlation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tag_correlation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tag_correlation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tag_correlation_id_seq OWNED BY public.mdl_tag_correlation.id;


--
-- Name: mdl_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tag_id_seq OWNED BY public.mdl_tag.id;


--
-- Name: mdl_tag_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tag_instance (
    id bigint NOT NULL,
    tagid bigint NOT NULL,
    component character varying(100) DEFAULT ''::character varying NOT NULL,
    itemtype character varying(100) DEFAULT ''::character varying NOT NULL,
    itemid bigint NOT NULL,
    contextid bigint,
    tiuserid bigint DEFAULT 0 NOT NULL,
    ordering bigint,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_tag_instance; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tag_instance IS 'tag_instance table holds the information of associations between tags and other items';


--
-- Name: mdl_tag_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tag_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tag_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tag_instance_id_seq OWNED BY public.mdl_tag_instance.id;


--
-- Name: mdl_task_adhoc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_task_adhoc (
    id bigint NOT NULL,
    component character varying(255) DEFAULT ''::character varying NOT NULL,
    classname character varying(255) DEFAULT ''::character varying NOT NULL,
    nextruntime bigint NOT NULL,
    faildelay bigint,
    customdata text,
    userid bigint,
    timecreated bigint DEFAULT 0 NOT NULL,
    timestarted bigint,
    hostname character varying(255),
    pid bigint,
    attemptsavailable smallint,
    firststartingtime bigint
);


--
-- Name: TABLE mdl_task_adhoc; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_task_adhoc IS 'List of adhoc tasks waiting to run.';


--
-- Name: mdl_task_adhoc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_task_adhoc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_task_adhoc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_task_adhoc_id_seq OWNED BY public.mdl_task_adhoc.id;


--
-- Name: mdl_task_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_task_log (
    id bigint NOT NULL,
    type smallint NOT NULL,
    component character varying(255) DEFAULT ''::character varying NOT NULL,
    classname character varying(255) DEFAULT ''::character varying NOT NULL,
    userid bigint NOT NULL,
    timestart numeric(20,10) NOT NULL,
    timeend numeric(20,10) NOT NULL,
    dbreads bigint NOT NULL,
    dbwrites bigint NOT NULL,
    result smallint NOT NULL,
    output text NOT NULL,
    hostname character varying(255),
    pid bigint
);


--
-- Name: TABLE mdl_task_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_task_log IS 'The log table for all tasks';


--
-- Name: mdl_task_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_task_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_task_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_task_log_id_seq OWNED BY public.mdl_task_log.id;


--
-- Name: mdl_task_scheduled; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_task_scheduled (
    id bigint NOT NULL,
    component character varying(255) DEFAULT ''::character varying NOT NULL,
    classname character varying(255) DEFAULT ''::character varying NOT NULL,
    lastruntime bigint,
    nextruntime bigint,
    minute character varying(200) DEFAULT ''::character varying NOT NULL,
    hour character varying(70) DEFAULT ''::character varying NOT NULL,
    day character varying(90) DEFAULT ''::character varying NOT NULL,
    month character varying(30) DEFAULT ''::character varying NOT NULL,
    dayofweek character varying(25) DEFAULT ''::character varying NOT NULL,
    faildelay bigint,
    customised smallint DEFAULT 0 NOT NULL,
    disabled smallint DEFAULT 0 NOT NULL,
    timestarted bigint,
    hostname character varying(255),
    pid bigint
);


--
-- Name: TABLE mdl_task_scheduled; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_task_scheduled IS 'List of scheduled tasks to be run by cron.';


--
-- Name: mdl_task_scheduled_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_task_scheduled_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_task_scheduled_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_task_scheduled_id_seq OWNED BY public.mdl_task_scheduled.id;


--
-- Name: mdl_tiny_autosave; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tiny_autosave (
    id bigint NOT NULL,
    elementid character varying(255) DEFAULT ''::character varying NOT NULL,
    contextid bigint NOT NULL,
    pagehash character varying(64) DEFAULT ''::character varying NOT NULL,
    userid bigint NOT NULL,
    drafttext text NOT NULL,
    draftid bigint,
    pageinstance character varying(64) DEFAULT ''::character varying NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_tiny_autosave; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tiny_autosave IS 'The content of the textarea saved during autosave operations';


--
-- Name: mdl_tiny_autosave_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tiny_autosave_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tiny_autosave_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tiny_autosave_id_seq OWNED BY public.mdl_tiny_autosave.id;


--
-- Name: mdl_tool_brickfield_areas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_brickfield_areas (
    id bigint NOT NULL,
    type smallint DEFAULT 0 NOT NULL,
    contextid bigint,
    component character varying(100),
    tablename character varying(40),
    fieldorarea character varying(50),
    itemid bigint,
    filename character varying(1333),
    reftable character varying(40),
    refid bigint,
    cmid bigint,
    courseid bigint,
    categoryid bigint
);


--
-- Name: TABLE mdl_tool_brickfield_areas; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_brickfield_areas IS 'Areas that have been checked for accessibility problems';


--
-- Name: mdl_tool_brickfield_areas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_brickfield_areas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_brickfield_areas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_brickfield_areas_id_seq OWNED BY public.mdl_tool_brickfield_areas.id;


--
-- Name: mdl_tool_brickfield_cache_acts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_brickfield_cache_acts (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    status smallint,
    component character varying(64),
    totalactivities bigint,
    failedactivities bigint,
    passedactivities bigint,
    errorcount bigint
);


--
-- Name: TABLE mdl_tool_brickfield_cache_acts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_brickfield_cache_acts IS 'Contains accessibility summary information per activity.';


--
-- Name: mdl_tool_brickfield_cache_acts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_brickfield_cache_acts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_brickfield_cache_acts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_brickfield_cache_acts_id_seq OWNED BY public.mdl_tool_brickfield_cache_acts.id;


--
-- Name: mdl_tool_brickfield_cache_check; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_brickfield_cache_check (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    status smallint,
    checkid bigint,
    checkcount bigint,
    errorcount bigint
);


--
-- Name: TABLE mdl_tool_brickfield_cache_check; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_brickfield_cache_check IS 'Contains accessibility summary information per check.';


--
-- Name: mdl_tool_brickfield_cache_check_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_brickfield_cache_check_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_brickfield_cache_check_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_brickfield_cache_check_id_seq OWNED BY public.mdl_tool_brickfield_cache_check.id;


--
-- Name: mdl_tool_brickfield_checks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_brickfield_checks (
    id bigint NOT NULL,
    checktype character varying(64),
    shortname character varying(64),
    checkgroup bigint DEFAULT 0,
    status smallint NOT NULL,
    severity smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_tool_brickfield_checks; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_brickfield_checks IS 'Checks details';


--
-- Name: mdl_tool_brickfield_checks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_brickfield_checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_brickfield_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_brickfield_checks_id_seq OWNED BY public.mdl_tool_brickfield_checks.id;


--
-- Name: mdl_tool_brickfield_content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_brickfield_content (
    id bigint NOT NULL,
    areaid bigint NOT NULL,
    contenthash character varying(40) DEFAULT ''::character varying NOT NULL,
    iscurrent smallint DEFAULT 0 NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    timecreated bigint NOT NULL,
    timechecked bigint
);


--
-- Name: TABLE mdl_tool_brickfield_content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_brickfield_content IS 'Content of an area at a particular time (recognised by a hash)';


--
-- Name: mdl_tool_brickfield_content_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_brickfield_content_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_brickfield_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_brickfield_content_id_seq OWNED BY public.mdl_tool_brickfield_content.id;


--
-- Name: mdl_tool_brickfield_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_brickfield_errors (
    id bigint NOT NULL,
    resultid bigint NOT NULL,
    linenumber bigint DEFAULT 0 NOT NULL,
    errordata text,
    htmlcode text
);


--
-- Name: TABLE mdl_tool_brickfield_errors; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_brickfield_errors IS 'Errors during the accessibility checks';


--
-- Name: mdl_tool_brickfield_errors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_brickfield_errors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_brickfield_errors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_brickfield_errors_id_seq OWNED BY public.mdl_tool_brickfield_errors.id;


--
-- Name: mdl_tool_brickfield_process; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_brickfield_process (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    item character varying(64),
    contextid bigint,
    innercontextid bigint,
    timecreated bigint,
    timecompleted bigint
);


--
-- Name: TABLE mdl_tool_brickfield_process; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_brickfield_process IS 'Queued records to initiate new processing of specific targets';


--
-- Name: mdl_tool_brickfield_process_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_brickfield_process_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_brickfield_process_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_brickfield_process_id_seq OWNED BY public.mdl_tool_brickfield_process.id;


--
-- Name: mdl_tool_brickfield_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_brickfield_results (
    id bigint NOT NULL,
    contentid bigint,
    checkid bigint NOT NULL,
    errorcount bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_tool_brickfield_results; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_brickfield_results IS 'Results of the accessibility checks';


--
-- Name: mdl_tool_brickfield_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_brickfield_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_brickfield_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_brickfield_results_id_seq OWNED BY public.mdl_tool_brickfield_results.id;


--
-- Name: mdl_tool_brickfield_schedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_brickfield_schedule (
    id bigint NOT NULL,
    contextlevel bigint DEFAULT 50 NOT NULL,
    instanceid bigint NOT NULL,
    contextid bigint,
    status smallint DEFAULT 0 NOT NULL,
    timeanalyzed bigint DEFAULT 0,
    timemodified bigint DEFAULT 0
);


--
-- Name: TABLE mdl_tool_brickfield_schedule; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_brickfield_schedule IS 'Keeps the per course content analysis schedule.';


--
-- Name: mdl_tool_brickfield_schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_brickfield_schedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_brickfield_schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_brickfield_schedule_id_seq OWNED BY public.mdl_tool_brickfield_schedule.id;


--
-- Name: mdl_tool_brickfield_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_brickfield_summary (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    status smallint,
    activities bigint,
    activitiespassed bigint,
    activitiesfailed bigint,
    errorschecktype1 bigint,
    errorschecktype2 bigint,
    errorschecktype3 bigint,
    errorschecktype4 bigint,
    errorschecktype5 bigint,
    errorschecktype6 bigint,
    errorschecktype7 bigint,
    failedchecktype1 bigint,
    failedchecktype2 bigint,
    failedchecktype3 bigint,
    failedchecktype4 bigint,
    failedchecktype5 bigint,
    failedchecktype6 bigint,
    failedchecktype7 bigint,
    percentchecktype1 bigint,
    percentchecktype2 bigint,
    percentchecktype3 bigint,
    percentchecktype4 bigint,
    percentchecktype5 bigint,
    percentchecktype6 bigint,
    percentchecktype7 bigint
);


--
-- Name: TABLE mdl_tool_brickfield_summary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_brickfield_summary IS 'Contains accessibility check results summary information.';


--
-- Name: mdl_tool_brickfield_summary_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_brickfield_summary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_brickfield_summary_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_brickfield_summary_id_seq OWNED BY public.mdl_tool_brickfield_summary.id;


--
-- Name: mdl_tool_cohortroles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_cohortroles (
    id bigint NOT NULL,
    cohortid bigint NOT NULL,
    roleid bigint NOT NULL,
    userid bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    usermodified bigint
);


--
-- Name: TABLE mdl_tool_cohortroles; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_cohortroles IS 'Mapping of users to cohort role assignments.';


--
-- Name: mdl_tool_cohortroles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_cohortroles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_cohortroles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_cohortroles_id_seq OWNED BY public.mdl_tool_cohortroles.id;


--
-- Name: mdl_tool_customlang; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_customlang (
    id bigint NOT NULL,
    lang character varying(20) DEFAULT ''::character varying NOT NULL,
    componentid bigint NOT NULL,
    stringid character varying(255) DEFAULT ''::character varying NOT NULL,
    original text NOT NULL,
    master text,
    local text,
    timemodified bigint NOT NULL,
    timecustomized bigint,
    outdated smallint DEFAULT 0,
    modified smallint DEFAULT 0
);


--
-- Name: TABLE mdl_tool_customlang; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_customlang IS 'Contains the working checkout of all strings and their customization';


--
-- Name: mdl_tool_customlang_components; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_customlang_components (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    version character varying(255)
);


--
-- Name: TABLE mdl_tool_customlang_components; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_customlang_components IS 'Contains the list of all installed plugins that provide their own language pack';


--
-- Name: mdl_tool_customlang_components_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_customlang_components_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_customlang_components_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_customlang_components_id_seq OWNED BY public.mdl_tool_customlang_components.id;


--
-- Name: mdl_tool_customlang_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_customlang_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_customlang_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_customlang_id_seq OWNED BY public.mdl_tool_customlang.id;


--
-- Name: mdl_tool_dataprivacy_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_dataprivacy_category (
    id bigint NOT NULL,
    name character varying(100) DEFAULT ''::character varying NOT NULL,
    description text,
    descriptionformat smallint,
    usermodified bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_tool_dataprivacy_category; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_dataprivacy_category IS 'Data categories';


--
-- Name: mdl_tool_dataprivacy_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_dataprivacy_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_dataprivacy_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_dataprivacy_category_id_seq OWNED BY public.mdl_tool_dataprivacy_category.id;


--
-- Name: mdl_tool_dataprivacy_contextlist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_dataprivacy_contextlist (
    id bigint NOT NULL,
    component character varying(255) DEFAULT ''::character varying NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_tool_dataprivacy_contextlist; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_dataprivacy_contextlist IS 'List of contexts for a component';


--
-- Name: mdl_tool_dataprivacy_contextlist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_dataprivacy_contextlist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_dataprivacy_contextlist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_dataprivacy_contextlist_id_seq OWNED BY public.mdl_tool_dataprivacy_contextlist.id;


--
-- Name: mdl_tool_dataprivacy_ctxexpired; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_dataprivacy_ctxexpired (
    id bigint NOT NULL,
    contextid bigint NOT NULL,
    unexpiredroles text,
    expiredroles text,
    defaultexpired smallint NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    usermodified bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_tool_dataprivacy_ctxexpired; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_dataprivacy_ctxexpired IS 'Default comment for the table, please edit me';


--
-- Name: mdl_tool_dataprivacy_ctxexpired_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_dataprivacy_ctxexpired_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_dataprivacy_ctxexpired_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_dataprivacy_ctxexpired_id_seq OWNED BY public.mdl_tool_dataprivacy_ctxexpired.id;


--
-- Name: mdl_tool_dataprivacy_ctxinstance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_dataprivacy_ctxinstance (
    id bigint NOT NULL,
    contextid bigint NOT NULL,
    purposeid bigint,
    categoryid bigint,
    usermodified bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_tool_dataprivacy_ctxinstance; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_dataprivacy_ctxinstance IS 'Default comment for the table, please edit me';


--
-- Name: mdl_tool_dataprivacy_ctxinstance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_dataprivacy_ctxinstance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_dataprivacy_ctxinstance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_dataprivacy_ctxinstance_id_seq OWNED BY public.mdl_tool_dataprivacy_ctxinstance.id;


--
-- Name: mdl_tool_dataprivacy_ctxlevel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_dataprivacy_ctxlevel (
    id bigint NOT NULL,
    contextlevel smallint NOT NULL,
    purposeid bigint,
    categoryid bigint,
    usermodified bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_tool_dataprivacy_ctxlevel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_dataprivacy_ctxlevel IS 'Default comment for the table, please edit me';


--
-- Name: mdl_tool_dataprivacy_ctxlevel_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_dataprivacy_ctxlevel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_dataprivacy_ctxlevel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_dataprivacy_ctxlevel_id_seq OWNED BY public.mdl_tool_dataprivacy_ctxlevel.id;


--
-- Name: mdl_tool_dataprivacy_ctxlst_ctx; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_dataprivacy_ctxlst_ctx (
    id bigint NOT NULL,
    contextid bigint NOT NULL,
    contextlistid bigint NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_tool_dataprivacy_ctxlst_ctx; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_dataprivacy_ctxlst_ctx IS 'A contextlist context item';


--
-- Name: mdl_tool_dataprivacy_ctxlst_ctx_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_dataprivacy_ctxlst_ctx_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_dataprivacy_ctxlst_ctx_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_dataprivacy_ctxlst_ctx_id_seq OWNED BY public.mdl_tool_dataprivacy_ctxlst_ctx.id;


--
-- Name: mdl_tool_dataprivacy_purpose; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_dataprivacy_purpose (
    id bigint NOT NULL,
    name character varying(100) DEFAULT ''::character varying NOT NULL,
    description text,
    descriptionformat smallint,
    lawfulbases text NOT NULL,
    sensitivedatareasons text,
    retentionperiod character varying(255) DEFAULT ''::character varying NOT NULL,
    protected smallint,
    usermodified bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_tool_dataprivacy_purpose; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_dataprivacy_purpose IS 'Data purposes';


--
-- Name: mdl_tool_dataprivacy_purpose_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_dataprivacy_purpose_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_dataprivacy_purpose_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_dataprivacy_purpose_id_seq OWNED BY public.mdl_tool_dataprivacy_purpose.id;


--
-- Name: mdl_tool_dataprivacy_purposerole; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_dataprivacy_purposerole (
    id bigint NOT NULL,
    purposeid bigint NOT NULL,
    roleid bigint NOT NULL,
    lawfulbases text,
    sensitivedatareasons text,
    retentionperiod character varying(255) DEFAULT ''::character varying NOT NULL,
    protected smallint,
    usermodified bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_tool_dataprivacy_purposerole; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_dataprivacy_purposerole IS 'Data purpose overrides for a specific role';


--
-- Name: mdl_tool_dataprivacy_purposerole_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_dataprivacy_purposerole_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_dataprivacy_purposerole_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_dataprivacy_purposerole_id_seq OWNED BY public.mdl_tool_dataprivacy_purposerole.id;


--
-- Name: mdl_tool_dataprivacy_request; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_dataprivacy_request (
    id bigint NOT NULL,
    type bigint DEFAULT 0 NOT NULL,
    comments text,
    commentsformat smallint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    requestedby bigint DEFAULT 0 NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    dpo bigint DEFAULT 0,
    dpocomment text,
    dpocommentformat smallint DEFAULT 0 NOT NULL,
    systemapproved smallint DEFAULT 0 NOT NULL,
    usermodified bigint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    creationmethod bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_tool_dataprivacy_request; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_dataprivacy_request IS 'Table for data requests';


--
-- Name: mdl_tool_dataprivacy_request_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_dataprivacy_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_dataprivacy_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_dataprivacy_request_id_seq OWNED BY public.mdl_tool_dataprivacy_request.id;


--
-- Name: mdl_tool_dataprivacy_rqst_ctxlst; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_dataprivacy_rqst_ctxlst (
    id bigint NOT NULL,
    requestid bigint NOT NULL,
    contextlistid bigint NOT NULL
);


--
-- Name: TABLE mdl_tool_dataprivacy_rqst_ctxlst; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_dataprivacy_rqst_ctxlst IS 'Association table joining requests and contextlists';


--
-- Name: mdl_tool_dataprivacy_rqst_ctxlst_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_dataprivacy_rqst_ctxlst_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_dataprivacy_rqst_ctxlst_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_dataprivacy_rqst_ctxlst_id_seq OWNED BY public.mdl_tool_dataprivacy_rqst_ctxlst.id;


--
-- Name: mdl_tool_mfa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_mfa (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    factor character varying(100) DEFAULT ''::character varying NOT NULL,
    secret character varying(1333),
    label character varying(1333),
    timecreated bigint,
    createdfromip character varying(100),
    timemodified bigint,
    lastverified bigint,
    revoked smallint DEFAULT 0 NOT NULL,
    lockcounter integer DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_tool_mfa; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_mfa IS 'Table to store factor configurations for users';


--
-- Name: mdl_tool_mfa_auth; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_mfa_auth (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    lastverified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_tool_mfa_auth; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_mfa_auth IS 'Stores the last time a successful MFA auth was registered for a userid';


--
-- Name: mdl_tool_mfa_auth_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_mfa_auth_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_mfa_auth_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_mfa_auth_id_seq OWNED BY public.mdl_tool_mfa_auth.id;


--
-- Name: mdl_tool_mfa_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_mfa_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_mfa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_mfa_id_seq OWNED BY public.mdl_tool_mfa.id;


--
-- Name: mdl_tool_mfa_secrets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_mfa_secrets (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    factor character varying(100) DEFAULT ''::character varying NOT NULL,
    secret character varying(1333) DEFAULT ''::character varying NOT NULL,
    timecreated bigint NOT NULL,
    expiry bigint NOT NULL,
    revoked smallint DEFAULT 0 NOT NULL,
    sessionid character varying(100)
);


--
-- Name: TABLE mdl_tool_mfa_secrets; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_mfa_secrets IS 'Table to store factor secrets';


--
-- Name: mdl_tool_mfa_secrets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_mfa_secrets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_mfa_secrets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_mfa_secrets_id_seq OWNED BY public.mdl_tool_mfa_secrets.id;


--
-- Name: mdl_tool_monitor_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_monitor_events (
    id bigint NOT NULL,
    eventname character varying(254) DEFAULT ''::character varying NOT NULL,
    contextid bigint NOT NULL,
    contextlevel bigint NOT NULL,
    contextinstanceid bigint NOT NULL,
    link character varying(254) DEFAULT ''::character varying NOT NULL,
    courseid bigint NOT NULL,
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_tool_monitor_events; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_monitor_events IS 'A table that keeps a log of events related to subscriptions';


--
-- Name: mdl_tool_monitor_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_monitor_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_monitor_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_monitor_events_id_seq OWNED BY public.mdl_tool_monitor_events.id;


--
-- Name: mdl_tool_monitor_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_monitor_history (
    id bigint NOT NULL,
    sid bigint NOT NULL,
    userid bigint NOT NULL,
    timesent bigint NOT NULL
);


--
-- Name: TABLE mdl_tool_monitor_history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_monitor_history IS 'Table to store history of message notifications sent';


--
-- Name: mdl_tool_monitor_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_monitor_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_monitor_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_monitor_history_id_seq OWNED BY public.mdl_tool_monitor_history.id;


--
-- Name: mdl_tool_monitor_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_monitor_rules (
    id bigint NOT NULL,
    description text,
    descriptionformat smallint NOT NULL,
    name character varying(254) DEFAULT ''::character varying NOT NULL,
    userid bigint NOT NULL,
    courseid bigint NOT NULL,
    plugin character varying(254) DEFAULT ''::character varying NOT NULL,
    eventname character varying(254) DEFAULT ''::character varying NOT NULL,
    template text NOT NULL,
    templateformat smallint NOT NULL,
    frequency smallint NOT NULL,
    timewindow integer NOT NULL,
    timemodified bigint NOT NULL,
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_tool_monitor_rules; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_monitor_rules IS 'Table to store rules';


--
-- Name: mdl_tool_monitor_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_monitor_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_monitor_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_monitor_rules_id_seq OWNED BY public.mdl_tool_monitor_rules.id;


--
-- Name: mdl_tool_monitor_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_monitor_subscriptions (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    ruleid bigint NOT NULL,
    cmid bigint NOT NULL,
    userid bigint NOT NULL,
    timecreated bigint NOT NULL,
    lastnotificationsent bigint DEFAULT 0 NOT NULL,
    inactivedate bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_tool_monitor_subscriptions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_monitor_subscriptions IS 'Table to store user subscriptions to various rules';


--
-- Name: mdl_tool_monitor_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_monitor_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_monitor_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_monitor_subscriptions_id_seq OWNED BY public.mdl_tool_monitor_subscriptions.id;


--
-- Name: mdl_tool_policy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_policy (
    id bigint NOT NULL,
    sortorder integer DEFAULT 999 NOT NULL,
    currentversionid bigint
);


--
-- Name: TABLE mdl_tool_policy; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_policy IS 'Contains the list of policy documents defined on the site.';


--
-- Name: mdl_tool_policy_acceptances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_policy_acceptances (
    id bigint NOT NULL,
    policyversionid bigint NOT NULL,
    userid bigint NOT NULL,
    status smallint,
    lang character varying(30) DEFAULT ''::character varying NOT NULL,
    usermodified bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    note text
);


--
-- Name: TABLE mdl_tool_policy_acceptances; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_policy_acceptances IS 'Tracks users accepting the policy versions';


--
-- Name: mdl_tool_policy_acceptances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_policy_acceptances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_policy_acceptances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_policy_acceptances_id_seq OWNED BY public.mdl_tool_policy_acceptances.id;


--
-- Name: mdl_tool_policy_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_policy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_policy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_policy_id_seq OWNED BY public.mdl_tool_policy.id;


--
-- Name: mdl_tool_policy_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_policy_versions (
    id bigint NOT NULL,
    name character varying(1333) DEFAULT ''::character varying NOT NULL,
    type smallint DEFAULT 0 NOT NULL,
    audience smallint DEFAULT 0 NOT NULL,
    archived smallint DEFAULT 0 NOT NULL,
    usermodified bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    policyid bigint NOT NULL,
    agreementstyle smallint DEFAULT 0 NOT NULL,
    optional smallint DEFAULT 0 NOT NULL,
    revision character varying(1333) DEFAULT ''::character varying NOT NULL,
    summary text NOT NULL,
    summaryformat smallint NOT NULL,
    content text NOT NULL,
    contentformat smallint NOT NULL
);


--
-- Name: TABLE mdl_tool_policy_versions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_policy_versions IS 'Holds versions of the policy documents';


--
-- Name: mdl_tool_policy_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_policy_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_policy_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_policy_versions_id_seq OWNED BY public.mdl_tool_policy_versions.id;


--
-- Name: mdl_tool_recyclebin_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_recyclebin_category (
    id bigint NOT NULL,
    categoryid bigint NOT NULL,
    shortname character varying(255) DEFAULT ''::character varying NOT NULL,
    fullname character varying(255) DEFAULT ''::character varying NOT NULL,
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_tool_recyclebin_category; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_recyclebin_category IS 'A list of items in the category recycle bin';


--
-- Name: mdl_tool_recyclebin_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_recyclebin_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_recyclebin_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_recyclebin_category_id_seq OWNED BY public.mdl_tool_recyclebin_category.id;


--
-- Name: mdl_tool_recyclebin_course; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_recyclebin_course (
    id bigint NOT NULL,
    courseid bigint NOT NULL,
    section bigint NOT NULL,
    module bigint NOT NULL,
    name character varying(255),
    timecreated bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_tool_recyclebin_course; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_recyclebin_course IS 'A list of items in the course recycle bin';


--
-- Name: mdl_tool_recyclebin_course_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_recyclebin_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_recyclebin_course_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_recyclebin_course_id_seq OWNED BY public.mdl_tool_recyclebin_course.id;


--
-- Name: mdl_tool_usertours_steps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_usertours_steps (
    id bigint NOT NULL,
    tourid bigint NOT NULL,
    title text,
    content text,
    contentformat smallint DEFAULT 0 NOT NULL,
    targettype smallint NOT NULL,
    targetvalue text NOT NULL,
    sortorder bigint DEFAULT 0 NOT NULL,
    configdata text NOT NULL
);


--
-- Name: TABLE mdl_tool_usertours_steps; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_usertours_steps IS 'Steps in an tour';


--
-- Name: mdl_tool_usertours_steps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_usertours_steps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_usertours_steps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_usertours_steps_id_seq OWNED BY public.mdl_tool_usertours_steps.id;


--
-- Name: mdl_tool_usertours_tours; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_tool_usertours_tours (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    description text,
    pathmatch character varying(255),
    enabled smallint DEFAULT 0 NOT NULL,
    sortorder bigint DEFAULT 0 NOT NULL,
    endtourlabel character varying(255),
    configdata text NOT NULL,
    displaystepnumbers smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_tool_usertours_tours; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_tool_usertours_tours IS 'List of tours';


--
-- Name: mdl_tool_usertours_tours_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_tool_usertours_tours_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_tool_usertours_tours_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_tool_usertours_tours_id_seq OWNED BY public.mdl_tool_usertours_tours.id;


--
-- Name: mdl_upgrade_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_upgrade_log (
    id bigint NOT NULL,
    type bigint NOT NULL,
    plugin character varying(100),
    version character varying(100),
    targetversion character varying(100),
    info character varying(255) DEFAULT ''::character varying NOT NULL,
    details text,
    backtrace text,
    userid bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_upgrade_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_upgrade_log IS 'Upgrade logging';


--
-- Name: mdl_upgrade_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_upgrade_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_upgrade_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_upgrade_log_id_seq OWNED BY public.mdl_upgrade_log.id;


--
-- Name: mdl_url; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_url (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text,
    introformat smallint DEFAULT 0 NOT NULL,
    externalurl text NOT NULL,
    display smallint DEFAULT 0 NOT NULL,
    displayoptions text,
    parameters text,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_url IS 'each record is one url resource';


--
-- Name: mdl_url_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_url_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_url_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_url_id_seq OWNED BY public.mdl_url.id;


--
-- Name: mdl_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_user (
    id bigint NOT NULL,
    auth character varying(20) DEFAULT 'manual'::character varying NOT NULL,
    confirmed smallint DEFAULT 0 NOT NULL,
    policyagreed smallint DEFAULT 0 NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    suspended smallint DEFAULT 0 NOT NULL,
    mnethostid bigint DEFAULT 0 NOT NULL,
    username character varying(100) DEFAULT ''::character varying NOT NULL,
    password character varying(255) DEFAULT ''::character varying NOT NULL,
    idnumber character varying(255) DEFAULT ''::character varying NOT NULL,
    firstname character varying(100) DEFAULT ''::character varying NOT NULL,
    lastname character varying(100) DEFAULT ''::character varying NOT NULL,
    email character varying(100) DEFAULT ''::character varying NOT NULL,
    emailstop smallint DEFAULT 0 NOT NULL,
    phone1 character varying(20) DEFAULT ''::character varying NOT NULL,
    phone2 character varying(20) DEFAULT ''::character varying NOT NULL,
    institution character varying(255) DEFAULT ''::character varying NOT NULL,
    department character varying(255) DEFAULT ''::character varying NOT NULL,
    address character varying(255) DEFAULT ''::character varying NOT NULL,
    city character varying(120) DEFAULT ''::character varying NOT NULL,
    country character varying(2) DEFAULT ''::character varying NOT NULL,
    lang character varying(30) DEFAULT 'en'::character varying NOT NULL,
    calendartype character varying(30) DEFAULT 'gregorian'::character varying NOT NULL,
    theme character varying(50) DEFAULT ''::character varying NOT NULL,
    timezone character varying(100) DEFAULT '99'::character varying NOT NULL,
    firstaccess bigint DEFAULT 0 NOT NULL,
    lastaccess bigint DEFAULT 0 NOT NULL,
    lastlogin bigint DEFAULT 0 NOT NULL,
    currentlogin bigint DEFAULT 0 NOT NULL,
    lastip character varying(45) DEFAULT ''::character varying NOT NULL,
    secret character varying(15) DEFAULT ''::character varying NOT NULL,
    picture bigint DEFAULT 0 NOT NULL,
    description text,
    descriptionformat smallint DEFAULT 1 NOT NULL,
    mailformat smallint DEFAULT 1 NOT NULL,
    maildigest smallint DEFAULT 0 NOT NULL,
    maildisplay smallint DEFAULT 2 NOT NULL,
    autosubscribe smallint DEFAULT 1 NOT NULL,
    trackforums smallint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    trustbitmask bigint DEFAULT 0 NOT NULL,
    imagealt character varying(255),
    lastnamephonetic character varying(255),
    firstnamephonetic character varying(255),
    middlename character varying(255),
    alternatename character varying(255),
    moodlenetprofile character varying(255)
);


--
-- Name: TABLE mdl_user; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_user IS 'One record for each person';


--
-- Name: mdl_user_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_user_devices (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    appid character varying(128) DEFAULT ''::character varying NOT NULL,
    name character varying(32) DEFAULT ''::character varying NOT NULL,
    model character varying(32) DEFAULT ''::character varying NOT NULL,
    platform character varying(32) DEFAULT ''::character varying NOT NULL,
    version character varying(32) DEFAULT ''::character varying NOT NULL,
    pushid character varying(255) DEFAULT ''::character varying NOT NULL,
    uuid character varying(255) DEFAULT ''::character varying NOT NULL,
    publickey text,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL
);


--
-- Name: TABLE mdl_user_devices; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_user_devices IS 'This table stores user''s mobile devices information in order to send PUSH notifications';


--
-- Name: mdl_user_devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_user_devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_user_devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_user_devices_id_seq OWNED BY public.mdl_user_devices.id;


--
-- Name: mdl_user_enrolments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_user_enrolments (
    id bigint NOT NULL,
    status bigint DEFAULT 0 NOT NULL,
    enrolid bigint NOT NULL,
    userid bigint NOT NULL,
    timestart bigint DEFAULT 0 NOT NULL,
    timeend bigint DEFAULT 2147483647 NOT NULL,
    modifierid bigint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_user_enrolments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_user_enrolments IS 'Users participating in courses (aka enrolled users) - everybody who is participating/visible in course, that means both teachers and students';


--
-- Name: mdl_user_enrolments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_user_enrolments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_user_enrolments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_user_enrolments_id_seq OWNED BY public.mdl_user_enrolments.id;


--
-- Name: mdl_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_user_id_seq OWNED BY public.mdl_user.id;


--
-- Name: mdl_user_info_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_user_info_category (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    sortorder bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_user_info_category; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_user_info_category IS 'Customisable fields categories';


--
-- Name: mdl_user_info_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_user_info_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_user_info_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_user_info_category_id_seq OWNED BY public.mdl_user_info_category.id;


--
-- Name: mdl_user_info_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_user_info_data (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    fieldid bigint DEFAULT 0 NOT NULL,
    data text NOT NULL,
    dataformat smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_user_info_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_user_info_data IS 'Data for the customisable user fields';


--
-- Name: mdl_user_info_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_user_info_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_user_info_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_user_info_data_id_seq OWNED BY public.mdl_user_info_data.id;


--
-- Name: mdl_user_info_field; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_user_info_field (
    id bigint NOT NULL,
    shortname character varying(255) DEFAULT 'shortname'::character varying NOT NULL,
    name text NOT NULL,
    datatype character varying(255) DEFAULT ''::character varying NOT NULL,
    description text,
    descriptionformat smallint DEFAULT 0 NOT NULL,
    categoryid bigint DEFAULT 0 NOT NULL,
    sortorder bigint DEFAULT 0 NOT NULL,
    required smallint DEFAULT 0 NOT NULL,
    locked smallint DEFAULT 0 NOT NULL,
    visible smallint DEFAULT 0 NOT NULL,
    forceunique smallint DEFAULT 0 NOT NULL,
    signup smallint DEFAULT 0 NOT NULL,
    defaultdata text,
    defaultdataformat smallint DEFAULT 0 NOT NULL,
    param1 text,
    param2 text,
    param3 text,
    param4 text,
    param5 text
);


--
-- Name: TABLE mdl_user_info_field; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_user_info_field IS 'Customisable user profile fields';


--
-- Name: mdl_user_info_field_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_user_info_field_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_user_info_field_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_user_info_field_id_seq OWNED BY public.mdl_user_info_field.id;


--
-- Name: mdl_user_lastaccess; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_user_lastaccess (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    courseid bigint DEFAULT 0 NOT NULL,
    timeaccess bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_user_lastaccess; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_user_lastaccess IS 'To keep track of course page access times, used in online participants block, and participants list';


--
-- Name: mdl_user_lastaccess_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_user_lastaccess_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_user_lastaccess_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_user_lastaccess_id_seq OWNED BY public.mdl_user_lastaccess.id;


--
-- Name: mdl_user_password_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_user_password_history (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    hash character varying(255) DEFAULT ''::character varying NOT NULL,
    timecreated bigint NOT NULL
);


--
-- Name: TABLE mdl_user_password_history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_user_password_history IS 'A rotating log of hashes of previously used passwords for each user.';


--
-- Name: mdl_user_password_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_user_password_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_user_password_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_user_password_history_id_seq OWNED BY public.mdl_user_password_history.id;


--
-- Name: mdl_user_password_resets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_user_password_resets (
    id bigint NOT NULL,
    userid bigint NOT NULL,
    timerequested bigint NOT NULL,
    timererequested bigint DEFAULT 0 NOT NULL,
    token character varying(32) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_user_password_resets; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_user_password_resets IS 'table tracking password reset confirmation tokens';


--
-- Name: mdl_user_password_resets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_user_password_resets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_user_password_resets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_user_password_resets_id_seq OWNED BY public.mdl_user_password_resets.id;


--
-- Name: mdl_user_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_user_preferences (
    id bigint NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    value character varying(1333) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE mdl_user_preferences; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_user_preferences IS 'Allows modules to store arbitrary user preferences';


--
-- Name: mdl_user_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_user_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_user_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_user_preferences_id_seq OWNED BY public.mdl_user_preferences.id;


--
-- Name: mdl_user_private_key; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_user_private_key (
    id bigint NOT NULL,
    script character varying(128) DEFAULT ''::character varying NOT NULL,
    value character varying(128) DEFAULT ''::character varying NOT NULL,
    userid bigint NOT NULL,
    instance bigint,
    iprestriction character varying(255),
    validuntil bigint,
    timecreated bigint
);


--
-- Name: TABLE mdl_user_private_key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_user_private_key IS 'access keys used in cookieless scripts - rss, etc.';


--
-- Name: mdl_user_private_key_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_user_private_key_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_user_private_key_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_user_private_key_id_seq OWNED BY public.mdl_user_private_key.id;


--
-- Name: mdl_wiki; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_wiki (
    id bigint NOT NULL,
    course bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT 'Wiki'::character varying NOT NULL,
    intro text,
    introformat smallint DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    firstpagetitle character varying(255) DEFAULT 'First Page'::character varying NOT NULL,
    wikimode character varying(20) DEFAULT 'collaborative'::character varying NOT NULL,
    defaultformat character varying(20) DEFAULT 'creole'::character varying NOT NULL,
    forceformat smallint DEFAULT 1 NOT NULL,
    editbegin bigint DEFAULT 0 NOT NULL,
    editend bigint DEFAULT 0
);


--
-- Name: TABLE mdl_wiki; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_wiki IS 'Stores Wiki activity configuration';


--
-- Name: mdl_wiki_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_wiki_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_wiki_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_wiki_id_seq OWNED BY public.mdl_wiki.id;


--
-- Name: mdl_wiki_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_wiki_links (
    id bigint NOT NULL,
    subwikiid bigint DEFAULT 0 NOT NULL,
    frompageid bigint DEFAULT 0 NOT NULL,
    topageid bigint DEFAULT 0 NOT NULL,
    tomissingpage character varying(255)
);


--
-- Name: TABLE mdl_wiki_links; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_wiki_links IS 'Page wiki links';


--
-- Name: mdl_wiki_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_wiki_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_wiki_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_wiki_links_id_seq OWNED BY public.mdl_wiki_links.id;


--
-- Name: mdl_wiki_locks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_wiki_locks (
    id bigint NOT NULL,
    pageid bigint DEFAULT 0 NOT NULL,
    sectionname character varying(255),
    userid bigint DEFAULT 0 NOT NULL,
    lockedat bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_wiki_locks; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_wiki_locks IS 'Manages page locks';


--
-- Name: mdl_wiki_locks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_wiki_locks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_wiki_locks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_wiki_locks_id_seq OWNED BY public.mdl_wiki_locks.id;


--
-- Name: mdl_wiki_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_wiki_pages (
    id bigint NOT NULL,
    subwikiid bigint DEFAULT 0 NOT NULL,
    title character varying(255) DEFAULT 'title'::character varying NOT NULL,
    cachedcontent text NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    timemodified bigint DEFAULT 0 NOT NULL,
    timerendered bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL,
    pageviews bigint DEFAULT 0 NOT NULL,
    readonly smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_wiki_pages; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_wiki_pages IS 'Stores wiki pages';


--
-- Name: mdl_wiki_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_wiki_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_wiki_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_wiki_pages_id_seq OWNED BY public.mdl_wiki_pages.id;


--
-- Name: mdl_wiki_subwikis; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_wiki_subwikis (
    id bigint NOT NULL,
    wikiid bigint DEFAULT 0 NOT NULL,
    groupid bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_wiki_subwikis; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_wiki_subwikis IS 'Stores subwiki instances';


--
-- Name: mdl_wiki_subwikis_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_wiki_subwikis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_wiki_subwikis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_wiki_subwikis_id_seq OWNED BY public.mdl_wiki_subwikis.id;


--
-- Name: mdl_wiki_synonyms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_wiki_synonyms (
    id bigint NOT NULL,
    subwikiid bigint DEFAULT 0 NOT NULL,
    pageid bigint DEFAULT 0 NOT NULL,
    pagesynonym character varying(255) DEFAULT 'Pagesynonym'::character varying NOT NULL
);


--
-- Name: TABLE mdl_wiki_synonyms; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_wiki_synonyms IS 'Stores wiki pages synonyms';


--
-- Name: mdl_wiki_synonyms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_wiki_synonyms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_wiki_synonyms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_wiki_synonyms_id_seq OWNED BY public.mdl_wiki_synonyms.id;


--
-- Name: mdl_wiki_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_wiki_versions (
    id bigint NOT NULL,
    pageid bigint DEFAULT 0 NOT NULL,
    content text NOT NULL,
    contentformat character varying(20) DEFAULT 'creole'::character varying NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    timecreated bigint DEFAULT 0 NOT NULL,
    userid bigint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_wiki_versions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_wiki_versions IS 'Stores wiki page history';


--
-- Name: mdl_wiki_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_wiki_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_wiki_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_wiki_versions_id_seq OWNED BY public.mdl_wiki_versions.id;


--
-- Name: mdl_workshop; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_workshop (
    id bigint NOT NULL,
    course bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    intro text,
    introformat smallint DEFAULT 0 NOT NULL,
    instructauthors text,
    instructauthorsformat smallint DEFAULT 0 NOT NULL,
    instructreviewers text,
    instructreviewersformat smallint DEFAULT 0 NOT NULL,
    timemodified bigint NOT NULL,
    phase smallint DEFAULT 0,
    useexamples smallint DEFAULT 0,
    usepeerassessment smallint DEFAULT 0,
    useselfassessment smallint DEFAULT 0,
    grade numeric(10,5) DEFAULT 80,
    gradinggrade numeric(10,5) DEFAULT 20,
    strategy character varying(30) DEFAULT ''::character varying NOT NULL,
    evaluation character varying(30) DEFAULT ''::character varying NOT NULL,
    gradedecimals smallint DEFAULT 0,
    submissiontypetext smallint DEFAULT 1 NOT NULL,
    submissiontypefile smallint DEFAULT 1 NOT NULL,
    nattachments smallint DEFAULT 1,
    submissionfiletypes character varying(255),
    latesubmissions smallint DEFAULT 0,
    maxbytes bigint DEFAULT 100000,
    examplesmode smallint DEFAULT 0,
    submissionstart bigint DEFAULT 0,
    submissionend bigint DEFAULT 0,
    assessmentstart bigint DEFAULT 0,
    assessmentend bigint DEFAULT 0,
    phaseswitchassessment smallint DEFAULT 0 NOT NULL,
    conclusion text,
    conclusionformat smallint DEFAULT 1 NOT NULL,
    overallfeedbackmode smallint DEFAULT 1,
    overallfeedbackfiles smallint DEFAULT 0,
    overallfeedbackfiletypes character varying(255),
    overallfeedbackmaxbytes bigint DEFAULT 100000
);


--
-- Name: TABLE mdl_workshop; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_workshop IS 'This table keeps information about the module instances and their settings';


--
-- Name: mdl_workshop_aggregations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_workshop_aggregations (
    id bigint NOT NULL,
    workshopid bigint NOT NULL,
    userid bigint NOT NULL,
    gradinggrade numeric(10,5),
    timegraded bigint
);


--
-- Name: TABLE mdl_workshop_aggregations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_workshop_aggregations IS 'Aggregated grades for assessment are stored here. The aggregated grade for submission is stored in workshop_submissions';


--
-- Name: mdl_workshop_aggregations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_workshop_aggregations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_workshop_aggregations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_workshop_aggregations_id_seq OWNED BY public.mdl_workshop_aggregations.id;


--
-- Name: mdl_workshop_assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_workshop_assessments (
    id bigint NOT NULL,
    submissionid bigint NOT NULL,
    reviewerid bigint NOT NULL,
    weight bigint DEFAULT 1 NOT NULL,
    timecreated bigint DEFAULT 0,
    timemodified bigint DEFAULT 0,
    grade numeric(10,5),
    gradinggrade numeric(10,5),
    gradinggradeover numeric(10,5),
    gradinggradeoverby bigint,
    feedbackauthor text,
    feedbackauthorformat smallint DEFAULT 0,
    feedbackauthorattachment smallint DEFAULT 0,
    feedbackreviewer text,
    feedbackreviewerformat smallint DEFAULT 0
);


--
-- Name: TABLE mdl_workshop_assessments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_workshop_assessments IS 'Info about the made assessment and automatically calculated grade for it. The proposed grade can be overridden by teacher.';


--
-- Name: mdl_workshop_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_workshop_assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_workshop_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_workshop_assessments_id_seq OWNED BY public.mdl_workshop_assessments.id;


--
-- Name: mdl_workshop_grades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_workshop_grades (
    id bigint NOT NULL,
    assessmentid bigint NOT NULL,
    strategy character varying(30) DEFAULT ''::character varying NOT NULL,
    dimensionid bigint NOT NULL,
    grade numeric(10,5),
    peercomment text,
    peercommentformat smallint DEFAULT 0
);


--
-- Name: TABLE mdl_workshop_grades; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_workshop_grades IS 'How the reviewers filled-up the grading forms, given grades and comments';


--
-- Name: mdl_workshop_grades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_workshop_grades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_workshop_grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_workshop_grades_id_seq OWNED BY public.mdl_workshop_grades.id;


--
-- Name: mdl_workshop_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_workshop_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_workshop_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_workshop_id_seq OWNED BY public.mdl_workshop.id;


--
-- Name: mdl_workshop_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_workshop_submissions (
    id bigint NOT NULL,
    workshopid bigint NOT NULL,
    example smallint DEFAULT 0,
    authorid bigint NOT NULL,
    timecreated bigint NOT NULL,
    timemodified bigint NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    content text,
    contentformat smallint DEFAULT 0 NOT NULL,
    contenttrust smallint DEFAULT 0 NOT NULL,
    attachment smallint DEFAULT 0,
    grade numeric(10,5),
    gradeover numeric(10,5),
    gradeoverby bigint,
    feedbackauthor text,
    feedbackauthorformat smallint DEFAULT 0,
    timegraded bigint,
    published smallint DEFAULT 0,
    late smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE mdl_workshop_submissions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_workshop_submissions IS 'Info about the submission and the aggregation of the grade for submission, grade for assessment and final grade. Both grade for submission and grade for assessment can be overridden by teacher. Final grade is always the sum of them. All grades are st';


--
-- Name: mdl_workshop_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_workshop_submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_workshop_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_workshop_submissions_id_seq OWNED BY public.mdl_workshop_submissions.id;


--
-- Name: mdl_workshopallocation_scheduled; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_workshopallocation_scheduled (
    id bigint NOT NULL,
    workshopid bigint NOT NULL,
    enabled smallint DEFAULT 0 NOT NULL,
    submissionend bigint NOT NULL,
    timeallocated bigint,
    settings text,
    resultstatus bigint,
    resultmessage character varying(1333),
    resultlog text
);


--
-- Name: TABLE mdl_workshopallocation_scheduled; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_workshopallocation_scheduled IS 'Stores the allocation settings for the scheduled allocator';


--
-- Name: mdl_workshopallocation_scheduled_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_workshopallocation_scheduled_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_workshopallocation_scheduled_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_workshopallocation_scheduled_id_seq OWNED BY public.mdl_workshopallocation_scheduled.id;


--
-- Name: mdl_workshopeval_best_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_workshopeval_best_settings (
    id bigint NOT NULL,
    workshopid bigint NOT NULL,
    comparison smallint DEFAULT 5
);


--
-- Name: TABLE mdl_workshopeval_best_settings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_workshopeval_best_settings IS 'Settings for the grading evaluation subplugin Comparison with the best assessment.';


--
-- Name: mdl_workshopeval_best_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_workshopeval_best_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_workshopeval_best_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_workshopeval_best_settings_id_seq OWNED BY public.mdl_workshopeval_best_settings.id;


--
-- Name: mdl_workshopform_accumulative; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_workshopform_accumulative (
    id bigint NOT NULL,
    workshopid bigint NOT NULL,
    sort bigint DEFAULT 0,
    description text,
    descriptionformat smallint DEFAULT 0,
    grade bigint NOT NULL,
    weight integer DEFAULT 1
);


--
-- Name: TABLE mdl_workshopform_accumulative; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_workshopform_accumulative IS 'The assessment dimensions definitions of Accumulative grading strategy forms';


--
-- Name: mdl_workshopform_accumulative_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_workshopform_accumulative_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_workshopform_accumulative_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_workshopform_accumulative_id_seq OWNED BY public.mdl_workshopform_accumulative.id;


--
-- Name: mdl_workshopform_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_workshopform_comments (
    id bigint NOT NULL,
    workshopid bigint NOT NULL,
    sort bigint DEFAULT 0,
    description text,
    descriptionformat smallint DEFAULT 0
);


--
-- Name: TABLE mdl_workshopform_comments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_workshopform_comments IS 'The assessment dimensions definitions of Comments strategy forms';


--
-- Name: mdl_workshopform_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_workshopform_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_workshopform_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_workshopform_comments_id_seq OWNED BY public.mdl_workshopform_comments.id;


--
-- Name: mdl_workshopform_numerrors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_workshopform_numerrors (
    id bigint NOT NULL,
    workshopid bigint NOT NULL,
    sort bigint DEFAULT 0,
    description text,
    descriptionformat smallint DEFAULT 0,
    descriptiontrust bigint,
    grade0 character varying(50),
    grade1 character varying(50),
    weight integer DEFAULT 1
);


--
-- Name: TABLE mdl_workshopform_numerrors; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_workshopform_numerrors IS 'The assessment dimensions definitions of Number of errors grading strategy forms';


--
-- Name: mdl_workshopform_numerrors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_workshopform_numerrors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_workshopform_numerrors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_workshopform_numerrors_id_seq OWNED BY public.mdl_workshopform_numerrors.id;


--
-- Name: mdl_workshopform_numerrors_map; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_workshopform_numerrors_map (
    id bigint NOT NULL,
    workshopid bigint NOT NULL,
    nonegative bigint NOT NULL,
    grade numeric(10,5) NOT NULL
);


--
-- Name: TABLE mdl_workshopform_numerrors_map; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_workshopform_numerrors_map IS 'This maps the number of errors to a percentual grade for submission';


--
-- Name: mdl_workshopform_numerrors_map_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_workshopform_numerrors_map_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_workshopform_numerrors_map_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_workshopform_numerrors_map_id_seq OWNED BY public.mdl_workshopform_numerrors_map.id;


--
-- Name: mdl_workshopform_rubric; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_workshopform_rubric (
    id bigint NOT NULL,
    workshopid bigint NOT NULL,
    sort bigint DEFAULT 0,
    description text,
    descriptionformat smallint DEFAULT 0
);


--
-- Name: TABLE mdl_workshopform_rubric; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_workshopform_rubric IS 'The assessment dimensions definitions of Rubric grading strategy forms';


--
-- Name: mdl_workshopform_rubric_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_workshopform_rubric_config (
    id bigint NOT NULL,
    workshopid bigint NOT NULL,
    layout character varying(30) DEFAULT 'list'::character varying
);


--
-- Name: TABLE mdl_workshopform_rubric_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_workshopform_rubric_config IS 'Configuration table for the Rubric grading strategy';


--
-- Name: mdl_workshopform_rubric_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_workshopform_rubric_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_workshopform_rubric_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_workshopform_rubric_config_id_seq OWNED BY public.mdl_workshopform_rubric_config.id;


--
-- Name: mdl_workshopform_rubric_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_workshopform_rubric_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_workshopform_rubric_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_workshopform_rubric_id_seq OWNED BY public.mdl_workshopform_rubric.id;


--
-- Name: mdl_workshopform_rubric_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_workshopform_rubric_levels (
    id bigint NOT NULL,
    dimensionid bigint NOT NULL,
    grade numeric(10,5) NOT NULL,
    definition text,
    definitionformat smallint DEFAULT 0
);


--
-- Name: TABLE mdl_workshopform_rubric_levels; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_workshopform_rubric_levels IS 'The definition of rubric rating scales';


--
-- Name: mdl_workshopform_rubric_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_workshopform_rubric_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_workshopform_rubric_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_workshopform_rubric_levels_id_seq OWNED BY public.mdl_workshopform_rubric_levels.id;


--
-- Name: mdl_xapi_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mdl_xapi_states (
    id bigint NOT NULL,
    component character varying(255) DEFAULT ''::character varying NOT NULL,
    userid bigint,
    itemid bigint NOT NULL,
    stateid character varying(255) DEFAULT ''::character varying NOT NULL,
    statedata text,
    registration character varying(255),
    timecreated bigint NOT NULL,
    timemodified bigint
);


--
-- Name: TABLE mdl_xapi_states; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.mdl_xapi_states IS 'The stored xAPI states';


--
-- Name: mdl_xapi_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mdl_xapi_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mdl_xapi_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mdl_xapi_states_id_seq OWNED BY public.mdl_xapi_states.id;


--
-- Name: mdl_adminpresets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_adminpresets ALTER COLUMN id SET DEFAULT nextval('public.mdl_adminpresets_id_seq'::regclass);


--
-- Name: mdl_adminpresets_app id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_adminpresets_app ALTER COLUMN id SET DEFAULT nextval('public.mdl_adminpresets_app_id_seq'::regclass);


--
-- Name: mdl_adminpresets_app_it id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_adminpresets_app_it ALTER COLUMN id SET DEFAULT nextval('public.mdl_adminpresets_app_it_id_seq'::regclass);


--
-- Name: mdl_adminpresets_app_it_a id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_adminpresets_app_it_a ALTER COLUMN id SET DEFAULT nextval('public.mdl_adminpresets_app_it_a_id_seq'::regclass);


--
-- Name: mdl_adminpresets_app_plug id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_adminpresets_app_plug ALTER COLUMN id SET DEFAULT nextval('public.mdl_adminpresets_app_plug_id_seq'::regclass);


--
-- Name: mdl_adminpresets_it id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_adminpresets_it ALTER COLUMN id SET DEFAULT nextval('public.mdl_adminpresets_it_id_seq'::regclass);


--
-- Name: mdl_adminpresets_it_a id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_adminpresets_it_a ALTER COLUMN id SET DEFAULT nextval('public.mdl_adminpresets_it_a_id_seq'::regclass);


--
-- Name: mdl_adminpresets_plug id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_adminpresets_plug ALTER COLUMN id SET DEFAULT nextval('public.mdl_adminpresets_plug_id_seq'::regclass);


--
-- Name: mdl_ai_action_generate_image id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_ai_action_generate_image ALTER COLUMN id SET DEFAULT nextval('public.mdl_ai_action_generate_image_id_seq'::regclass);


--
-- Name: mdl_ai_action_generate_text id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_ai_action_generate_text ALTER COLUMN id SET DEFAULT nextval('public.mdl_ai_action_generate_text_id_seq'::regclass);


--
-- Name: mdl_ai_action_register id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_ai_action_register ALTER COLUMN id SET DEFAULT nextval('public.mdl_ai_action_register_id_seq'::regclass);


--
-- Name: mdl_ai_action_summarise_text id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_ai_action_summarise_text ALTER COLUMN id SET DEFAULT nextval('public.mdl_ai_action_summarise_text_id_seq'::regclass);


--
-- Name: mdl_ai_policy_register id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_ai_policy_register ALTER COLUMN id SET DEFAULT nextval('public.mdl_ai_policy_register_id_seq'::regclass);


--
-- Name: mdl_analytics_indicator_calc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_indicator_calc ALTER COLUMN id SET DEFAULT nextval('public.mdl_analytics_indicator_calc_id_seq'::regclass);


--
-- Name: mdl_analytics_models id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_models ALTER COLUMN id SET DEFAULT nextval('public.mdl_analytics_models_id_seq'::regclass);


--
-- Name: mdl_analytics_models_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_models_log ALTER COLUMN id SET DEFAULT nextval('public.mdl_analytics_models_log_id_seq'::regclass);


--
-- Name: mdl_analytics_predict_samples id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_predict_samples ALTER COLUMN id SET DEFAULT nextval('public.mdl_analytics_predict_samples_id_seq'::regclass);


--
-- Name: mdl_analytics_prediction_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_prediction_actions ALTER COLUMN id SET DEFAULT nextval('public.mdl_analytics_prediction_actions_id_seq'::regclass);


--
-- Name: mdl_analytics_predictions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_predictions ALTER COLUMN id SET DEFAULT nextval('public.mdl_analytics_predictions_id_seq'::regclass);


--
-- Name: mdl_analytics_train_samples id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_train_samples ALTER COLUMN id SET DEFAULT nextval('public.mdl_analytics_train_samples_id_seq'::regclass);


--
-- Name: mdl_analytics_used_analysables id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_used_analysables ALTER COLUMN id SET DEFAULT nextval('public.mdl_analytics_used_analysables_id_seq'::regclass);


--
-- Name: mdl_analytics_used_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_used_files ALTER COLUMN id SET DEFAULT nextval('public.mdl_analytics_used_files_id_seq'::regclass);


--
-- Name: mdl_assign id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assign ALTER COLUMN id SET DEFAULT nextval('public.mdl_assign_id_seq'::regclass);


--
-- Name: mdl_assign_grades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assign_grades ALTER COLUMN id SET DEFAULT nextval('public.mdl_assign_grades_id_seq'::regclass);


--
-- Name: mdl_assign_overrides id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assign_overrides ALTER COLUMN id SET DEFAULT nextval('public.mdl_assign_overrides_id_seq'::regclass);


--
-- Name: mdl_assign_plugin_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assign_plugin_config ALTER COLUMN id SET DEFAULT nextval('public.mdl_assign_plugin_config_id_seq'::regclass);


--
-- Name: mdl_assign_submission id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assign_submission ALTER COLUMN id SET DEFAULT nextval('public.mdl_assign_submission_id_seq'::regclass);


--
-- Name: mdl_assign_user_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assign_user_flags ALTER COLUMN id SET DEFAULT nextval('public.mdl_assign_user_flags_id_seq'::regclass);


--
-- Name: mdl_assign_user_mapping id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assign_user_mapping ALTER COLUMN id SET DEFAULT nextval('public.mdl_assign_user_mapping_id_seq'::regclass);


--
-- Name: mdl_assignfeedback_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assignfeedback_comments ALTER COLUMN id SET DEFAULT nextval('public.mdl_assignfeedback_comments_id_seq'::regclass);


--
-- Name: mdl_assignfeedback_editpdf_annot id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assignfeedback_editpdf_annot ALTER COLUMN id SET DEFAULT nextval('public.mdl_assignfeedback_editpdf_annot_id_seq'::regclass);


--
-- Name: mdl_assignfeedback_editpdf_cmnt id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assignfeedback_editpdf_cmnt ALTER COLUMN id SET DEFAULT nextval('public.mdl_assignfeedback_editpdf_cmnt_id_seq'::regclass);


--
-- Name: mdl_assignfeedback_editpdf_quick id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assignfeedback_editpdf_quick ALTER COLUMN id SET DEFAULT nextval('public.mdl_assignfeedback_editpdf_quick_id_seq'::regclass);


--
-- Name: mdl_assignfeedback_editpdf_rot id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assignfeedback_editpdf_rot ALTER COLUMN id SET DEFAULT nextval('public.mdl_assignfeedback_editpdf_rot_id_seq'::regclass);


--
-- Name: mdl_assignfeedback_file id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assignfeedback_file ALTER COLUMN id SET DEFAULT nextval('public.mdl_assignfeedback_file_id_seq'::regclass);


--
-- Name: mdl_assignsubmission_file id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assignsubmission_file ALTER COLUMN id SET DEFAULT nextval('public.mdl_assignsubmission_file_id_seq'::regclass);


--
-- Name: mdl_assignsubmission_onlinetext id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assignsubmission_onlinetext ALTER COLUMN id SET DEFAULT nextval('public.mdl_assignsubmission_onlinetext_id_seq'::regclass);


--
-- Name: mdl_auth_lti_linked_login id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_auth_lti_linked_login ALTER COLUMN id SET DEFAULT nextval('public.mdl_auth_lti_linked_login_id_seq'::regclass);


--
-- Name: mdl_auth_oauth2_linked_login id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_auth_oauth2_linked_login ALTER COLUMN id SET DEFAULT nextval('public.mdl_auth_oauth2_linked_login_id_seq'::regclass);


--
-- Name: mdl_backup_controllers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_backup_controllers ALTER COLUMN id SET DEFAULT nextval('public.mdl_backup_controllers_id_seq'::regclass);


--
-- Name: mdl_backup_courses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_backup_courses ALTER COLUMN id SET DEFAULT nextval('public.mdl_backup_courses_id_seq'::regclass);


--
-- Name: mdl_backup_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_backup_logs ALTER COLUMN id SET DEFAULT nextval('public.mdl_backup_logs_id_seq'::regclass);


--
-- Name: mdl_badge id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge ALTER COLUMN id SET DEFAULT nextval('public.mdl_badge_id_seq'::regclass);


--
-- Name: mdl_badge_alignment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_alignment ALTER COLUMN id SET DEFAULT nextval('public.mdl_badge_alignment_id_seq'::regclass);


--
-- Name: mdl_badge_backpack id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_backpack ALTER COLUMN id SET DEFAULT nextval('public.mdl_badge_backpack_id_seq'::regclass);


--
-- Name: mdl_badge_backpack_oauth2 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_backpack_oauth2 ALTER COLUMN id SET DEFAULT nextval('public.mdl_badge_backpack_oauth2_id_seq'::regclass);


--
-- Name: mdl_badge_criteria id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_criteria ALTER COLUMN id SET DEFAULT nextval('public.mdl_badge_criteria_id_seq'::regclass);


--
-- Name: mdl_badge_criteria_met id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_criteria_met ALTER COLUMN id SET DEFAULT nextval('public.mdl_badge_criteria_met_id_seq'::regclass);


--
-- Name: mdl_badge_criteria_param id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_criteria_param ALTER COLUMN id SET DEFAULT nextval('public.mdl_badge_criteria_param_id_seq'::regclass);


--
-- Name: mdl_badge_endorsement id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_endorsement ALTER COLUMN id SET DEFAULT nextval('public.mdl_badge_endorsement_id_seq'::regclass);


--
-- Name: mdl_badge_external id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_external ALTER COLUMN id SET DEFAULT nextval('public.mdl_badge_external_id_seq'::regclass);


--
-- Name: mdl_badge_external_backpack id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_external_backpack ALTER COLUMN id SET DEFAULT nextval('public.mdl_badge_external_backpack_id_seq'::regclass);


--
-- Name: mdl_badge_external_identifier id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_external_identifier ALTER COLUMN id SET DEFAULT nextval('public.mdl_badge_external_identifier_id_seq'::regclass);


--
-- Name: mdl_badge_issued id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_issued ALTER COLUMN id SET DEFAULT nextval('public.mdl_badge_issued_id_seq'::regclass);


--
-- Name: mdl_badge_manual_award id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_manual_award ALTER COLUMN id SET DEFAULT nextval('public.mdl_badge_manual_award_id_seq'::regclass);


--
-- Name: mdl_badge_related id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_related ALTER COLUMN id SET DEFAULT nextval('public.mdl_badge_related_id_seq'::regclass);


--
-- Name: mdl_bigbluebuttonbn id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_bigbluebuttonbn ALTER COLUMN id SET DEFAULT nextval('public.mdl_bigbluebuttonbn_id_seq'::regclass);


--
-- Name: mdl_bigbluebuttonbn_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_bigbluebuttonbn_logs ALTER COLUMN id SET DEFAULT nextval('public.mdl_bigbluebuttonbn_logs_id_seq'::regclass);


--
-- Name: mdl_bigbluebuttonbn_recordings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_bigbluebuttonbn_recordings ALTER COLUMN id SET DEFAULT nextval('public.mdl_bigbluebuttonbn_recordings_id_seq'::regclass);


--
-- Name: mdl_block id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_block ALTER COLUMN id SET DEFAULT nextval('public.mdl_block_id_seq'::regclass);


--
-- Name: mdl_block_instances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_block_instances ALTER COLUMN id SET DEFAULT nextval('public.mdl_block_instances_id_seq'::regclass);


--
-- Name: mdl_block_positions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_block_positions ALTER COLUMN id SET DEFAULT nextval('public.mdl_block_positions_id_seq'::regclass);


--
-- Name: mdl_block_recent_activity id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_block_recent_activity ALTER COLUMN id SET DEFAULT nextval('public.mdl_block_recent_activity_id_seq'::regclass);


--
-- Name: mdl_block_recentlyaccesseditems id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_block_recentlyaccesseditems ALTER COLUMN id SET DEFAULT nextval('public.mdl_block_recentlyaccesseditems_id_seq'::regclass);


--
-- Name: mdl_block_rss_client id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_block_rss_client ALTER COLUMN id SET DEFAULT nextval('public.mdl_block_rss_client_id_seq'::regclass);


--
-- Name: mdl_blog_association id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_blog_association ALTER COLUMN id SET DEFAULT nextval('public.mdl_blog_association_id_seq'::regclass);


--
-- Name: mdl_blog_external id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_blog_external ALTER COLUMN id SET DEFAULT nextval('public.mdl_blog_external_id_seq'::regclass);


--
-- Name: mdl_book id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_book ALTER COLUMN id SET DEFAULT nextval('public.mdl_book_id_seq'::regclass);


--
-- Name: mdl_book_chapters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_book_chapters ALTER COLUMN id SET DEFAULT nextval('public.mdl_book_chapters_id_seq'::regclass);


--
-- Name: mdl_cache_filters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_cache_filters ALTER COLUMN id SET DEFAULT nextval('public.mdl_cache_filters_id_seq'::regclass);


--
-- Name: mdl_cache_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_cache_flags ALTER COLUMN id SET DEFAULT nextval('public.mdl_cache_flags_id_seq'::regclass);


--
-- Name: mdl_capabilities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_capabilities ALTER COLUMN id SET DEFAULT nextval('public.mdl_capabilities_id_seq'::regclass);


--
-- Name: mdl_chat id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_chat ALTER COLUMN id SET DEFAULT nextval('public.mdl_chat_id_seq'::regclass);


--
-- Name: mdl_chat_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_chat_messages ALTER COLUMN id SET DEFAULT nextval('public.mdl_chat_messages_id_seq'::regclass);


--
-- Name: mdl_chat_messages_current id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_chat_messages_current ALTER COLUMN id SET DEFAULT nextval('public.mdl_chat_messages_current_id_seq'::regclass);


--
-- Name: mdl_chat_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_chat_users ALTER COLUMN id SET DEFAULT nextval('public.mdl_chat_users_id_seq'::regclass);


--
-- Name: mdl_choice id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_choice ALTER COLUMN id SET DEFAULT nextval('public.mdl_choice_id_seq'::regclass);


--
-- Name: mdl_choice_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_choice_answers ALTER COLUMN id SET DEFAULT nextval('public.mdl_choice_answers_id_seq'::regclass);


--
-- Name: mdl_choice_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_choice_options ALTER COLUMN id SET DEFAULT nextval('public.mdl_choice_options_id_seq'::regclass);


--
-- Name: mdl_cohort id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_cohort ALTER COLUMN id SET DEFAULT nextval('public.mdl_cohort_id_seq'::regclass);


--
-- Name: mdl_cohort_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_cohort_members ALTER COLUMN id SET DEFAULT nextval('public.mdl_cohort_members_id_seq'::regclass);


--
-- Name: mdl_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_comments ALTER COLUMN id SET DEFAULT nextval('public.mdl_comments_id_seq'::regclass);


--
-- Name: mdl_communication id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_communication ALTER COLUMN id SET DEFAULT nextval('public.mdl_communication_id_seq'::regclass);


--
-- Name: mdl_communication_customlink id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_communication_customlink ALTER COLUMN id SET DEFAULT nextval('public.mdl_communication_customlink_id_seq'::regclass);


--
-- Name: mdl_communication_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_communication_user ALTER COLUMN id SET DEFAULT nextval('public.mdl_communication_user_id_seq'::regclass);


--
-- Name: mdl_competency id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_id_seq'::regclass);


--
-- Name: mdl_competency_coursecomp id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_coursecomp ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_coursecomp_id_seq'::regclass);


--
-- Name: mdl_competency_coursecompsetting id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_coursecompsetting ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_coursecompsetting_id_seq'::regclass);


--
-- Name: mdl_competency_evidence id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_evidence ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_evidence_id_seq'::regclass);


--
-- Name: mdl_competency_framework id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_framework ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_framework_id_seq'::regclass);


--
-- Name: mdl_competency_modulecomp id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_modulecomp ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_modulecomp_id_seq'::regclass);


--
-- Name: mdl_competency_plan id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_plan ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_plan_id_seq'::regclass);


--
-- Name: mdl_competency_plancomp id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_plancomp ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_plancomp_id_seq'::regclass);


--
-- Name: mdl_competency_relatedcomp id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_relatedcomp ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_relatedcomp_id_seq'::regclass);


--
-- Name: mdl_competency_template id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_template ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_template_id_seq'::regclass);


--
-- Name: mdl_competency_templatecohort id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_templatecohort ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_templatecohort_id_seq'::regclass);


--
-- Name: mdl_competency_templatecomp id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_templatecomp ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_templatecomp_id_seq'::regclass);


--
-- Name: mdl_competency_usercomp id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_usercomp ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_usercomp_id_seq'::regclass);


--
-- Name: mdl_competency_usercompcourse id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_usercompcourse ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_usercompcourse_id_seq'::regclass);


--
-- Name: mdl_competency_usercompplan id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_usercompplan ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_usercompplan_id_seq'::regclass);


--
-- Name: mdl_competency_userevidence id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_userevidence ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_userevidence_id_seq'::regclass);


--
-- Name: mdl_competency_userevidencecomp id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_userevidencecomp ALTER COLUMN id SET DEFAULT nextval('public.mdl_competency_userevidencecomp_id_seq'::regclass);


--
-- Name: mdl_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_config ALTER COLUMN id SET DEFAULT nextval('public.mdl_config_id_seq'::regclass);


--
-- Name: mdl_config_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_config_log ALTER COLUMN id SET DEFAULT nextval('public.mdl_config_log_id_seq'::regclass);


--
-- Name: mdl_config_plugins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_config_plugins ALTER COLUMN id SET DEFAULT nextval('public.mdl_config_plugins_id_seq'::regclass);


--
-- Name: mdl_contentbank_content id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_contentbank_content ALTER COLUMN id SET DEFAULT nextval('public.mdl_contentbank_content_id_seq'::regclass);


--
-- Name: mdl_context id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_context ALTER COLUMN id SET DEFAULT nextval('public.mdl_context_id_seq'::regclass);


--
-- Name: mdl_course id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course ALTER COLUMN id SET DEFAULT nextval('public.mdl_course_id_seq'::regclass);


--
-- Name: mdl_course_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_categories ALTER COLUMN id SET DEFAULT nextval('public.mdl_course_categories_id_seq'::regclass);


--
-- Name: mdl_course_completion_aggr_methd id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_completion_aggr_methd ALTER COLUMN id SET DEFAULT nextval('public.mdl_course_completion_aggr_methd_id_seq'::regclass);


--
-- Name: mdl_course_completion_crit_compl id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_completion_crit_compl ALTER COLUMN id SET DEFAULT nextval('public.mdl_course_completion_crit_compl_id_seq'::regclass);


--
-- Name: mdl_course_completion_criteria id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_completion_criteria ALTER COLUMN id SET DEFAULT nextval('public.mdl_course_completion_criteria_id_seq'::regclass);


--
-- Name: mdl_course_completion_defaults id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_completion_defaults ALTER COLUMN id SET DEFAULT nextval('public.mdl_course_completion_defaults_id_seq'::regclass);


--
-- Name: mdl_course_completions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_completions ALTER COLUMN id SET DEFAULT nextval('public.mdl_course_completions_id_seq'::regclass);


--
-- Name: mdl_course_format_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_format_options ALTER COLUMN id SET DEFAULT nextval('public.mdl_course_format_options_id_seq'::regclass);


--
-- Name: mdl_course_modules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_modules ALTER COLUMN id SET DEFAULT nextval('public.mdl_course_modules_id_seq'::regclass);


--
-- Name: mdl_course_modules_completion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_modules_completion ALTER COLUMN id SET DEFAULT nextval('public.mdl_course_modules_completion_id_seq'::regclass);


--
-- Name: mdl_course_modules_viewed id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_modules_viewed ALTER COLUMN id SET DEFAULT nextval('public.mdl_course_modules_viewed_id_seq'::regclass);


--
-- Name: mdl_course_published id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_published ALTER COLUMN id SET DEFAULT nextval('public.mdl_course_published_id_seq'::regclass);


--
-- Name: mdl_course_request id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_request ALTER COLUMN id SET DEFAULT nextval('public.mdl_course_request_id_seq'::regclass);


--
-- Name: mdl_course_sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_sections ALTER COLUMN id SET DEFAULT nextval('public.mdl_course_sections_id_seq'::regclass);


--
-- Name: mdl_customfield_category id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_customfield_category ALTER COLUMN id SET DEFAULT nextval('public.mdl_customfield_category_id_seq'::regclass);


--
-- Name: mdl_customfield_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_customfield_data ALTER COLUMN id SET DEFAULT nextval('public.mdl_customfield_data_id_seq'::regclass);


--
-- Name: mdl_customfield_field id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_customfield_field ALTER COLUMN id SET DEFAULT nextval('public.mdl_customfield_field_id_seq'::regclass);


--
-- Name: mdl_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_data ALTER COLUMN id SET DEFAULT nextval('public.mdl_data_id_seq'::regclass);


--
-- Name: mdl_data_content id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_data_content ALTER COLUMN id SET DEFAULT nextval('public.mdl_data_content_id_seq'::regclass);


--
-- Name: mdl_data_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_data_fields ALTER COLUMN id SET DEFAULT nextval('public.mdl_data_fields_id_seq'::regclass);


--
-- Name: mdl_data_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_data_records ALTER COLUMN id SET DEFAULT nextval('public.mdl_data_records_id_seq'::regclass);


--
-- Name: mdl_editor_atto_autosave id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_editor_atto_autosave ALTER COLUMN id SET DEFAULT nextval('public.mdl_editor_atto_autosave_id_seq'::regclass);


--
-- Name: mdl_enrol id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_id_seq'::regclass);


--
-- Name: mdl_enrol_flatfile id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_flatfile ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_flatfile_id_seq'::regclass);


--
-- Name: mdl_enrol_lti_app_registration id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_app_registration ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_lti_app_registration_id_seq'::regclass);


--
-- Name: mdl_enrol_lti_context id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_context ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_lti_context_id_seq'::regclass);


--
-- Name: mdl_enrol_lti_deployment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_deployment ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_lti_deployment_id_seq'::regclass);


--
-- Name: mdl_enrol_lti_lti2_consumer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_lti2_consumer ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_lti_lti2_consumer_id_seq'::regclass);


--
-- Name: mdl_enrol_lti_lti2_context id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_lti2_context ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_lti_lti2_context_id_seq'::regclass);


--
-- Name: mdl_enrol_lti_lti2_nonce id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_lti2_nonce ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_lti_lti2_nonce_id_seq'::regclass);


--
-- Name: mdl_enrol_lti_lti2_resource_link id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_lti2_resource_link ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_lti_lti2_resource_link_id_seq'::regclass);


--
-- Name: mdl_enrol_lti_lti2_share_key id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_lti2_share_key ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_lti_lti2_share_key_id_seq'::regclass);


--
-- Name: mdl_enrol_lti_lti2_tool_proxy id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_lti2_tool_proxy ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_lti_lti2_tool_proxy_id_seq'::regclass);


--
-- Name: mdl_enrol_lti_lti2_user_result id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_lti2_user_result ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_lti_lti2_user_result_id_seq'::regclass);


--
-- Name: mdl_enrol_lti_resource_link id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_resource_link ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_lti_resource_link_id_seq'::regclass);


--
-- Name: mdl_enrol_lti_tool_consumer_map id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_tool_consumer_map ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_lti_tool_consumer_map_id_seq'::regclass);


--
-- Name: mdl_enrol_lti_tools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_tools ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_lti_tools_id_seq'::regclass);


--
-- Name: mdl_enrol_lti_user_resource_link id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_user_resource_link ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_lti_user_resource_link_id_seq'::regclass);


--
-- Name: mdl_enrol_lti_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_users ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_lti_users_id_seq'::regclass);


--
-- Name: mdl_enrol_paypal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_paypal ALTER COLUMN id SET DEFAULT nextval('public.mdl_enrol_paypal_id_seq'::regclass);


--
-- Name: mdl_event id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_event ALTER COLUMN id SET DEFAULT nextval('public.mdl_event_id_seq'::regclass);


--
-- Name: mdl_event_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_event_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.mdl_event_subscriptions_id_seq'::regclass);


--
-- Name: mdl_events_handlers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_events_handlers ALTER COLUMN id SET DEFAULT nextval('public.mdl_events_handlers_id_seq'::regclass);


--
-- Name: mdl_events_queue id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_events_queue ALTER COLUMN id SET DEFAULT nextval('public.mdl_events_queue_id_seq'::regclass);


--
-- Name: mdl_events_queue_handlers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_events_queue_handlers ALTER COLUMN id SET DEFAULT nextval('public.mdl_events_queue_handlers_id_seq'::regclass);


--
-- Name: mdl_external_functions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_external_functions ALTER COLUMN id SET DEFAULT nextval('public.mdl_external_functions_id_seq'::regclass);


--
-- Name: mdl_external_services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_external_services ALTER COLUMN id SET DEFAULT nextval('public.mdl_external_services_id_seq'::regclass);


--
-- Name: mdl_external_services_functions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_external_services_functions ALTER COLUMN id SET DEFAULT nextval('public.mdl_external_services_functions_id_seq'::regclass);


--
-- Name: mdl_external_services_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_external_services_users ALTER COLUMN id SET DEFAULT nextval('public.mdl_external_services_users_id_seq'::regclass);


--
-- Name: mdl_external_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_external_tokens ALTER COLUMN id SET DEFAULT nextval('public.mdl_external_tokens_id_seq'::regclass);


--
-- Name: mdl_favourite id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_favourite ALTER COLUMN id SET DEFAULT nextval('public.mdl_favourite_id_seq'::regclass);


--
-- Name: mdl_feedback id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_feedback ALTER COLUMN id SET DEFAULT nextval('public.mdl_feedback_id_seq'::regclass);


--
-- Name: mdl_feedback_completed id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_feedback_completed ALTER COLUMN id SET DEFAULT nextval('public.mdl_feedback_completed_id_seq'::regclass);


--
-- Name: mdl_feedback_completedtmp id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_feedback_completedtmp ALTER COLUMN id SET DEFAULT nextval('public.mdl_feedback_completedtmp_id_seq'::regclass);


--
-- Name: mdl_feedback_item id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_feedback_item ALTER COLUMN id SET DEFAULT nextval('public.mdl_feedback_item_id_seq'::regclass);


--
-- Name: mdl_feedback_sitecourse_map id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_feedback_sitecourse_map ALTER COLUMN id SET DEFAULT nextval('public.mdl_feedback_sitecourse_map_id_seq'::regclass);


--
-- Name: mdl_feedback_template id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_feedback_template ALTER COLUMN id SET DEFAULT nextval('public.mdl_feedback_template_id_seq'::regclass);


--
-- Name: mdl_feedback_value id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_feedback_value ALTER COLUMN id SET DEFAULT nextval('public.mdl_feedback_value_id_seq'::regclass);


--
-- Name: mdl_feedback_valuetmp id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_feedback_valuetmp ALTER COLUMN id SET DEFAULT nextval('public.mdl_feedback_valuetmp_id_seq'::regclass);


--
-- Name: mdl_file_conversion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_file_conversion ALTER COLUMN id SET DEFAULT nextval('public.mdl_file_conversion_id_seq'::regclass);


--
-- Name: mdl_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_files ALTER COLUMN id SET DEFAULT nextval('public.mdl_files_id_seq'::regclass);


--
-- Name: mdl_files_reference id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_files_reference ALTER COLUMN id SET DEFAULT nextval('public.mdl_files_reference_id_seq'::regclass);


--
-- Name: mdl_filter_active id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_filter_active ALTER COLUMN id SET DEFAULT nextval('public.mdl_filter_active_id_seq'::regclass);


--
-- Name: mdl_filter_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_filter_config ALTER COLUMN id SET DEFAULT nextval('public.mdl_filter_config_id_seq'::regclass);


--
-- Name: mdl_folder id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_folder ALTER COLUMN id SET DEFAULT nextval('public.mdl_folder_id_seq'::regclass);


--
-- Name: mdl_forum id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum ALTER COLUMN id SET DEFAULT nextval('public.mdl_forum_id_seq'::regclass);


--
-- Name: mdl_forum_digests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_digests ALTER COLUMN id SET DEFAULT nextval('public.mdl_forum_digests_id_seq'::regclass);


--
-- Name: mdl_forum_discussion_subs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_discussion_subs ALTER COLUMN id SET DEFAULT nextval('public.mdl_forum_discussion_subs_id_seq'::regclass);


--
-- Name: mdl_forum_discussions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_discussions ALTER COLUMN id SET DEFAULT nextval('public.mdl_forum_discussions_id_seq'::regclass);


--
-- Name: mdl_forum_grades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_grades ALTER COLUMN id SET DEFAULT nextval('public.mdl_forum_grades_id_seq'::regclass);


--
-- Name: mdl_forum_posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_posts ALTER COLUMN id SET DEFAULT nextval('public.mdl_forum_posts_id_seq'::regclass);


--
-- Name: mdl_forum_queue id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_queue ALTER COLUMN id SET DEFAULT nextval('public.mdl_forum_queue_id_seq'::regclass);


--
-- Name: mdl_forum_read id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_read ALTER COLUMN id SET DEFAULT nextval('public.mdl_forum_read_id_seq'::regclass);


--
-- Name: mdl_forum_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.mdl_forum_subscriptions_id_seq'::regclass);


--
-- Name: mdl_forum_track_prefs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_track_prefs ALTER COLUMN id SET DEFAULT nextval('public.mdl_forum_track_prefs_id_seq'::regclass);


--
-- Name: mdl_glossary id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_glossary ALTER COLUMN id SET DEFAULT nextval('public.mdl_glossary_id_seq'::regclass);


--
-- Name: mdl_glossary_alias id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_glossary_alias ALTER COLUMN id SET DEFAULT nextval('public.mdl_glossary_alias_id_seq'::regclass);


--
-- Name: mdl_glossary_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_glossary_categories ALTER COLUMN id SET DEFAULT nextval('public.mdl_glossary_categories_id_seq'::regclass);


--
-- Name: mdl_glossary_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_glossary_entries ALTER COLUMN id SET DEFAULT nextval('public.mdl_glossary_entries_id_seq'::regclass);


--
-- Name: mdl_glossary_entries_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_glossary_entries_categories ALTER COLUMN id SET DEFAULT nextval('public.mdl_glossary_entries_categories_id_seq'::regclass);


--
-- Name: mdl_glossary_formats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_glossary_formats ALTER COLUMN id SET DEFAULT nextval('public.mdl_glossary_formats_id_seq'::regclass);


--
-- Name: mdl_grade_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_categories ALTER COLUMN id SET DEFAULT nextval('public.mdl_grade_categories_id_seq'::regclass);


--
-- Name: mdl_grade_categories_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_categories_history ALTER COLUMN id SET DEFAULT nextval('public.mdl_grade_categories_history_id_seq'::regclass);


--
-- Name: mdl_grade_grades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_grades ALTER COLUMN id SET DEFAULT nextval('public.mdl_grade_grades_id_seq'::regclass);


--
-- Name: mdl_grade_grades_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_grades_history ALTER COLUMN id SET DEFAULT nextval('public.mdl_grade_grades_history_id_seq'::regclass);


--
-- Name: mdl_grade_import_newitem id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_import_newitem ALTER COLUMN id SET DEFAULT nextval('public.mdl_grade_import_newitem_id_seq'::regclass);


--
-- Name: mdl_grade_import_values id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_import_values ALTER COLUMN id SET DEFAULT nextval('public.mdl_grade_import_values_id_seq'::regclass);


--
-- Name: mdl_grade_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_items ALTER COLUMN id SET DEFAULT nextval('public.mdl_grade_items_id_seq'::regclass);


--
-- Name: mdl_grade_items_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_items_history ALTER COLUMN id SET DEFAULT nextval('public.mdl_grade_items_history_id_seq'::regclass);


--
-- Name: mdl_grade_letters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_letters ALTER COLUMN id SET DEFAULT nextval('public.mdl_grade_letters_id_seq'::regclass);


--
-- Name: mdl_grade_outcomes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_outcomes ALTER COLUMN id SET DEFAULT nextval('public.mdl_grade_outcomes_id_seq'::regclass);


--
-- Name: mdl_grade_outcomes_courses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_outcomes_courses ALTER COLUMN id SET DEFAULT nextval('public.mdl_grade_outcomes_courses_id_seq'::regclass);


--
-- Name: mdl_grade_outcomes_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_outcomes_history ALTER COLUMN id SET DEFAULT nextval('public.mdl_grade_outcomes_history_id_seq'::regclass);


--
-- Name: mdl_grade_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_settings ALTER COLUMN id SET DEFAULT nextval('public.mdl_grade_settings_id_seq'::regclass);


--
-- Name: mdl_grading_areas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grading_areas ALTER COLUMN id SET DEFAULT nextval('public.mdl_grading_areas_id_seq'::regclass);


--
-- Name: mdl_grading_definitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grading_definitions ALTER COLUMN id SET DEFAULT nextval('public.mdl_grading_definitions_id_seq'::regclass);


--
-- Name: mdl_grading_instances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grading_instances ALTER COLUMN id SET DEFAULT nextval('public.mdl_grading_instances_id_seq'::regclass);


--
-- Name: mdl_gradingform_guide_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_gradingform_guide_comments ALTER COLUMN id SET DEFAULT nextval('public.mdl_gradingform_guide_comments_id_seq'::regclass);


--
-- Name: mdl_gradingform_guide_criteria id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_gradingform_guide_criteria ALTER COLUMN id SET DEFAULT nextval('public.mdl_gradingform_guide_criteria_id_seq'::regclass);


--
-- Name: mdl_gradingform_guide_fillings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_gradingform_guide_fillings ALTER COLUMN id SET DEFAULT nextval('public.mdl_gradingform_guide_fillings_id_seq'::regclass);


--
-- Name: mdl_gradingform_rubric_criteria id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_gradingform_rubric_criteria ALTER COLUMN id SET DEFAULT nextval('public.mdl_gradingform_rubric_criteria_id_seq'::regclass);


--
-- Name: mdl_gradingform_rubric_fillings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_gradingform_rubric_fillings ALTER COLUMN id SET DEFAULT nextval('public.mdl_gradingform_rubric_fillings_id_seq'::regclass);


--
-- Name: mdl_gradingform_rubric_levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_gradingform_rubric_levels ALTER COLUMN id SET DEFAULT nextval('public.mdl_gradingform_rubric_levels_id_seq'::regclass);


--
-- Name: mdl_groupings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_groupings ALTER COLUMN id SET DEFAULT nextval('public.mdl_groupings_id_seq'::regclass);


--
-- Name: mdl_groupings_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_groupings_groups ALTER COLUMN id SET DEFAULT nextval('public.mdl_groupings_groups_id_seq'::regclass);


--
-- Name: mdl_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_groups ALTER COLUMN id SET DEFAULT nextval('public.mdl_groups_id_seq'::regclass);


--
-- Name: mdl_groups_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_groups_members ALTER COLUMN id SET DEFAULT nextval('public.mdl_groups_members_id_seq'::regclass);


--
-- Name: mdl_h5p id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_h5p ALTER COLUMN id SET DEFAULT nextval('public.mdl_h5p_id_seq'::regclass);


--
-- Name: mdl_h5p_contents_libraries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_h5p_contents_libraries ALTER COLUMN id SET DEFAULT nextval('public.mdl_h5p_contents_libraries_id_seq'::regclass);


--
-- Name: mdl_h5p_libraries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_h5p_libraries ALTER COLUMN id SET DEFAULT nextval('public.mdl_h5p_libraries_id_seq'::regclass);


--
-- Name: mdl_h5p_libraries_cachedassets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_h5p_libraries_cachedassets ALTER COLUMN id SET DEFAULT nextval('public.mdl_h5p_libraries_cachedassets_id_seq'::regclass);


--
-- Name: mdl_h5p_library_dependencies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_h5p_library_dependencies ALTER COLUMN id SET DEFAULT nextval('public.mdl_h5p_library_dependencies_id_seq'::regclass);


--
-- Name: mdl_h5pactivity id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_h5pactivity ALTER COLUMN id SET DEFAULT nextval('public.mdl_h5pactivity_id_seq'::regclass);


--
-- Name: mdl_h5pactivity_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_h5pactivity_attempts ALTER COLUMN id SET DEFAULT nextval('public.mdl_h5pactivity_attempts_id_seq'::regclass);


--
-- Name: mdl_h5pactivity_attempts_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_h5pactivity_attempts_results ALTER COLUMN id SET DEFAULT nextval('public.mdl_h5pactivity_attempts_results_id_seq'::regclass);


--
-- Name: mdl_imscp id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_imscp ALTER COLUMN id SET DEFAULT nextval('public.mdl_imscp_id_seq'::regclass);


--
-- Name: mdl_infected_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_infected_files ALTER COLUMN id SET DEFAULT nextval('public.mdl_infected_files_id_seq'::regclass);


--
-- Name: mdl_label id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_label ALTER COLUMN id SET DEFAULT nextval('public.mdl_label_id_seq'::regclass);


--
-- Name: mdl_lesson id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lesson ALTER COLUMN id SET DEFAULT nextval('public.mdl_lesson_id_seq'::regclass);


--
-- Name: mdl_lesson_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lesson_answers ALTER COLUMN id SET DEFAULT nextval('public.mdl_lesson_answers_id_seq'::regclass);


--
-- Name: mdl_lesson_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lesson_attempts ALTER COLUMN id SET DEFAULT nextval('public.mdl_lesson_attempts_id_seq'::regclass);


--
-- Name: mdl_lesson_branch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lesson_branch ALTER COLUMN id SET DEFAULT nextval('public.mdl_lesson_branch_id_seq'::regclass);


--
-- Name: mdl_lesson_grades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lesson_grades ALTER COLUMN id SET DEFAULT nextval('public.mdl_lesson_grades_id_seq'::regclass);


--
-- Name: mdl_lesson_overrides id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lesson_overrides ALTER COLUMN id SET DEFAULT nextval('public.mdl_lesson_overrides_id_seq'::regclass);


--
-- Name: mdl_lesson_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lesson_pages ALTER COLUMN id SET DEFAULT nextval('public.mdl_lesson_pages_id_seq'::regclass);


--
-- Name: mdl_lesson_timer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lesson_timer ALTER COLUMN id SET DEFAULT nextval('public.mdl_lesson_timer_id_seq'::regclass);


--
-- Name: mdl_license id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_license ALTER COLUMN id SET DEFAULT nextval('public.mdl_license_id_seq'::regclass);


--
-- Name: mdl_lock_db id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lock_db ALTER COLUMN id SET DEFAULT nextval('public.mdl_lock_db_id_seq'::regclass);


--
-- Name: mdl_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_log ALTER COLUMN id SET DEFAULT nextval('public.mdl_log_id_seq'::regclass);


--
-- Name: mdl_log_display id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_log_display ALTER COLUMN id SET DEFAULT nextval('public.mdl_log_display_id_seq'::regclass);


--
-- Name: mdl_log_queries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_log_queries ALTER COLUMN id SET DEFAULT nextval('public.mdl_log_queries_id_seq'::regclass);


--
-- Name: mdl_logstore_standard_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_logstore_standard_log ALTER COLUMN id SET DEFAULT nextval('public.mdl_logstore_standard_log_id_seq'::regclass);


--
-- Name: mdl_lti id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti ALTER COLUMN id SET DEFAULT nextval('public.mdl_lti_id_seq'::regclass);


--
-- Name: mdl_lti_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.mdl_lti_access_tokens_id_seq'::regclass);


--
-- Name: mdl_lti_coursevisible id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti_coursevisible ALTER COLUMN id SET DEFAULT nextval('public.mdl_lti_coursevisible_id_seq'::regclass);


--
-- Name: mdl_lti_submission id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti_submission ALTER COLUMN id SET DEFAULT nextval('public.mdl_lti_submission_id_seq'::regclass);


--
-- Name: mdl_lti_tool_proxies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti_tool_proxies ALTER COLUMN id SET DEFAULT nextval('public.mdl_lti_tool_proxies_id_seq'::regclass);


--
-- Name: mdl_lti_tool_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti_tool_settings ALTER COLUMN id SET DEFAULT nextval('public.mdl_lti_tool_settings_id_seq'::regclass);


--
-- Name: mdl_lti_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti_types ALTER COLUMN id SET DEFAULT nextval('public.mdl_lti_types_id_seq'::regclass);


--
-- Name: mdl_lti_types_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti_types_categories ALTER COLUMN id SET DEFAULT nextval('public.mdl_lti_types_categories_id_seq'::regclass);


--
-- Name: mdl_lti_types_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti_types_config ALTER COLUMN id SET DEFAULT nextval('public.mdl_lti_types_config_id_seq'::regclass);


--
-- Name: mdl_ltiservice_gradebookservices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_ltiservice_gradebookservices ALTER COLUMN id SET DEFAULT nextval('public.mdl_ltiservice_gradebookservices_id_seq'::regclass);


--
-- Name: mdl_matrix_room id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_matrix_room ALTER COLUMN id SET DEFAULT nextval('public.mdl_matrix_room_id_seq'::regclass);


--
-- Name: mdl_message id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message ALTER COLUMN id SET DEFAULT nextval('public.mdl_message_id_seq'::regclass);


--
-- Name: mdl_message_airnotifier_devices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_airnotifier_devices ALTER COLUMN id SET DEFAULT nextval('public.mdl_message_airnotifier_devices_id_seq'::regclass);


--
-- Name: mdl_message_contact_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_contact_requests ALTER COLUMN id SET DEFAULT nextval('public.mdl_message_contact_requests_id_seq'::regclass);


--
-- Name: mdl_message_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_contacts ALTER COLUMN id SET DEFAULT nextval('public.mdl_message_contacts_id_seq'::regclass);


--
-- Name: mdl_message_conversation_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_conversation_actions ALTER COLUMN id SET DEFAULT nextval('public.mdl_message_conversation_actions_id_seq'::regclass);


--
-- Name: mdl_message_conversation_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_conversation_members ALTER COLUMN id SET DEFAULT nextval('public.mdl_message_conversation_members_id_seq'::regclass);


--
-- Name: mdl_message_conversations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_conversations ALTER COLUMN id SET DEFAULT nextval('public.mdl_message_conversations_id_seq'::regclass);


--
-- Name: mdl_message_email_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_email_messages ALTER COLUMN id SET DEFAULT nextval('public.mdl_message_email_messages_id_seq'::regclass);


--
-- Name: mdl_message_popup id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_popup ALTER COLUMN id SET DEFAULT nextval('public.mdl_message_popup_id_seq'::regclass);


--
-- Name: mdl_message_popup_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_popup_notifications ALTER COLUMN id SET DEFAULT nextval('public.mdl_message_popup_notifications_id_seq'::regclass);


--
-- Name: mdl_message_processors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_processors ALTER COLUMN id SET DEFAULT nextval('public.mdl_message_processors_id_seq'::regclass);


--
-- Name: mdl_message_providers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_providers ALTER COLUMN id SET DEFAULT nextval('public.mdl_message_providers_id_seq'::regclass);


--
-- Name: mdl_message_read id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_read ALTER COLUMN id SET DEFAULT nextval('public.mdl_message_read_id_seq'::regclass);


--
-- Name: mdl_message_user_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_user_actions ALTER COLUMN id SET DEFAULT nextval('public.mdl_message_user_actions_id_seq'::regclass);


--
-- Name: mdl_message_users_blocked id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_users_blocked ALTER COLUMN id SET DEFAULT nextval('public.mdl_message_users_blocked_id_seq'::regclass);


--
-- Name: mdl_messageinbound_datakeys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_messageinbound_datakeys ALTER COLUMN id SET DEFAULT nextval('public.mdl_messageinbound_datakeys_id_seq'::regclass);


--
-- Name: mdl_messageinbound_handlers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_messageinbound_handlers ALTER COLUMN id SET DEFAULT nextval('public.mdl_messageinbound_handlers_id_seq'::regclass);


--
-- Name: mdl_messageinbound_messagelist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_messageinbound_messagelist ALTER COLUMN id SET DEFAULT nextval('public.mdl_messageinbound_messagelist_id_seq'::regclass);


--
-- Name: mdl_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_messages ALTER COLUMN id SET DEFAULT nextval('public.mdl_messages_id_seq'::regclass);


--
-- Name: mdl_mnet_application id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_application ALTER COLUMN id SET DEFAULT nextval('public.mdl_mnet_application_id_seq'::regclass);


--
-- Name: mdl_mnet_host id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_host ALTER COLUMN id SET DEFAULT nextval('public.mdl_mnet_host_id_seq'::regclass);


--
-- Name: mdl_mnet_host2service id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_host2service ALTER COLUMN id SET DEFAULT nextval('public.mdl_mnet_host2service_id_seq'::regclass);


--
-- Name: mdl_mnet_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_log ALTER COLUMN id SET DEFAULT nextval('public.mdl_mnet_log_id_seq'::regclass);


--
-- Name: mdl_mnet_remote_rpc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_remote_rpc ALTER COLUMN id SET DEFAULT nextval('public.mdl_mnet_remote_rpc_id_seq'::regclass);


--
-- Name: mdl_mnet_remote_service2rpc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_remote_service2rpc ALTER COLUMN id SET DEFAULT nextval('public.mdl_mnet_remote_service2rpc_id_seq'::regclass);


--
-- Name: mdl_mnet_rpc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_rpc ALTER COLUMN id SET DEFAULT nextval('public.mdl_mnet_rpc_id_seq'::regclass);


--
-- Name: mdl_mnet_service id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_service ALTER COLUMN id SET DEFAULT nextval('public.mdl_mnet_service_id_seq'::regclass);


--
-- Name: mdl_mnet_service2rpc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_service2rpc ALTER COLUMN id SET DEFAULT nextval('public.mdl_mnet_service2rpc_id_seq'::regclass);


--
-- Name: mdl_mnet_session id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_session ALTER COLUMN id SET DEFAULT nextval('public.mdl_mnet_session_id_seq'::regclass);


--
-- Name: mdl_mnet_sso_access_control id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_sso_access_control ALTER COLUMN id SET DEFAULT nextval('public.mdl_mnet_sso_access_control_id_seq'::regclass);


--
-- Name: mdl_mnetservice_enrol_courses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnetservice_enrol_courses ALTER COLUMN id SET DEFAULT nextval('public.mdl_mnetservice_enrol_courses_id_seq'::regclass);


--
-- Name: mdl_mnetservice_enrol_enrolments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnetservice_enrol_enrolments ALTER COLUMN id SET DEFAULT nextval('public.mdl_mnetservice_enrol_enrolments_id_seq'::regclass);


--
-- Name: mdl_modules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_modules ALTER COLUMN id SET DEFAULT nextval('public.mdl_modules_id_seq'::regclass);


--
-- Name: mdl_moodlenet_share_progress id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_moodlenet_share_progress ALTER COLUMN id SET DEFAULT nextval('public.mdl_moodlenet_share_progress_id_seq'::regclass);


--
-- Name: mdl_my_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_my_pages ALTER COLUMN id SET DEFAULT nextval('public.mdl_my_pages_id_seq'::regclass);


--
-- Name: mdl_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_notifications ALTER COLUMN id SET DEFAULT nextval('public.mdl_notifications_id_seq'::regclass);


--
-- Name: mdl_oauth2_access_token id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_oauth2_access_token ALTER COLUMN id SET DEFAULT nextval('public.mdl_oauth2_access_token_id_seq'::regclass);


--
-- Name: mdl_oauth2_endpoint id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_oauth2_endpoint ALTER COLUMN id SET DEFAULT nextval('public.mdl_oauth2_endpoint_id_seq'::regclass);


--
-- Name: mdl_oauth2_issuer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_oauth2_issuer ALTER COLUMN id SET DEFAULT nextval('public.mdl_oauth2_issuer_id_seq'::regclass);


--
-- Name: mdl_oauth2_refresh_token id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_oauth2_refresh_token ALTER COLUMN id SET DEFAULT nextval('public.mdl_oauth2_refresh_token_id_seq'::regclass);


--
-- Name: mdl_oauth2_system_account id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_oauth2_system_account ALTER COLUMN id SET DEFAULT nextval('public.mdl_oauth2_system_account_id_seq'::regclass);


--
-- Name: mdl_oauth2_user_field_mapping id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_oauth2_user_field_mapping ALTER COLUMN id SET DEFAULT nextval('public.mdl_oauth2_user_field_mapping_id_seq'::regclass);


--
-- Name: mdl_page id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_page ALTER COLUMN id SET DEFAULT nextval('public.mdl_page_id_seq'::regclass);


--
-- Name: mdl_paygw_paypal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_paygw_paypal ALTER COLUMN id SET DEFAULT nextval('public.mdl_paygw_paypal_id_seq'::regclass);


--
-- Name: mdl_payment_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_payment_accounts ALTER COLUMN id SET DEFAULT nextval('public.mdl_payment_accounts_id_seq'::regclass);


--
-- Name: mdl_payment_gateways id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_payment_gateways ALTER COLUMN id SET DEFAULT nextval('public.mdl_payment_gateways_id_seq'::regclass);


--
-- Name: mdl_payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_payments ALTER COLUMN id SET DEFAULT nextval('public.mdl_payments_id_seq'::regclass);


--
-- Name: mdl_portfolio_instance id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_portfolio_instance ALTER COLUMN id SET DEFAULT nextval('public.mdl_portfolio_instance_id_seq'::regclass);


--
-- Name: mdl_portfolio_instance_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_portfolio_instance_config ALTER COLUMN id SET DEFAULT nextval('public.mdl_portfolio_instance_config_id_seq'::regclass);


--
-- Name: mdl_portfolio_instance_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_portfolio_instance_user ALTER COLUMN id SET DEFAULT nextval('public.mdl_portfolio_instance_user_id_seq'::regclass);


--
-- Name: mdl_portfolio_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_portfolio_log ALTER COLUMN id SET DEFAULT nextval('public.mdl_portfolio_log_id_seq'::regclass);


--
-- Name: mdl_portfolio_mahara_queue id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_portfolio_mahara_queue ALTER COLUMN id SET DEFAULT nextval('public.mdl_portfolio_mahara_queue_id_seq'::regclass);


--
-- Name: mdl_portfolio_tempdata id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_portfolio_tempdata ALTER COLUMN id SET DEFAULT nextval('public.mdl_portfolio_tempdata_id_seq'::regclass);


--
-- Name: mdl_post id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_post ALTER COLUMN id SET DEFAULT nextval('public.mdl_post_id_seq'::regclass);


--
-- Name: mdl_profiling id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_profiling ALTER COLUMN id SET DEFAULT nextval('public.mdl_profiling_id_seq'::regclass);


--
-- Name: mdl_qtype_ddimageortext id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_ddimageortext ALTER COLUMN id SET DEFAULT nextval('public.mdl_qtype_ddimageortext_id_seq'::regclass);


--
-- Name: mdl_qtype_ddimageortext_drags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_ddimageortext_drags ALTER COLUMN id SET DEFAULT nextval('public.mdl_qtype_ddimageortext_drags_id_seq'::regclass);


--
-- Name: mdl_qtype_ddimageortext_drops id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_ddimageortext_drops ALTER COLUMN id SET DEFAULT nextval('public.mdl_qtype_ddimageortext_drops_id_seq'::regclass);


--
-- Name: mdl_qtype_ddmarker id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_ddmarker ALTER COLUMN id SET DEFAULT nextval('public.mdl_qtype_ddmarker_id_seq'::regclass);


--
-- Name: mdl_qtype_ddmarker_drags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_ddmarker_drags ALTER COLUMN id SET DEFAULT nextval('public.mdl_qtype_ddmarker_drags_id_seq'::regclass);


--
-- Name: mdl_qtype_ddmarker_drops id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_ddmarker_drops ALTER COLUMN id SET DEFAULT nextval('public.mdl_qtype_ddmarker_drops_id_seq'::regclass);


--
-- Name: mdl_qtype_essay_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_essay_options ALTER COLUMN id SET DEFAULT nextval('public.mdl_qtype_essay_options_id_seq'::regclass);


--
-- Name: mdl_qtype_match_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_match_options ALTER COLUMN id SET DEFAULT nextval('public.mdl_qtype_match_options_id_seq'::regclass);


--
-- Name: mdl_qtype_match_subquestions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_match_subquestions ALTER COLUMN id SET DEFAULT nextval('public.mdl_qtype_match_subquestions_id_seq'::regclass);


--
-- Name: mdl_qtype_multichoice_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_multichoice_options ALTER COLUMN id SET DEFAULT nextval('public.mdl_qtype_multichoice_options_id_seq'::regclass);


--
-- Name: mdl_qtype_ordering_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_ordering_options ALTER COLUMN id SET DEFAULT nextval('public.mdl_qtype_ordering_options_id_seq'::regclass);


--
-- Name: mdl_qtype_randomsamatch_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_randomsamatch_options ALTER COLUMN id SET DEFAULT nextval('public.mdl_qtype_randomsamatch_options_id_seq'::regclass);


--
-- Name: mdl_qtype_shortanswer_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_shortanswer_options ALTER COLUMN id SET DEFAULT nextval('public.mdl_qtype_shortanswer_options_id_seq'::regclass);


--
-- Name: mdl_question id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_id_seq'::regclass);


--
-- Name: mdl_question_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_answers ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_answers_id_seq'::regclass);


--
-- Name: mdl_question_attempt_step_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_attempt_step_data ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_attempt_step_data_id_seq'::regclass);


--
-- Name: mdl_question_attempt_steps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_attempt_steps ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_attempt_steps_id_seq'::regclass);


--
-- Name: mdl_question_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_attempts ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_attempts_id_seq'::regclass);


--
-- Name: mdl_question_bank_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_bank_entries ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_bank_entries_id_seq'::regclass);


--
-- Name: mdl_question_calculated id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_calculated ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_calculated_id_seq'::regclass);


--
-- Name: mdl_question_calculated_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_calculated_options ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_calculated_options_id_seq'::regclass);


--
-- Name: mdl_question_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_categories ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_categories_id_seq'::regclass);


--
-- Name: mdl_question_dataset_definitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_dataset_definitions ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_dataset_definitions_id_seq'::regclass);


--
-- Name: mdl_question_dataset_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_dataset_items ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_dataset_items_id_seq'::regclass);


--
-- Name: mdl_question_datasets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_datasets ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_datasets_id_seq'::regclass);


--
-- Name: mdl_question_ddwtos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_ddwtos ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_ddwtos_id_seq'::regclass);


--
-- Name: mdl_question_gapselect id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_gapselect ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_gapselect_id_seq'::regclass);


--
-- Name: mdl_question_hints id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_hints ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_hints_id_seq'::regclass);


--
-- Name: mdl_question_multianswer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_multianswer ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_multianswer_id_seq'::regclass);


--
-- Name: mdl_question_numerical id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_numerical ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_numerical_id_seq'::regclass);


--
-- Name: mdl_question_numerical_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_numerical_options ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_numerical_options_id_seq'::regclass);


--
-- Name: mdl_question_numerical_units id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_numerical_units ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_numerical_units_id_seq'::regclass);


--
-- Name: mdl_question_references id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_references ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_references_id_seq'::regclass);


--
-- Name: mdl_question_response_analysis id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_response_analysis ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_response_analysis_id_seq'::regclass);


--
-- Name: mdl_question_response_count id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_response_count ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_response_count_id_seq'::regclass);


--
-- Name: mdl_question_set_references id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_set_references ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_set_references_id_seq'::regclass);


--
-- Name: mdl_question_statistics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_statistics ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_statistics_id_seq'::regclass);


--
-- Name: mdl_question_truefalse id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_truefalse ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_truefalse_id_seq'::regclass);


--
-- Name: mdl_question_usages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_usages ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_usages_id_seq'::regclass);


--
-- Name: mdl_question_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_versions ALTER COLUMN id SET DEFAULT nextval('public.mdl_question_versions_id_seq'::regclass);


--
-- Name: mdl_quiz id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz ALTER COLUMN id SET DEFAULT nextval('public.mdl_quiz_id_seq'::regclass);


--
-- Name: mdl_quiz_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_attempts ALTER COLUMN id SET DEFAULT nextval('public.mdl_quiz_attempts_id_seq'::regclass);


--
-- Name: mdl_quiz_feedback id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_feedback ALTER COLUMN id SET DEFAULT nextval('public.mdl_quiz_feedback_id_seq'::regclass);


--
-- Name: mdl_quiz_grade_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_grade_items ALTER COLUMN id SET DEFAULT nextval('public.mdl_quiz_grade_items_id_seq'::regclass);


--
-- Name: mdl_quiz_grades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_grades ALTER COLUMN id SET DEFAULT nextval('public.mdl_quiz_grades_id_seq'::regclass);


--
-- Name: mdl_quiz_overrides id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_overrides ALTER COLUMN id SET DEFAULT nextval('public.mdl_quiz_overrides_id_seq'::regclass);


--
-- Name: mdl_quiz_overview_regrades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_overview_regrades ALTER COLUMN id SET DEFAULT nextval('public.mdl_quiz_overview_regrades_id_seq'::regclass);


--
-- Name: mdl_quiz_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_reports ALTER COLUMN id SET DEFAULT nextval('public.mdl_quiz_reports_id_seq'::regclass);


--
-- Name: mdl_quiz_sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_sections ALTER COLUMN id SET DEFAULT nextval('public.mdl_quiz_sections_id_seq'::regclass);


--
-- Name: mdl_quiz_slots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_slots ALTER COLUMN id SET DEFAULT nextval('public.mdl_quiz_slots_id_seq'::regclass);


--
-- Name: mdl_quiz_statistics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_statistics ALTER COLUMN id SET DEFAULT nextval('public.mdl_quiz_statistics_id_seq'::regclass);


--
-- Name: mdl_quizaccess_seb_quizsettings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quizaccess_seb_quizsettings ALTER COLUMN id SET DEFAULT nextval('public.mdl_quizaccess_seb_quizsettings_id_seq'::regclass);


--
-- Name: mdl_quizaccess_seb_template id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quizaccess_seb_template ALTER COLUMN id SET DEFAULT nextval('public.mdl_quizaccess_seb_template_id_seq'::regclass);


--
-- Name: mdl_rating id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_rating ALTER COLUMN id SET DEFAULT nextval('public.mdl_rating_id_seq'::regclass);


--
-- Name: mdl_registration_hubs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_registration_hubs ALTER COLUMN id SET DEFAULT nextval('public.mdl_registration_hubs_id_seq'::regclass);


--
-- Name: mdl_reportbuilder_audience id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_reportbuilder_audience ALTER COLUMN id SET DEFAULT nextval('public.mdl_reportbuilder_audience_id_seq'::regclass);


--
-- Name: mdl_reportbuilder_column id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_reportbuilder_column ALTER COLUMN id SET DEFAULT nextval('public.mdl_reportbuilder_column_id_seq'::regclass);


--
-- Name: mdl_reportbuilder_filter id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_reportbuilder_filter ALTER COLUMN id SET DEFAULT nextval('public.mdl_reportbuilder_filter_id_seq'::regclass);


--
-- Name: mdl_reportbuilder_report id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_reportbuilder_report ALTER COLUMN id SET DEFAULT nextval('public.mdl_reportbuilder_report_id_seq'::regclass);


--
-- Name: mdl_reportbuilder_schedule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_reportbuilder_schedule ALTER COLUMN id SET DEFAULT nextval('public.mdl_reportbuilder_schedule_id_seq'::regclass);


--
-- Name: mdl_repository id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_repository ALTER COLUMN id SET DEFAULT nextval('public.mdl_repository_id_seq'::regclass);


--
-- Name: mdl_repository_instance_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_repository_instance_config ALTER COLUMN id SET DEFAULT nextval('public.mdl_repository_instance_config_id_seq'::regclass);


--
-- Name: mdl_repository_instances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_repository_instances ALTER COLUMN id SET DEFAULT nextval('public.mdl_repository_instances_id_seq'::regclass);


--
-- Name: mdl_repository_onedrive_access id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_repository_onedrive_access ALTER COLUMN id SET DEFAULT nextval('public.mdl_repository_onedrive_access_id_seq'::regclass);


--
-- Name: mdl_resource id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_resource ALTER COLUMN id SET DEFAULT nextval('public.mdl_resource_id_seq'::regclass);


--
-- Name: mdl_resource_old id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_resource_old ALTER COLUMN id SET DEFAULT nextval('public.mdl_resource_old_id_seq'::regclass);


--
-- Name: mdl_role id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role ALTER COLUMN id SET DEFAULT nextval('public.mdl_role_id_seq'::regclass);


--
-- Name: mdl_role_allow_assign id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role_allow_assign ALTER COLUMN id SET DEFAULT nextval('public.mdl_role_allow_assign_id_seq'::regclass);


--
-- Name: mdl_role_allow_override id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role_allow_override ALTER COLUMN id SET DEFAULT nextval('public.mdl_role_allow_override_id_seq'::regclass);


--
-- Name: mdl_role_allow_switch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role_allow_switch ALTER COLUMN id SET DEFAULT nextval('public.mdl_role_allow_switch_id_seq'::regclass);


--
-- Name: mdl_role_allow_view id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role_allow_view ALTER COLUMN id SET DEFAULT nextval('public.mdl_role_allow_view_id_seq'::regclass);


--
-- Name: mdl_role_assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role_assignments ALTER COLUMN id SET DEFAULT nextval('public.mdl_role_assignments_id_seq'::regclass);


--
-- Name: mdl_role_capabilities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role_capabilities ALTER COLUMN id SET DEFAULT nextval('public.mdl_role_capabilities_id_seq'::regclass);


--
-- Name: mdl_role_context_levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role_context_levels ALTER COLUMN id SET DEFAULT nextval('public.mdl_role_context_levels_id_seq'::regclass);


--
-- Name: mdl_role_names id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role_names ALTER COLUMN id SET DEFAULT nextval('public.mdl_role_names_id_seq'::regclass);


--
-- Name: mdl_scale id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scale ALTER COLUMN id SET DEFAULT nextval('public.mdl_scale_id_seq'::regclass);


--
-- Name: mdl_scale_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scale_history ALTER COLUMN id SET DEFAULT nextval('public.mdl_scale_history_id_seq'::regclass);


--
-- Name: mdl_scorm id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm ALTER COLUMN id SET DEFAULT nextval('public.mdl_scorm_id_seq'::regclass);


--
-- Name: mdl_scorm_aicc_session id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_aicc_session ALTER COLUMN id SET DEFAULT nextval('public.mdl_scorm_aicc_session_id_seq'::regclass);


--
-- Name: mdl_scorm_attempt id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_attempt ALTER COLUMN id SET DEFAULT nextval('public.mdl_scorm_attempt_id_seq'::regclass);


--
-- Name: mdl_scorm_element id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_element ALTER COLUMN id SET DEFAULT nextval('public.mdl_scorm_element_id_seq'::regclass);


--
-- Name: mdl_scorm_scoes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_scoes ALTER COLUMN id SET DEFAULT nextval('public.mdl_scorm_scoes_id_seq'::regclass);


--
-- Name: mdl_scorm_scoes_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_scoes_data ALTER COLUMN id SET DEFAULT nextval('public.mdl_scorm_scoes_data_id_seq'::regclass);


--
-- Name: mdl_scorm_scoes_value id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_scoes_value ALTER COLUMN id SET DEFAULT nextval('public.mdl_scorm_scoes_value_id_seq'::regclass);


--
-- Name: mdl_scorm_seq_mapinfo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_seq_mapinfo ALTER COLUMN id SET DEFAULT nextval('public.mdl_scorm_seq_mapinfo_id_seq'::regclass);


--
-- Name: mdl_scorm_seq_objective id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_seq_objective ALTER COLUMN id SET DEFAULT nextval('public.mdl_scorm_seq_objective_id_seq'::regclass);


--
-- Name: mdl_scorm_seq_rolluprule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_seq_rolluprule ALTER COLUMN id SET DEFAULT nextval('public.mdl_scorm_seq_rolluprule_id_seq'::regclass);


--
-- Name: mdl_scorm_seq_rolluprulecond id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_seq_rolluprulecond ALTER COLUMN id SET DEFAULT nextval('public.mdl_scorm_seq_rolluprulecond_id_seq'::regclass);


--
-- Name: mdl_scorm_seq_rulecond id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_seq_rulecond ALTER COLUMN id SET DEFAULT nextval('public.mdl_scorm_seq_rulecond_id_seq'::regclass);


--
-- Name: mdl_scorm_seq_ruleconds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_seq_ruleconds ALTER COLUMN id SET DEFAULT nextval('public.mdl_scorm_seq_ruleconds_id_seq'::regclass);


--
-- Name: mdl_search_index_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_search_index_requests ALTER COLUMN id SET DEFAULT nextval('public.mdl_search_index_requests_id_seq'::regclass);


--
-- Name: mdl_search_simpledb_index id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_search_simpledb_index ALTER COLUMN id SET DEFAULT nextval('public.mdl_search_simpledb_index_id_seq'::regclass);


--
-- Name: mdl_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_sessions ALTER COLUMN id SET DEFAULT nextval('public.mdl_sessions_id_seq'::regclass);


--
-- Name: mdl_sms_gateways id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_sms_gateways ALTER COLUMN id SET DEFAULT nextval('public.mdl_sms_gateways_id_seq'::regclass);


--
-- Name: mdl_sms_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_sms_messages ALTER COLUMN id SET DEFAULT nextval('public.mdl_sms_messages_id_seq'::regclass);


--
-- Name: mdl_stats_daily id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_stats_daily ALTER COLUMN id SET DEFAULT nextval('public.mdl_stats_daily_id_seq'::regclass);


--
-- Name: mdl_stats_monthly id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_stats_monthly ALTER COLUMN id SET DEFAULT nextval('public.mdl_stats_monthly_id_seq'::regclass);


--
-- Name: mdl_stats_user_daily id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_stats_user_daily ALTER COLUMN id SET DEFAULT nextval('public.mdl_stats_user_daily_id_seq'::regclass);


--
-- Name: mdl_stats_user_monthly id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_stats_user_monthly ALTER COLUMN id SET DEFAULT nextval('public.mdl_stats_user_monthly_id_seq'::regclass);


--
-- Name: mdl_stats_user_weekly id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_stats_user_weekly ALTER COLUMN id SET DEFAULT nextval('public.mdl_stats_user_weekly_id_seq'::regclass);


--
-- Name: mdl_stats_weekly id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_stats_weekly ALTER COLUMN id SET DEFAULT nextval('public.mdl_stats_weekly_id_seq'::regclass);


--
-- Name: mdl_stored_progress id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_stored_progress ALTER COLUMN id SET DEFAULT nextval('public.mdl_stored_progress_id_seq'::regclass);


--
-- Name: mdl_subsection id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_subsection ALTER COLUMN id SET DEFAULT nextval('public.mdl_subsection_id_seq'::regclass);


--
-- Name: mdl_survey id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_survey ALTER COLUMN id SET DEFAULT nextval('public.mdl_survey_id_seq'::regclass);


--
-- Name: mdl_survey_analysis id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_survey_analysis ALTER COLUMN id SET DEFAULT nextval('public.mdl_survey_analysis_id_seq'::regclass);


--
-- Name: mdl_survey_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_survey_answers ALTER COLUMN id SET DEFAULT nextval('public.mdl_survey_answers_id_seq'::regclass);


--
-- Name: mdl_survey_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_survey_questions ALTER COLUMN id SET DEFAULT nextval('public.mdl_survey_questions_id_seq'::regclass);


--
-- Name: mdl_tag id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tag ALTER COLUMN id SET DEFAULT nextval('public.mdl_tag_id_seq'::regclass);


--
-- Name: mdl_tag_area id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tag_area ALTER COLUMN id SET DEFAULT nextval('public.mdl_tag_area_id_seq'::regclass);


--
-- Name: mdl_tag_coll id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tag_coll ALTER COLUMN id SET DEFAULT nextval('public.mdl_tag_coll_id_seq'::regclass);


--
-- Name: mdl_tag_correlation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tag_correlation ALTER COLUMN id SET DEFAULT nextval('public.mdl_tag_correlation_id_seq'::regclass);


--
-- Name: mdl_tag_instance id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tag_instance ALTER COLUMN id SET DEFAULT nextval('public.mdl_tag_instance_id_seq'::regclass);


--
-- Name: mdl_task_adhoc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_task_adhoc ALTER COLUMN id SET DEFAULT nextval('public.mdl_task_adhoc_id_seq'::regclass);


--
-- Name: mdl_task_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_task_log ALTER COLUMN id SET DEFAULT nextval('public.mdl_task_log_id_seq'::regclass);


--
-- Name: mdl_task_scheduled id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_task_scheduled ALTER COLUMN id SET DEFAULT nextval('public.mdl_task_scheduled_id_seq'::regclass);


--
-- Name: mdl_tiny_autosave id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tiny_autosave ALTER COLUMN id SET DEFAULT nextval('public.mdl_tiny_autosave_id_seq'::regclass);


--
-- Name: mdl_tool_brickfield_areas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_areas ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_brickfield_areas_id_seq'::regclass);


--
-- Name: mdl_tool_brickfield_cache_acts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_cache_acts ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_brickfield_cache_acts_id_seq'::regclass);


--
-- Name: mdl_tool_brickfield_cache_check id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_cache_check ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_brickfield_cache_check_id_seq'::regclass);


--
-- Name: mdl_tool_brickfield_checks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_checks ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_brickfield_checks_id_seq'::regclass);


--
-- Name: mdl_tool_brickfield_content id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_content ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_brickfield_content_id_seq'::regclass);


--
-- Name: mdl_tool_brickfield_errors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_errors ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_brickfield_errors_id_seq'::regclass);


--
-- Name: mdl_tool_brickfield_process id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_process ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_brickfield_process_id_seq'::regclass);


--
-- Name: mdl_tool_brickfield_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_results ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_brickfield_results_id_seq'::regclass);


--
-- Name: mdl_tool_brickfield_schedule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_schedule ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_brickfield_schedule_id_seq'::regclass);


--
-- Name: mdl_tool_brickfield_summary id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_summary ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_brickfield_summary_id_seq'::regclass);


--
-- Name: mdl_tool_cohortroles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_cohortroles ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_cohortroles_id_seq'::regclass);


--
-- Name: mdl_tool_customlang id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_customlang ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_customlang_id_seq'::regclass);


--
-- Name: mdl_tool_customlang_components id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_customlang_components ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_customlang_components_id_seq'::regclass);


--
-- Name: mdl_tool_dataprivacy_category id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_category ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_dataprivacy_category_id_seq'::regclass);


--
-- Name: mdl_tool_dataprivacy_contextlist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_contextlist ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_dataprivacy_contextlist_id_seq'::regclass);


--
-- Name: mdl_tool_dataprivacy_ctxexpired id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_ctxexpired ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_dataprivacy_ctxexpired_id_seq'::regclass);


--
-- Name: mdl_tool_dataprivacy_ctxinstance id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_ctxinstance ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_dataprivacy_ctxinstance_id_seq'::regclass);


--
-- Name: mdl_tool_dataprivacy_ctxlevel id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_ctxlevel ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_dataprivacy_ctxlevel_id_seq'::regclass);


--
-- Name: mdl_tool_dataprivacy_ctxlst_ctx id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_ctxlst_ctx ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_dataprivacy_ctxlst_ctx_id_seq'::regclass);


--
-- Name: mdl_tool_dataprivacy_purpose id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_purpose ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_dataprivacy_purpose_id_seq'::regclass);


--
-- Name: mdl_tool_dataprivacy_purposerole id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_purposerole ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_dataprivacy_purposerole_id_seq'::regclass);


--
-- Name: mdl_tool_dataprivacy_request id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_request ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_dataprivacy_request_id_seq'::regclass);


--
-- Name: mdl_tool_dataprivacy_rqst_ctxlst id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_rqst_ctxlst ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_dataprivacy_rqst_ctxlst_id_seq'::regclass);


--
-- Name: mdl_tool_mfa id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_mfa ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_mfa_id_seq'::regclass);


--
-- Name: mdl_tool_mfa_auth id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_mfa_auth ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_mfa_auth_id_seq'::regclass);


--
-- Name: mdl_tool_mfa_secrets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_mfa_secrets ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_mfa_secrets_id_seq'::regclass);


--
-- Name: mdl_tool_monitor_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_monitor_events ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_monitor_events_id_seq'::regclass);


--
-- Name: mdl_tool_monitor_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_monitor_history ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_monitor_history_id_seq'::regclass);


--
-- Name: mdl_tool_monitor_rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_monitor_rules ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_monitor_rules_id_seq'::regclass);


--
-- Name: mdl_tool_monitor_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_monitor_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_monitor_subscriptions_id_seq'::regclass);


--
-- Name: mdl_tool_policy id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_policy ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_policy_id_seq'::regclass);


--
-- Name: mdl_tool_policy_acceptances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_policy_acceptances ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_policy_acceptances_id_seq'::regclass);


--
-- Name: mdl_tool_policy_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_policy_versions ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_policy_versions_id_seq'::regclass);


--
-- Name: mdl_tool_recyclebin_category id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_recyclebin_category ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_recyclebin_category_id_seq'::regclass);


--
-- Name: mdl_tool_recyclebin_course id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_recyclebin_course ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_recyclebin_course_id_seq'::regclass);


--
-- Name: mdl_tool_usertours_steps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_usertours_steps ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_usertours_steps_id_seq'::regclass);


--
-- Name: mdl_tool_usertours_tours id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_usertours_tours ALTER COLUMN id SET DEFAULT nextval('public.mdl_tool_usertours_tours_id_seq'::regclass);


--
-- Name: mdl_upgrade_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_upgrade_log ALTER COLUMN id SET DEFAULT nextval('public.mdl_upgrade_log_id_seq'::regclass);


--
-- Name: mdl_url id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_url ALTER COLUMN id SET DEFAULT nextval('public.mdl_url_id_seq'::regclass);


--
-- Name: mdl_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user ALTER COLUMN id SET DEFAULT nextval('public.mdl_user_id_seq'::regclass);


--
-- Name: mdl_user_devices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_devices ALTER COLUMN id SET DEFAULT nextval('public.mdl_user_devices_id_seq'::regclass);


--
-- Name: mdl_user_enrolments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_enrolments ALTER COLUMN id SET DEFAULT nextval('public.mdl_user_enrolments_id_seq'::regclass);


--
-- Name: mdl_user_info_category id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_info_category ALTER COLUMN id SET DEFAULT nextval('public.mdl_user_info_category_id_seq'::regclass);


--
-- Name: mdl_user_info_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_info_data ALTER COLUMN id SET DEFAULT nextval('public.mdl_user_info_data_id_seq'::regclass);


--
-- Name: mdl_user_info_field id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_info_field ALTER COLUMN id SET DEFAULT nextval('public.mdl_user_info_field_id_seq'::regclass);


--
-- Name: mdl_user_lastaccess id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_lastaccess ALTER COLUMN id SET DEFAULT nextval('public.mdl_user_lastaccess_id_seq'::regclass);


--
-- Name: mdl_user_password_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_password_history ALTER COLUMN id SET DEFAULT nextval('public.mdl_user_password_history_id_seq'::regclass);


--
-- Name: mdl_user_password_resets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_password_resets ALTER COLUMN id SET DEFAULT nextval('public.mdl_user_password_resets_id_seq'::regclass);


--
-- Name: mdl_user_preferences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_preferences ALTER COLUMN id SET DEFAULT nextval('public.mdl_user_preferences_id_seq'::regclass);


--
-- Name: mdl_user_private_key id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_private_key ALTER COLUMN id SET DEFAULT nextval('public.mdl_user_private_key_id_seq'::regclass);


--
-- Name: mdl_wiki id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_wiki ALTER COLUMN id SET DEFAULT nextval('public.mdl_wiki_id_seq'::regclass);


--
-- Name: mdl_wiki_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_wiki_links ALTER COLUMN id SET DEFAULT nextval('public.mdl_wiki_links_id_seq'::regclass);


--
-- Name: mdl_wiki_locks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_wiki_locks ALTER COLUMN id SET DEFAULT nextval('public.mdl_wiki_locks_id_seq'::regclass);


--
-- Name: mdl_wiki_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_wiki_pages ALTER COLUMN id SET DEFAULT nextval('public.mdl_wiki_pages_id_seq'::regclass);


--
-- Name: mdl_wiki_subwikis id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_wiki_subwikis ALTER COLUMN id SET DEFAULT nextval('public.mdl_wiki_subwikis_id_seq'::regclass);


--
-- Name: mdl_wiki_synonyms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_wiki_synonyms ALTER COLUMN id SET DEFAULT nextval('public.mdl_wiki_synonyms_id_seq'::regclass);


--
-- Name: mdl_wiki_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_wiki_versions ALTER COLUMN id SET DEFAULT nextval('public.mdl_wiki_versions_id_seq'::regclass);


--
-- Name: mdl_workshop id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshop ALTER COLUMN id SET DEFAULT nextval('public.mdl_workshop_id_seq'::regclass);


--
-- Name: mdl_workshop_aggregations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshop_aggregations ALTER COLUMN id SET DEFAULT nextval('public.mdl_workshop_aggregations_id_seq'::regclass);


--
-- Name: mdl_workshop_assessments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshop_assessments ALTER COLUMN id SET DEFAULT nextval('public.mdl_workshop_assessments_id_seq'::regclass);


--
-- Name: mdl_workshop_grades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshop_grades ALTER COLUMN id SET DEFAULT nextval('public.mdl_workshop_grades_id_seq'::regclass);


--
-- Name: mdl_workshop_submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshop_submissions ALTER COLUMN id SET DEFAULT nextval('public.mdl_workshop_submissions_id_seq'::regclass);


--
-- Name: mdl_workshopallocation_scheduled id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopallocation_scheduled ALTER COLUMN id SET DEFAULT nextval('public.mdl_workshopallocation_scheduled_id_seq'::regclass);


--
-- Name: mdl_workshopeval_best_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopeval_best_settings ALTER COLUMN id SET DEFAULT nextval('public.mdl_workshopeval_best_settings_id_seq'::regclass);


--
-- Name: mdl_workshopform_accumulative id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopform_accumulative ALTER COLUMN id SET DEFAULT nextval('public.mdl_workshopform_accumulative_id_seq'::regclass);


--
-- Name: mdl_workshopform_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopform_comments ALTER COLUMN id SET DEFAULT nextval('public.mdl_workshopform_comments_id_seq'::regclass);


--
-- Name: mdl_workshopform_numerrors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopform_numerrors ALTER COLUMN id SET DEFAULT nextval('public.mdl_workshopform_numerrors_id_seq'::regclass);


--
-- Name: mdl_workshopform_numerrors_map id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopform_numerrors_map ALTER COLUMN id SET DEFAULT nextval('public.mdl_workshopform_numerrors_map_id_seq'::regclass);


--
-- Name: mdl_workshopform_rubric id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopform_rubric ALTER COLUMN id SET DEFAULT nextval('public.mdl_workshopform_rubric_id_seq'::regclass);


--
-- Name: mdl_workshopform_rubric_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopform_rubric_config ALTER COLUMN id SET DEFAULT nextval('public.mdl_workshopform_rubric_config_id_seq'::regclass);


--
-- Name: mdl_workshopform_rubric_levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopform_rubric_levels ALTER COLUMN id SET DEFAULT nextval('public.mdl_workshopform_rubric_levels_id_seq'::regclass);


--
-- Name: mdl_xapi_states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_xapi_states ALTER COLUMN id SET DEFAULT nextval('public.mdl_xapi_states_id_seq'::regclass);


--
-- Name: mdl_adminpresets mdl_admi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_adminpresets
    ADD CONSTRAINT mdl_admi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_adminpresets_app mdl_admiapp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_adminpresets_app
    ADD CONSTRAINT mdl_admiapp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_adminpresets_app_it mdl_admiappit_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_adminpresets_app_it
    ADD CONSTRAINT mdl_admiappit_id_pk PRIMARY KEY (id);


--
-- Name: mdl_adminpresets_app_it_a mdl_admiappita_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_adminpresets_app_it_a
    ADD CONSTRAINT mdl_admiappita_id_pk PRIMARY KEY (id);


--
-- Name: mdl_adminpresets_app_plug mdl_admiappplug_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_adminpresets_app_plug
    ADD CONSTRAINT mdl_admiappplug_id_pk PRIMARY KEY (id);


--
-- Name: mdl_adminpresets_it mdl_admiit_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_adminpresets_it
    ADD CONSTRAINT mdl_admiit_id_pk PRIMARY KEY (id);


--
-- Name: mdl_adminpresets_it_a mdl_admiita_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_adminpresets_it_a
    ADD CONSTRAINT mdl_admiita_id_pk PRIMARY KEY (id);


--
-- Name: mdl_adminpresets_plug mdl_admiplug_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_adminpresets_plug
    ADD CONSTRAINT mdl_admiplug_id_pk PRIMARY KEY (id);


--
-- Name: mdl_ai_action_generate_image mdl_aiactigeneimag_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_ai_action_generate_image
    ADD CONSTRAINT mdl_aiactigeneimag_id_pk PRIMARY KEY (id);


--
-- Name: mdl_ai_action_generate_text mdl_aiactigenetext_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_ai_action_generate_text
    ADD CONSTRAINT mdl_aiactigenetext_id_pk PRIMARY KEY (id);


--
-- Name: mdl_ai_action_register mdl_aiactiregi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_ai_action_register
    ADD CONSTRAINT mdl_aiactiregi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_ai_action_summarise_text mdl_aiactisummtext_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_ai_action_summarise_text
    ADD CONSTRAINT mdl_aiactisummtext_id_pk PRIMARY KEY (id);


--
-- Name: mdl_ai_policy_register mdl_aipoliregi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_ai_policy_register
    ADD CONSTRAINT mdl_aipoliregi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_analytics_indicator_calc mdl_analindicalc_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_indicator_calc
    ADD CONSTRAINT mdl_analindicalc_id_pk PRIMARY KEY (id);


--
-- Name: mdl_analytics_models mdl_analmode_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_models
    ADD CONSTRAINT mdl_analmode_id_pk PRIMARY KEY (id);


--
-- Name: mdl_analytics_models_log mdl_analmodelog_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_models_log
    ADD CONSTRAINT mdl_analmodelog_id_pk PRIMARY KEY (id);


--
-- Name: mdl_analytics_predictions mdl_analpred_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_predictions
    ADD CONSTRAINT mdl_analpred_id_pk PRIMARY KEY (id);


--
-- Name: mdl_analytics_prediction_actions mdl_analpredacti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_prediction_actions
    ADD CONSTRAINT mdl_analpredacti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_analytics_predict_samples mdl_analpredsamp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_predict_samples
    ADD CONSTRAINT mdl_analpredsamp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_analytics_train_samples mdl_analtraisamp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_train_samples
    ADD CONSTRAINT mdl_analtraisamp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_analytics_used_analysables mdl_analusedanal_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_used_analysables
    ADD CONSTRAINT mdl_analusedanal_id_pk PRIMARY KEY (id);


--
-- Name: mdl_analytics_used_files mdl_analusedfile_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_analytics_used_files
    ADD CONSTRAINT mdl_analusedfile_id_pk PRIMARY KEY (id);


--
-- Name: mdl_assign mdl_assi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assign
    ADD CONSTRAINT mdl_assi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_assignfeedback_comments mdl_assicomm_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assignfeedback_comments
    ADD CONSTRAINT mdl_assicomm_id_pk PRIMARY KEY (id);


--
-- Name: mdl_assignfeedback_editpdf_annot mdl_assieditanno_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assignfeedback_editpdf_annot
    ADD CONSTRAINT mdl_assieditanno_id_pk PRIMARY KEY (id);


--
-- Name: mdl_assignfeedback_editpdf_cmnt mdl_assieditcmnt_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assignfeedback_editpdf_cmnt
    ADD CONSTRAINT mdl_assieditcmnt_id_pk PRIMARY KEY (id);


--
-- Name: mdl_assignfeedback_editpdf_quick mdl_assieditquic_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assignfeedback_editpdf_quick
    ADD CONSTRAINT mdl_assieditquic_id_pk PRIMARY KEY (id);


--
-- Name: mdl_assignfeedback_editpdf_rot mdl_assieditrot_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assignfeedback_editpdf_rot
    ADD CONSTRAINT mdl_assieditrot_id_pk PRIMARY KEY (id);


--
-- Name: mdl_assignfeedback_file mdl_assifile_id3_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assignfeedback_file
    ADD CONSTRAINT mdl_assifile_id3_pk PRIMARY KEY (id);


--
-- Name: mdl_assignsubmission_file mdl_assifile_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assignsubmission_file
    ADD CONSTRAINT mdl_assifile_id_pk PRIMARY KEY (id);


--
-- Name: mdl_assign_grades mdl_assigrad_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assign_grades
    ADD CONSTRAINT mdl_assigrad_id_pk PRIMARY KEY (id);


--
-- Name: mdl_assignsubmission_onlinetext mdl_assionli_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assignsubmission_onlinetext
    ADD CONSTRAINT mdl_assionli_id_pk PRIMARY KEY (id);


--
-- Name: mdl_assign_overrides mdl_assiover_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assign_overrides
    ADD CONSTRAINT mdl_assiover_id_pk PRIMARY KEY (id);


--
-- Name: mdl_assign_plugin_config mdl_assiplugconf_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assign_plugin_config
    ADD CONSTRAINT mdl_assiplugconf_id_pk PRIMARY KEY (id);


--
-- Name: mdl_assign_submission mdl_assisubm_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assign_submission
    ADD CONSTRAINT mdl_assisubm_id_pk PRIMARY KEY (id);


--
-- Name: mdl_assign_user_flags mdl_assiuserflag_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assign_user_flags
    ADD CONSTRAINT mdl_assiuserflag_id_pk PRIMARY KEY (id);


--
-- Name: mdl_assign_user_mapping mdl_assiusermapp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_assign_user_mapping
    ADD CONSTRAINT mdl_assiusermapp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_auth_lti_linked_login mdl_authltilinklogi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_auth_lti_linked_login
    ADD CONSTRAINT mdl_authltilinklogi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_auth_oauth2_linked_login mdl_authoautlinklogi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_auth_oauth2_linked_login
    ADD CONSTRAINT mdl_authoautlinklogi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_backup_controllers mdl_backcont_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_backup_controllers
    ADD CONSTRAINT mdl_backcont_id_pk PRIMARY KEY (id);


--
-- Name: mdl_backup_courses mdl_backcour_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_backup_courses
    ADD CONSTRAINT mdl_backcour_id_pk PRIMARY KEY (id);


--
-- Name: mdl_backup_logs mdl_backlogs_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_backup_logs
    ADD CONSTRAINT mdl_backlogs_id_pk PRIMARY KEY (id);


--
-- Name: mdl_badge mdl_badg_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge
    ADD CONSTRAINT mdl_badg_id_pk PRIMARY KEY (id);


--
-- Name: mdl_badge_alignment mdl_badgalig_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_alignment
    ADD CONSTRAINT mdl_badgalig_id_pk PRIMARY KEY (id);


--
-- Name: mdl_badge_backpack mdl_badgback_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_backpack
    ADD CONSTRAINT mdl_badgback_id_pk PRIMARY KEY (id);


--
-- Name: mdl_badge_backpack_oauth2 mdl_badgbackoaut_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_backpack_oauth2
    ADD CONSTRAINT mdl_badgbackoaut_id_pk PRIMARY KEY (id);


--
-- Name: mdl_badge_criteria mdl_badgcrit_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_criteria
    ADD CONSTRAINT mdl_badgcrit_id_pk PRIMARY KEY (id);


--
-- Name: mdl_badge_criteria_met mdl_badgcritmet_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_criteria_met
    ADD CONSTRAINT mdl_badgcritmet_id_pk PRIMARY KEY (id);


--
-- Name: mdl_badge_criteria_param mdl_badgcritpara_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_criteria_param
    ADD CONSTRAINT mdl_badgcritpara_id_pk PRIMARY KEY (id);


--
-- Name: mdl_badge_endorsement mdl_badgendo_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_endorsement
    ADD CONSTRAINT mdl_badgendo_id_pk PRIMARY KEY (id);


--
-- Name: mdl_badge_external mdl_badgexte_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_external
    ADD CONSTRAINT mdl_badgexte_id_pk PRIMARY KEY (id);


--
-- Name: mdl_badge_external_backpack mdl_badgexteback_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_external_backpack
    ADD CONSTRAINT mdl_badgexteback_id_pk PRIMARY KEY (id);


--
-- Name: mdl_badge_external_identifier mdl_badgexteiden_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_external_identifier
    ADD CONSTRAINT mdl_badgexteiden_id_pk PRIMARY KEY (id);


--
-- Name: mdl_badge_issued mdl_badgissu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_issued
    ADD CONSTRAINT mdl_badgissu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_badge_manual_award mdl_badgmanuawar_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_manual_award
    ADD CONSTRAINT mdl_badgmanuawar_id_pk PRIMARY KEY (id);


--
-- Name: mdl_badge_related mdl_badgrela_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_badge_related
    ADD CONSTRAINT mdl_badgrela_id_pk PRIMARY KEY (id);


--
-- Name: mdl_bigbluebuttonbn mdl_bigb_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_bigbluebuttonbn
    ADD CONSTRAINT mdl_bigb_id_pk PRIMARY KEY (id);


--
-- Name: mdl_bigbluebuttonbn_logs mdl_bigblogs_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_bigbluebuttonbn_logs
    ADD CONSTRAINT mdl_bigblogs_id_pk PRIMARY KEY (id);


--
-- Name: mdl_bigbluebuttonbn_recordings mdl_bigbreco_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_bigbluebuttonbn_recordings
    ADD CONSTRAINT mdl_bigbreco_id_pk PRIMARY KEY (id);


--
-- Name: mdl_block mdl_bloc_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_block
    ADD CONSTRAINT mdl_bloc_id_pk PRIMARY KEY (id);


--
-- Name: mdl_block_instances mdl_blocinst_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_block_instances
    ADD CONSTRAINT mdl_blocinst_id_pk PRIMARY KEY (id);


--
-- Name: mdl_block_positions mdl_blocposi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_block_positions
    ADD CONSTRAINT mdl_blocposi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_block_recentlyaccesseditems mdl_blocrece_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_block_recentlyaccesseditems
    ADD CONSTRAINT mdl_blocrece_id_pk PRIMARY KEY (id);


--
-- Name: mdl_block_recent_activity mdl_blocreceacti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_block_recent_activity
    ADD CONSTRAINT mdl_blocreceacti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_block_rss_client mdl_blocrssclie_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_block_rss_client
    ADD CONSTRAINT mdl_blocrssclie_id_pk PRIMARY KEY (id);


--
-- Name: mdl_blog_association mdl_blogasso_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_blog_association
    ADD CONSTRAINT mdl_blogasso_id_pk PRIMARY KEY (id);


--
-- Name: mdl_blog_external mdl_blogexte_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_blog_external
    ADD CONSTRAINT mdl_blogexte_id_pk PRIMARY KEY (id);


--
-- Name: mdl_book mdl_book_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_book
    ADD CONSTRAINT mdl_book_id_pk PRIMARY KEY (id);


--
-- Name: mdl_book_chapters mdl_bookchap_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_book_chapters
    ADD CONSTRAINT mdl_bookchap_id_pk PRIMARY KEY (id);


--
-- Name: mdl_cache_filters mdl_cachfilt_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_cache_filters
    ADD CONSTRAINT mdl_cachfilt_id_pk PRIMARY KEY (id);


--
-- Name: mdl_cache_flags mdl_cachflag_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_cache_flags
    ADD CONSTRAINT mdl_cachflag_id_pk PRIMARY KEY (id);


--
-- Name: mdl_capabilities mdl_capa_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_capabilities
    ADD CONSTRAINT mdl_capa_id_pk PRIMARY KEY (id);


--
-- Name: mdl_chat mdl_chat_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_chat
    ADD CONSTRAINT mdl_chat_id_pk PRIMARY KEY (id);


--
-- Name: mdl_chat_messages mdl_chatmess_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_chat_messages
    ADD CONSTRAINT mdl_chatmess_id_pk PRIMARY KEY (id);


--
-- Name: mdl_chat_messages_current mdl_chatmesscurr_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_chat_messages_current
    ADD CONSTRAINT mdl_chatmesscurr_id_pk PRIMARY KEY (id);


--
-- Name: mdl_chat_users mdl_chatuser_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_chat_users
    ADD CONSTRAINT mdl_chatuser_id_pk PRIMARY KEY (id);


--
-- Name: mdl_choice mdl_choi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_choice
    ADD CONSTRAINT mdl_choi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_choice_answers mdl_choiansw_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_choice_answers
    ADD CONSTRAINT mdl_choiansw_id_pk PRIMARY KEY (id);


--
-- Name: mdl_choice_options mdl_choiopti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_choice_options
    ADD CONSTRAINT mdl_choiopti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_cohort mdl_coho_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_cohort
    ADD CONSTRAINT mdl_coho_id_pk PRIMARY KEY (id);


--
-- Name: mdl_cohort_members mdl_cohomemb_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_cohort_members
    ADD CONSTRAINT mdl_cohomemb_id_pk PRIMARY KEY (id);


--
-- Name: mdl_comments mdl_comm_id3_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_comments
    ADD CONSTRAINT mdl_comm_id3_pk PRIMARY KEY (id);


--
-- Name: mdl_communication mdl_comm_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_communication
    ADD CONSTRAINT mdl_comm_id_pk PRIMARY KEY (id);


--
-- Name: mdl_communication_customlink mdl_commcust_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_communication_customlink
    ADD CONSTRAINT mdl_commcust_id_pk PRIMARY KEY (id);


--
-- Name: mdl_communication_user mdl_commuser_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_communication_user
    ADD CONSTRAINT mdl_commuser_id_pk PRIMARY KEY (id);


--
-- Name: mdl_competency mdl_comp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency
    ADD CONSTRAINT mdl_comp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_competency_coursecomp mdl_compcour_id3_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_coursecomp
    ADD CONSTRAINT mdl_compcour_id3_pk PRIMARY KEY (id);


--
-- Name: mdl_competency_coursecompsetting mdl_compcour_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_coursecompsetting
    ADD CONSTRAINT mdl_compcour_id_pk PRIMARY KEY (id);


--
-- Name: mdl_competency_evidence mdl_compevid_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_evidence
    ADD CONSTRAINT mdl_compevid_id_pk PRIMARY KEY (id);


--
-- Name: mdl_competency_framework mdl_compfram_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_framework
    ADD CONSTRAINT mdl_compfram_id_pk PRIMARY KEY (id);


--
-- Name: mdl_competency_modulecomp mdl_compmodu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_modulecomp
    ADD CONSTRAINT mdl_compmodu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_competency_plancomp mdl_compplan_id3_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_plancomp
    ADD CONSTRAINT mdl_compplan_id3_pk PRIMARY KEY (id);


--
-- Name: mdl_competency_plan mdl_compplan_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_plan
    ADD CONSTRAINT mdl_compplan_id_pk PRIMARY KEY (id);


--
-- Name: mdl_competency_relatedcomp mdl_comprela_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_relatedcomp
    ADD CONSTRAINT mdl_comprela_id_pk PRIMARY KEY (id);


--
-- Name: mdl_competency_templatecomp mdl_comptemp_id3_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_templatecomp
    ADD CONSTRAINT mdl_comptemp_id3_pk PRIMARY KEY (id);


--
-- Name: mdl_competency_templatecohort mdl_comptemp_id5_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_templatecohort
    ADD CONSTRAINT mdl_comptemp_id5_pk PRIMARY KEY (id);


--
-- Name: mdl_competency_template mdl_comptemp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_template
    ADD CONSTRAINT mdl_comptemp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_competency_usercompcourse mdl_compuser_id3_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_usercompcourse
    ADD CONSTRAINT mdl_compuser_id3_pk PRIMARY KEY (id);


--
-- Name: mdl_competency_usercompplan mdl_compuser_id5_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_usercompplan
    ADD CONSTRAINT mdl_compuser_id5_pk PRIMARY KEY (id);


--
-- Name: mdl_competency_userevidence mdl_compuser_id7_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_userevidence
    ADD CONSTRAINT mdl_compuser_id7_pk PRIMARY KEY (id);


--
-- Name: mdl_competency_userevidencecomp mdl_compuser_id9_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_userevidencecomp
    ADD CONSTRAINT mdl_compuser_id9_pk PRIMARY KEY (id);


--
-- Name: mdl_competency_usercomp mdl_compuser_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_competency_usercomp
    ADD CONSTRAINT mdl_compuser_id_pk PRIMARY KEY (id);


--
-- Name: mdl_config mdl_conf_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_config
    ADD CONSTRAINT mdl_conf_id_pk PRIMARY KEY (id);


--
-- Name: mdl_config_log mdl_conflog_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_config_log
    ADD CONSTRAINT mdl_conflog_id_pk PRIMARY KEY (id);


--
-- Name: mdl_config_plugins mdl_confplug_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_config_plugins
    ADD CONSTRAINT mdl_confplug_id_pk PRIMARY KEY (id);


--
-- Name: mdl_context mdl_cont_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_context
    ADD CONSTRAINT mdl_cont_id_pk PRIMARY KEY (id);


--
-- Name: mdl_contentbank_content mdl_contcont_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_contentbank_content
    ADD CONSTRAINT mdl_contcont_id_pk PRIMARY KEY (id);


--
-- Name: mdl_context_temp mdl_conttemp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_context_temp
    ADD CONSTRAINT mdl_conttemp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_course mdl_cour_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course
    ADD CONSTRAINT mdl_cour_id_pk PRIMARY KEY (id);


--
-- Name: mdl_course_categories mdl_courcate_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_categories
    ADD CONSTRAINT mdl_courcate_id_pk PRIMARY KEY (id);


--
-- Name: mdl_course_completions mdl_courcomp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_completions
    ADD CONSTRAINT mdl_courcomp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_course_completion_aggr_methd mdl_courcompaggrmeth_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_completion_aggr_methd
    ADD CONSTRAINT mdl_courcompaggrmeth_id_pk PRIMARY KEY (id);


--
-- Name: mdl_course_completion_criteria mdl_courcompcrit_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_completion_criteria
    ADD CONSTRAINT mdl_courcompcrit_id_pk PRIMARY KEY (id);


--
-- Name: mdl_course_completion_crit_compl mdl_courcompcritcomp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_completion_crit_compl
    ADD CONSTRAINT mdl_courcompcritcomp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_course_completion_defaults mdl_courcompdefa_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_completion_defaults
    ADD CONSTRAINT mdl_courcompdefa_id_pk PRIMARY KEY (id);


--
-- Name: mdl_course_format_options mdl_courformopti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_format_options
    ADD CONSTRAINT mdl_courformopti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_course_modules mdl_courmodu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_modules
    ADD CONSTRAINT mdl_courmodu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_course_modules_completion mdl_courmoducomp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_modules_completion
    ADD CONSTRAINT mdl_courmoducomp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_course_modules_viewed mdl_courmoduview_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_modules_viewed
    ADD CONSTRAINT mdl_courmoduview_id_pk PRIMARY KEY (id);


--
-- Name: mdl_course_published mdl_courpubl_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_published
    ADD CONSTRAINT mdl_courpubl_id_pk PRIMARY KEY (id);


--
-- Name: mdl_course_request mdl_courrequ_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_request
    ADD CONSTRAINT mdl_courrequ_id_pk PRIMARY KEY (id);


--
-- Name: mdl_course_sections mdl_coursect_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_course_sections
    ADD CONSTRAINT mdl_coursect_id_pk PRIMARY KEY (id);


--
-- Name: mdl_customfield_category mdl_custcate_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_customfield_category
    ADD CONSTRAINT mdl_custcate_id_pk PRIMARY KEY (id);


--
-- Name: mdl_customfield_data mdl_custdata_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_customfield_data
    ADD CONSTRAINT mdl_custdata_id_pk PRIMARY KEY (id);


--
-- Name: mdl_customfield_field mdl_custfiel_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_customfield_field
    ADD CONSTRAINT mdl_custfiel_id_pk PRIMARY KEY (id);


--
-- Name: mdl_data mdl_data_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_data
    ADD CONSTRAINT mdl_data_id_pk PRIMARY KEY (id);


--
-- Name: mdl_data_content mdl_datacont_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_data_content
    ADD CONSTRAINT mdl_datacont_id_pk PRIMARY KEY (id);


--
-- Name: mdl_data_fields mdl_datafiel_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_data_fields
    ADD CONSTRAINT mdl_datafiel_id_pk PRIMARY KEY (id);


--
-- Name: mdl_data_records mdl_datareco_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_data_records
    ADD CONSTRAINT mdl_datareco_id_pk PRIMARY KEY (id);


--
-- Name: mdl_editor_atto_autosave mdl_editattoauto_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_editor_atto_autosave
    ADD CONSTRAINT mdl_editattoauto_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol mdl_enro_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol
    ADD CONSTRAINT mdl_enro_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_flatfile mdl_enroflat_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_flatfile
    ADD CONSTRAINT mdl_enroflat_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_lti_app_registration mdl_enroltiappregi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_app_registration
    ADD CONSTRAINT mdl_enroltiappregi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_lti_context mdl_enrolticont_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_context
    ADD CONSTRAINT mdl_enrolticont_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_lti_deployment mdl_enroltidepl_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_deployment
    ADD CONSTRAINT mdl_enroltidepl_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_lti_lti2_consumer mdl_enroltilti2cons_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_lti2_consumer
    ADD CONSTRAINT mdl_enroltilti2cons_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_lti_lti2_context mdl_enroltilti2cont_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_lti2_context
    ADD CONSTRAINT mdl_enroltilti2cont_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_lti_lti2_nonce mdl_enroltilti2nonc_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_lti2_nonce
    ADD CONSTRAINT mdl_enroltilti2nonc_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_lti_lti2_resource_link mdl_enroltilti2resolink_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_lti2_resource_link
    ADD CONSTRAINT mdl_enroltilti2resolink_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_lti_lti2_share_key mdl_enroltilti2sharkey_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_lti2_share_key
    ADD CONSTRAINT mdl_enroltilti2sharkey_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_lti_lti2_tool_proxy mdl_enroltilti2toolprox_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_lti2_tool_proxy
    ADD CONSTRAINT mdl_enroltilti2toolprox_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_lti_lti2_user_result mdl_enroltilti2userresu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_lti2_user_result
    ADD CONSTRAINT mdl_enroltilti2userresu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_lti_resource_link mdl_enroltiresolink_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_resource_link
    ADD CONSTRAINT mdl_enroltiresolink_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_lti_tools mdl_enroltitool_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_tools
    ADD CONSTRAINT mdl_enroltitool_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_lti_tool_consumer_map mdl_enroltitoolconsmap_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_tool_consumer_map
    ADD CONSTRAINT mdl_enroltitoolconsmap_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_lti_users mdl_enroltiuser_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_users
    ADD CONSTRAINT mdl_enroltiuser_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_lti_user_resource_link mdl_enroltiuserresolink_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_lti_user_resource_link
    ADD CONSTRAINT mdl_enroltiuserresolink_id_pk PRIMARY KEY (id);


--
-- Name: mdl_enrol_paypal mdl_enropayp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_enrol_paypal
    ADD CONSTRAINT mdl_enropayp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_event mdl_even_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_event
    ADD CONSTRAINT mdl_even_id_pk PRIMARY KEY (id);


--
-- Name: mdl_events_handlers mdl_evenhand_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_events_handlers
    ADD CONSTRAINT mdl_evenhand_id_pk PRIMARY KEY (id);


--
-- Name: mdl_events_queue mdl_evenqueu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_events_queue
    ADD CONSTRAINT mdl_evenqueu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_events_queue_handlers mdl_evenqueuhand_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_events_queue_handlers
    ADD CONSTRAINT mdl_evenqueuhand_id_pk PRIMARY KEY (id);


--
-- Name: mdl_event_subscriptions mdl_evensubs_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_event_subscriptions
    ADD CONSTRAINT mdl_evensubs_id_pk PRIMARY KEY (id);


--
-- Name: mdl_external_functions mdl_extefunc_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_external_functions
    ADD CONSTRAINT mdl_extefunc_id_pk PRIMARY KEY (id);


--
-- Name: mdl_external_services mdl_exteserv_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_external_services
    ADD CONSTRAINT mdl_exteserv_id_pk PRIMARY KEY (id);


--
-- Name: mdl_external_services_functions mdl_exteservfunc_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_external_services_functions
    ADD CONSTRAINT mdl_exteservfunc_id_pk PRIMARY KEY (id);


--
-- Name: mdl_external_services_users mdl_exteservuser_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_external_services_users
    ADD CONSTRAINT mdl_exteservuser_id_pk PRIMARY KEY (id);


--
-- Name: mdl_external_tokens mdl_extetoke_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_external_tokens
    ADD CONSTRAINT mdl_extetoke_id_pk PRIMARY KEY (id);


--
-- Name: mdl_favourite mdl_favo_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_favourite
    ADD CONSTRAINT mdl_favo_id_pk PRIMARY KEY (id);


--
-- Name: mdl_feedback mdl_feed_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_feedback
    ADD CONSTRAINT mdl_feed_id_pk PRIMARY KEY (id);


--
-- Name: mdl_feedback_completedtmp mdl_feedcomp_id3_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_feedback_completedtmp
    ADD CONSTRAINT mdl_feedcomp_id3_pk PRIMARY KEY (id);


--
-- Name: mdl_feedback_completed mdl_feedcomp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_feedback_completed
    ADD CONSTRAINT mdl_feedcomp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_feedback_item mdl_feeditem_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_feedback_item
    ADD CONSTRAINT mdl_feeditem_id_pk PRIMARY KEY (id);


--
-- Name: mdl_feedback_sitecourse_map mdl_feedsitemap_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_feedback_sitecourse_map
    ADD CONSTRAINT mdl_feedsitemap_id_pk PRIMARY KEY (id);


--
-- Name: mdl_feedback_template mdl_feedtemp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_feedback_template
    ADD CONSTRAINT mdl_feedtemp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_feedback_valuetmp mdl_feedvalu_id3_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_feedback_valuetmp
    ADD CONSTRAINT mdl_feedvalu_id3_pk PRIMARY KEY (id);


--
-- Name: mdl_feedback_value mdl_feedvalu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_feedback_value
    ADD CONSTRAINT mdl_feedvalu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_files mdl_file_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_files
    ADD CONSTRAINT mdl_file_id_pk PRIMARY KEY (id);


--
-- Name: mdl_file_conversion mdl_fileconv_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_file_conversion
    ADD CONSTRAINT mdl_fileconv_id_pk PRIMARY KEY (id);


--
-- Name: mdl_files_reference mdl_filerefe_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_files_reference
    ADD CONSTRAINT mdl_filerefe_id_pk PRIMARY KEY (id);


--
-- Name: mdl_filter_active mdl_filtacti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_filter_active
    ADD CONSTRAINT mdl_filtacti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_filter_config mdl_filtconf_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_filter_config
    ADD CONSTRAINT mdl_filtconf_id_pk PRIMARY KEY (id);


--
-- Name: mdl_folder mdl_fold_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_folder
    ADD CONSTRAINT mdl_fold_id_pk PRIMARY KEY (id);


--
-- Name: mdl_forum mdl_foru_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum
    ADD CONSTRAINT mdl_foru_id_pk PRIMARY KEY (id);


--
-- Name: mdl_forum_digests mdl_forudige_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_digests
    ADD CONSTRAINT mdl_forudige_id_pk PRIMARY KEY (id);


--
-- Name: mdl_forum_discussions mdl_forudisc_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_discussions
    ADD CONSTRAINT mdl_forudisc_id_pk PRIMARY KEY (id);


--
-- Name: mdl_forum_discussion_subs mdl_forudiscsubs_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_discussion_subs
    ADD CONSTRAINT mdl_forudiscsubs_id_pk PRIMARY KEY (id);


--
-- Name: mdl_forum_grades mdl_forugrad_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_grades
    ADD CONSTRAINT mdl_forugrad_id_pk PRIMARY KEY (id);


--
-- Name: mdl_forum_posts mdl_forupost_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_posts
    ADD CONSTRAINT mdl_forupost_id_pk PRIMARY KEY (id);


--
-- Name: mdl_forum_queue mdl_foruqueu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_queue
    ADD CONSTRAINT mdl_foruqueu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_forum_read mdl_foruread_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_read
    ADD CONSTRAINT mdl_foruread_id_pk PRIMARY KEY (id);


--
-- Name: mdl_forum_subscriptions mdl_forusubs_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_subscriptions
    ADD CONSTRAINT mdl_forusubs_id_pk PRIMARY KEY (id);


--
-- Name: mdl_forum_track_prefs mdl_forutracpref_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_forum_track_prefs
    ADD CONSTRAINT mdl_forutracpref_id_pk PRIMARY KEY (id);


--
-- Name: mdl_glossary mdl_glos_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_glossary
    ADD CONSTRAINT mdl_glos_id_pk PRIMARY KEY (id);


--
-- Name: mdl_glossary_alias mdl_glosalia_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_glossary_alias
    ADD CONSTRAINT mdl_glosalia_id_pk PRIMARY KEY (id);


--
-- Name: mdl_glossary_categories mdl_gloscate_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_glossary_categories
    ADD CONSTRAINT mdl_gloscate_id_pk PRIMARY KEY (id);


--
-- Name: mdl_glossary_entries mdl_glosentr_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_glossary_entries
    ADD CONSTRAINT mdl_glosentr_id_pk PRIMARY KEY (id);


--
-- Name: mdl_glossary_entries_categories mdl_glosentrcate_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_glossary_entries_categories
    ADD CONSTRAINT mdl_glosentrcate_id_pk PRIMARY KEY (id);


--
-- Name: mdl_glossary_formats mdl_glosform_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_glossary_formats
    ADD CONSTRAINT mdl_glosform_id_pk PRIMARY KEY (id);


--
-- Name: mdl_grading_areas mdl_gradarea_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grading_areas
    ADD CONSTRAINT mdl_gradarea_id_pk PRIMARY KEY (id);


--
-- Name: mdl_grade_categories mdl_gradcate_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_categories
    ADD CONSTRAINT mdl_gradcate_id_pk PRIMARY KEY (id);


--
-- Name: mdl_grade_categories_history mdl_gradcatehist_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_categories_history
    ADD CONSTRAINT mdl_gradcatehist_id_pk PRIMARY KEY (id);


--
-- Name: mdl_grading_definitions mdl_graddefi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grading_definitions
    ADD CONSTRAINT mdl_graddefi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_grade_grades mdl_gradgrad_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_grades
    ADD CONSTRAINT mdl_gradgrad_id_pk PRIMARY KEY (id);


--
-- Name: mdl_grade_grades_history mdl_gradgradhist_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_grades_history
    ADD CONSTRAINT mdl_gradgradhist_id_pk PRIMARY KEY (id);


--
-- Name: mdl_gradingform_guide_comments mdl_gradguidcomm_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_gradingform_guide_comments
    ADD CONSTRAINT mdl_gradguidcomm_id_pk PRIMARY KEY (id);


--
-- Name: mdl_gradingform_guide_criteria mdl_gradguidcrit_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_gradingform_guide_criteria
    ADD CONSTRAINT mdl_gradguidcrit_id_pk PRIMARY KEY (id);


--
-- Name: mdl_gradingform_guide_fillings mdl_gradguidfill_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_gradingform_guide_fillings
    ADD CONSTRAINT mdl_gradguidfill_id_pk PRIMARY KEY (id);


--
-- Name: mdl_grade_import_newitem mdl_gradimponewi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_import_newitem
    ADD CONSTRAINT mdl_gradimponewi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_grade_import_values mdl_gradimpovalu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_import_values
    ADD CONSTRAINT mdl_gradimpovalu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_grading_instances mdl_gradinst_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grading_instances
    ADD CONSTRAINT mdl_gradinst_id_pk PRIMARY KEY (id);


--
-- Name: mdl_grade_items mdl_graditem_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_items
    ADD CONSTRAINT mdl_graditem_id_pk PRIMARY KEY (id);


--
-- Name: mdl_grade_items_history mdl_graditemhist_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_items_history
    ADD CONSTRAINT mdl_graditemhist_id_pk PRIMARY KEY (id);


--
-- Name: mdl_grade_letters mdl_gradlett_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_letters
    ADD CONSTRAINT mdl_gradlett_id_pk PRIMARY KEY (id);


--
-- Name: mdl_grade_outcomes mdl_gradoutc_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_outcomes
    ADD CONSTRAINT mdl_gradoutc_id_pk PRIMARY KEY (id);


--
-- Name: mdl_grade_outcomes_courses mdl_gradoutccour_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_outcomes_courses
    ADD CONSTRAINT mdl_gradoutccour_id_pk PRIMARY KEY (id);


--
-- Name: mdl_grade_outcomes_history mdl_gradoutchist_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_outcomes_history
    ADD CONSTRAINT mdl_gradoutchist_id_pk PRIMARY KEY (id);


--
-- Name: mdl_gradingform_rubric_criteria mdl_gradrubrcrit_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_gradingform_rubric_criteria
    ADD CONSTRAINT mdl_gradrubrcrit_id_pk PRIMARY KEY (id);


--
-- Name: mdl_gradingform_rubric_fillings mdl_gradrubrfill_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_gradingform_rubric_fillings
    ADD CONSTRAINT mdl_gradrubrfill_id_pk PRIMARY KEY (id);


--
-- Name: mdl_gradingform_rubric_levels mdl_gradrubrleve_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_gradingform_rubric_levels
    ADD CONSTRAINT mdl_gradrubrleve_id_pk PRIMARY KEY (id);


--
-- Name: mdl_grade_settings mdl_gradsett_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_grade_settings
    ADD CONSTRAINT mdl_gradsett_id_pk PRIMARY KEY (id);


--
-- Name: mdl_groupings mdl_grou_id3_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_groupings
    ADD CONSTRAINT mdl_grou_id3_pk PRIMARY KEY (id);


--
-- Name: mdl_groups mdl_grou_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_groups
    ADD CONSTRAINT mdl_grou_id_pk PRIMARY KEY (id);


--
-- Name: mdl_groupings_groups mdl_grougrou_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_groupings_groups
    ADD CONSTRAINT mdl_grougrou_id_pk PRIMARY KEY (id);


--
-- Name: mdl_groups_members mdl_groumemb_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_groups_members
    ADD CONSTRAINT mdl_groumemb_id_pk PRIMARY KEY (id);


--
-- Name: mdl_h5p mdl_h5p_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_h5p
    ADD CONSTRAINT mdl_h5p_id_pk PRIMARY KEY (id);


--
-- Name: mdl_h5pactivity mdl_h5pa_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_h5pactivity
    ADD CONSTRAINT mdl_h5pa_id_pk PRIMARY KEY (id);


--
-- Name: mdl_h5pactivity_attempts mdl_h5paatte_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_h5pactivity_attempts
    ADD CONSTRAINT mdl_h5paatte_id_pk PRIMARY KEY (id);


--
-- Name: mdl_h5pactivity_attempts_results mdl_h5paatteresu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_h5pactivity_attempts_results
    ADD CONSTRAINT mdl_h5paatteresu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_h5p_contents_libraries mdl_h5pcontlibr_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_h5p_contents_libraries
    ADD CONSTRAINT mdl_h5pcontlibr_id_pk PRIMARY KEY (id);


--
-- Name: mdl_h5p_libraries mdl_h5plibr_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_h5p_libraries
    ADD CONSTRAINT mdl_h5plibr_id_pk PRIMARY KEY (id);


--
-- Name: mdl_h5p_libraries_cachedassets mdl_h5plibrcach_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_h5p_libraries_cachedassets
    ADD CONSTRAINT mdl_h5plibrcach_id_pk PRIMARY KEY (id);


--
-- Name: mdl_h5p_library_dependencies mdl_h5plibrdepe_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_h5p_library_dependencies
    ADD CONSTRAINT mdl_h5plibrdepe_id_pk PRIMARY KEY (id);


--
-- Name: mdl_imscp mdl_imsc_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_imscp
    ADD CONSTRAINT mdl_imsc_id_pk PRIMARY KEY (id);


--
-- Name: mdl_infected_files mdl_infefile_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_infected_files
    ADD CONSTRAINT mdl_infefile_id_pk PRIMARY KEY (id);


--
-- Name: mdl_label mdl_labe_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_label
    ADD CONSTRAINT mdl_labe_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lesson mdl_less_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lesson
    ADD CONSTRAINT mdl_less_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lesson_answers mdl_lessansw_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lesson_answers
    ADD CONSTRAINT mdl_lessansw_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lesson_attempts mdl_lessatte_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lesson_attempts
    ADD CONSTRAINT mdl_lessatte_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lesson_branch mdl_lessbran_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lesson_branch
    ADD CONSTRAINT mdl_lessbran_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lesson_grades mdl_lessgrad_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lesson_grades
    ADD CONSTRAINT mdl_lessgrad_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lesson_overrides mdl_lessover_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lesson_overrides
    ADD CONSTRAINT mdl_lessover_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lesson_pages mdl_lesspage_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lesson_pages
    ADD CONSTRAINT mdl_lesspage_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lesson_timer mdl_lesstime_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lesson_timer
    ADD CONSTRAINT mdl_lesstime_id_pk PRIMARY KEY (id);


--
-- Name: mdl_license mdl_lice_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_license
    ADD CONSTRAINT mdl_lice_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lock_db mdl_lockdb_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lock_db
    ADD CONSTRAINT mdl_lockdb_id_pk PRIMARY KEY (id);


--
-- Name: mdl_log mdl_log_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_log
    ADD CONSTRAINT mdl_log_id_pk PRIMARY KEY (id);


--
-- Name: mdl_log_display mdl_logdisp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_log_display
    ADD CONSTRAINT mdl_logdisp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_log_queries mdl_logquer_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_log_queries
    ADD CONSTRAINT mdl_logquer_id_pk PRIMARY KEY (id);


--
-- Name: mdl_logstore_standard_log mdl_logsstanlog_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_logstore_standard_log
    ADD CONSTRAINT mdl_logsstanlog_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lti mdl_lti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti
    ADD CONSTRAINT mdl_lti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lti_access_tokens mdl_ltiaccetoke_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti_access_tokens
    ADD CONSTRAINT mdl_ltiaccetoke_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lti_coursevisible mdl_lticour_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti_coursevisible
    ADD CONSTRAINT mdl_lticour_id_pk PRIMARY KEY (id);


--
-- Name: mdl_ltiservice_gradebookservices mdl_ltisgrad_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_ltiservice_gradebookservices
    ADD CONSTRAINT mdl_ltisgrad_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lti_submission mdl_ltisubm_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti_submission
    ADD CONSTRAINT mdl_ltisubm_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lti_tool_proxies mdl_ltitoolprox_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti_tool_proxies
    ADD CONSTRAINT mdl_ltitoolprox_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lti_tool_settings mdl_ltitoolsett_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti_tool_settings
    ADD CONSTRAINT mdl_ltitoolsett_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lti_types mdl_ltitype_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti_types
    ADD CONSTRAINT mdl_ltitype_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lti_types_categories mdl_ltitypecate_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti_types_categories
    ADD CONSTRAINT mdl_ltitypecate_id_pk PRIMARY KEY (id);


--
-- Name: mdl_lti_types_config mdl_ltitypeconf_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_lti_types_config
    ADD CONSTRAINT mdl_ltitypeconf_id_pk PRIMARY KEY (id);


--
-- Name: mdl_matrix_room mdl_matrroom_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_matrix_room
    ADD CONSTRAINT mdl_matrroom_id_pk PRIMARY KEY (id);


--
-- Name: mdl_messages mdl_mess_id3_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_messages
    ADD CONSTRAINT mdl_mess_id3_pk PRIMARY KEY (id);


--
-- Name: mdl_message mdl_mess_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message
    ADD CONSTRAINT mdl_mess_id_pk PRIMARY KEY (id);


--
-- Name: mdl_message_airnotifier_devices mdl_messairndevi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_airnotifier_devices
    ADD CONSTRAINT mdl_messairndevi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_message_contacts mdl_messcont_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_contacts
    ADD CONSTRAINT mdl_messcont_id_pk PRIMARY KEY (id);


--
-- Name: mdl_message_contact_requests mdl_messcontrequ_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_contact_requests
    ADD CONSTRAINT mdl_messcontrequ_id_pk PRIMARY KEY (id);


--
-- Name: mdl_message_conversations mdl_messconv_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_conversations
    ADD CONSTRAINT mdl_messconv_id_pk PRIMARY KEY (id);


--
-- Name: mdl_message_conversation_actions mdl_messconvacti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_conversation_actions
    ADD CONSTRAINT mdl_messconvacti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_message_conversation_members mdl_messconvmemb_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_conversation_members
    ADD CONSTRAINT mdl_messconvmemb_id_pk PRIMARY KEY (id);


--
-- Name: mdl_messageinbound_datakeys mdl_messdata_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_messageinbound_datakeys
    ADD CONSTRAINT mdl_messdata_id_pk PRIMARY KEY (id);


--
-- Name: mdl_message_email_messages mdl_messemaimess_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_email_messages
    ADD CONSTRAINT mdl_messemaimess_id_pk PRIMARY KEY (id);


--
-- Name: mdl_messageinbound_handlers mdl_messhand_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_messageinbound_handlers
    ADD CONSTRAINT mdl_messhand_id_pk PRIMARY KEY (id);


--
-- Name: mdl_messageinbound_messagelist mdl_messmess_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_messageinbound_messagelist
    ADD CONSTRAINT mdl_messmess_id_pk PRIMARY KEY (id);


--
-- Name: mdl_message_popup mdl_messpopu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_popup
    ADD CONSTRAINT mdl_messpopu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_message_popup_notifications mdl_messpopunoti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_popup_notifications
    ADD CONSTRAINT mdl_messpopunoti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_message_processors mdl_messproc_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_processors
    ADD CONSTRAINT mdl_messproc_id_pk PRIMARY KEY (id);


--
-- Name: mdl_message_providers mdl_messprov_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_providers
    ADD CONSTRAINT mdl_messprov_id_pk PRIMARY KEY (id);


--
-- Name: mdl_message_read mdl_messread_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_read
    ADD CONSTRAINT mdl_messread_id_pk PRIMARY KEY (id);


--
-- Name: mdl_message_user_actions mdl_messuseracti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_user_actions
    ADD CONSTRAINT mdl_messuseracti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_message_users_blocked mdl_messuserbloc_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_message_users_blocked
    ADD CONSTRAINT mdl_messuserbloc_id_pk PRIMARY KEY (id);


--
-- Name: mdl_mnet_application mdl_mnetappl_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_application
    ADD CONSTRAINT mdl_mnetappl_id_pk PRIMARY KEY (id);


--
-- Name: mdl_mnetservice_enrol_courses mdl_mnetenrocour_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnetservice_enrol_courses
    ADD CONSTRAINT mdl_mnetenrocour_id_pk PRIMARY KEY (id);


--
-- Name: mdl_mnetservice_enrol_enrolments mdl_mnetenroenro_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnetservice_enrol_enrolments
    ADD CONSTRAINT mdl_mnetenroenro_id_pk PRIMARY KEY (id);


--
-- Name: mdl_mnet_host2service mdl_mnethost_id3_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_host2service
    ADD CONSTRAINT mdl_mnethost_id3_pk PRIMARY KEY (id);


--
-- Name: mdl_mnet_host mdl_mnethost_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_host
    ADD CONSTRAINT mdl_mnethost_id_pk PRIMARY KEY (id);


--
-- Name: mdl_mnet_log mdl_mnetlog_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_log
    ADD CONSTRAINT mdl_mnetlog_id_pk PRIMARY KEY (id);


--
-- Name: mdl_mnet_remote_rpc mdl_mnetremorpc_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_remote_rpc
    ADD CONSTRAINT mdl_mnetremorpc_id_pk PRIMARY KEY (id);


--
-- Name: mdl_mnet_remote_service2rpc mdl_mnetremoserv_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_remote_service2rpc
    ADD CONSTRAINT mdl_mnetremoserv_id_pk PRIMARY KEY (id);


--
-- Name: mdl_mnet_rpc mdl_mnetrpc_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_rpc
    ADD CONSTRAINT mdl_mnetrpc_id_pk PRIMARY KEY (id);


--
-- Name: mdl_mnet_service2rpc mdl_mnetserv_id3_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_service2rpc
    ADD CONSTRAINT mdl_mnetserv_id3_pk PRIMARY KEY (id);


--
-- Name: mdl_mnet_service mdl_mnetserv_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_service
    ADD CONSTRAINT mdl_mnetserv_id_pk PRIMARY KEY (id);


--
-- Name: mdl_mnet_session mdl_mnetsess_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_session
    ADD CONSTRAINT mdl_mnetsess_id_pk PRIMARY KEY (id);


--
-- Name: mdl_mnet_sso_access_control mdl_mnetssoaccecont_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_mnet_sso_access_control
    ADD CONSTRAINT mdl_mnetssoaccecont_id_pk PRIMARY KEY (id);


--
-- Name: mdl_modules mdl_modu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_modules
    ADD CONSTRAINT mdl_modu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_moodlenet_share_progress mdl_moodsharprog_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_moodlenet_share_progress
    ADD CONSTRAINT mdl_moodsharprog_id_pk PRIMARY KEY (id);


--
-- Name: mdl_my_pages mdl_mypage_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_my_pages
    ADD CONSTRAINT mdl_mypage_id_pk PRIMARY KEY (id);


--
-- Name: mdl_notifications mdl_noti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_notifications
    ADD CONSTRAINT mdl_noti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_oauth2_access_token mdl_oautaccetoke_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_oauth2_access_token
    ADD CONSTRAINT mdl_oautaccetoke_id_pk PRIMARY KEY (id);


--
-- Name: mdl_oauth2_endpoint mdl_oautendp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_oauth2_endpoint
    ADD CONSTRAINT mdl_oautendp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_oauth2_issuer mdl_oautissu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_oauth2_issuer
    ADD CONSTRAINT mdl_oautissu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_oauth2_refresh_token mdl_oautrefrtoke_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_oauth2_refresh_token
    ADD CONSTRAINT mdl_oautrefrtoke_id_pk PRIMARY KEY (id);


--
-- Name: mdl_oauth2_system_account mdl_oautsystacco_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_oauth2_system_account
    ADD CONSTRAINT mdl_oautsystacco_id_pk PRIMARY KEY (id);


--
-- Name: mdl_oauth2_user_field_mapping mdl_oautuserfielmapp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_oauth2_user_field_mapping
    ADD CONSTRAINT mdl_oautuserfielmapp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_page mdl_page_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_page
    ADD CONSTRAINT mdl_page_id_pk PRIMARY KEY (id);


--
-- Name: mdl_paygw_paypal mdl_paygpayp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_paygw_paypal
    ADD CONSTRAINT mdl_paygpayp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_payments mdl_paym_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_payments
    ADD CONSTRAINT mdl_paym_id_pk PRIMARY KEY (id);


--
-- Name: mdl_payment_accounts mdl_paymacco_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_payment_accounts
    ADD CONSTRAINT mdl_paymacco_id_pk PRIMARY KEY (id);


--
-- Name: mdl_payment_gateways mdl_paymgate_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_payment_gateways
    ADD CONSTRAINT mdl_paymgate_id_pk PRIMARY KEY (id);


--
-- Name: mdl_portfolio_instance mdl_portinst_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_portfolio_instance
    ADD CONSTRAINT mdl_portinst_id_pk PRIMARY KEY (id);


--
-- Name: mdl_portfolio_instance_config mdl_portinstconf_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_portfolio_instance_config
    ADD CONSTRAINT mdl_portinstconf_id_pk PRIMARY KEY (id);


--
-- Name: mdl_portfolio_instance_user mdl_portinstuser_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_portfolio_instance_user
    ADD CONSTRAINT mdl_portinstuser_id_pk PRIMARY KEY (id);


--
-- Name: mdl_portfolio_log mdl_portlog_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_portfolio_log
    ADD CONSTRAINT mdl_portlog_id_pk PRIMARY KEY (id);


--
-- Name: mdl_portfolio_mahara_queue mdl_portmahaqueu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_portfolio_mahara_queue
    ADD CONSTRAINT mdl_portmahaqueu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_portfolio_tempdata mdl_porttemp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_portfolio_tempdata
    ADD CONSTRAINT mdl_porttemp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_post mdl_post_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_post
    ADD CONSTRAINT mdl_post_id_pk PRIMARY KEY (id);


--
-- Name: mdl_profiling mdl_prof_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_profiling
    ADD CONSTRAINT mdl_prof_id_pk PRIMARY KEY (id);


--
-- Name: mdl_qtype_ddimageortext mdl_qtypddim_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_ddimageortext
    ADD CONSTRAINT mdl_qtypddim_id_pk PRIMARY KEY (id);


--
-- Name: mdl_qtype_ddimageortext_drags mdl_qtypddimdrag_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_ddimageortext_drags
    ADD CONSTRAINT mdl_qtypddimdrag_id_pk PRIMARY KEY (id);


--
-- Name: mdl_qtype_ddimageortext_drops mdl_qtypddimdrop_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_ddimageortext_drops
    ADD CONSTRAINT mdl_qtypddimdrop_id_pk PRIMARY KEY (id);


--
-- Name: mdl_qtype_ddmarker mdl_qtypddma_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_ddmarker
    ADD CONSTRAINT mdl_qtypddma_id_pk PRIMARY KEY (id);


--
-- Name: mdl_qtype_ddmarker_drags mdl_qtypddmadrag_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_ddmarker_drags
    ADD CONSTRAINT mdl_qtypddmadrag_id_pk PRIMARY KEY (id);


--
-- Name: mdl_qtype_ddmarker_drops mdl_qtypddmadrop_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_ddmarker_drops
    ADD CONSTRAINT mdl_qtypddmadrop_id_pk PRIMARY KEY (id);


--
-- Name: mdl_qtype_essay_options mdl_qtypessaopti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_essay_options
    ADD CONSTRAINT mdl_qtypessaopti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_qtype_match_options mdl_qtypmatcopti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_match_options
    ADD CONSTRAINT mdl_qtypmatcopti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_qtype_match_subquestions mdl_qtypmatcsubq_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_match_subquestions
    ADD CONSTRAINT mdl_qtypmatcsubq_id_pk PRIMARY KEY (id);


--
-- Name: mdl_qtype_multichoice_options mdl_qtypmultopti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_multichoice_options
    ADD CONSTRAINT mdl_qtypmultopti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_qtype_ordering_options mdl_qtypordeopti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_ordering_options
    ADD CONSTRAINT mdl_qtypordeopti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_qtype_randomsamatch_options mdl_qtyprandopti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_randomsamatch_options
    ADD CONSTRAINT mdl_qtyprandopti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_qtype_shortanswer_options mdl_qtypshoropti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_qtype_shortanswer_options
    ADD CONSTRAINT mdl_qtypshoropti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question mdl_ques_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question
    ADD CONSTRAINT mdl_ques_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_answers mdl_quesansw_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_answers
    ADD CONSTRAINT mdl_quesansw_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_attempts mdl_quesatte_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_attempts
    ADD CONSTRAINT mdl_quesatte_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_attempt_steps mdl_quesattestep_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_attempt_steps
    ADD CONSTRAINT mdl_quesattestep_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_attempt_step_data mdl_quesattestepdata_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_attempt_step_data
    ADD CONSTRAINT mdl_quesattestepdata_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_bank_entries mdl_quesbankentr_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_bank_entries
    ADD CONSTRAINT mdl_quesbankentr_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_calculated mdl_quescalc_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_calculated
    ADD CONSTRAINT mdl_quescalc_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_calculated_options mdl_quescalcopti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_calculated_options
    ADD CONSTRAINT mdl_quescalcopti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_categories mdl_quescate_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_categories
    ADD CONSTRAINT mdl_quescate_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_datasets mdl_quesdata_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_datasets
    ADD CONSTRAINT mdl_quesdata_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_dataset_definitions mdl_quesdatadefi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_dataset_definitions
    ADD CONSTRAINT mdl_quesdatadefi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_dataset_items mdl_quesdataitem_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_dataset_items
    ADD CONSTRAINT mdl_quesdataitem_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_ddwtos mdl_quesddwt_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_ddwtos
    ADD CONSTRAINT mdl_quesddwt_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_gapselect mdl_quesgaps_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_gapselect
    ADD CONSTRAINT mdl_quesgaps_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_hints mdl_queshint_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_hints
    ADD CONSTRAINT mdl_queshint_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_multianswer mdl_quesmult_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_multianswer
    ADD CONSTRAINT mdl_quesmult_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_numerical mdl_quesnume_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_numerical
    ADD CONSTRAINT mdl_quesnume_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_numerical_options mdl_quesnumeopti_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_numerical_options
    ADD CONSTRAINT mdl_quesnumeopti_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_numerical_units mdl_quesnumeunit_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_numerical_units
    ADD CONSTRAINT mdl_quesnumeunit_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_references mdl_quesrefe_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_references
    ADD CONSTRAINT mdl_quesrefe_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_response_analysis mdl_quesrespanal_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_response_analysis
    ADD CONSTRAINT mdl_quesrespanal_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_response_count mdl_quesrespcoun_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_response_count
    ADD CONSTRAINT mdl_quesrespcoun_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_set_references mdl_quessetrefe_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_set_references
    ADD CONSTRAINT mdl_quessetrefe_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_statistics mdl_quesstat_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_statistics
    ADD CONSTRAINT mdl_quesstat_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_truefalse mdl_questrue_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_truefalse
    ADD CONSTRAINT mdl_questrue_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_usages mdl_quesusag_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_usages
    ADD CONSTRAINT mdl_quesusag_id_pk PRIMARY KEY (id);


--
-- Name: mdl_question_versions mdl_quesvers_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_question_versions
    ADD CONSTRAINT mdl_quesvers_id_pk PRIMARY KEY (id);


--
-- Name: mdl_quiz mdl_quiz_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz
    ADD CONSTRAINT mdl_quiz_id_pk PRIMARY KEY (id);


--
-- Name: mdl_quiz_attempts mdl_quizatte_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_attempts
    ADD CONSTRAINT mdl_quizatte_id_pk PRIMARY KEY (id);


--
-- Name: mdl_quiz_feedback mdl_quizfeed_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_feedback
    ADD CONSTRAINT mdl_quizfeed_id_pk PRIMARY KEY (id);


--
-- Name: mdl_quiz_grades mdl_quizgrad_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_grades
    ADD CONSTRAINT mdl_quizgrad_id_pk PRIMARY KEY (id);


--
-- Name: mdl_quiz_grade_items mdl_quizgraditem_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_grade_items
    ADD CONSTRAINT mdl_quizgraditem_id_pk PRIMARY KEY (id);


--
-- Name: mdl_quiz_overrides mdl_quizover_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_overrides
    ADD CONSTRAINT mdl_quizover_id_pk PRIMARY KEY (id);


--
-- Name: mdl_quiz_overview_regrades mdl_quizoverregr_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_overview_regrades
    ADD CONSTRAINT mdl_quizoverregr_id_pk PRIMARY KEY (id);


--
-- Name: mdl_quiz_reports mdl_quizrepo_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_reports
    ADD CONSTRAINT mdl_quizrepo_id_pk PRIMARY KEY (id);


--
-- Name: mdl_quizaccess_seb_quizsettings mdl_quizsebquiz_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quizaccess_seb_quizsettings
    ADD CONSTRAINT mdl_quizsebquiz_id_pk PRIMARY KEY (id);


--
-- Name: mdl_quizaccess_seb_template mdl_quizsebtemp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quizaccess_seb_template
    ADD CONSTRAINT mdl_quizsebtemp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_quiz_sections mdl_quizsect_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_sections
    ADD CONSTRAINT mdl_quizsect_id_pk PRIMARY KEY (id);


--
-- Name: mdl_quiz_slots mdl_quizslot_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_slots
    ADD CONSTRAINT mdl_quizslot_id_pk PRIMARY KEY (id);


--
-- Name: mdl_quiz_statistics mdl_quizstat_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_quiz_statistics
    ADD CONSTRAINT mdl_quizstat_id_pk PRIMARY KEY (id);


--
-- Name: mdl_rating mdl_rati_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_rating
    ADD CONSTRAINT mdl_rati_id_pk PRIMARY KEY (id);


--
-- Name: mdl_registration_hubs mdl_regihubs_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_registration_hubs
    ADD CONSTRAINT mdl_regihubs_id_pk PRIMARY KEY (id);


--
-- Name: mdl_repository mdl_repo_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_repository
    ADD CONSTRAINT mdl_repo_id_pk PRIMARY KEY (id);


--
-- Name: mdl_reportbuilder_audience mdl_repoaudi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_reportbuilder_audience
    ADD CONSTRAINT mdl_repoaudi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_reportbuilder_column mdl_repocolu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_reportbuilder_column
    ADD CONSTRAINT mdl_repocolu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_reportbuilder_filter mdl_repofilt_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_reportbuilder_filter
    ADD CONSTRAINT mdl_repofilt_id_pk PRIMARY KEY (id);


--
-- Name: mdl_repository_instances mdl_repoinst_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_repository_instances
    ADD CONSTRAINT mdl_repoinst_id_pk PRIMARY KEY (id);


--
-- Name: mdl_repository_instance_config mdl_repoinstconf_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_repository_instance_config
    ADD CONSTRAINT mdl_repoinstconf_id_pk PRIMARY KEY (id);


--
-- Name: mdl_repository_onedrive_access mdl_repoonedacce_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_repository_onedrive_access
    ADD CONSTRAINT mdl_repoonedacce_id_pk PRIMARY KEY (id);


--
-- Name: mdl_reportbuilder_report mdl_reporepo_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_reportbuilder_report
    ADD CONSTRAINT mdl_reporepo_id_pk PRIMARY KEY (id);


--
-- Name: mdl_reportbuilder_schedule mdl_reposche_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_reportbuilder_schedule
    ADD CONSTRAINT mdl_reposche_id_pk PRIMARY KEY (id);


--
-- Name: mdl_resource mdl_reso_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_resource
    ADD CONSTRAINT mdl_reso_id_pk PRIMARY KEY (id);


--
-- Name: mdl_resource_old mdl_resoold_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_resource_old
    ADD CONSTRAINT mdl_resoold_id_pk PRIMARY KEY (id);


--
-- Name: mdl_role mdl_role_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role
    ADD CONSTRAINT mdl_role_id_pk PRIMARY KEY (id);


--
-- Name: mdl_role_allow_assign mdl_rolealloassi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role_allow_assign
    ADD CONSTRAINT mdl_rolealloassi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_role_allow_override mdl_rolealloover_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role_allow_override
    ADD CONSTRAINT mdl_rolealloover_id_pk PRIMARY KEY (id);


--
-- Name: mdl_role_allow_switch mdl_rolealloswit_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role_allow_switch
    ADD CONSTRAINT mdl_rolealloswit_id_pk PRIMARY KEY (id);


--
-- Name: mdl_role_allow_view mdl_rolealloview_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role_allow_view
    ADD CONSTRAINT mdl_rolealloview_id_pk PRIMARY KEY (id);


--
-- Name: mdl_role_assignments mdl_roleassi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role_assignments
    ADD CONSTRAINT mdl_roleassi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_role_capabilities mdl_rolecapa_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role_capabilities
    ADD CONSTRAINT mdl_rolecapa_id_pk PRIMARY KEY (id);


--
-- Name: mdl_role_context_levels mdl_rolecontleve_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role_context_levels
    ADD CONSTRAINT mdl_rolecontleve_id_pk PRIMARY KEY (id);


--
-- Name: mdl_role_names mdl_rolename_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_role_names
    ADD CONSTRAINT mdl_rolename_id_pk PRIMARY KEY (id);


--
-- Name: mdl_scale mdl_scal_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scale
    ADD CONSTRAINT mdl_scal_id_pk PRIMARY KEY (id);


--
-- Name: mdl_scale_history mdl_scalhist_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scale_history
    ADD CONSTRAINT mdl_scalhist_id_pk PRIMARY KEY (id);


--
-- Name: mdl_scorm mdl_scor_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm
    ADD CONSTRAINT mdl_scor_id_pk PRIMARY KEY (id);


--
-- Name: mdl_scorm_aicc_session mdl_scoraiccsess_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_aicc_session
    ADD CONSTRAINT mdl_scoraiccsess_id_pk PRIMARY KEY (id);


--
-- Name: mdl_scorm_attempt mdl_scoratte_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_attempt
    ADD CONSTRAINT mdl_scoratte_id_pk PRIMARY KEY (id);


--
-- Name: mdl_scorm_element mdl_scorelem_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_element
    ADD CONSTRAINT mdl_scorelem_id_pk PRIMARY KEY (id);


--
-- Name: mdl_scorm_scoes mdl_scorscoe_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_scoes
    ADD CONSTRAINT mdl_scorscoe_id_pk PRIMARY KEY (id);


--
-- Name: mdl_scorm_scoes_data mdl_scorscoedata_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_scoes_data
    ADD CONSTRAINT mdl_scorscoedata_id_pk PRIMARY KEY (id);


--
-- Name: mdl_scorm_scoes_value mdl_scorscoevalu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_scoes_value
    ADD CONSTRAINT mdl_scorscoevalu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_scorm_seq_mapinfo mdl_scorseqmapi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_seq_mapinfo
    ADD CONSTRAINT mdl_scorseqmapi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_scorm_seq_objective mdl_scorseqobje_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_seq_objective
    ADD CONSTRAINT mdl_scorseqobje_id_pk PRIMARY KEY (id);


--
-- Name: mdl_scorm_seq_rolluprulecond mdl_scorseqroll_id3_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_seq_rolluprulecond
    ADD CONSTRAINT mdl_scorseqroll_id3_pk PRIMARY KEY (id);


--
-- Name: mdl_scorm_seq_rolluprule mdl_scorseqroll_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_seq_rolluprule
    ADD CONSTRAINT mdl_scorseqroll_id_pk PRIMARY KEY (id);


--
-- Name: mdl_scorm_seq_rulecond mdl_scorseqrule_id3_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_seq_rulecond
    ADD CONSTRAINT mdl_scorseqrule_id3_pk PRIMARY KEY (id);


--
-- Name: mdl_scorm_seq_ruleconds mdl_scorseqrule_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_scorm_seq_ruleconds
    ADD CONSTRAINT mdl_scorseqrule_id_pk PRIMARY KEY (id);


--
-- Name: mdl_search_index_requests mdl_searinderequ_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_search_index_requests
    ADD CONSTRAINT mdl_searinderequ_id_pk PRIMARY KEY (id);


--
-- Name: mdl_search_simpledb_index mdl_searsimpinde_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_search_simpledb_index
    ADD CONSTRAINT mdl_searsimpinde_id_pk PRIMARY KEY (id);


--
-- Name: mdl_sessions mdl_sess_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_sessions
    ADD CONSTRAINT mdl_sess_id_pk PRIMARY KEY (id);


--
-- Name: mdl_sms_gateways mdl_smsgate_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_sms_gateways
    ADD CONSTRAINT mdl_smsgate_id_pk PRIMARY KEY (id);


--
-- Name: mdl_sms_messages mdl_smsmess_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_sms_messages
    ADD CONSTRAINT mdl_smsmess_id_pk PRIMARY KEY (id);


--
-- Name: mdl_stats_daily mdl_statdail_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_stats_daily
    ADD CONSTRAINT mdl_statdail_id_pk PRIMARY KEY (id);


--
-- Name: mdl_stats_monthly mdl_statmont_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_stats_monthly
    ADD CONSTRAINT mdl_statmont_id_pk PRIMARY KEY (id);


--
-- Name: mdl_stats_user_daily mdl_statuserdail_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_stats_user_daily
    ADD CONSTRAINT mdl_statuserdail_id_pk PRIMARY KEY (id);


--
-- Name: mdl_stats_user_monthly mdl_statusermont_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_stats_user_monthly
    ADD CONSTRAINT mdl_statusermont_id_pk PRIMARY KEY (id);


--
-- Name: mdl_stats_user_weekly mdl_statuserweek_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_stats_user_weekly
    ADD CONSTRAINT mdl_statuserweek_id_pk PRIMARY KEY (id);


--
-- Name: mdl_stats_weekly mdl_statweek_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_stats_weekly
    ADD CONSTRAINT mdl_statweek_id_pk PRIMARY KEY (id);


--
-- Name: mdl_stored_progress mdl_storprog_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_stored_progress
    ADD CONSTRAINT mdl_storprog_id_pk PRIMARY KEY (id);


--
-- Name: mdl_subsection mdl_subs_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_subsection
    ADD CONSTRAINT mdl_subs_id_pk PRIMARY KEY (id);


--
-- Name: mdl_survey mdl_surv_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_survey
    ADD CONSTRAINT mdl_surv_id_pk PRIMARY KEY (id);


--
-- Name: mdl_survey_analysis mdl_survanal_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_survey_analysis
    ADD CONSTRAINT mdl_survanal_id_pk PRIMARY KEY (id);


--
-- Name: mdl_survey_answers mdl_survansw_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_survey_answers
    ADD CONSTRAINT mdl_survansw_id_pk PRIMARY KEY (id);


--
-- Name: mdl_survey_questions mdl_survques_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_survey_questions
    ADD CONSTRAINT mdl_survques_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tag mdl_tag_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tag
    ADD CONSTRAINT mdl_tag_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tag_area mdl_tagarea_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tag_area
    ADD CONSTRAINT mdl_tagarea_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tag_coll mdl_tagcoll_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tag_coll
    ADD CONSTRAINT mdl_tagcoll_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tag_correlation mdl_tagcorr_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tag_correlation
    ADD CONSTRAINT mdl_tagcorr_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tag_instance mdl_taginst_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tag_instance
    ADD CONSTRAINT mdl_taginst_id_pk PRIMARY KEY (id);


--
-- Name: mdl_task_adhoc mdl_taskadho_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_task_adhoc
    ADD CONSTRAINT mdl_taskadho_id_pk PRIMARY KEY (id);


--
-- Name: mdl_task_log mdl_tasklog_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_task_log
    ADD CONSTRAINT mdl_tasklog_id_pk PRIMARY KEY (id);


--
-- Name: mdl_task_scheduled mdl_tasksche_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_task_scheduled
    ADD CONSTRAINT mdl_tasksche_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tiny_autosave mdl_tinyauto_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tiny_autosave
    ADD CONSTRAINT mdl_tinyauto_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_brickfield_areas mdl_toolbricarea_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_areas
    ADD CONSTRAINT mdl_toolbricarea_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_brickfield_cache_acts mdl_toolbriccachacts_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_cache_acts
    ADD CONSTRAINT mdl_toolbriccachacts_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_brickfield_cache_check mdl_toolbriccachchec_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_cache_check
    ADD CONSTRAINT mdl_toolbriccachchec_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_brickfield_checks mdl_toolbricchec_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_checks
    ADD CONSTRAINT mdl_toolbricchec_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_brickfield_content mdl_toolbriccont_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_content
    ADD CONSTRAINT mdl_toolbriccont_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_brickfield_errors mdl_toolbricerro_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_errors
    ADD CONSTRAINT mdl_toolbricerro_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_brickfield_process mdl_toolbricproc_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_process
    ADD CONSTRAINT mdl_toolbricproc_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_brickfield_results mdl_toolbricresu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_results
    ADD CONSTRAINT mdl_toolbricresu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_brickfield_schedule mdl_toolbricsche_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_schedule
    ADD CONSTRAINT mdl_toolbricsche_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_brickfield_summary mdl_toolbricsumm_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_brickfield_summary
    ADD CONSTRAINT mdl_toolbricsumm_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_cohortroles mdl_toolcoho_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_cohortroles
    ADD CONSTRAINT mdl_toolcoho_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_customlang mdl_toolcust_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_customlang
    ADD CONSTRAINT mdl_toolcust_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_customlang_components mdl_toolcustcomp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_customlang_components
    ADD CONSTRAINT mdl_toolcustcomp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_dataprivacy_category mdl_tooldatacate_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_category
    ADD CONSTRAINT mdl_tooldatacate_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_dataprivacy_contextlist mdl_tooldatacont_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_contextlist
    ADD CONSTRAINT mdl_tooldatacont_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_dataprivacy_ctxexpired mdl_tooldatactxe_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_ctxexpired
    ADD CONSTRAINT mdl_tooldatactxe_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_dataprivacy_ctxinstance mdl_tooldatactxi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_ctxinstance
    ADD CONSTRAINT mdl_tooldatactxi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_dataprivacy_ctxlevel mdl_tooldatactxl_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_ctxlevel
    ADD CONSTRAINT mdl_tooldatactxl_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_dataprivacy_ctxlst_ctx mdl_tooldatactxlctx_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_ctxlst_ctx
    ADD CONSTRAINT mdl_tooldatactxlctx_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_dataprivacy_purposerole mdl_tooldatapurp_id3_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_purposerole
    ADD CONSTRAINT mdl_tooldatapurp_id3_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_dataprivacy_purpose mdl_tooldatapurp_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_purpose
    ADD CONSTRAINT mdl_tooldatapurp_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_dataprivacy_request mdl_tooldatarequ_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_request
    ADD CONSTRAINT mdl_tooldatarequ_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_dataprivacy_rqst_ctxlst mdl_tooldatarqstctxl_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_dataprivacy_rqst_ctxlst
    ADD CONSTRAINT mdl_tooldatarqstctxl_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_mfa mdl_toolmfa_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_mfa
    ADD CONSTRAINT mdl_toolmfa_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_mfa_auth mdl_toolmfaauth_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_mfa_auth
    ADD CONSTRAINT mdl_toolmfaauth_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_mfa_secrets mdl_toolmfasecr_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_mfa_secrets
    ADD CONSTRAINT mdl_toolmfasecr_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_monitor_events mdl_toolmonieven_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_monitor_events
    ADD CONSTRAINT mdl_toolmonieven_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_monitor_history mdl_toolmonihist_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_monitor_history
    ADD CONSTRAINT mdl_toolmonihist_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_monitor_rules mdl_toolmonirule_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_monitor_rules
    ADD CONSTRAINT mdl_toolmonirule_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_monitor_subscriptions mdl_toolmonisubs_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_monitor_subscriptions
    ADD CONSTRAINT mdl_toolmonisubs_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_policy mdl_toolpoli_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_policy
    ADD CONSTRAINT mdl_toolpoli_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_policy_acceptances mdl_toolpoliacce_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_policy_acceptances
    ADD CONSTRAINT mdl_toolpoliacce_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_policy_versions mdl_toolpolivers_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_policy_versions
    ADD CONSTRAINT mdl_toolpolivers_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_recyclebin_category mdl_toolrecycate_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_recyclebin_category
    ADD CONSTRAINT mdl_toolrecycate_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_recyclebin_course mdl_toolrecycour_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_recyclebin_course
    ADD CONSTRAINT mdl_toolrecycour_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_usertours_steps mdl_tooluserstep_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_usertours_steps
    ADD CONSTRAINT mdl_tooluserstep_id_pk PRIMARY KEY (id);


--
-- Name: mdl_tool_usertours_tours mdl_toolusertour_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_tool_usertours_tours
    ADD CONSTRAINT mdl_toolusertour_id_pk PRIMARY KEY (id);


--
-- Name: mdl_upgrade_log mdl_upgrlog_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_upgrade_log
    ADD CONSTRAINT mdl_upgrlog_id_pk PRIMARY KEY (id);


--
-- Name: mdl_url mdl_url_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_url
    ADD CONSTRAINT mdl_url_id_pk PRIMARY KEY (id);


--
-- Name: mdl_user mdl_user_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user
    ADD CONSTRAINT mdl_user_id_pk PRIMARY KEY (id);


--
-- Name: mdl_user_devices mdl_userdevi_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_devices
    ADD CONSTRAINT mdl_userdevi_id_pk PRIMARY KEY (id);


--
-- Name: mdl_user_enrolments mdl_userenro_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_enrolments
    ADD CONSTRAINT mdl_userenro_id_pk PRIMARY KEY (id);


--
-- Name: mdl_user_info_category mdl_userinfocate_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_info_category
    ADD CONSTRAINT mdl_userinfocate_id_pk PRIMARY KEY (id);


--
-- Name: mdl_user_info_data mdl_userinfodata_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_info_data
    ADD CONSTRAINT mdl_userinfodata_id_pk PRIMARY KEY (id);


--
-- Name: mdl_user_info_field mdl_userinfofiel_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_info_field
    ADD CONSTRAINT mdl_userinfofiel_id_pk PRIMARY KEY (id);


--
-- Name: mdl_user_lastaccess mdl_userlast_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_lastaccess
    ADD CONSTRAINT mdl_userlast_id_pk PRIMARY KEY (id);


--
-- Name: mdl_user_password_history mdl_userpasshist_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_password_history
    ADD CONSTRAINT mdl_userpasshist_id_pk PRIMARY KEY (id);


--
-- Name: mdl_user_password_resets mdl_userpassrese_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_password_resets
    ADD CONSTRAINT mdl_userpassrese_id_pk PRIMARY KEY (id);


--
-- Name: mdl_user_preferences mdl_userpref_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_preferences
    ADD CONSTRAINT mdl_userpref_id_pk PRIMARY KEY (id);


--
-- Name: mdl_user_private_key mdl_userprivkey_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_user_private_key
    ADD CONSTRAINT mdl_userprivkey_id_pk PRIMARY KEY (id);


--
-- Name: mdl_wiki mdl_wiki_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_wiki
    ADD CONSTRAINT mdl_wiki_id_pk PRIMARY KEY (id);


--
-- Name: mdl_wiki_links mdl_wikilink_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_wiki_links
    ADD CONSTRAINT mdl_wikilink_id_pk PRIMARY KEY (id);


--
-- Name: mdl_wiki_locks mdl_wikilock_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_wiki_locks
    ADD CONSTRAINT mdl_wikilock_id_pk PRIMARY KEY (id);


--
-- Name: mdl_wiki_pages mdl_wikipage_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_wiki_pages
    ADD CONSTRAINT mdl_wikipage_id_pk PRIMARY KEY (id);


--
-- Name: mdl_wiki_subwikis mdl_wikisubw_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_wiki_subwikis
    ADD CONSTRAINT mdl_wikisubw_id_pk PRIMARY KEY (id);


--
-- Name: mdl_wiki_synonyms mdl_wikisyno_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_wiki_synonyms
    ADD CONSTRAINT mdl_wikisyno_id_pk PRIMARY KEY (id);


--
-- Name: mdl_wiki_versions mdl_wikivers_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_wiki_versions
    ADD CONSTRAINT mdl_wikivers_id_pk PRIMARY KEY (id);


--
-- Name: mdl_workshop mdl_work_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshop
    ADD CONSTRAINT mdl_work_id_pk PRIMARY KEY (id);


--
-- Name: mdl_workshopform_accumulative mdl_workaccu_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopform_accumulative
    ADD CONSTRAINT mdl_workaccu_id_pk PRIMARY KEY (id);


--
-- Name: mdl_workshop_aggregations mdl_workaggr_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshop_aggregations
    ADD CONSTRAINT mdl_workaggr_id_pk PRIMARY KEY (id);


--
-- Name: mdl_workshop_assessments mdl_workasse_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshop_assessments
    ADD CONSTRAINT mdl_workasse_id_pk PRIMARY KEY (id);


--
-- Name: mdl_workshopeval_best_settings mdl_workbestsett_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopeval_best_settings
    ADD CONSTRAINT mdl_workbestsett_id_pk PRIMARY KEY (id);


--
-- Name: mdl_workshopform_comments mdl_workcomm_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopform_comments
    ADD CONSTRAINT mdl_workcomm_id_pk PRIMARY KEY (id);


--
-- Name: mdl_workshop_grades mdl_workgrad_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshop_grades
    ADD CONSTRAINT mdl_workgrad_id_pk PRIMARY KEY (id);


--
-- Name: mdl_workshopform_numerrors mdl_worknume_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopform_numerrors
    ADD CONSTRAINT mdl_worknume_id_pk PRIMARY KEY (id);


--
-- Name: mdl_workshopform_numerrors_map mdl_worknumemap_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopform_numerrors_map
    ADD CONSTRAINT mdl_worknumemap_id_pk PRIMARY KEY (id);


--
-- Name: mdl_workshopform_rubric mdl_workrubr_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopform_rubric
    ADD CONSTRAINT mdl_workrubr_id_pk PRIMARY KEY (id);


--
-- Name: mdl_workshopform_rubric_config mdl_workrubrconf_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopform_rubric_config
    ADD CONSTRAINT mdl_workrubrconf_id_pk PRIMARY KEY (id);


--
-- Name: mdl_workshopform_rubric_levels mdl_workrubrleve_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopform_rubric_levels
    ADD CONSTRAINT mdl_workrubrleve_id_pk PRIMARY KEY (id);


--
-- Name: mdl_workshopallocation_scheduled mdl_worksche_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshopallocation_scheduled
    ADD CONSTRAINT mdl_worksche_id_pk PRIMARY KEY (id);


--
-- Name: mdl_workshop_submissions mdl_worksubm_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_workshop_submissions
    ADD CONSTRAINT mdl_worksubm_id_pk PRIMARY KEY (id);


--
-- Name: mdl_xapi_states mdl_xapistat_id_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mdl_xapi_states
    ADD CONSTRAINT mdl_xapistat_id_pk PRIMARY KEY (id);


--
-- Name: mdl_admiapp_adm_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_admiapp_adm_ix ON public.mdl_adminpresets_app USING btree (adminpresetid);


--
-- Name: mdl_admiappit_adm_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_admiappit_adm_ix ON public.mdl_adminpresets_app_it USING btree (adminpresetapplyid);


--
-- Name: mdl_admiappit_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_admiappit_con_ix ON public.mdl_adminpresets_app_it USING btree (configlogid);


--
-- Name: mdl_admiappita_adm_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_admiappita_adm_ix ON public.mdl_adminpresets_app_it_a USING btree (adminpresetapplyid);


--
-- Name: mdl_admiappita_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_admiappita_con_ix ON public.mdl_adminpresets_app_it_a USING btree (configlogid);


--
-- Name: mdl_admiappplug_adm_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_admiappplug_adm_ix ON public.mdl_adminpresets_app_plug USING btree (adminpresetapplyid);


--
-- Name: mdl_admiit_adm_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_admiit_adm_ix ON public.mdl_adminpresets_it USING btree (adminpresetid);


--
-- Name: mdl_admiita_ite_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_admiita_ite_ix ON public.mdl_adminpresets_it_a USING btree (itemid);


--
-- Name: mdl_admiplug_adm_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_admiplug_adm_ix ON public.mdl_adminpresets_plug USING btree (adminpresetid);


--
-- Name: mdl_aiactiregi_actact_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_aiactiregi_actact_uix ON public.mdl_ai_action_register USING btree (actionname, actionid);


--
-- Name: mdl_aiactiregi_actpro_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_aiactiregi_actpro_ix ON public.mdl_ai_action_register USING btree (actionname, provider);


--
-- Name: mdl_aiactiregi_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_aiactiregi_use_ix ON public.mdl_ai_action_register USING btree (userid);


--
-- Name: mdl_aipoliregi_use_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_aipoliregi_use_uix ON public.mdl_ai_policy_register USING btree (userid);


--
-- Name: mdl_analindicalc_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analindicalc_con_ix ON public.mdl_analytics_indicator_calc USING btree (contextid);


--
-- Name: mdl_analindicalc_staendcon_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analindicalc_staendcon_ix ON public.mdl_analytics_indicator_calc USING btree (starttime, endtime, contextid);


--
-- Name: mdl_analmode_enatra_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analmode_enatra_ix ON public.mdl_analytics_models USING btree (enabled, trained);


--
-- Name: mdl_analmode_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analmode_use_ix ON public.mdl_analytics_models USING btree (usermodified);


--
-- Name: mdl_analmodelog_mod_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analmodelog_mod_ix ON public.mdl_analytics_models_log USING btree (modelid);


--
-- Name: mdl_analmodelog_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analmodelog_use_ix ON public.mdl_analytics_models_log USING btree (usermodified);


--
-- Name: mdl_analpred_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analpred_con_ix ON public.mdl_analytics_predictions USING btree (contextid);


--
-- Name: mdl_analpred_mod_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analpred_mod_ix ON public.mdl_analytics_predictions USING btree (modelid);


--
-- Name: mdl_analpred_modcon_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analpred_modcon_ix ON public.mdl_analytics_predictions USING btree (modelid, contextid);


--
-- Name: mdl_analpredacti_pre_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analpredacti_pre_ix ON public.mdl_analytics_prediction_actions USING btree (predictionid);


--
-- Name: mdl_analpredacti_preuseact_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analpredacti_preuseact_ix ON public.mdl_analytics_prediction_actions USING btree (predictionid, userid, actionname);


--
-- Name: mdl_analpredacti_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analpredacti_use_ix ON public.mdl_analytics_prediction_actions USING btree (userid);


--
-- Name: mdl_analpredsamp_mod_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analpredsamp_mod_ix ON public.mdl_analytics_predict_samples USING btree (modelid);


--
-- Name: mdl_analpredsamp_modanatimr_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analpredsamp_modanatimr_ix ON public.mdl_analytics_predict_samples USING btree (modelid, analysableid, timesplitting, rangeindex);


--
-- Name: mdl_analtraisamp_mod_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analtraisamp_mod_ix ON public.mdl_analytics_train_samples USING btree (modelid);


--
-- Name: mdl_analtraisamp_modanatim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analtraisamp_modanatim_ix ON public.mdl_analytics_train_samples USING btree (modelid, analysableid, timesplitting);


--
-- Name: mdl_analusedanal_ana_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analusedanal_ana_ix ON public.mdl_analytics_used_analysables USING btree (analysableid);


--
-- Name: mdl_analusedanal_mod_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analusedanal_mod_ix ON public.mdl_analytics_used_analysables USING btree (modelid);


--
-- Name: mdl_analusedanal_modact_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analusedanal_modact_ix ON public.mdl_analytics_used_analysables USING btree (modelid, action);


--
-- Name: mdl_analusedfile_fil_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analusedfile_fil_ix ON public.mdl_analytics_used_files USING btree (fileid);


--
-- Name: mdl_analusedfile_mod_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analusedfile_mod_ix ON public.mdl_analytics_used_files USING btree (modelid);


--
-- Name: mdl_analusedfile_modactfil_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_analusedfile_modactfil_ix ON public.mdl_analytics_used_files USING btree (modelid, action, fileid);


--
-- Name: mdl_assi_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assi_cou_ix ON public.mdl_assign USING btree (course);


--
-- Name: mdl_assi_tea_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assi_tea_ix ON public.mdl_assign USING btree (teamsubmissiongroupingid);


--
-- Name: mdl_assicomm_ass_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assicomm_ass_ix ON public.mdl_assignfeedback_comments USING btree (assignment);


--
-- Name: mdl_assicomm_gra_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assicomm_gra_ix ON public.mdl_assignfeedback_comments USING btree (grade);


--
-- Name: mdl_assieditanno_gra_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assieditanno_gra_ix ON public.mdl_assignfeedback_editpdf_annot USING btree (gradeid);


--
-- Name: mdl_assieditanno_grapag_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assieditanno_grapag_ix ON public.mdl_assignfeedback_editpdf_annot USING btree (gradeid, pageno);


--
-- Name: mdl_assieditcmnt_gra_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assieditcmnt_gra_ix ON public.mdl_assignfeedback_editpdf_cmnt USING btree (gradeid);


--
-- Name: mdl_assieditcmnt_grapag_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assieditcmnt_grapag_ix ON public.mdl_assignfeedback_editpdf_cmnt USING btree (gradeid, pageno);


--
-- Name: mdl_assieditquic_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assieditquic_use_ix ON public.mdl_assignfeedback_editpdf_quick USING btree (userid);


--
-- Name: mdl_assieditrot_gra_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assieditrot_gra_ix ON public.mdl_assignfeedback_editpdf_rot USING btree (gradeid);


--
-- Name: mdl_assieditrot_grapag_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_assieditrot_grapag_uix ON public.mdl_assignfeedback_editpdf_rot USING btree (gradeid, pageno);


--
-- Name: mdl_assifile_ass2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assifile_ass2_ix ON public.mdl_assignfeedback_file USING btree (assignment);


--
-- Name: mdl_assifile_ass_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assifile_ass_ix ON public.mdl_assignsubmission_file USING btree (assignment);


--
-- Name: mdl_assifile_gra_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assifile_gra_ix ON public.mdl_assignfeedback_file USING btree (grade);


--
-- Name: mdl_assifile_sub_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assifile_sub_ix ON public.mdl_assignsubmission_file USING btree (submission);


--
-- Name: mdl_assigrad_ass_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assigrad_ass_ix ON public.mdl_assign_grades USING btree (assignment);


--
-- Name: mdl_assigrad_assuseatt_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_assigrad_assuseatt_uix ON public.mdl_assign_grades USING btree (assignment, userid, attemptnumber);


--
-- Name: mdl_assigrad_att_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assigrad_att_ix ON public.mdl_assign_grades USING btree (attemptnumber);


--
-- Name: mdl_assigrad_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assigrad_use_ix ON public.mdl_assign_grades USING btree (userid);


--
-- Name: mdl_assionli_ass_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assionli_ass_ix ON public.mdl_assignsubmission_onlinetext USING btree (assignment);


--
-- Name: mdl_assionli_sub_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assionli_sub_ix ON public.mdl_assignsubmission_onlinetext USING btree (submission);


--
-- Name: mdl_assiover_ass_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assiover_ass_ix ON public.mdl_assign_overrides USING btree (assignid);


--
-- Name: mdl_assiover_gro_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assiover_gro_ix ON public.mdl_assign_overrides USING btree (groupid);


--
-- Name: mdl_assiover_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assiover_use_ix ON public.mdl_assign_overrides USING btree (userid);


--
-- Name: mdl_assiplugconf_ass_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assiplugconf_ass_ix ON public.mdl_assign_plugin_config USING btree (assignment);


--
-- Name: mdl_assiplugconf_nam_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assiplugconf_nam_ix ON public.mdl_assign_plugin_config USING btree (name);


--
-- Name: mdl_assiplugconf_plu_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assiplugconf_plu_ix ON public.mdl_assign_plugin_config USING btree (plugin);


--
-- Name: mdl_assiplugconf_sub_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assiplugconf_sub_ix ON public.mdl_assign_plugin_config USING btree (subtype);


--
-- Name: mdl_assisubm_ass_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assisubm_ass_ix ON public.mdl_assign_submission USING btree (assignment);


--
-- Name: mdl_assisubm_assusegroatt_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_assisubm_assusegroatt_uix ON public.mdl_assign_submission USING btree (assignment, userid, groupid, attemptnumber);


--
-- Name: mdl_assisubm_assusegrolat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assisubm_assusegrolat_ix ON public.mdl_assign_submission USING btree (assignment, userid, groupid, latest);


--
-- Name: mdl_assisubm_att_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assisubm_att_ix ON public.mdl_assign_submission USING btree (attemptnumber);


--
-- Name: mdl_assisubm_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assisubm_use_ix ON public.mdl_assign_submission USING btree (userid);


--
-- Name: mdl_assiuserflag_ass_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assiuserflag_ass_ix ON public.mdl_assign_user_flags USING btree (assignment);


--
-- Name: mdl_assiuserflag_mai_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assiuserflag_mai_ix ON public.mdl_assign_user_flags USING btree (mailed);


--
-- Name: mdl_assiuserflag_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assiuserflag_use_ix ON public.mdl_assign_user_flags USING btree (userid);


--
-- Name: mdl_assiusermapp_ass_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assiusermapp_ass_ix ON public.mdl_assign_user_mapping USING btree (assignment);


--
-- Name: mdl_assiusermapp_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_assiusermapp_use_ix ON public.mdl_assign_user_mapping USING btree (userid);


--
-- Name: mdl_authltilinklogi_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_authltilinklogi_use_ix ON public.mdl_auth_lti_linked_login USING btree (userid);


--
-- Name: mdl_authltilinklogi_useiss_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_authltilinklogi_useiss_uix ON public.mdl_auth_lti_linked_login USING btree (userid, issuer256, sub256);


--
-- Name: mdl_authoautlinklogi_iss_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_authoautlinklogi_iss_ix ON public.mdl_auth_oauth2_linked_login USING btree (issuerid);


--
-- Name: mdl_authoautlinklogi_issuse_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_authoautlinklogi_issuse_ix ON public.mdl_auth_oauth2_linked_login USING btree (issuerid, username);


--
-- Name: mdl_authoautlinklogi_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_authoautlinklogi_use2_ix ON public.mdl_auth_oauth2_linked_login USING btree (userid);


--
-- Name: mdl_authoautlinklogi_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_authoautlinklogi_use_ix ON public.mdl_auth_oauth2_linked_login USING btree (usermodified);


--
-- Name: mdl_authoautlinklogi_useis_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_authoautlinklogi_useis_uix ON public.mdl_auth_oauth2_linked_login USING btree (userid, issuerid, username);


--
-- Name: mdl_backcont_bac_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_backcont_bac_uix ON public.mdl_backup_controllers USING btree (backupid);


--
-- Name: mdl_backcont_typite_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_backcont_typite_ix ON public.mdl_backup_controllers USING btree (type, itemid);


--
-- Name: mdl_backcont_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_backcont_use_ix ON public.mdl_backup_controllers USING btree (userid);


--
-- Name: mdl_backcont_useite_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_backcont_useite_ix ON public.mdl_backup_controllers USING btree (userid, itemid);


--
-- Name: mdl_backcour_cou_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_backcour_cou_uix ON public.mdl_backup_courses USING btree (courseid);


--
-- Name: mdl_backlogs_bac_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_backlogs_bac_ix ON public.mdl_backup_logs USING btree (backupid);


--
-- Name: mdl_backlogs_bacid_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_backlogs_bacid_uix ON public.mdl_backup_logs USING btree (backupid, id);


--
-- Name: mdl_badg_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badg_cou_ix ON public.mdl_badge USING btree (courseid);


--
-- Name: mdl_badg_typ_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badg_typ_ix ON public.mdl_badge USING btree (type);


--
-- Name: mdl_badg_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badg_use2_ix ON public.mdl_badge USING btree (usercreated);


--
-- Name: mdl_badg_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badg_use_ix ON public.mdl_badge USING btree (usermodified);


--
-- Name: mdl_badgalig_bad_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgalig_bad_ix ON public.mdl_badge_alignment USING btree (badgeid);


--
-- Name: mdl_badgback_ext_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgback_ext_ix ON public.mdl_badge_backpack USING btree (externalbackpackid);


--
-- Name: mdl_badgback_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgback_use_ix ON public.mdl_badge_backpack USING btree (userid);


--
-- Name: mdl_badgback_useext_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_badgback_useext_uix ON public.mdl_badge_backpack USING btree (userid, externalbackpackid);


--
-- Name: mdl_badgbackoaut_ext_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgbackoaut_ext_ix ON public.mdl_badge_backpack_oauth2 USING btree (externalbackpackid);


--
-- Name: mdl_badgbackoaut_iss_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgbackoaut_iss_ix ON public.mdl_badge_backpack_oauth2 USING btree (issuerid);


--
-- Name: mdl_badgbackoaut_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgbackoaut_use2_ix ON public.mdl_badge_backpack_oauth2 USING btree (userid);


--
-- Name: mdl_badgbackoaut_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgbackoaut_use_ix ON public.mdl_badge_backpack_oauth2 USING btree (usermodified);


--
-- Name: mdl_badgcrit_bad_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgcrit_bad_ix ON public.mdl_badge_criteria USING btree (badgeid);


--
-- Name: mdl_badgcrit_badcri_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_badgcrit_badcri_uix ON public.mdl_badge_criteria USING btree (badgeid, criteriatype);


--
-- Name: mdl_badgcrit_cri_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgcrit_cri_ix ON public.mdl_badge_criteria USING btree (criteriatype);


--
-- Name: mdl_badgcritmet_cri_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgcritmet_cri_ix ON public.mdl_badge_criteria_met USING btree (critid);


--
-- Name: mdl_badgcritmet_iss_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgcritmet_iss_ix ON public.mdl_badge_criteria_met USING btree (issuedid);


--
-- Name: mdl_badgcritmet_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgcritmet_use_ix ON public.mdl_badge_criteria_met USING btree (userid);


--
-- Name: mdl_badgcritpara_cri_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgcritpara_cri_ix ON public.mdl_badge_criteria_param USING btree (critid);


--
-- Name: mdl_badgendo_bad_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgendo_bad_ix ON public.mdl_badge_endorsement USING btree (badgeid);


--
-- Name: mdl_badgexte_bac_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgexte_bac_ix ON public.mdl_badge_external USING btree (backpackid);


--
-- Name: mdl_badgexteback_bac2_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_badgexteback_bac2_uix ON public.mdl_badge_external_backpack USING btree (backpackweburl);


--
-- Name: mdl_badgexteback_bac_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_badgexteback_bac_uix ON public.mdl_badge_external_backpack USING btree (backpackapiurl);


--
-- Name: mdl_badgexteback_oau_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgexteback_oau_ix ON public.mdl_badge_external_backpack USING btree (oauth2_issuerid);


--
-- Name: mdl_badgexteiden_sit_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgexteiden_sit_ix ON public.mdl_badge_external_identifier USING btree (sitebackpackid);


--
-- Name: mdl_badgexteiden_sitintext_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_badgexteiden_sitintext_uix ON public.mdl_badge_external_identifier USING btree (sitebackpackid, internalid, externalid, type);


--
-- Name: mdl_badgissu_bad_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgissu_bad_ix ON public.mdl_badge_issued USING btree (badgeid);


--
-- Name: mdl_badgissu_baduse_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_badgissu_baduse_uix ON public.mdl_badge_issued USING btree (badgeid, userid);


--
-- Name: mdl_badgissu_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgissu_use_ix ON public.mdl_badge_issued USING btree (userid);


--
-- Name: mdl_badgmanuawar_bad_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgmanuawar_bad_ix ON public.mdl_badge_manual_award USING btree (badgeid);


--
-- Name: mdl_badgmanuawar_iss2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgmanuawar_iss2_ix ON public.mdl_badge_manual_award USING btree (issuerrole);


--
-- Name: mdl_badgmanuawar_iss_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgmanuawar_iss_ix ON public.mdl_badge_manual_award USING btree (issuerid);


--
-- Name: mdl_badgmanuawar_rec_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgmanuawar_rec_ix ON public.mdl_badge_manual_award USING btree (recipientid);


--
-- Name: mdl_badgrela_bad_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgrela_bad_ix ON public.mdl_badge_related USING btree (badgeid);


--
-- Name: mdl_badgrela_badrel_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_badgrela_badrel_uix ON public.mdl_badge_related USING btree (badgeid, relatedbadgeid);


--
-- Name: mdl_badgrela_rel_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_badgrela_rel_ix ON public.mdl_badge_related USING btree (relatedbadgeid);


--
-- Name: mdl_bigblogs_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_bigblogs_cou_ix ON public.mdl_bigbluebuttonbn_logs USING btree (courseid);


--
-- Name: mdl_bigblogs_coubig_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_bigblogs_coubig_ix ON public.mdl_bigbluebuttonbn_logs USING btree (courseid, bigbluebuttonbnid);


--
-- Name: mdl_bigblogs_coubiguselog_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_bigblogs_coubiguselog_ix ON public.mdl_bigbluebuttonbn_logs USING btree (courseid, bigbluebuttonbnid, userid, log);


--
-- Name: mdl_bigblogs_log_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_bigblogs_log_ix ON public.mdl_bigbluebuttonbn_logs USING btree (log);


--
-- Name: mdl_bigblogs_uselog_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_bigblogs_uselog_ix ON public.mdl_bigbluebuttonbn_logs USING btree (userid, log);


--
-- Name: mdl_bigbreco_big_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_bigbreco_big_ix ON public.mdl_bigbluebuttonbn_recordings USING btree (bigbluebuttonbnid);


--
-- Name: mdl_bigbreco_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_bigbreco_cou_ix ON public.mdl_bigbluebuttonbn_recordings USING btree (courseid);


--
-- Name: mdl_bigbreco_rec_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_bigbreco_rec_ix ON public.mdl_bigbluebuttonbn_recordings USING btree (recordingid);


--
-- Name: mdl_bigbreco_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_bigbreco_use_ix ON public.mdl_bigbluebuttonbn_recordings USING btree (usermodified);


--
-- Name: mdl_bloc_nam_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_bloc_nam_uix ON public.mdl_block USING btree (name);


--
-- Name: mdl_blocinst_blo_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_blocinst_blo_ix ON public.mdl_block_instances USING btree (blockname);


--
-- Name: mdl_blocinst_par_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_blocinst_par_ix ON public.mdl_block_instances USING btree (parentcontextid);


--
-- Name: mdl_blocinst_parshopagsub_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_blocinst_parshopagsub_ix ON public.mdl_block_instances USING btree (parentcontextid, showinsubcontexts, pagetypepattern, subpagepattern);


--
-- Name: mdl_blocinst_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_blocinst_tim_ix ON public.mdl_block_instances USING btree (timemodified);


--
-- Name: mdl_blocposi_blo_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_blocposi_blo_ix ON public.mdl_block_positions USING btree (blockinstanceid);


--
-- Name: mdl_blocposi_bloconpagsub_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_blocposi_bloconpagsub_uix ON public.mdl_block_positions USING btree (blockinstanceid, contextid, pagetype, subpage);


--
-- Name: mdl_blocposi_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_blocposi_con_ix ON public.mdl_block_positions USING btree (contextid);


--
-- Name: mdl_blocrece_cmi_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_blocrece_cmi_ix ON public.mdl_block_recentlyaccesseditems USING btree (cmid);


--
-- Name: mdl_blocrece_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_blocrece_cou_ix ON public.mdl_block_recentlyaccesseditems USING btree (courseid);


--
-- Name: mdl_blocrece_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_blocrece_use_ix ON public.mdl_block_recentlyaccesseditems USING btree (userid);


--
-- Name: mdl_blocrece_usecoucmi_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_blocrece_usecoucmi_uix ON public.mdl_block_recentlyaccesseditems USING btree (userid, courseid, cmid);


--
-- Name: mdl_blocreceacti_coutim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_blocreceacti_coutim_ix ON public.mdl_block_recent_activity USING btree (courseid, timecreated);


--
-- Name: mdl_blogasso_blo_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_blogasso_blo_ix ON public.mdl_blog_association USING btree (blogid);


--
-- Name: mdl_blogasso_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_blogasso_con_ix ON public.mdl_blog_association USING btree (contextid);


--
-- Name: mdl_blogexte_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_blogexte_use_ix ON public.mdl_blog_external USING btree (userid);


--
-- Name: mdl_book_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_book_cou_ix ON public.mdl_book USING btree (course);


--
-- Name: mdl_bookchap_boo_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_bookchap_boo_ix ON public.mdl_book_chapters USING btree (bookid);


--
-- Name: mdl_cachfilt_filmd5_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_cachfilt_filmd5_ix ON public.mdl_cache_filters USING btree (filter, md5key);


--
-- Name: mdl_cachflag_fla_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_cachflag_fla_ix ON public.mdl_cache_flags USING btree (flagtype);


--
-- Name: mdl_cachflag_nam_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_cachflag_nam_ix ON public.mdl_cache_flags USING btree (name);


--
-- Name: mdl_capa_nam_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_capa_nam_uix ON public.mdl_capabilities USING btree (name);


--
-- Name: mdl_chat_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_chat_cou_ix ON public.mdl_chat USING btree (course);


--
-- Name: mdl_chatmess_cha_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_chatmess_cha_ix ON public.mdl_chat_messages USING btree (chatid);


--
-- Name: mdl_chatmess_gro_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_chatmess_gro_ix ON public.mdl_chat_messages USING btree (groupid);


--
-- Name: mdl_chatmess_timcha_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_chatmess_timcha_ix ON public.mdl_chat_messages USING btree ("timestamp", chatid);


--
-- Name: mdl_chatmess_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_chatmess_use_ix ON public.mdl_chat_messages USING btree (userid);


--
-- Name: mdl_chatmesscurr_cha_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_chatmesscurr_cha_ix ON public.mdl_chat_messages_current USING btree (chatid);


--
-- Name: mdl_chatmesscurr_gro_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_chatmesscurr_gro_ix ON public.mdl_chat_messages_current USING btree (groupid);


--
-- Name: mdl_chatmesscurr_timcha_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_chatmesscurr_timcha_ix ON public.mdl_chat_messages_current USING btree ("timestamp", chatid);


--
-- Name: mdl_chatmesscurr_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_chatmesscurr_use_ix ON public.mdl_chat_messages_current USING btree (userid);


--
-- Name: mdl_chatuser_cha_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_chatuser_cha_ix ON public.mdl_chat_users USING btree (chatid);


--
-- Name: mdl_chatuser_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_chatuser_cou_ix ON public.mdl_chat_users USING btree (course);


--
-- Name: mdl_chatuser_gro_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_chatuser_gro_ix ON public.mdl_chat_users USING btree (groupid);


--
-- Name: mdl_chatuser_las_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_chatuser_las_ix ON public.mdl_chat_users USING btree (lastping);


--
-- Name: mdl_chatuser_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_chatuser_use_ix ON public.mdl_chat_users USING btree (userid);


--
-- Name: mdl_choi_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_choi_cou_ix ON public.mdl_choice USING btree (course);


--
-- Name: mdl_choiansw_cho_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_choiansw_cho_ix ON public.mdl_choice_answers USING btree (choiceid);


--
-- Name: mdl_choiansw_opt_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_choiansw_opt_ix ON public.mdl_choice_answers USING btree (optionid);


--
-- Name: mdl_choiansw_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_choiansw_use_ix ON public.mdl_choice_answers USING btree (userid);


--
-- Name: mdl_choiopti_cho_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_choiopti_cho_ix ON public.mdl_choice_options USING btree (choiceid);


--
-- Name: mdl_coho_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_coho_con_ix ON public.mdl_cohort USING btree (contextid);


--
-- Name: mdl_cohomemb_coh_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_cohomemb_coh_ix ON public.mdl_cohort_members USING btree (cohortid);


--
-- Name: mdl_cohomemb_cohuse_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_cohomemb_cohuse_uix ON public.mdl_cohort_members USING btree (cohortid, userid);


--
-- Name: mdl_cohomemb_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_cohomemb_use_ix ON public.mdl_cohort_members USING btree (userid);


--
-- Name: mdl_comm_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_comm_con_ix ON public.mdl_communication USING btree (contextid);


--
-- Name: mdl_comm_concomite_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_comm_concomite_ix ON public.mdl_comments USING btree (contextid, commentarea, itemid);


--
-- Name: mdl_comm_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_comm_use_ix ON public.mdl_comments USING btree (userid);


--
-- Name: mdl_commcust_com_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_commcust_com_ix ON public.mdl_communication_customlink USING btree (commid);


--
-- Name: mdl_commuser_com_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_commuser_com_ix ON public.mdl_communication_user USING btree (commid);


--
-- Name: mdl_commuser_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_commuser_use_ix ON public.mdl_communication_user USING btree (userid);


--
-- Name: mdl_comp_comidn_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_comp_comidn_uix ON public.mdl_competency USING btree (competencyframeworkid, idnumber);


--
-- Name: mdl_comp_rul_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_comp_rul_ix ON public.mdl_competency USING btree (ruleoutcome);


--
-- Name: mdl_comp_sca_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_comp_sca_ix ON public.mdl_competency USING btree (scaleid);


--
-- Name: mdl_comp_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_comp_use_ix ON public.mdl_competency USING btree (usermodified);


--
-- Name: mdl_compcour_com_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compcour_com_ix ON public.mdl_competency_coursecomp USING btree (competencyid);


--
-- Name: mdl_compcour_cou2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compcour_cou2_ix ON public.mdl_competency_coursecomp USING btree (courseid);


--
-- Name: mdl_compcour_cou_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_compcour_cou_uix ON public.mdl_competency_coursecompsetting USING btree (courseid);


--
-- Name: mdl_compcour_coucom_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_compcour_coucom_uix ON public.mdl_competency_coursecomp USING btree (courseid, competencyid);


--
-- Name: mdl_compcour_courul_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compcour_courul_ix ON public.mdl_competency_coursecomp USING btree (courseid, ruleoutcome);


--
-- Name: mdl_compcour_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compcour_use2_ix ON public.mdl_competency_coursecomp USING btree (usermodified);


--
-- Name: mdl_compcour_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compcour_use_ix ON public.mdl_competency_coursecompsetting USING btree (usermodified);


--
-- Name: mdl_compevid_act_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compevid_act_ix ON public.mdl_competency_evidence USING btree (actionuserid);


--
-- Name: mdl_compevid_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compevid_con_ix ON public.mdl_competency_evidence USING btree (contextid);


--
-- Name: mdl_compevid_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compevid_use2_ix ON public.mdl_competency_evidence USING btree (usermodified);


--
-- Name: mdl_compevid_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compevid_use_ix ON public.mdl_competency_evidence USING btree (usercompetencyid);


--
-- Name: mdl_compfram_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compfram_con_ix ON public.mdl_competency_framework USING btree (contextid);


--
-- Name: mdl_compfram_idn_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_compfram_idn_uix ON public.mdl_competency_framework USING btree (idnumber);


--
-- Name: mdl_compfram_sca_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compfram_sca_ix ON public.mdl_competency_framework USING btree (scaleid);


--
-- Name: mdl_compfram_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compfram_use_ix ON public.mdl_competency_framework USING btree (usermodified);


--
-- Name: mdl_compmodu_cmi_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compmodu_cmi_ix ON public.mdl_competency_modulecomp USING btree (cmid);


--
-- Name: mdl_compmodu_cmicom_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_compmodu_cmicom_uix ON public.mdl_competency_modulecomp USING btree (cmid, competencyid);


--
-- Name: mdl_compmodu_cmirul_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compmodu_cmirul_ix ON public.mdl_competency_modulecomp USING btree (cmid, ruleoutcome);


--
-- Name: mdl_compmodu_com_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compmodu_com_ix ON public.mdl_competency_modulecomp USING btree (competencyid);


--
-- Name: mdl_compmodu_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compmodu_use_ix ON public.mdl_competency_modulecomp USING btree (usermodified);


--
-- Name: mdl_compplan_placom_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_compplan_placom_uix ON public.mdl_competency_plancomp USING btree (planid, competencyid);


--
-- Name: mdl_compplan_stadue_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compplan_stadue_ix ON public.mdl_competency_plan USING btree (status, duedate);


--
-- Name: mdl_compplan_tem_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compplan_tem_ix ON public.mdl_competency_plan USING btree (templateid);


--
-- Name: mdl_compplan_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compplan_use2_ix ON public.mdl_competency_plancomp USING btree (usermodified);


--
-- Name: mdl_compplan_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compplan_use_ix ON public.mdl_competency_plan USING btree (usermodified);


--
-- Name: mdl_compplan_usesta_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compplan_usesta_ix ON public.mdl_competency_plan USING btree (userid, status);


--
-- Name: mdl_comprela_com_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_comprela_com_ix ON public.mdl_competency_relatedcomp USING btree (competencyid);


--
-- Name: mdl_comprela_rel_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_comprela_rel_ix ON public.mdl_competency_relatedcomp USING btree (relatedcompetencyid);


--
-- Name: mdl_comprela_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_comprela_use_ix ON public.mdl_competency_relatedcomp USING btree (usermodified);


--
-- Name: mdl_comptemp_com_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_comptemp_com_ix ON public.mdl_competency_templatecomp USING btree (competencyid);


--
-- Name: mdl_comptemp_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_comptemp_con_ix ON public.mdl_competency_template USING btree (contextid);


--
-- Name: mdl_comptemp_tem2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_comptemp_tem2_ix ON public.mdl_competency_templatecohort USING btree (templateid);


--
-- Name: mdl_comptemp_tem_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_comptemp_tem_ix ON public.mdl_competency_templatecomp USING btree (templateid);


--
-- Name: mdl_comptemp_temcoh_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_comptemp_temcoh_uix ON public.mdl_competency_templatecohort USING btree (templateid, cohortid);


--
-- Name: mdl_comptemp_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_comptemp_use2_ix ON public.mdl_competency_templatecomp USING btree (usermodified);


--
-- Name: mdl_comptemp_use3_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_comptemp_use3_ix ON public.mdl_competency_templatecohort USING btree (usermodified);


--
-- Name: mdl_comptemp_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_comptemp_use_ix ON public.mdl_competency_template USING btree (usermodified);


--
-- Name: mdl_compuser_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compuser_use2_ix ON public.mdl_competency_usercompcourse USING btree (usermodified);


--
-- Name: mdl_compuser_use3_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compuser_use3_ix ON public.mdl_competency_usercompplan USING btree (usermodified);


--
-- Name: mdl_compuser_use4_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compuser_use4_ix ON public.mdl_competency_userevidence USING btree (userid);


--
-- Name: mdl_compuser_use5_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compuser_use5_ix ON public.mdl_competency_userevidence USING btree (usermodified);


--
-- Name: mdl_compuser_use6_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compuser_use6_ix ON public.mdl_competency_userevidencecomp USING btree (userevidenceid);


--
-- Name: mdl_compuser_use7_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compuser_use7_ix ON public.mdl_competency_userevidencecomp USING btree (usermodified);


--
-- Name: mdl_compuser_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_compuser_use_ix ON public.mdl_competency_usercomp USING btree (usermodified);


--
-- Name: mdl_compuser_usecom2_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_compuser_usecom2_uix ON public.mdl_competency_userevidencecomp USING btree (userevidenceid, competencyid);


--
-- Name: mdl_compuser_usecom_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_compuser_usecom_uix ON public.mdl_competency_usercomp USING btree (userid, competencyid);


--
-- Name: mdl_compuser_usecompla_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_compuser_usecompla_uix ON public.mdl_competency_usercompplan USING btree (userid, competencyid, planid);


--
-- Name: mdl_compuser_usecoucom_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_compuser_usecoucom_uix ON public.mdl_competency_usercompcourse USING btree (userid, courseid, competencyid);


--
-- Name: mdl_conf_nam_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_conf_nam_uix ON public.mdl_config USING btree (name);


--
-- Name: mdl_conflog_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_conflog_tim_ix ON public.mdl_config_log USING btree (timemodified);


--
-- Name: mdl_conflog_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_conflog_use_ix ON public.mdl_config_log USING btree (userid);


--
-- Name: mdl_confplug_plunam_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_confplug_plunam_uix ON public.mdl_config_plugins USING btree (plugin, name);


--
-- Name: mdl_cont_conins_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_cont_conins_uix ON public.mdl_context USING btree (contextlevel, instanceid);


--
-- Name: mdl_cont_ins_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_cont_ins_ix ON public.mdl_context USING btree (instanceid);


--
-- Name: mdl_cont_pat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_cont_pat_ix ON public.mdl_context USING btree (path);


--
-- Name: mdl_cont_pat_ix_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_cont_pat_ix_pattern ON public.mdl_context USING btree (path varchar_pattern_ops);


--
-- Name: mdl_contcont_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_contcont_con_ix ON public.mdl_contentbank_content USING btree (contextid);


--
-- Name: mdl_contcont_conconins_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_contcont_conconins_ix ON public.mdl_contentbank_content USING btree (contextid, contenttype, instanceid);


--
-- Name: mdl_contcont_nam_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_contcont_nam_ix ON public.mdl_contentbank_content USING btree (name);


--
-- Name: mdl_contcont_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_contcont_use2_ix ON public.mdl_contentbank_content USING btree (usercreated);


--
-- Name: mdl_contcont_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_contcont_use_ix ON public.mdl_contentbank_content USING btree (usermodified);


--
-- Name: mdl_cour_cat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_cour_cat_ix ON public.mdl_course USING btree (category);


--
-- Name: mdl_cour_idn_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_cour_idn_ix ON public.mdl_course USING btree (idnumber);


--
-- Name: mdl_cour_ori_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_cour_ori_ix ON public.mdl_course USING btree (originalcourseid);


--
-- Name: mdl_cour_sho_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_cour_sho_ix ON public.mdl_course USING btree (shortname);


--
-- Name: mdl_cour_sor_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_cour_sor_ix ON public.mdl_course USING btree (sortorder);


--
-- Name: mdl_courcate_par_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courcate_par_ix ON public.mdl_course_categories USING btree (parent);


--
-- Name: mdl_courcomp_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courcomp_cou_ix ON public.mdl_course_completions USING btree (course);


--
-- Name: mdl_courcomp_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courcomp_tim_ix ON public.mdl_course_completions USING btree (timecompleted);


--
-- Name: mdl_courcomp_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courcomp_use_ix ON public.mdl_course_completions USING btree (userid);


--
-- Name: mdl_courcomp_usecou_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_courcomp_usecou_uix ON public.mdl_course_completions USING btree (userid, course);


--
-- Name: mdl_courcompaggrmeth_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courcompaggrmeth_cou_ix ON public.mdl_course_completion_aggr_methd USING btree (course);


--
-- Name: mdl_courcompaggrmeth_coucr_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_courcompaggrmeth_coucr_uix ON public.mdl_course_completion_aggr_methd USING btree (course, criteriatype);


--
-- Name: mdl_courcompaggrmeth_cri_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courcompaggrmeth_cri_ix ON public.mdl_course_completion_aggr_methd USING btree (criteriatype);


--
-- Name: mdl_courcompcrit_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courcompcrit_cou_ix ON public.mdl_course_completion_criteria USING btree (course);


--
-- Name: mdl_courcompcritcomp_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courcompcritcomp_cou_ix ON public.mdl_course_completion_crit_compl USING btree (course);


--
-- Name: mdl_courcompcritcomp_cri_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courcompcritcomp_cri_ix ON public.mdl_course_completion_crit_compl USING btree (criteriaid);


--
-- Name: mdl_courcompcritcomp_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courcompcritcomp_tim_ix ON public.mdl_course_completion_crit_compl USING btree (timecompleted);


--
-- Name: mdl_courcompcritcomp_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courcompcritcomp_use_ix ON public.mdl_course_completion_crit_compl USING btree (userid);


--
-- Name: mdl_courcompcritcomp_useco_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_courcompcritcomp_useco_uix ON public.mdl_course_completion_crit_compl USING btree (userid, course, criteriaid);


--
-- Name: mdl_courcompdefa_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courcompdefa_cou_ix ON public.mdl_course_completion_defaults USING btree (course);


--
-- Name: mdl_courcompdefa_coumod_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_courcompdefa_coumod_uix ON public.mdl_course_completion_defaults USING btree (course, module);


--
-- Name: mdl_courcompdefa_mod_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courcompdefa_mod_ix ON public.mdl_course_completion_defaults USING btree (module);


--
-- Name: mdl_courformopti_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courformopti_cou_ix ON public.mdl_course_format_options USING btree (courseid);


--
-- Name: mdl_courformopti_couforsec_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_courformopti_couforsec_uix ON public.mdl_course_format_options USING btree (courseid, format, sectionid, name);


--
-- Name: mdl_courmodu_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courmodu_cou_ix ON public.mdl_course_modules USING btree (course);


--
-- Name: mdl_courmodu_gro_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courmodu_gro_ix ON public.mdl_course_modules USING btree (groupingid);


--
-- Name: mdl_courmodu_idncou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courmodu_idncou_ix ON public.mdl_course_modules USING btree (idnumber, course);


--
-- Name: mdl_courmodu_ins_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courmodu_ins_ix ON public.mdl_course_modules USING btree (instance);


--
-- Name: mdl_courmodu_mod_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courmodu_mod_ix ON public.mdl_course_modules USING btree (module);


--
-- Name: mdl_courmodu_vis_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courmodu_vis_ix ON public.mdl_course_modules USING btree (visible);


--
-- Name: mdl_courmoducomp_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courmoducomp_cou_ix ON public.mdl_course_modules_completion USING btree (coursemoduleid);


--
-- Name: mdl_courmoducomp_usecou_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_courmoducomp_usecou_uix ON public.mdl_course_modules_completion USING btree (userid, coursemoduleid);


--
-- Name: mdl_courmoduview_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courmoduview_cou_ix ON public.mdl_course_modules_viewed USING btree (coursemoduleid);


--
-- Name: mdl_courmoduview_usecou_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_courmoduview_usecou_uix ON public.mdl_course_modules_viewed USING btree (userid, coursemoduleid);


--
-- Name: mdl_courpubl_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courpubl_cou_ix ON public.mdl_course_published USING btree (courseid);


--
-- Name: mdl_courpubl_hub_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courpubl_hub_ix ON public.mdl_course_published USING btree (hubcourseid);


--
-- Name: mdl_courrequ_sho_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_courrequ_sho_ix ON public.mdl_course_request USING btree (shortname);


--
-- Name: mdl_coursect_comite_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_coursect_comite_ix ON public.mdl_course_sections USING btree (component, itemid);


--
-- Name: mdl_coursect_cousec_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_coursect_cousec_uix ON public.mdl_course_sections USING btree (course, section);


--
-- Name: mdl_custcate_comareitesor_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_custcate_comareitesor_ix ON public.mdl_customfield_category USING btree (component, area, itemid, sortorder);


--
-- Name: mdl_custcate_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_custcate_con_ix ON public.mdl_customfield_category USING btree (contextid);


--
-- Name: mdl_custdata_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_custdata_con_ix ON public.mdl_customfield_data USING btree (contextid);


--
-- Name: mdl_custdata_fie_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_custdata_fie_ix ON public.mdl_customfield_data USING btree (fieldid);


--
-- Name: mdl_custdata_fiedec_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_custdata_fiedec_ix ON public.mdl_customfield_data USING btree (fieldid, decvalue);


--
-- Name: mdl_custdata_fieint_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_custdata_fieint_ix ON public.mdl_customfield_data USING btree (fieldid, intvalue);


--
-- Name: mdl_custdata_fiesho_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_custdata_fiesho_ix ON public.mdl_customfield_data USING btree (fieldid, shortcharvalue);


--
-- Name: mdl_custdata_insfie_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_custdata_insfie_uix ON public.mdl_customfield_data USING btree (instanceid, fieldid);


--
-- Name: mdl_custfiel_cat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_custfiel_cat_ix ON public.mdl_customfield_field USING btree (categoryid);


--
-- Name: mdl_custfiel_catsor_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_custfiel_catsor_ix ON public.mdl_customfield_field USING btree (categoryid, sortorder);


--
-- Name: mdl_data_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_data_cou_ix ON public.mdl_data USING btree (course);


--
-- Name: mdl_datacont_fie_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_datacont_fie_ix ON public.mdl_data_content USING btree (fieldid);


--
-- Name: mdl_datacont_rec_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_datacont_rec_ix ON public.mdl_data_content USING btree (recordid);


--
-- Name: mdl_datafiel_dat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_datafiel_dat_ix ON public.mdl_data_fields USING btree (dataid);


--
-- Name: mdl_datafiel_typdat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_datafiel_typdat_ix ON public.mdl_data_fields USING btree (type, dataid);


--
-- Name: mdl_datareco_dat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_datareco_dat_ix ON public.mdl_data_records USING btree (dataid);


--
-- Name: mdl_datareco_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_datareco_use_ix ON public.mdl_data_records USING btree (userid);


--
-- Name: mdl_editattoauto_eleconuse_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_editattoauto_eleconuse_uix ON public.mdl_editor_atto_autosave USING btree (elementid, contextid, userid, pagehash);


--
-- Name: mdl_enro_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enro_cou_ix ON public.mdl_enrol USING btree (courseid);


--
-- Name: mdl_enro_enr_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enro_enr_ix ON public.mdl_enrol USING btree (enrol);


--
-- Name: mdl_enro_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enro_rol_ix ON public.mdl_enrol USING btree (roleid);


--
-- Name: mdl_enroflat_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroflat_cou_ix ON public.mdl_enrol_flatfile USING btree (courseid);


--
-- Name: mdl_enroflat_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroflat_rol_ix ON public.mdl_enrol_flatfile USING btree (roleid);


--
-- Name: mdl_enroflat_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroflat_use_ix ON public.mdl_enrol_flatfile USING btree (userid);


--
-- Name: mdl_enroltiappregi_pla2_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_enroltiappregi_pla2_uix ON public.mdl_enrol_lti_app_registration USING btree (platformuniqueidhash);


--
-- Name: mdl_enroltiappregi_pla_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_enroltiappregi_pla_uix ON public.mdl_enrol_lti_app_registration USING btree (platformclienthash);


--
-- Name: mdl_enroltiappregi_uni_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_enroltiappregi_uni_uix ON public.mdl_enrol_lti_app_registration USING btree (uniqueid);


--
-- Name: mdl_enrolticont_lti_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enrolticont_lti_ix ON public.mdl_enrol_lti_context USING btree (ltideploymentid);


--
-- Name: mdl_enrolticont_lticon_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_enrolticont_lticon_uix ON public.mdl_enrol_lti_context USING btree (ltideploymentid, contextid);


--
-- Name: mdl_enroltidepl_pla_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltidepl_pla_ix ON public.mdl_enrol_lti_deployment USING btree (platformid);


--
-- Name: mdl_enroltidepl_pladep_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_enroltidepl_pladep_uix ON public.mdl_enrol_lti_deployment USING btree (platformid, deploymentid);


--
-- Name: mdl_enroltilti2cons_con_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_enroltilti2cons_con_uix ON public.mdl_enrol_lti_lti2_consumer USING btree (consumerkey256);


--
-- Name: mdl_enroltilti2cont_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltilti2cont_con_ix ON public.mdl_enrol_lti_lti2_context USING btree (consumerid);


--
-- Name: mdl_enroltilti2nonc_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltilti2nonc_con_ix ON public.mdl_enrol_lti_lti2_nonce USING btree (consumerid);


--
-- Name: mdl_enroltilti2resolink_co2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltilti2resolink_co2_ix ON public.mdl_enrol_lti_lti2_resource_link USING btree (consumerid);


--
-- Name: mdl_enroltilti2resolink_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltilti2resolink_con_ix ON public.mdl_enrol_lti_lti2_resource_link USING btree (contextid);


--
-- Name: mdl_enroltilti2resolink_pri_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltilti2resolink_pri_ix ON public.mdl_enrol_lti_lti2_resource_link USING btree (primaryresourcelinkid);


--
-- Name: mdl_enroltilti2sharkey_res_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_enroltilti2sharkey_res_uix ON public.mdl_enrol_lti_lti2_share_key USING btree (resourcelinkid);


--
-- Name: mdl_enroltilti2sharkey_sha_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_enroltilti2sharkey_sha_uix ON public.mdl_enrol_lti_lti2_share_key USING btree (sharekey);


--
-- Name: mdl_enroltilti2toolprox_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltilti2toolprox_con_ix ON public.mdl_enrol_lti_lti2_tool_proxy USING btree (consumerid);


--
-- Name: mdl_enroltilti2toolprox_to_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_enroltilti2toolprox_to_uix ON public.mdl_enrol_lti_lti2_tool_proxy USING btree (toolproxykey);


--
-- Name: mdl_enroltilti2userresu_res_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltilti2userresu_res_ix ON public.mdl_enrol_lti_lti2_user_result USING btree (resourcelinkid);


--
-- Name: mdl_enroltiresolink_lti2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltiresolink_lti2_ix ON public.mdl_enrol_lti_resource_link USING btree (lticontextid);


--
-- Name: mdl_enroltiresolink_lti_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltiresolink_lti_ix ON public.mdl_enrol_lti_resource_link USING btree (ltideploymentid);


--
-- Name: mdl_enroltiresolink_reslti_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_enroltiresolink_reslti_uix ON public.mdl_enrol_lti_resource_link USING btree (resourcelinkid, ltideploymentid);


--
-- Name: mdl_enroltitool_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltitool_con_ix ON public.mdl_enrol_lti_tools USING btree (contextid);


--
-- Name: mdl_enroltitool_enr_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltitool_enr_ix ON public.mdl_enrol_lti_tools USING btree (enrolid);


--
-- Name: mdl_enroltitool_uui_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_enroltitool_uui_uix ON public.mdl_enrol_lti_tools USING btree (uuid);


--
-- Name: mdl_enroltitoolconsmap_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltitoolconsmap_con_ix ON public.mdl_enrol_lti_tool_consumer_map USING btree (consumerid);


--
-- Name: mdl_enroltitoolconsmap_too_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltitoolconsmap_too_ix ON public.mdl_enrol_lti_tool_consumer_map USING btree (toolid);


--
-- Name: mdl_enroltiuser_lti_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltiuser_lti_ix ON public.mdl_enrol_lti_users USING btree (ltideploymentid);


--
-- Name: mdl_enroltiuser_too_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltiuser_too_ix ON public.mdl_enrol_lti_users USING btree (toolid);


--
-- Name: mdl_enroltiuser_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltiuser_use_ix ON public.mdl_enrol_lti_users USING btree (userid);


--
-- Name: mdl_enroltiuserresolink_lt_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_enroltiuserresolink_lt_uix ON public.mdl_enrol_lti_user_resource_link USING btree (ltiuserid, resourcelinkid);


--
-- Name: mdl_enroltiuserresolink_lti_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltiuserresolink_lti_ix ON public.mdl_enrol_lti_user_resource_link USING btree (ltiuserid);


--
-- Name: mdl_enroltiuserresolink_res_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enroltiuserresolink_res_ix ON public.mdl_enrol_lti_user_resource_link USING btree (resourcelinkid);


--
-- Name: mdl_enropayp_bus_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enropayp_bus_ix ON public.mdl_enrol_paypal USING btree (business);


--
-- Name: mdl_enropayp_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enropayp_cou_ix ON public.mdl_enrol_paypal USING btree (courseid);


--
-- Name: mdl_enropayp_ins_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enropayp_ins_ix ON public.mdl_enrol_paypal USING btree (instanceid);


--
-- Name: mdl_enropayp_rec_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enropayp_rec_ix ON public.mdl_enrol_paypal USING btree (receiver_email);


--
-- Name: mdl_enropayp_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_enropayp_use_ix ON public.mdl_enrol_paypal USING btree (userid);


--
-- Name: mdl_even_cat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_even_cat_ix ON public.mdl_event USING btree (categoryid);


--
-- Name: mdl_even_comeveins_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_even_comeveins_ix ON public.mdl_event USING btree (component, eventtype, instance);


--
-- Name: mdl_even_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_even_cou_ix ON public.mdl_event USING btree (courseid);


--
-- Name: mdl_even_eve_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_even_eve_ix ON public.mdl_event USING btree (eventtype);


--
-- Name: mdl_even_grocoucatvisuse_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_even_grocoucatvisuse_ix ON public.mdl_event USING btree (groupid, courseid, categoryid, visible, userid);


--
-- Name: mdl_even_modinseve_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_even_modinseve_ix ON public.mdl_event USING btree (modulename, instance, eventtype);


--
-- Name: mdl_even_sub_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_even_sub_ix ON public.mdl_event USING btree (subscriptionid);


--
-- Name: mdl_even_tim2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_even_tim2_ix ON public.mdl_event USING btree (timeduration);


--
-- Name: mdl_even_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_even_tim_ix ON public.mdl_event USING btree (timestart);


--
-- Name: mdl_even_typtim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_even_typtim_ix ON public.mdl_event USING btree (type, timesort);


--
-- Name: mdl_even_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_even_use_ix ON public.mdl_event USING btree (userid);


--
-- Name: mdl_even_uui_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_even_uui_ix ON public.mdl_event USING btree (uuid);


--
-- Name: mdl_evenhand_evecom_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_evenhand_evecom_uix ON public.mdl_events_handlers USING btree (eventname, component);


--
-- Name: mdl_evenqueu_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_evenqueu_use_ix ON public.mdl_events_queue USING btree (userid);


--
-- Name: mdl_evenqueuhand_han_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_evenqueuhand_han_ix ON public.mdl_events_queue_handlers USING btree (handlerid);


--
-- Name: mdl_evenqueuhand_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_evenqueuhand_que_ix ON public.mdl_events_queue_handlers USING btree (queuedeventid);


--
-- Name: mdl_evensubs_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_evensubs_cou_ix ON public.mdl_event_subscriptions USING btree (courseid);


--
-- Name: mdl_evensubs_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_evensubs_use_ix ON public.mdl_event_subscriptions USING btree (userid);


--
-- Name: mdl_extefunc_nam_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_extefunc_nam_uix ON public.mdl_external_functions USING btree (name);


--
-- Name: mdl_exteserv_nam_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_exteserv_nam_uix ON public.mdl_external_services USING btree (name);


--
-- Name: mdl_exteservfunc_ext_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_exteservfunc_ext_ix ON public.mdl_external_services_functions USING btree (externalserviceid);


--
-- Name: mdl_exteservuser_ext_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_exteservuser_ext_ix ON public.mdl_external_services_users USING btree (externalserviceid);


--
-- Name: mdl_exteservuser_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_exteservuser_use_ix ON public.mdl_external_services_users USING btree (userid);


--
-- Name: mdl_extetoke_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_extetoke_con_ix ON public.mdl_external_tokens USING btree (contextid);


--
-- Name: mdl_extetoke_cre_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_extetoke_cre_ix ON public.mdl_external_tokens USING btree (creatorid);


--
-- Name: mdl_extetoke_ext_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_extetoke_ext_ix ON public.mdl_external_tokens USING btree (externalserviceid);


--
-- Name: mdl_extetoke_sid_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_extetoke_sid_ix ON public.mdl_external_tokens USING btree (sid);


--
-- Name: mdl_extetoke_tok_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_extetoke_tok_ix ON public.mdl_external_tokens USING btree (token);


--
-- Name: mdl_extetoke_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_extetoke_use_ix ON public.mdl_external_tokens USING btree (userid);


--
-- Name: mdl_favo_comiteiteconuse_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_favo_comiteiteconuse_uix ON public.mdl_favourite USING btree (component, itemtype, itemid, contextid, userid);


--
-- Name: mdl_favo_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_favo_con_ix ON public.mdl_favourite USING btree (contextid);


--
-- Name: mdl_favo_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_favo_use_ix ON public.mdl_favourite USING btree (userid);


--
-- Name: mdl_feed_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_feed_cou_ix ON public.mdl_feedback USING btree (course);


--
-- Name: mdl_feedcomp_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_feedcomp_cou_ix ON public.mdl_feedback_completed USING btree (courseid);


--
-- Name: mdl_feedcomp_fee2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_feedcomp_fee2_ix ON public.mdl_feedback_completedtmp USING btree (feedback);


--
-- Name: mdl_feedcomp_fee_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_feedcomp_fee_ix ON public.mdl_feedback_completed USING btree (feedback);


--
-- Name: mdl_feedcomp_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_feedcomp_use2_ix ON public.mdl_feedback_completedtmp USING btree (userid);


--
-- Name: mdl_feedcomp_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_feedcomp_use_ix ON public.mdl_feedback_completed USING btree (userid);


--
-- Name: mdl_feeditem_fee_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_feeditem_fee_ix ON public.mdl_feedback_item USING btree (feedback);


--
-- Name: mdl_feeditem_tem_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_feeditem_tem_ix ON public.mdl_feedback_item USING btree (template);


--
-- Name: mdl_feedsitemap_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_feedsitemap_cou_ix ON public.mdl_feedback_sitecourse_map USING btree (courseid);


--
-- Name: mdl_feedsitemap_fee_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_feedsitemap_fee_ix ON public.mdl_feedback_sitecourse_map USING btree (feedbackid);


--
-- Name: mdl_feedtemp_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_feedtemp_cou_ix ON public.mdl_feedback_template USING btree (course);


--
-- Name: mdl_feedvalu_comitecou2_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_feedvalu_comitecou2_uix ON public.mdl_feedback_valuetmp USING btree (completed, item, course_id);


--
-- Name: mdl_feedvalu_comitecou_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_feedvalu_comitecou_uix ON public.mdl_feedback_value USING btree (completed, item, course_id);


--
-- Name: mdl_feedvalu_cou2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_feedvalu_cou2_ix ON public.mdl_feedback_valuetmp USING btree (course_id);


--
-- Name: mdl_feedvalu_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_feedvalu_cou_ix ON public.mdl_feedback_value USING btree (course_id);


--
-- Name: mdl_feedvalu_ite2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_feedvalu_ite2_ix ON public.mdl_feedback_valuetmp USING btree (item);


--
-- Name: mdl_feedvalu_ite_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_feedvalu_ite_ix ON public.mdl_feedback_value USING btree (item);


--
-- Name: mdl_file_comfilconite_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_file_comfilconite_ix ON public.mdl_files USING btree (component, filearea, contextid, itemid);


--
-- Name: mdl_file_con2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_file_con2_ix ON public.mdl_files USING btree (contextid);


--
-- Name: mdl_file_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_file_con_ix ON public.mdl_files USING btree (contenthash);


--
-- Name: mdl_file_fil_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_file_fil_ix ON public.mdl_files USING btree (filename);


--
-- Name: mdl_file_lic_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_file_lic_ix ON public.mdl_files USING btree (license);


--
-- Name: mdl_file_pat_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_file_pat_uix ON public.mdl_files USING btree (pathnamehash);


--
-- Name: mdl_file_ref_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_file_ref_ix ON public.mdl_files USING btree (referencefileid);


--
-- Name: mdl_file_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_file_use_ix ON public.mdl_files USING btree (userid);


--
-- Name: mdl_fileconv_des_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_fileconv_des_ix ON public.mdl_file_conversion USING btree (destfileid);


--
-- Name: mdl_fileconv_sou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_fileconv_sou_ix ON public.mdl_file_conversion USING btree (sourcefileid);


--
-- Name: mdl_fileconv_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_fileconv_use_ix ON public.mdl_file_conversion USING btree (usermodified);


--
-- Name: mdl_filerefe_refrep_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_filerefe_refrep_uix ON public.mdl_files_reference USING btree (referencehash, repositoryid);


--
-- Name: mdl_filerefe_rep_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_filerefe_rep_ix ON public.mdl_files_reference USING btree (repositoryid);


--
-- Name: mdl_filtacti_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_filtacti_con_ix ON public.mdl_filter_active USING btree (contextid);


--
-- Name: mdl_filtacti_confil_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_filtacti_confil_uix ON public.mdl_filter_active USING btree (contextid, filter);


--
-- Name: mdl_filtconf_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_filtconf_con_ix ON public.mdl_filter_config USING btree (contextid);


--
-- Name: mdl_filtconf_confilnam_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_filtconf_confilnam_uix ON public.mdl_filter_config USING btree (contextid, filter, name);


--
-- Name: mdl_fold_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_fold_cou_ix ON public.mdl_folder USING btree (course);


--
-- Name: mdl_foru_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_foru_cou_ix ON public.mdl_forum USING btree (course);


--
-- Name: mdl_forudige_for_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forudige_for_ix ON public.mdl_forum_digests USING btree (forum);


--
-- Name: mdl_forudige_forusemai_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_forudige_forusemai_uix ON public.mdl_forum_digests USING btree (forum, userid, maildigest);


--
-- Name: mdl_forudige_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forudige_use_ix ON public.mdl_forum_digests USING btree (userid);


--
-- Name: mdl_forudisc_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forudisc_cou_ix ON public.mdl_forum_discussions USING btree (course);


--
-- Name: mdl_forudisc_for_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forudisc_for_ix ON public.mdl_forum_discussions USING btree (forum);


--
-- Name: mdl_forudisc_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forudisc_use2_ix ON public.mdl_forum_discussions USING btree (usermodified);


--
-- Name: mdl_forudisc_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forudisc_use_ix ON public.mdl_forum_discussions USING btree (userid);


--
-- Name: mdl_forudiscsubs_dis_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forudiscsubs_dis_ix ON public.mdl_forum_discussion_subs USING btree (discussion);


--
-- Name: mdl_forudiscsubs_for_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forudiscsubs_for_ix ON public.mdl_forum_discussion_subs USING btree (forum);


--
-- Name: mdl_forudiscsubs_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forudiscsubs_use_ix ON public.mdl_forum_discussion_subs USING btree (userid);


--
-- Name: mdl_forudiscsubs_usedis_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_forudiscsubs_usedis_uix ON public.mdl_forum_discussion_subs USING btree (userid, discussion);


--
-- Name: mdl_forugrad_for_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forugrad_for_ix ON public.mdl_forum_grades USING btree (forum);


--
-- Name: mdl_forugrad_foriteuse_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_forugrad_foriteuse_uix ON public.mdl_forum_grades USING btree (forum, itemnumber, userid);


--
-- Name: mdl_forugrad_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forugrad_use_ix ON public.mdl_forum_grades USING btree (userid);


--
-- Name: mdl_forupost_cre_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forupost_cre_ix ON public.mdl_forum_posts USING btree (created);


--
-- Name: mdl_forupost_dis_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forupost_dis_ix ON public.mdl_forum_posts USING btree (discussion);


--
-- Name: mdl_forupost_mai_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forupost_mai_ix ON public.mdl_forum_posts USING btree (mailed);


--
-- Name: mdl_forupost_par_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forupost_par_ix ON public.mdl_forum_posts USING btree (parent);


--
-- Name: mdl_forupost_pri_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forupost_pri_ix ON public.mdl_forum_posts USING btree (privatereplyto);


--
-- Name: mdl_forupost_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forupost_use_ix ON public.mdl_forum_posts USING btree (userid);


--
-- Name: mdl_foruqueu_dis_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_foruqueu_dis_ix ON public.mdl_forum_queue USING btree (discussionid);


--
-- Name: mdl_foruqueu_pos_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_foruqueu_pos_ix ON public.mdl_forum_queue USING btree (postid);


--
-- Name: mdl_foruqueu_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_foruqueu_use_ix ON public.mdl_forum_queue USING btree (userid);


--
-- Name: mdl_foruread_disuse_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_foruread_disuse_ix ON public.mdl_forum_read USING btree (discussionid, userid);


--
-- Name: mdl_foruread_foruse_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_foruread_foruse_ix ON public.mdl_forum_read USING btree (forumid, userid);


--
-- Name: mdl_foruread_posuse_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_foruread_posuse_ix ON public.mdl_forum_read USING btree (postid, userid);


--
-- Name: mdl_foruread_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_foruread_use_ix ON public.mdl_forum_read USING btree (userid);


--
-- Name: mdl_forusubs_for_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forusubs_for_ix ON public.mdl_forum_subscriptions USING btree (forum);


--
-- Name: mdl_forusubs_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forusubs_use_ix ON public.mdl_forum_subscriptions USING btree (userid);


--
-- Name: mdl_forusubs_usefor_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_forusubs_usefor_uix ON public.mdl_forum_subscriptions USING btree (userid, forum);


--
-- Name: mdl_forutracpref_usefor_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_forutracpref_usefor_ix ON public.mdl_forum_track_prefs USING btree (userid, forumid);


--
-- Name: mdl_glos_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_glos_cou_ix ON public.mdl_glossary USING btree (course);


--
-- Name: mdl_glosalia_ent_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_glosalia_ent_ix ON public.mdl_glossary_alias USING btree (entryid);


--
-- Name: mdl_gloscate_glo_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gloscate_glo_ix ON public.mdl_glossary_categories USING btree (glossaryid);


--
-- Name: mdl_glosentr_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_glosentr_con_ix ON public.mdl_glossary_entries USING btree (concept);


--
-- Name: mdl_glosentr_glo_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_glosentr_glo_ix ON public.mdl_glossary_entries USING btree (glossaryid);


--
-- Name: mdl_glosentr_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_glosentr_use_ix ON public.mdl_glossary_entries USING btree (userid);


--
-- Name: mdl_glosentrcate_cat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_glosentrcate_cat_ix ON public.mdl_glossary_entries_categories USING btree (categoryid);


--
-- Name: mdl_glosentrcate_ent_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_glosentrcate_ent_ix ON public.mdl_glossary_entries_categories USING btree (entryid);


--
-- Name: mdl_gradarea_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradarea_con_ix ON public.mdl_grading_areas USING btree (contextid);


--
-- Name: mdl_gradarea_concomare_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_gradarea_concomare_uix ON public.mdl_grading_areas USING btree (contextid, component, areaname);


--
-- Name: mdl_gradcate_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradcate_cou_ix ON public.mdl_grade_categories USING btree (courseid);


--
-- Name: mdl_gradcate_par_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradcate_par_ix ON public.mdl_grade_categories USING btree (parent);


--
-- Name: mdl_gradcatehist_act_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradcatehist_act_ix ON public.mdl_grade_categories_history USING btree (action);


--
-- Name: mdl_gradcatehist_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradcatehist_cou_ix ON public.mdl_grade_categories_history USING btree (courseid);


--
-- Name: mdl_gradcatehist_log_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradcatehist_log_ix ON public.mdl_grade_categories_history USING btree (loggeduser);


--
-- Name: mdl_gradcatehist_old_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradcatehist_old_ix ON public.mdl_grade_categories_history USING btree (oldid);


--
-- Name: mdl_gradcatehist_par_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradcatehist_par_ix ON public.mdl_grade_categories_history USING btree (parent);


--
-- Name: mdl_gradcatehist_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradcatehist_tim_ix ON public.mdl_grade_categories_history USING btree (timemodified);


--
-- Name: mdl_graddefi_are_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graddefi_are_ix ON public.mdl_grading_definitions USING btree (areaid);


--
-- Name: mdl_graddefi_aremet_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_graddefi_aremet_uix ON public.mdl_grading_definitions USING btree (areaid, method);


--
-- Name: mdl_graddefi_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graddefi_use2_ix ON public.mdl_grading_definitions USING btree (usercreated);


--
-- Name: mdl_graddefi_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graddefi_use_ix ON public.mdl_grading_definitions USING btree (usermodified);


--
-- Name: mdl_gradgrad_ite_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradgrad_ite_ix ON public.mdl_grade_grades USING btree (itemid);


--
-- Name: mdl_gradgrad_locloc_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradgrad_locloc_ix ON public.mdl_grade_grades USING btree (locked, locktime);


--
-- Name: mdl_gradgrad_raw_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradgrad_raw_ix ON public.mdl_grade_grades USING btree (rawscaleid);


--
-- Name: mdl_gradgrad_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradgrad_use2_ix ON public.mdl_grade_grades USING btree (usermodified);


--
-- Name: mdl_gradgrad_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradgrad_use_ix ON public.mdl_grade_grades USING btree (userid);


--
-- Name: mdl_gradgrad_useite_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_gradgrad_useite_uix ON public.mdl_grade_grades USING btree (userid, itemid);


--
-- Name: mdl_gradgradhist_act_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradgradhist_act_ix ON public.mdl_grade_grades_history USING btree (action);


--
-- Name: mdl_gradgradhist_ite_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradgradhist_ite_ix ON public.mdl_grade_grades_history USING btree (itemid);


--
-- Name: mdl_gradgradhist_log_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradgradhist_log_ix ON public.mdl_grade_grades_history USING btree (loggeduser);


--
-- Name: mdl_gradgradhist_old_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradgradhist_old_ix ON public.mdl_grade_grades_history USING btree (oldid);


--
-- Name: mdl_gradgradhist_raw_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradgradhist_raw_ix ON public.mdl_grade_grades_history USING btree (rawscaleid);


--
-- Name: mdl_gradgradhist_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradgradhist_tim_ix ON public.mdl_grade_grades_history USING btree (timemodified);


--
-- Name: mdl_gradgradhist_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradgradhist_use2_ix ON public.mdl_grade_grades_history USING btree (usermodified);


--
-- Name: mdl_gradgradhist_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradgradhist_use_ix ON public.mdl_grade_grades_history USING btree (userid);


--
-- Name: mdl_gradgradhist_useitetim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradgradhist_useitetim_ix ON public.mdl_grade_grades_history USING btree (userid, itemid, timemodified);


--
-- Name: mdl_gradguidcomm_def_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradguidcomm_def_ix ON public.mdl_gradingform_guide_comments USING btree (definitionid);


--
-- Name: mdl_gradguidcrit_def_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradguidcrit_def_ix ON public.mdl_gradingform_guide_criteria USING btree (definitionid);


--
-- Name: mdl_gradguidfill_cri_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradguidfill_cri_ix ON public.mdl_gradingform_guide_fillings USING btree (criterionid);


--
-- Name: mdl_gradguidfill_ins_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradguidfill_ins_ix ON public.mdl_gradingform_guide_fillings USING btree (instanceid);


--
-- Name: mdl_gradguidfill_inscri_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_gradguidfill_inscri_uix ON public.mdl_gradingform_guide_fillings USING btree (instanceid, criterionid);


--
-- Name: mdl_gradimponewi_imp_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradimponewi_imp_ix ON public.mdl_grade_import_newitem USING btree (importer);


--
-- Name: mdl_gradimpovalu_imp_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradimpovalu_imp_ix ON public.mdl_grade_import_values USING btree (importer);


--
-- Name: mdl_gradimpovalu_ite_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradimpovalu_ite_ix ON public.mdl_grade_import_values USING btree (itemid);


--
-- Name: mdl_gradimpovalu_new_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradimpovalu_new_ix ON public.mdl_grade_import_values USING btree (newgradeitem);


--
-- Name: mdl_gradimpovalu_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradimpovalu_use_ix ON public.mdl_grade_import_values USING btree (userid);


--
-- Name: mdl_gradinst_def_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradinst_def_ix ON public.mdl_grading_instances USING btree (definitionid);


--
-- Name: mdl_gradinst_rat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradinst_rat_ix ON public.mdl_grading_instances USING btree (raterid);


--
-- Name: mdl_graditem_cat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditem_cat_ix ON public.mdl_grade_items USING btree (categoryid);


--
-- Name: mdl_graditem_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditem_cou_ix ON public.mdl_grade_items USING btree (courseid);


--
-- Name: mdl_graditem_gra_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditem_gra_ix ON public.mdl_grade_items USING btree (gradetype);


--
-- Name: mdl_graditem_idncou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditem_idncou_ix ON public.mdl_grade_items USING btree (idnumber, courseid);


--
-- Name: mdl_graditem_iteiteitecou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditem_iteiteitecou_ix ON public.mdl_grade_items USING btree (itemtype, itemmodule, iteminstance, courseid);


--
-- Name: mdl_graditem_itenee_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditem_itenee_ix ON public.mdl_grade_items USING btree (itemtype, needsupdate);


--
-- Name: mdl_graditem_locloc_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditem_locloc_ix ON public.mdl_grade_items USING btree (locked, locktime);


--
-- Name: mdl_graditem_out_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditem_out_ix ON public.mdl_grade_items USING btree (outcomeid);


--
-- Name: mdl_graditem_sca_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditem_sca_ix ON public.mdl_grade_items USING btree (scaleid);


--
-- Name: mdl_graditemhist_act_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditemhist_act_ix ON public.mdl_grade_items_history USING btree (action);


--
-- Name: mdl_graditemhist_cat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditemhist_cat_ix ON public.mdl_grade_items_history USING btree (categoryid);


--
-- Name: mdl_graditemhist_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditemhist_cou_ix ON public.mdl_grade_items_history USING btree (courseid);


--
-- Name: mdl_graditemhist_log_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditemhist_log_ix ON public.mdl_grade_items_history USING btree (loggeduser);


--
-- Name: mdl_graditemhist_old_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditemhist_old_ix ON public.mdl_grade_items_history USING btree (oldid);


--
-- Name: mdl_graditemhist_out_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditemhist_out_ix ON public.mdl_grade_items_history USING btree (outcomeid);


--
-- Name: mdl_graditemhist_sca_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditemhist_sca_ix ON public.mdl_grade_items_history USING btree (scaleid);


--
-- Name: mdl_graditemhist_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_graditemhist_tim_ix ON public.mdl_grade_items_history USING btree (timemodified);


--
-- Name: mdl_gradlett_conlowlet_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_gradlett_conlowlet_uix ON public.mdl_grade_letters USING btree (contextid, lowerboundary, letter);


--
-- Name: mdl_gradoutc_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradoutc_cou_ix ON public.mdl_grade_outcomes USING btree (courseid);


--
-- Name: mdl_gradoutc_cousho_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_gradoutc_cousho_uix ON public.mdl_grade_outcomes USING btree (courseid, shortname);


--
-- Name: mdl_gradoutc_sca_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradoutc_sca_ix ON public.mdl_grade_outcomes USING btree (scaleid);


--
-- Name: mdl_gradoutc_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradoutc_use_ix ON public.mdl_grade_outcomes USING btree (usermodified);


--
-- Name: mdl_gradoutccour_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradoutccour_cou_ix ON public.mdl_grade_outcomes_courses USING btree (courseid);


--
-- Name: mdl_gradoutccour_couout_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_gradoutccour_couout_uix ON public.mdl_grade_outcomes_courses USING btree (courseid, outcomeid);


--
-- Name: mdl_gradoutccour_out_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradoutccour_out_ix ON public.mdl_grade_outcomes_courses USING btree (outcomeid);


--
-- Name: mdl_gradoutchist_act_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradoutchist_act_ix ON public.mdl_grade_outcomes_history USING btree (action);


--
-- Name: mdl_gradoutchist_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradoutchist_cou_ix ON public.mdl_grade_outcomes_history USING btree (courseid);


--
-- Name: mdl_gradoutchist_log_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradoutchist_log_ix ON public.mdl_grade_outcomes_history USING btree (loggeduser);


--
-- Name: mdl_gradoutchist_old_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradoutchist_old_ix ON public.mdl_grade_outcomes_history USING btree (oldid);


--
-- Name: mdl_gradoutchist_sca_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradoutchist_sca_ix ON public.mdl_grade_outcomes_history USING btree (scaleid);


--
-- Name: mdl_gradoutchist_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradoutchist_tim_ix ON public.mdl_grade_outcomes_history USING btree (timemodified);


--
-- Name: mdl_gradrubrcrit_def_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradrubrcrit_def_ix ON public.mdl_gradingform_rubric_criteria USING btree (definitionid);


--
-- Name: mdl_gradrubrfill_cri_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradrubrfill_cri_ix ON public.mdl_gradingform_rubric_fillings USING btree (criterionid);


--
-- Name: mdl_gradrubrfill_ins_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradrubrfill_ins_ix ON public.mdl_gradingform_rubric_fillings USING btree (instanceid);


--
-- Name: mdl_gradrubrfill_inscri_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_gradrubrfill_inscri_uix ON public.mdl_gradingform_rubric_fillings USING btree (instanceid, criterionid);


--
-- Name: mdl_gradrubrfill_lev_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradrubrfill_lev_ix ON public.mdl_gradingform_rubric_fillings USING btree (levelid);


--
-- Name: mdl_gradrubrleve_cri_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradrubrleve_cri_ix ON public.mdl_gradingform_rubric_levels USING btree (criterionid);


--
-- Name: mdl_gradsett_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_gradsett_cou_ix ON public.mdl_grade_settings USING btree (courseid);


--
-- Name: mdl_gradsett_counam_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_gradsett_counam_uix ON public.mdl_grade_settings USING btree (courseid, name);


--
-- Name: mdl_grou_cou2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_grou_cou2_ix ON public.mdl_groupings USING btree (courseid);


--
-- Name: mdl_grou_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_grou_cou_ix ON public.mdl_groups USING btree (courseid);


--
-- Name: mdl_grou_idn2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_grou_idn2_ix ON public.mdl_groupings USING btree (idnumber);


--
-- Name: mdl_grou_idn_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_grou_idn_ix ON public.mdl_groups USING btree (idnumber);


--
-- Name: mdl_grougrou_gro2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_grougrou_gro2_ix ON public.mdl_groupings_groups USING btree (groupid);


--
-- Name: mdl_grougrou_gro_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_grougrou_gro_ix ON public.mdl_groupings_groups USING btree (groupingid);


--
-- Name: mdl_groumemb_gro_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_groumemb_gro_ix ON public.mdl_groups_members USING btree (groupid);


--
-- Name: mdl_groumemb_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_groumemb_use_ix ON public.mdl_groups_members USING btree (userid);


--
-- Name: mdl_groumemb_usegro_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_groumemb_usegro_uix ON public.mdl_groups_members USING btree (userid, groupid);


--
-- Name: mdl_h5p_mai_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_h5p_mai_ix ON public.mdl_h5p USING btree (mainlibraryid);


--
-- Name: mdl_h5p_pat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_h5p_pat_ix ON public.mdl_h5p USING btree (pathnamehash);


--
-- Name: mdl_h5pa_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_h5pa_cou_ix ON public.mdl_h5pactivity USING btree (course);


--
-- Name: mdl_h5paatte_h5p_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_h5paatte_h5p_ix ON public.mdl_h5pactivity_attempts USING btree (h5pactivityid);


--
-- Name: mdl_h5paatte_h5ptim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_h5paatte_h5ptim_ix ON public.mdl_h5pactivity_attempts USING btree (h5pactivityid, timecreated);


--
-- Name: mdl_h5paatte_h5puse_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_h5paatte_h5puse_ix ON public.mdl_h5pactivity_attempts USING btree (h5pactivityid, userid);


--
-- Name: mdl_h5paatte_h5puseatt_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_h5paatte_h5puseatt_uix ON public.mdl_h5pactivity_attempts USING btree (h5pactivityid, userid, attempt);


--
-- Name: mdl_h5paatte_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_h5paatte_tim_ix ON public.mdl_h5pactivity_attempts USING btree (timecreated);


--
-- Name: mdl_h5paatteresu_att_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_h5paatteresu_att_ix ON public.mdl_h5pactivity_attempts_results USING btree (attemptid);


--
-- Name: mdl_h5paatteresu_atttim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_h5paatteresu_atttim_ix ON public.mdl_h5pactivity_attempts_results USING btree (attemptid, timecreated);


--
-- Name: mdl_h5pcontlibr_h5p_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_h5pcontlibr_h5p_ix ON public.mdl_h5p_contents_libraries USING btree (h5pid);


--
-- Name: mdl_h5pcontlibr_lib_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_h5pcontlibr_lib_ix ON public.mdl_h5p_contents_libraries USING btree (libraryid);


--
-- Name: mdl_h5plibr_macmajminpatrun_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_h5plibr_macmajminpatrun_ix ON public.mdl_h5p_libraries USING btree (machinename, majorversion, minorversion, patchversion, runnable);


--
-- Name: mdl_h5plibrcach_lib_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_h5plibrcach_lib_ix ON public.mdl_h5p_libraries_cachedassets USING btree (libraryid);


--
-- Name: mdl_h5plibrdepe_lib_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_h5plibrdepe_lib_ix ON public.mdl_h5p_library_dependencies USING btree (libraryid);


--
-- Name: mdl_h5plibrdepe_req_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_h5plibrdepe_req_ix ON public.mdl_h5p_library_dependencies USING btree (requiredlibraryid);


--
-- Name: mdl_imsc_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_imsc_cou_ix ON public.mdl_imscp USING btree (course);


--
-- Name: mdl_infefile_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_infefile_use_ix ON public.mdl_infected_files USING btree (userid);


--
-- Name: mdl_labe_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_labe_cou_ix ON public.mdl_label USING btree (course);


--
-- Name: mdl_less_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_less_cou_ix ON public.mdl_lesson USING btree (course);


--
-- Name: mdl_lessansw_les_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lessansw_les_ix ON public.mdl_lesson_answers USING btree (lessonid);


--
-- Name: mdl_lessansw_pag_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lessansw_pag_ix ON public.mdl_lesson_answers USING btree (pageid);


--
-- Name: mdl_lessatte_ans_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lessatte_ans_ix ON public.mdl_lesson_attempts USING btree (answerid);


--
-- Name: mdl_lessatte_les_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lessatte_les_ix ON public.mdl_lesson_attempts USING btree (lessonid);


--
-- Name: mdl_lessatte_pag_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lessatte_pag_ix ON public.mdl_lesson_attempts USING btree (pageid);


--
-- Name: mdl_lessatte_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lessatte_use_ix ON public.mdl_lesson_attempts USING btree (userid);


--
-- Name: mdl_lessbran_les_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lessbran_les_ix ON public.mdl_lesson_branch USING btree (lessonid);


--
-- Name: mdl_lessbran_pag_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lessbran_pag_ix ON public.mdl_lesson_branch USING btree (pageid);


--
-- Name: mdl_lessbran_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lessbran_use_ix ON public.mdl_lesson_branch USING btree (userid);


--
-- Name: mdl_lessgrad_les_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lessgrad_les_ix ON public.mdl_lesson_grades USING btree (lessonid);


--
-- Name: mdl_lessgrad_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lessgrad_use_ix ON public.mdl_lesson_grades USING btree (userid);


--
-- Name: mdl_lessover_gro_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lessover_gro_ix ON public.mdl_lesson_overrides USING btree (groupid);


--
-- Name: mdl_lessover_les_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lessover_les_ix ON public.mdl_lesson_overrides USING btree (lessonid);


--
-- Name: mdl_lessover_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lessover_use_ix ON public.mdl_lesson_overrides USING btree (userid);


--
-- Name: mdl_lesspage_les_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lesspage_les_ix ON public.mdl_lesson_pages USING btree (lessonid);


--
-- Name: mdl_lesstime_les_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lesstime_les_ix ON public.mdl_lesson_timer USING btree (lessonid);


--
-- Name: mdl_lesstime_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lesstime_use_ix ON public.mdl_lesson_timer USING btree (userid);


--
-- Name: mdl_lockdb_exp_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lockdb_exp_ix ON public.mdl_lock_db USING btree (expires);


--
-- Name: mdl_lockdb_own_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lockdb_own_ix ON public.mdl_lock_db USING btree (owner);


--
-- Name: mdl_lockdb_res_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_lockdb_res_uix ON public.mdl_lock_db USING btree (resourcekey);


--
-- Name: mdl_log_act_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_log_act_ix ON public.mdl_log USING btree (action);


--
-- Name: mdl_log_cmi_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_log_cmi_ix ON public.mdl_log USING btree (cmid);


--
-- Name: mdl_log_coumodact_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_log_coumodact_ix ON public.mdl_log USING btree (course, module, action);


--
-- Name: mdl_log_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_log_tim_ix ON public.mdl_log USING btree ("time");


--
-- Name: mdl_log_usecou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_log_usecou_ix ON public.mdl_log USING btree (userid, course);


--
-- Name: mdl_logdisp_modact_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_logdisp_modact_uix ON public.mdl_log_display USING btree (module, action);


--
-- Name: mdl_logsstanlog_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_logsstanlog_con_ix ON public.mdl_logstore_standard_log USING btree (contextid);


--
-- Name: mdl_logsstanlog_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_logsstanlog_cou_ix ON public.mdl_logstore_standard_log USING btree (courseid);


--
-- Name: mdl_logsstanlog_couanotim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_logsstanlog_couanotim_ix ON public.mdl_logstore_standard_log USING btree (courseid, anonymous, timecreated);


--
-- Name: mdl_logsstanlog_rea_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_logsstanlog_rea_ix ON public.mdl_logstore_standard_log USING btree (realuserid);


--
-- Name: mdl_logsstanlog_rel_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_logsstanlog_rel_ix ON public.mdl_logstore_standard_log USING btree (relateduserid);


--
-- Name: mdl_logsstanlog_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_logsstanlog_tim_ix ON public.mdl_logstore_standard_log USING btree (timecreated);


--
-- Name: mdl_logsstanlog_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_logsstanlog_use_ix ON public.mdl_logstore_standard_log USING btree (userid);


--
-- Name: mdl_logsstanlog_useconconcr_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_logsstanlog_useconconcr_ix ON public.mdl_logstore_standard_log USING btree (userid, contextlevel, contextinstanceid, crud, edulevel, timecreated);


--
-- Name: mdl_lti_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lti_cou_ix ON public.mdl_lti USING btree (course);


--
-- Name: mdl_ltiaccetoke_tok_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_ltiaccetoke_tok_uix ON public.mdl_lti_access_tokens USING btree (token);


--
-- Name: mdl_ltiaccetoke_typ_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ltiaccetoke_typ_ix ON public.mdl_lti_access_tokens USING btree (typeid);


--
-- Name: mdl_lticour_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lticour_cou_ix ON public.mdl_lti_coursevisible USING btree (courseid);


--
-- Name: mdl_lticour_typ_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_lticour_typ_ix ON public.mdl_lti_coursevisible USING btree (typeid);


--
-- Name: mdl_ltisgrad_gracou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ltisgrad_gracou_ix ON public.mdl_ltiservice_gradebookservices USING btree (gradeitemid, courseid);


--
-- Name: mdl_ltisgrad_lti_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ltisgrad_lti_ix ON public.mdl_ltiservice_gradebookservices USING btree (ltilinkid);


--
-- Name: mdl_ltisubm_lti_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ltisubm_lti_ix ON public.mdl_lti_submission USING btree (ltiid);


--
-- Name: mdl_ltitoolprox_gui_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_ltitoolprox_gui_uix ON public.mdl_lti_tool_proxies USING btree (guid);


--
-- Name: mdl_ltitoolsett_cou2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ltitoolsett_cou2_ix ON public.mdl_lti_tool_settings USING btree (coursemoduleid);


--
-- Name: mdl_ltitoolsett_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ltitoolsett_cou_ix ON public.mdl_lti_tool_settings USING btree (course);


--
-- Name: mdl_ltitoolsett_too_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ltitoolsett_too_ix ON public.mdl_lti_tool_settings USING btree (toolproxyid);


--
-- Name: mdl_ltitoolsett_typ_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ltitoolsett_typ_ix ON public.mdl_lti_tool_settings USING btree (typeid);


--
-- Name: mdl_ltitype_cli_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_ltitype_cli_uix ON public.mdl_lti_types USING btree (clientid);


--
-- Name: mdl_ltitype_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ltitype_cou_ix ON public.mdl_lti_types USING btree (course);


--
-- Name: mdl_ltitype_too_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ltitype_too_ix ON public.mdl_lti_types USING btree (tooldomain);


--
-- Name: mdl_ltitypecate_cat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ltitypecate_cat_ix ON public.mdl_lti_types_categories USING btree (categoryid);


--
-- Name: mdl_ltitypecate_typ_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ltitypecate_typ_ix ON public.mdl_lti_types_categories USING btree (typeid);


--
-- Name: mdl_ltitypeconf_typ_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ltitypeconf_typ_ix ON public.mdl_lti_types_config USING btree (typeid);


--
-- Name: mdl_matrroom_com_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_matrroom_com_ix ON public.mdl_matrix_room USING btree (commid);


--
-- Name: mdl_mess_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_mess_con_ix ON public.mdl_messages USING btree (conversationid);


--
-- Name: mdl_mess_contim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_mess_contim_ix ON public.mdl_messages USING btree (conversationid, timecreated);


--
-- Name: mdl_mess_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_mess_use_ix ON public.mdl_messages USING btree (useridfrom);


--
-- Name: mdl_mess_usetimnot2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_mess_usetimnot2_ix ON public.mdl_message USING btree (useridto, timeusertodeleted, notification);


--
-- Name: mdl_mess_usetimnot_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_mess_usetimnot_ix ON public.mdl_message USING btree (useridfrom, timeuserfromdeleted, notification);


--
-- Name: mdl_mess_useusetimtim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_mess_useusetimtim_ix ON public.mdl_message USING btree (useridfrom, useridto, timeuserfromdeleted, timeusertodeleted);


--
-- Name: mdl_messairndevi_use_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_messairndevi_use_uix ON public.mdl_message_airnotifier_devices USING btree (userdeviceid);


--
-- Name: mdl_messcont_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messcont_con_ix ON public.mdl_message_contacts USING btree (contactid);


--
-- Name: mdl_messcont_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messcont_use_ix ON public.mdl_message_contacts USING btree (userid);


--
-- Name: mdl_messcont_usecon_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_messcont_usecon_uix ON public.mdl_message_contacts USING btree (userid, contactid);


--
-- Name: mdl_messcontrequ_req_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messcontrequ_req_ix ON public.mdl_message_contact_requests USING btree (requesteduserid);


--
-- Name: mdl_messcontrequ_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messcontrequ_use_ix ON public.mdl_message_contact_requests USING btree (userid);


--
-- Name: mdl_messcontrequ_usereq_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_messcontrequ_usereq_uix ON public.mdl_message_contact_requests USING btree (userid, requesteduserid);


--
-- Name: mdl_messconv_comiteitecon_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messconv_comiteitecon_ix ON public.mdl_message_conversations USING btree (component, itemtype, itemid, contextid);


--
-- Name: mdl_messconv_con2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messconv_con2_ix ON public.mdl_message_conversations USING btree (contextid);


--
-- Name: mdl_messconv_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messconv_con_ix ON public.mdl_message_conversations USING btree (convhash);


--
-- Name: mdl_messconv_typ_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messconv_typ_ix ON public.mdl_message_conversations USING btree (type);


--
-- Name: mdl_messconvacti_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messconvacti_con_ix ON public.mdl_message_conversation_actions USING btree (conversationid);


--
-- Name: mdl_messconvacti_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messconvacti_use_ix ON public.mdl_message_conversation_actions USING btree (userid);


--
-- Name: mdl_messconvmemb_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messconvmemb_con_ix ON public.mdl_message_conversation_members USING btree (conversationid);


--
-- Name: mdl_messconvmemb_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messconvmemb_use_ix ON public.mdl_message_conversation_members USING btree (userid);


--
-- Name: mdl_messdata_han_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messdata_han_ix ON public.mdl_messageinbound_datakeys USING btree (handler);


--
-- Name: mdl_messdata_handat_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_messdata_handat_uix ON public.mdl_messageinbound_datakeys USING btree (handler, datavalue);


--
-- Name: mdl_messemaimess_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messemaimess_con_ix ON public.mdl_message_email_messages USING btree (conversationid);


--
-- Name: mdl_messemaimess_mes_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messemaimess_mes_ix ON public.mdl_message_email_messages USING btree (messageid);


--
-- Name: mdl_messemaimess_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messemaimess_use_ix ON public.mdl_message_email_messages USING btree (useridto);


--
-- Name: mdl_messhand_cla_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_messhand_cla_uix ON public.mdl_messageinbound_handlers USING btree (classname);


--
-- Name: mdl_messmess_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messmess_use_ix ON public.mdl_messageinbound_messagelist USING btree (userid);


--
-- Name: mdl_messpopu_isr_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messpopu_isr_ix ON public.mdl_message_popup USING btree (isread);


--
-- Name: mdl_messpopu_mesisr_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_messpopu_mesisr_uix ON public.mdl_message_popup USING btree (messageid, isread);


--
-- Name: mdl_messpopunoti_not_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messpopunoti_not_ix ON public.mdl_message_popup_notifications USING btree (notificationid);


--
-- Name: mdl_messprov_comnam_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_messprov_comnam_uix ON public.mdl_message_providers USING btree (component, name);


--
-- Name: mdl_messread_nottim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messread_nottim_ix ON public.mdl_message_read USING btree (notification, timeread);


--
-- Name: mdl_messread_usetimnot2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messread_usetimnot2_ix ON public.mdl_message_read USING btree (useridto, timeusertodeleted, notification);


--
-- Name: mdl_messread_usetimnot_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messread_usetimnot_ix ON public.mdl_message_read USING btree (useridfrom, timeuserfromdeleted, notification);


--
-- Name: mdl_messread_useusetimtim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messread_useusetimtim_ix ON public.mdl_message_read USING btree (useridfrom, useridto, timeuserfromdeleted, timeusertodeleted);


--
-- Name: mdl_messuseracti_mes_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messuseracti_mes_ix ON public.mdl_message_user_actions USING btree (messageid);


--
-- Name: mdl_messuseracti_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messuseracti_use_ix ON public.mdl_message_user_actions USING btree (userid);


--
-- Name: mdl_messuseracti_usemesact_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_messuseracti_usemesact_uix ON public.mdl_message_user_actions USING btree (userid, messageid, action);


--
-- Name: mdl_messuserbloc_blo_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messuserbloc_blo_ix ON public.mdl_message_users_blocked USING btree (blockeduserid);


--
-- Name: mdl_messuserbloc_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_messuserbloc_use_ix ON public.mdl_message_users_blocked USING btree (userid);


--
-- Name: mdl_messuserbloc_useblo_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_messuserbloc_useblo_uix ON public.mdl_message_users_blocked USING btree (userid, blockeduserid);


--
-- Name: mdl_mnetenrocour_hosrem_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_mnetenrocour_hosrem_uix ON public.mdl_mnetservice_enrol_courses USING btree (hostid, remoteid);


--
-- Name: mdl_mnetenroenro_hos_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_mnetenroenro_hos_ix ON public.mdl_mnetservice_enrol_enrolments USING btree (hostid);


--
-- Name: mdl_mnetenroenro_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_mnetenroenro_use_ix ON public.mdl_mnetservice_enrol_enrolments USING btree (userid);


--
-- Name: mdl_mnethost_app_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_mnethost_app_ix ON public.mdl_mnet_host USING btree (applicationid);


--
-- Name: mdl_mnethost_hosser_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_mnethost_hosser_uix ON public.mdl_mnet_host2service USING btree (hostid, serviceid);


--
-- Name: mdl_mnethost_las_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_mnethost_las_ix ON public.mdl_mnet_host USING btree (last_log_id);


--
-- Name: mdl_mnetlog_hosusecou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_mnetlog_hosusecou_ix ON public.mdl_mnet_log USING btree (hostid, userid, course);


--
-- Name: mdl_mnetremoserv_rpcser_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_mnetremoserv_rpcser_uix ON public.mdl_mnet_remote_service2rpc USING btree (rpcid, serviceid);


--
-- Name: mdl_mnetrpc_enaxml_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_mnetrpc_enaxml_ix ON public.mdl_mnet_rpc USING btree (enabled, xmlrpcpath);


--
-- Name: mdl_mnetserv_rpcser_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_mnetserv_rpcser_uix ON public.mdl_mnet_service2rpc USING btree (rpcid, serviceid);


--
-- Name: mdl_mnetsess_mne_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_mnetsess_mne_ix ON public.mdl_mnet_session USING btree (mnethostid);


--
-- Name: mdl_mnetsess_tok_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_mnetsess_tok_uix ON public.mdl_mnet_session USING btree (token);


--
-- Name: mdl_mnetsess_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_mnetsess_use_ix ON public.mdl_mnet_session USING btree (userid);


--
-- Name: mdl_mnetssoaccecont_mneuse_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_mnetssoaccecont_mneuse_uix ON public.mdl_mnet_sso_access_control USING btree (mnet_host_id, username);


--
-- Name: mdl_modu_nam_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_modu_nam_ix ON public.mdl_modules USING btree (name);


--
-- Name: mdl_mypage_usepri_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_mypage_usepri_ix ON public.mdl_my_pages USING btree (userid, private);


--
-- Name: mdl_noti_tim2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_noti_tim2_ix ON public.mdl_notifications USING btree (timeread);


--
-- Name: mdl_noti_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_noti_tim_ix ON public.mdl_notifications USING btree (timecreated);


--
-- Name: mdl_noti_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_noti_use2_ix ON public.mdl_notifications USING btree (useridto);


--
-- Name: mdl_noti_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_noti_use_ix ON public.mdl_notifications USING btree (useridfrom);


--
-- Name: mdl_oautaccetoke_iss_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_oautaccetoke_iss_uix ON public.mdl_oauth2_access_token USING btree (issuerid);


--
-- Name: mdl_oautaccetoke_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_oautaccetoke_use_ix ON public.mdl_oauth2_access_token USING btree (usermodified);


--
-- Name: mdl_oautendp_iss_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_oautendp_iss_ix ON public.mdl_oauth2_endpoint USING btree (issuerid);


--
-- Name: mdl_oautendp_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_oautendp_use_ix ON public.mdl_oauth2_endpoint USING btree (usermodified);


--
-- Name: mdl_oautrefrtoke_iss_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_oautrefrtoke_iss_ix ON public.mdl_oauth2_refresh_token USING btree (issuerid);


--
-- Name: mdl_oautrefrtoke_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_oautrefrtoke_use_ix ON public.mdl_oauth2_refresh_token USING btree (userid);


--
-- Name: mdl_oautrefrtoke_useisssco_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_oautrefrtoke_useisssco_uix ON public.mdl_oauth2_refresh_token USING btree (userid, issuerid, scopehash);


--
-- Name: mdl_oautsystacco_iss_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_oautsystacco_iss_uix ON public.mdl_oauth2_system_account USING btree (issuerid);


--
-- Name: mdl_oautsystacco_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_oautsystacco_use_ix ON public.mdl_oauth2_system_account USING btree (usermodified);


--
-- Name: mdl_oautuserfielmapp_iss_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_oautuserfielmapp_iss_ix ON public.mdl_oauth2_user_field_mapping USING btree (issuerid);


--
-- Name: mdl_oautuserfielmapp_issin_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_oautuserfielmapp_issin_uix ON public.mdl_oauth2_user_field_mapping USING btree (issuerid, internalfield);


--
-- Name: mdl_oautuserfielmapp_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_oautuserfielmapp_use_ix ON public.mdl_oauth2_user_field_mapping USING btree (usermodified);


--
-- Name: mdl_page_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_page_cou_ix ON public.mdl_page USING btree (course);


--
-- Name: mdl_paygpayp_pay_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_paygpayp_pay_uix ON public.mdl_paygw_paypal USING btree (paymentid);


--
-- Name: mdl_paym_acc_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_paym_acc_ix ON public.mdl_payments USING btree (accountid);


--
-- Name: mdl_paym_compayite_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_paym_compayite_ix ON public.mdl_payments USING btree (component, paymentarea, itemid);


--
-- Name: mdl_paym_gat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_paym_gat_ix ON public.mdl_payments USING btree (gateway);


--
-- Name: mdl_paym_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_paym_use_ix ON public.mdl_payments USING btree (userid);


--
-- Name: mdl_paymacco_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_paymacco_con_ix ON public.mdl_payment_accounts USING btree (contextid);


--
-- Name: mdl_paymgate_acc_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_paymgate_acc_ix ON public.mdl_payment_gateways USING btree (accountid);


--
-- Name: mdl_portinstconf_ins_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_portinstconf_ins_ix ON public.mdl_portfolio_instance_config USING btree (instance);


--
-- Name: mdl_portinstconf_nam_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_portinstconf_nam_ix ON public.mdl_portfolio_instance_config USING btree (name);


--
-- Name: mdl_portinstuser_ins_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_portinstuser_ins_ix ON public.mdl_portfolio_instance_user USING btree (instance);


--
-- Name: mdl_portinstuser_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_portinstuser_use_ix ON public.mdl_portfolio_instance_user USING btree (userid);


--
-- Name: mdl_portlog_por_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_portlog_por_ix ON public.mdl_portfolio_log USING btree (portfolio);


--
-- Name: mdl_portlog_tem_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_portlog_tem_ix ON public.mdl_portfolio_log USING btree (tempdataid);


--
-- Name: mdl_portlog_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_portlog_use_ix ON public.mdl_portfolio_log USING btree (userid);


--
-- Name: mdl_portmahaqueu_tok_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_portmahaqueu_tok_ix ON public.mdl_portfolio_mahara_queue USING btree (token);


--
-- Name: mdl_portmahaqueu_tra_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_portmahaqueu_tra_ix ON public.mdl_portfolio_mahara_queue USING btree (transferid);


--
-- Name: mdl_porttemp_ins_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_porttemp_ins_ix ON public.mdl_portfolio_tempdata USING btree (instance);


--
-- Name: mdl_porttemp_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_porttemp_use_ix ON public.mdl_portfolio_tempdata USING btree (userid);


--
-- Name: mdl_post_cou2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_post_cou2_ix ON public.mdl_post USING btree (coursemoduleid);


--
-- Name: mdl_post_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_post_cou_ix ON public.mdl_post USING btree (courseid);


--
-- Name: mdl_post_iduse_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_post_iduse_uix ON public.mdl_post USING btree (id, userid);


--
-- Name: mdl_post_las_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_post_las_ix ON public.mdl_post USING btree (lastmodified);


--
-- Name: mdl_post_mod_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_post_mod_ix ON public.mdl_post USING btree (module);


--
-- Name: mdl_post_sub_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_post_sub_ix ON public.mdl_post USING btree (subject);


--
-- Name: mdl_post_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_post_use_ix ON public.mdl_post USING btree (usermodified);


--
-- Name: mdl_prof_run_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_prof_run_uix ON public.mdl_profiling USING btree (runid);


--
-- Name: mdl_prof_timrun_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_prof_timrun_ix ON public.mdl_profiling USING btree (timecreated, runreference);


--
-- Name: mdl_prof_urlrun_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_prof_urlrun_ix ON public.mdl_profiling USING btree (url, runreference);


--
-- Name: mdl_qtypddim_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_qtypddim_que_ix ON public.mdl_qtype_ddimageortext USING btree (questionid);


--
-- Name: mdl_qtypddimdrag_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_qtypddimdrag_que_ix ON public.mdl_qtype_ddimageortext_drags USING btree (questionid);


--
-- Name: mdl_qtypddimdrop_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_qtypddimdrop_que_ix ON public.mdl_qtype_ddimageortext_drops USING btree (questionid);


--
-- Name: mdl_qtypddma_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_qtypddma_que_ix ON public.mdl_qtype_ddmarker USING btree (questionid);


--
-- Name: mdl_qtypddmadrag_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_qtypddmadrag_que_ix ON public.mdl_qtype_ddmarker_drags USING btree (questionid);


--
-- Name: mdl_qtypddmadrop_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_qtypddmadrop_que_ix ON public.mdl_qtype_ddmarker_drops USING btree (questionid);


--
-- Name: mdl_qtypessaopti_que_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_qtypessaopti_que_uix ON public.mdl_qtype_essay_options USING btree (questionid);


--
-- Name: mdl_qtypmatcopti_que_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_qtypmatcopti_que_uix ON public.mdl_qtype_match_options USING btree (questionid);


--
-- Name: mdl_qtypmatcsubq_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_qtypmatcsubq_que_ix ON public.mdl_qtype_match_subquestions USING btree (questionid);


--
-- Name: mdl_qtypmultopti_que_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_qtypmultopti_que_uix ON public.mdl_qtype_multichoice_options USING btree (questionid);


--
-- Name: mdl_qtypordeopti_que_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_qtypordeopti_que_uix ON public.mdl_qtype_ordering_options USING btree (questionid);


--
-- Name: mdl_qtyprandopti_que_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_qtyprandopti_que_uix ON public.mdl_qtype_randomsamatch_options USING btree (questionid);


--
-- Name: mdl_qtypshoropti_que_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_qtypshoropti_que_uix ON public.mdl_qtype_shortanswer_options USING btree (questionid);


--
-- Name: mdl_ques_cre_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ques_cre_ix ON public.mdl_question USING btree (createdby);


--
-- Name: mdl_ques_mod_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ques_mod_ix ON public.mdl_question USING btree (modifiedby);


--
-- Name: mdl_ques_par_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ques_par_ix ON public.mdl_question USING btree (parent);


--
-- Name: mdl_ques_qty_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_ques_qty_ix ON public.mdl_question USING btree (qtype);


--
-- Name: mdl_quesansw_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesansw_que_ix ON public.mdl_question_answers USING btree (question);


--
-- Name: mdl_quesatte_beh_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesatte_beh_ix ON public.mdl_question_attempts USING btree (behaviour);


--
-- Name: mdl_quesatte_que2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesatte_que2_ix ON public.mdl_question_attempts USING btree (questionusageid);


--
-- Name: mdl_quesatte_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesatte_que_ix ON public.mdl_question_attempts USING btree (questionid);


--
-- Name: mdl_quesatte_queslo_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_quesatte_queslo_uix ON public.mdl_question_attempts USING btree (questionusageid, slot);


--
-- Name: mdl_quesattestep_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesattestep_que_ix ON public.mdl_question_attempt_steps USING btree (questionattemptid);


--
-- Name: mdl_quesattestep_queseq_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_quesattestep_queseq_uix ON public.mdl_question_attempt_steps USING btree (questionattemptid, sequencenumber);


--
-- Name: mdl_quesattestep_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesattestep_use_ix ON public.mdl_question_attempt_steps USING btree (userid);


--
-- Name: mdl_quesattestepdata_att_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesattestepdata_att_ix ON public.mdl_question_attempt_step_data USING btree (attemptstepid);


--
-- Name: mdl_quesbankentr_own_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesbankentr_own_ix ON public.mdl_question_bank_entries USING btree (ownerid);


--
-- Name: mdl_quesbankentr_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesbankentr_que_ix ON public.mdl_question_bank_entries USING btree (questioncategoryid);


--
-- Name: mdl_quesbankentr_queidn_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_quesbankentr_queidn_uix ON public.mdl_question_bank_entries USING btree (questioncategoryid, idnumber);


--
-- Name: mdl_quescalc_ans_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quescalc_ans_ix ON public.mdl_question_calculated USING btree (answer);


--
-- Name: mdl_quescalc_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quescalc_que_ix ON public.mdl_question_calculated USING btree (question);


--
-- Name: mdl_quescalcopti_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quescalcopti_que_ix ON public.mdl_question_calculated_options USING btree (question);


--
-- Name: mdl_quescate_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quescate_con_ix ON public.mdl_question_categories USING btree (contextid);


--
-- Name: mdl_quescate_conidn_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_quescate_conidn_uix ON public.mdl_question_categories USING btree (contextid, idnumber);


--
-- Name: mdl_quescate_consta_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_quescate_consta_uix ON public.mdl_question_categories USING btree (contextid, stamp);


--
-- Name: mdl_quescate_par_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quescate_par_ix ON public.mdl_question_categories USING btree (parent);


--
-- Name: mdl_quesdata_dat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesdata_dat_ix ON public.mdl_question_datasets USING btree (datasetdefinition);


--
-- Name: mdl_quesdata_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesdata_que_ix ON public.mdl_question_datasets USING btree (question);


--
-- Name: mdl_quesdata_quedat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesdata_quedat_ix ON public.mdl_question_datasets USING btree (question, datasetdefinition);


--
-- Name: mdl_quesdatadefi_cat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesdatadefi_cat_ix ON public.mdl_question_dataset_definitions USING btree (category);


--
-- Name: mdl_quesdataitem_def_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesdataitem_def_ix ON public.mdl_question_dataset_items USING btree (definition);


--
-- Name: mdl_quesddwt_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesddwt_que_ix ON public.mdl_question_ddwtos USING btree (questionid);


--
-- Name: mdl_quesgaps_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesgaps_que_ix ON public.mdl_question_gapselect USING btree (questionid);


--
-- Name: mdl_queshint_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_queshint_que_ix ON public.mdl_question_hints USING btree (questionid);


--
-- Name: mdl_quesmult_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesmult_que_ix ON public.mdl_question_multianswer USING btree (question);


--
-- Name: mdl_quesnume_ans_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesnume_ans_ix ON public.mdl_question_numerical USING btree (answer);


--
-- Name: mdl_quesnume_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesnume_que_ix ON public.mdl_question_numerical USING btree (question);


--
-- Name: mdl_quesnumeopti_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesnumeopti_que_ix ON public.mdl_question_numerical_options USING btree (question);


--
-- Name: mdl_quesnumeunit_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesnumeunit_que_ix ON public.mdl_question_numerical_units USING btree (question);


--
-- Name: mdl_quesnumeunit_queuni_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_quesnumeunit_queuni_uix ON public.mdl_question_numerical_units USING btree (question, unit);


--
-- Name: mdl_quesrefe_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesrefe_que_ix ON public.mdl_question_references USING btree (questionbankentryid);


--
-- Name: mdl_quesrefe_usi_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesrefe_usi_ix ON public.mdl_question_references USING btree (usingcontextid);


--
-- Name: mdl_quesrefe_usicomqueite_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_quesrefe_usicomqueite_uix ON public.mdl_question_references USING btree (usingcontextid, component, questionarea, itemid);


--
-- Name: mdl_quesrespanal_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesrespanal_que_ix ON public.mdl_question_response_analysis USING btree (questionid);


--
-- Name: mdl_quesrespcoun_ana_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesrespcoun_ana_ix ON public.mdl_question_response_count USING btree (analysisid);


--
-- Name: mdl_quessetrefe_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quessetrefe_que_ix ON public.mdl_question_set_references USING btree (questionscontextid);


--
-- Name: mdl_quessetrefe_usi_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quessetrefe_usi_ix ON public.mdl_question_set_references USING btree (usingcontextid);


--
-- Name: mdl_quessetrefe_usicomquei_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_quessetrefe_usicomquei_uix ON public.mdl_question_set_references USING btree (usingcontextid, component, questionarea, itemid);


--
-- Name: mdl_quesstat_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesstat_que_ix ON public.mdl_question_statistics USING btree (questionid);


--
-- Name: mdl_questrue_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_questrue_que_ix ON public.mdl_question_truefalse USING btree (question);


--
-- Name: mdl_quesusag_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesusag_con_ix ON public.mdl_question_usages USING btree (contextid);


--
-- Name: mdl_quesvers_que2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesvers_que2_ix ON public.mdl_question_versions USING btree (questionid);


--
-- Name: mdl_quesvers_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quesvers_que_ix ON public.mdl_question_versions USING btree (questionbankentryid);


--
-- Name: mdl_quiz_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quiz_cou_ix ON public.mdl_quiz USING btree (course);


--
-- Name: mdl_quizatte_qui_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizatte_qui_ix ON public.mdl_quiz_attempts USING btree (quiz);


--
-- Name: mdl_quizatte_quiuseatt_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_quizatte_quiuseatt_uix ON public.mdl_quiz_attempts USING btree (quiz, userid, attempt);


--
-- Name: mdl_quizatte_statim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizatte_statim_ix ON public.mdl_quiz_attempts USING btree (state, timecheckstate);


--
-- Name: mdl_quizatte_uni_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_quizatte_uni_uix ON public.mdl_quiz_attempts USING btree (uniqueid);


--
-- Name: mdl_quizatte_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizatte_use_ix ON public.mdl_quiz_attempts USING btree (userid);


--
-- Name: mdl_quizfeed_qui_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizfeed_qui_ix ON public.mdl_quiz_feedback USING btree (quizid);


--
-- Name: mdl_quizgrad_qui_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizgrad_qui_ix ON public.mdl_quiz_grades USING btree (quiz);


--
-- Name: mdl_quizgrad_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizgrad_use_ix ON public.mdl_quiz_grades USING btree (userid);


--
-- Name: mdl_quizgraditem_qui_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizgraditem_qui_ix ON public.mdl_quiz_grade_items USING btree (quizid);


--
-- Name: mdl_quizgraditem_quisor_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_quizgraditem_quisor_uix ON public.mdl_quiz_grade_items USING btree (quizid, sortorder);


--
-- Name: mdl_quizover_gro_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizover_gro_ix ON public.mdl_quiz_overrides USING btree (groupid);


--
-- Name: mdl_quizover_qui_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizover_qui_ix ON public.mdl_quiz_overrides USING btree (quiz);


--
-- Name: mdl_quizover_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizover_use_ix ON public.mdl_quiz_overrides USING btree (userid);


--
-- Name: mdl_quizoverregr_queslo_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizoverregr_queslo_ix ON public.mdl_quiz_overview_regrades USING btree (questionusageid, slot);


--
-- Name: mdl_quizrepo_nam_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_quizrepo_nam_uix ON public.mdl_quiz_reports USING btree (name);


--
-- Name: mdl_quizsebquiz_cmi_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_quizsebquiz_cmi_uix ON public.mdl_quizaccess_seb_quizsettings USING btree (cmid);


--
-- Name: mdl_quizsebquiz_qui_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_quizsebquiz_qui_uix ON public.mdl_quizaccess_seb_quizsettings USING btree (quizid);


--
-- Name: mdl_quizsebquiz_tem_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizsebquiz_tem_ix ON public.mdl_quizaccess_seb_quizsettings USING btree (templateid);


--
-- Name: mdl_quizsebquiz_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizsebquiz_use_ix ON public.mdl_quizaccess_seb_quizsettings USING btree (usermodified);


--
-- Name: mdl_quizsebtemp_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizsebtemp_use_ix ON public.mdl_quizaccess_seb_template USING btree (usermodified);


--
-- Name: mdl_quizsect_qui_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizsect_qui_ix ON public.mdl_quiz_sections USING btree (quizid);


--
-- Name: mdl_quizsect_quifir_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_quizsect_quifir_uix ON public.mdl_quiz_sections USING btree (quizid, firstslot);


--
-- Name: mdl_quizslot_qui2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizslot_qui2_ix ON public.mdl_quiz_slots USING btree (quizgradeitemid);


--
-- Name: mdl_quizslot_qui_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_quizslot_qui_ix ON public.mdl_quiz_slots USING btree (quizid);


--
-- Name: mdl_quizslot_quislo_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_quizslot_quislo_uix ON public.mdl_quiz_slots USING btree (quizid, slot);


--
-- Name: mdl_rati_comratconite_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rati_comratconite_ix ON public.mdl_rating USING btree (component, ratingarea, contextid, itemid);


--
-- Name: mdl_rati_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rati_con_ix ON public.mdl_rating USING btree (contextid);


--
-- Name: mdl_rati_sca_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rati_sca_ix ON public.mdl_rating USING btree (scaleid);


--
-- Name: mdl_rati_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rati_use_ix ON public.mdl_rating USING btree (userid);


--
-- Name: mdl_repoaudi_rep_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_repoaudi_rep_ix ON public.mdl_reportbuilder_audience USING btree (reportid);


--
-- Name: mdl_repoaudi_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_repoaudi_use2_ix ON public.mdl_reportbuilder_audience USING btree (usermodified);


--
-- Name: mdl_repoaudi_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_repoaudi_use_ix ON public.mdl_reportbuilder_audience USING btree (usercreated);


--
-- Name: mdl_repocolu_rep_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_repocolu_rep_ix ON public.mdl_reportbuilder_column USING btree (reportid);


--
-- Name: mdl_repocolu_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_repocolu_use2_ix ON public.mdl_reportbuilder_column USING btree (usermodified);


--
-- Name: mdl_repocolu_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_repocolu_use_ix ON public.mdl_reportbuilder_column USING btree (usercreated);


--
-- Name: mdl_repofilt_rep_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_repofilt_rep_ix ON public.mdl_reportbuilder_filter USING btree (reportid);


--
-- Name: mdl_repofilt_repuniisc_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_repofilt_repuniisc_uix ON public.mdl_reportbuilder_filter USING btree (reportid, uniqueidentifier, iscondition);


--
-- Name: mdl_repofilt_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_repofilt_use2_ix ON public.mdl_reportbuilder_filter USING btree (usermodified);


--
-- Name: mdl_repofilt_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_repofilt_use_ix ON public.mdl_reportbuilder_filter USING btree (usercreated);


--
-- Name: mdl_repoinst_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_repoinst_con_ix ON public.mdl_repository_instances USING btree (contextid);


--
-- Name: mdl_repoinst_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_repoinst_use_ix ON public.mdl_repository_instances USING btree (userid);


--
-- Name: mdl_repoonedacce_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_repoonedacce_use_ix ON public.mdl_repository_onedrive_access USING btree (usermodified);


--
-- Name: mdl_reporepo_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_reporepo_con_ix ON public.mdl_reportbuilder_report USING btree (contextid);


--
-- Name: mdl_reporepo_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_reporepo_use2_ix ON public.mdl_reportbuilder_report USING btree (usermodified);


--
-- Name: mdl_reporepo_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_reporepo_use_ix ON public.mdl_reportbuilder_report USING btree (usercreated);


--
-- Name: mdl_reposche_rep_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_reposche_rep_ix ON public.mdl_reportbuilder_schedule USING btree (reportid);


--
-- Name: mdl_reposche_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_reposche_use2_ix ON public.mdl_reportbuilder_schedule USING btree (usercreated);


--
-- Name: mdl_reposche_use3_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_reposche_use3_ix ON public.mdl_reportbuilder_schedule USING btree (usermodified);


--
-- Name: mdl_reposche_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_reposche_use_ix ON public.mdl_reportbuilder_schedule USING btree (userviewas);


--
-- Name: mdl_reso_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_reso_cou_ix ON public.mdl_resource USING btree (course);


--
-- Name: mdl_resoold_cmi_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_resoold_cmi_ix ON public.mdl_resource_old USING btree (cmid);


--
-- Name: mdl_resoold_old_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_resoold_old_uix ON public.mdl_resource_old USING btree (oldid);


--
-- Name: mdl_role_sho_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_role_sho_uix ON public.mdl_role USING btree (shortname);


--
-- Name: mdl_role_sor_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_role_sor_uix ON public.mdl_role USING btree (sortorder);


--
-- Name: mdl_rolealloassi_all_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rolealloassi_all_ix ON public.mdl_role_allow_assign USING btree (allowassign);


--
-- Name: mdl_rolealloassi_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rolealloassi_rol_ix ON public.mdl_role_allow_assign USING btree (roleid);


--
-- Name: mdl_rolealloassi_rolall_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_rolealloassi_rolall_uix ON public.mdl_role_allow_assign USING btree (roleid, allowassign);


--
-- Name: mdl_rolealloover_all_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rolealloover_all_ix ON public.mdl_role_allow_override USING btree (allowoverride);


--
-- Name: mdl_rolealloover_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rolealloover_rol_ix ON public.mdl_role_allow_override USING btree (roleid);


--
-- Name: mdl_rolealloover_rolall_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_rolealloover_rolall_uix ON public.mdl_role_allow_override USING btree (roleid, allowoverride);


--
-- Name: mdl_rolealloswit_all_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rolealloswit_all_ix ON public.mdl_role_allow_switch USING btree (allowswitch);


--
-- Name: mdl_rolealloswit_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rolealloswit_rol_ix ON public.mdl_role_allow_switch USING btree (roleid);


--
-- Name: mdl_rolealloswit_rolall_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_rolealloswit_rolall_uix ON public.mdl_role_allow_switch USING btree (roleid, allowswitch);


--
-- Name: mdl_rolealloview_all_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rolealloview_all_ix ON public.mdl_role_allow_view USING btree (allowview);


--
-- Name: mdl_rolealloview_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rolealloview_rol_ix ON public.mdl_role_allow_view USING btree (roleid);


--
-- Name: mdl_rolealloview_rolall_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_rolealloview_rolall_uix ON public.mdl_role_allow_view USING btree (roleid, allowview);


--
-- Name: mdl_roleassi_comiteuse_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_roleassi_comiteuse_ix ON public.mdl_role_assignments USING btree (component, itemid, userid);


--
-- Name: mdl_roleassi_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_roleassi_con_ix ON public.mdl_role_assignments USING btree (contextid);


--
-- Name: mdl_roleassi_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_roleassi_rol_ix ON public.mdl_role_assignments USING btree (roleid);


--
-- Name: mdl_roleassi_rolcon_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_roleassi_rolcon_ix ON public.mdl_role_assignments USING btree (roleid, contextid);


--
-- Name: mdl_roleassi_sor_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_roleassi_sor_ix ON public.mdl_role_assignments USING btree (sortorder);


--
-- Name: mdl_roleassi_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_roleassi_use_ix ON public.mdl_role_assignments USING btree (userid);


--
-- Name: mdl_roleassi_useconrol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_roleassi_useconrol_ix ON public.mdl_role_assignments USING btree (userid, contextid, roleid);


--
-- Name: mdl_rolecapa_cap_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rolecapa_cap_ix ON public.mdl_role_capabilities USING btree (capability);


--
-- Name: mdl_rolecapa_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rolecapa_con_ix ON public.mdl_role_capabilities USING btree (contextid);


--
-- Name: mdl_rolecapa_mod_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rolecapa_mod_ix ON public.mdl_role_capabilities USING btree (modifierid);


--
-- Name: mdl_rolecapa_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rolecapa_rol_ix ON public.mdl_role_capabilities USING btree (roleid);


--
-- Name: mdl_rolecapa_rolconcap_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_rolecapa_rolconcap_uix ON public.mdl_role_capabilities USING btree (roleid, contextid, capability);


--
-- Name: mdl_rolecontleve_conrol_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_rolecontleve_conrol_uix ON public.mdl_role_context_levels USING btree (contextlevel, roleid);


--
-- Name: mdl_rolecontleve_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rolecontleve_rol_ix ON public.mdl_role_context_levels USING btree (roleid);


--
-- Name: mdl_rolename_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rolename_con_ix ON public.mdl_role_names USING btree (contextid);


--
-- Name: mdl_rolename_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_rolename_rol_ix ON public.mdl_role_names USING btree (roleid);


--
-- Name: mdl_rolename_rolcon_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_rolename_rolcon_uix ON public.mdl_role_names USING btree (roleid, contextid);


--
-- Name: mdl_scal_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scal_cou_ix ON public.mdl_scale USING btree (courseid);


--
-- Name: mdl_scal_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scal_use_ix ON public.mdl_scale USING btree (userid);


--
-- Name: mdl_scalhist_act_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scalhist_act_ix ON public.mdl_scale_history USING btree (action);


--
-- Name: mdl_scalhist_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scalhist_cou_ix ON public.mdl_scale_history USING btree (courseid);


--
-- Name: mdl_scalhist_log_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scalhist_log_ix ON public.mdl_scale_history USING btree (loggeduser);


--
-- Name: mdl_scalhist_old_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scalhist_old_ix ON public.mdl_scale_history USING btree (oldid);


--
-- Name: mdl_scalhist_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scalhist_tim_ix ON public.mdl_scale_history USING btree (timemodified);


--
-- Name: mdl_scalhist_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scalhist_use_ix ON public.mdl_scale_history USING btree (userid);


--
-- Name: mdl_scor_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scor_cou_ix ON public.mdl_scorm USING btree (course);


--
-- Name: mdl_scoraiccsess_sco_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scoraiccsess_sco_ix ON public.mdl_scorm_aicc_session USING btree (scormid);


--
-- Name: mdl_scoraiccsess_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scoraiccsess_use_ix ON public.mdl_scorm_aicc_session USING btree (userid);


--
-- Name: mdl_scoratte_sco_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scoratte_sco_ix ON public.mdl_scorm_attempt USING btree (scormid);


--
-- Name: mdl_scoratte_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scoratte_use_ix ON public.mdl_scorm_attempt USING btree (userid);


--
-- Name: mdl_scorelem_ele_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_scorelem_ele_uix ON public.mdl_scorm_element USING btree (element);


--
-- Name: mdl_scorscoe_sco_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scorscoe_sco_ix ON public.mdl_scorm_scoes USING btree (scorm);


--
-- Name: mdl_scorscoedata_sco_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scorscoedata_sco_ix ON public.mdl_scorm_scoes_data USING btree (scoid);


--
-- Name: mdl_scorscoevalu_att_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scorscoevalu_att_ix ON public.mdl_scorm_scoes_value USING btree (attemptid);


--
-- Name: mdl_scorscoevalu_ele_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scorscoevalu_ele_ix ON public.mdl_scorm_scoes_value USING btree (elementid);


--
-- Name: mdl_scorscoevalu_sco_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scorscoevalu_sco_ix ON public.mdl_scorm_scoes_value USING btree (scoid);


--
-- Name: mdl_scorseqmapi_obj_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scorseqmapi_obj_ix ON public.mdl_scorm_seq_mapinfo USING btree (objectiveid);


--
-- Name: mdl_scorseqmapi_sco_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scorseqmapi_sco_ix ON public.mdl_scorm_seq_mapinfo USING btree (scoid);


--
-- Name: mdl_scorseqmapi_scoidobj_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_scorseqmapi_scoidobj_uix ON public.mdl_scorm_seq_mapinfo USING btree (scoid, id, objectiveid);


--
-- Name: mdl_scorseqobje_sco_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scorseqobje_sco_ix ON public.mdl_scorm_seq_objective USING btree (scoid);


--
-- Name: mdl_scorseqobje_scoid_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_scorseqobje_scoid_uix ON public.mdl_scorm_seq_objective USING btree (scoid, id);


--
-- Name: mdl_scorseqroll_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scorseqroll_rol_ix ON public.mdl_scorm_seq_rolluprulecond USING btree (rollupruleid);


--
-- Name: mdl_scorseqroll_sco2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scorseqroll_sco2_ix ON public.mdl_scorm_seq_rolluprulecond USING btree (scoid);


--
-- Name: mdl_scorseqroll_sco_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scorseqroll_sco_ix ON public.mdl_scorm_seq_rolluprule USING btree (scoid);


--
-- Name: mdl_scorseqroll_scoid_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_scorseqroll_scoid_uix ON public.mdl_scorm_seq_rolluprule USING btree (scoid, id);


--
-- Name: mdl_scorseqroll_scorolid_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_scorseqroll_scorolid_uix ON public.mdl_scorm_seq_rolluprulecond USING btree (scoid, rollupruleid, id);


--
-- Name: mdl_scorseqrule_idscorul_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_scorseqrule_idscorul_uix ON public.mdl_scorm_seq_rulecond USING btree (id, scoid, ruleconditionsid);


--
-- Name: mdl_scorseqrule_rul_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scorseqrule_rul_ix ON public.mdl_scorm_seq_rulecond USING btree (ruleconditionsid);


--
-- Name: mdl_scorseqrule_sco2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scorseqrule_sco2_ix ON public.mdl_scorm_seq_rulecond USING btree (scoid);


--
-- Name: mdl_scorseqrule_sco_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_scorseqrule_sco_ix ON public.mdl_scorm_seq_ruleconds USING btree (scoid);


--
-- Name: mdl_scorseqrule_scoid_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_scorseqrule_scoid_uix ON public.mdl_scorm_seq_ruleconds USING btree (scoid, id);


--
-- Name: mdl_search_simpledb_content; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_search_simpledb_content ON public.mdl_search_simpledb_index USING gin (to_tsvector('simple'::regconfig, content));


--
-- Name: mdl_search_simpledb_description1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_search_simpledb_description1 ON public.mdl_search_simpledb_index USING gin (to_tsvector('simple'::regconfig, description1));


--
-- Name: mdl_search_simpledb_description2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_search_simpledb_description2 ON public.mdl_search_simpledb_index USING gin (to_tsvector('simple'::regconfig, description2));


--
-- Name: mdl_search_simpledb_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_search_simpledb_title ON public.mdl_search_simpledb_index USING gin (to_tsvector('simple'::regconfig, title));


--
-- Name: mdl_searinderequ_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_searinderequ_con_ix ON public.mdl_search_index_requests USING btree (contextid);


--
-- Name: mdl_searinderequ_indtim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_searinderequ_indtim_ix ON public.mdl_search_index_requests USING btree (indexpriority, timerequested);


--
-- Name: mdl_searsimpinde_are_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_searsimpinde_are_ix ON public.mdl_search_simpledb_index USING btree (areaid);


--
-- Name: mdl_searsimpinde_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_searsimpinde_con_ix ON public.mdl_search_simpledb_index USING btree (contextid);


--
-- Name: mdl_searsimpinde_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_searsimpinde_cou_ix ON public.mdl_search_simpledb_index USING btree (courseid);


--
-- Name: mdl_searsimpinde_doc_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_searsimpinde_doc_uix ON public.mdl_search_simpledb_index USING btree (docid);


--
-- Name: mdl_searsimpinde_owncon_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_searsimpinde_owncon_ix ON public.mdl_search_simpledb_index USING btree (owneruserid, contextid);


--
-- Name: mdl_sess_sid_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_sess_sid_uix ON public.mdl_sessions USING btree (sid);


--
-- Name: mdl_sess_sta_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_sess_sta_ix ON public.mdl_sessions USING btree (state);


--
-- Name: mdl_sess_tim2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_sess_tim2_ix ON public.mdl_sessions USING btree (timemodified);


--
-- Name: mdl_sess_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_sess_tim_ix ON public.mdl_sessions USING btree (timecreated);


--
-- Name: mdl_sess_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_sess_use_ix ON public.mdl_sessions USING btree (userid);


--
-- Name: mdl_smsmess_gat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_smsmess_gat_ix ON public.mdl_sms_messages USING btree (gatewayid);


--
-- Name: mdl_statdail_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statdail_cou_ix ON public.mdl_stats_daily USING btree (courseid);


--
-- Name: mdl_statdail_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statdail_rol_ix ON public.mdl_stats_daily USING btree (roleid);


--
-- Name: mdl_statdail_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statdail_tim_ix ON public.mdl_stats_daily USING btree (timeend);


--
-- Name: mdl_statmont_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statmont_cou_ix ON public.mdl_stats_monthly USING btree (courseid);


--
-- Name: mdl_statmont_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statmont_rol_ix ON public.mdl_stats_monthly USING btree (roleid);


--
-- Name: mdl_statmont_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statmont_tim_ix ON public.mdl_stats_monthly USING btree (timeend);


--
-- Name: mdl_statuserdail_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statuserdail_cou_ix ON public.mdl_stats_user_daily USING btree (courseid);


--
-- Name: mdl_statuserdail_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statuserdail_rol_ix ON public.mdl_stats_user_daily USING btree (roleid);


--
-- Name: mdl_statuserdail_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statuserdail_tim_ix ON public.mdl_stats_user_daily USING btree (timeend);


--
-- Name: mdl_statuserdail_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statuserdail_use_ix ON public.mdl_stats_user_daily USING btree (userid);


--
-- Name: mdl_statusermont_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statusermont_cou_ix ON public.mdl_stats_user_monthly USING btree (courseid);


--
-- Name: mdl_statusermont_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statusermont_rol_ix ON public.mdl_stats_user_monthly USING btree (roleid);


--
-- Name: mdl_statusermont_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statusermont_tim_ix ON public.mdl_stats_user_monthly USING btree (timeend);


--
-- Name: mdl_statusermont_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statusermont_use_ix ON public.mdl_stats_user_monthly USING btree (userid);


--
-- Name: mdl_statuserweek_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statuserweek_cou_ix ON public.mdl_stats_user_weekly USING btree (courseid);


--
-- Name: mdl_statuserweek_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statuserweek_rol_ix ON public.mdl_stats_user_weekly USING btree (roleid);


--
-- Name: mdl_statuserweek_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statuserweek_tim_ix ON public.mdl_stats_user_weekly USING btree (timeend);


--
-- Name: mdl_statuserweek_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statuserweek_use_ix ON public.mdl_stats_user_weekly USING btree (userid);


--
-- Name: mdl_statweek_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statweek_cou_ix ON public.mdl_stats_weekly USING btree (courseid);


--
-- Name: mdl_statweek_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statweek_rol_ix ON public.mdl_stats_weekly USING btree (roleid);


--
-- Name: mdl_statweek_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_statweek_tim_ix ON public.mdl_stats_weekly USING btree (timeend);


--
-- Name: mdl_storprog_idn_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_storprog_idn_ix ON public.mdl_stored_progress USING btree (idnumber);


--
-- Name: mdl_subs_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_subs_cou_ix ON public.mdl_subsection USING btree (course);


--
-- Name: mdl_surv_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_surv_cou_ix ON public.mdl_survey USING btree (course);


--
-- Name: mdl_survanal_sur_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_survanal_sur_ix ON public.mdl_survey_analysis USING btree (survey);


--
-- Name: mdl_survanal_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_survanal_use_ix ON public.mdl_survey_analysis USING btree (userid);


--
-- Name: mdl_survansw_que_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_survansw_que_ix ON public.mdl_survey_answers USING btree (question);


--
-- Name: mdl_survansw_sur_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_survansw_sur_ix ON public.mdl_survey_answers USING btree (survey);


--
-- Name: mdl_survansw_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_survansw_use_ix ON public.mdl_survey_answers USING btree (userid);


--
-- Name: mdl_tag_tag_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tag_tag_ix ON public.mdl_tag USING btree (tagcollid);


--
-- Name: mdl_tag_tagiss_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tag_tagiss_ix ON public.mdl_tag USING btree (tagcollid, isstandard);


--
-- Name: mdl_tag_tagnam_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_tag_tagnam_uix ON public.mdl_tag USING btree (tagcollid, name);


--
-- Name: mdl_tag_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tag_use_ix ON public.mdl_tag USING btree (userid);


--
-- Name: mdl_tagarea_comite_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_tagarea_comite_uix ON public.mdl_tag_area USING btree (component, itemtype);


--
-- Name: mdl_tagarea_tag_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tagarea_tag_ix ON public.mdl_tag_area USING btree (tagcollid);


--
-- Name: mdl_tagcorr_tag_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tagcorr_tag_ix ON public.mdl_tag_correlation USING btree (tagid);


--
-- Name: mdl_taginst_comiteiteconti_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_taginst_comiteiteconti_uix ON public.mdl_tag_instance USING btree (component, itemtype, itemid, contextid, tiuserid, tagid);


--
-- Name: mdl_taginst_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_taginst_con_ix ON public.mdl_tag_instance USING btree (contextid);


--
-- Name: mdl_taginst_itecomtagcon_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_taginst_itecomtagcon_ix ON public.mdl_tag_instance USING btree (itemtype, component, tagid, contextid);


--
-- Name: mdl_taginst_tag_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_taginst_tag_ix ON public.mdl_tag_instance USING btree (tagid);


--
-- Name: mdl_taskadho_nex_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_taskadho_nex_ix ON public.mdl_task_adhoc USING btree (nextruntime);


--
-- Name: mdl_taskadho_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_taskadho_tim_ix ON public.mdl_task_adhoc USING btree (timestarted);


--
-- Name: mdl_taskadho_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_taskadho_use_ix ON public.mdl_task_adhoc USING btree (userid);


--
-- Name: mdl_tasklog_cla_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tasklog_cla_ix ON public.mdl_task_log USING btree (classname);


--
-- Name: mdl_tasklog_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tasklog_tim_ix ON public.mdl_task_log USING btree (timestart);


--
-- Name: mdl_tasklog_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tasklog_use_ix ON public.mdl_task_log USING btree (userid);


--
-- Name: mdl_tasksche_cla_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_tasksche_cla_uix ON public.mdl_task_scheduled USING btree (classname);


--
-- Name: mdl_tinyauto_eleconusepag_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_tinyauto_eleconusepag_uix ON public.mdl_tiny_autosave USING btree (elementid, contextid, userid, pagehash);


--
-- Name: mdl_toolbricarea_cat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricarea_cat_ix ON public.mdl_tool_brickfield_areas USING btree (categoryid);


--
-- Name: mdl_toolbricarea_cmi_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricarea_cmi_ix ON public.mdl_tool_brickfield_areas USING btree (cmid);


--
-- Name: mdl_toolbricarea_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricarea_con_ix ON public.mdl_tool_brickfield_areas USING btree (contextid);


--
-- Name: mdl_toolbricarea_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricarea_cou_ix ON public.mdl_tool_brickfield_areas USING btree (courseid);


--
-- Name: mdl_toolbricarea_coucmi_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricarea_coucmi_ix ON public.mdl_tool_brickfield_areas USING btree (courseid, cmid);


--
-- Name: mdl_toolbricarea_refreftyp_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricarea_refreftyp_ix ON public.mdl_tool_brickfield_areas USING btree (reftable, refid, type);


--
-- Name: mdl_toolbricarea_typconcomf_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricarea_typconcomf_ix ON public.mdl_tool_brickfield_areas USING btree (type, contextid, component, fieldorarea, itemid);


--
-- Name: mdl_toolbricarea_typtabitef_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricarea_typtabitef_ix ON public.mdl_tool_brickfield_areas USING btree (type, tablename, itemid, fieldorarea);


--
-- Name: mdl_toolbriccachacts_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbriccachacts_cou_ix ON public.mdl_tool_brickfield_cache_acts USING btree (courseid);


--
-- Name: mdl_toolbriccachacts_sta_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbriccachacts_sta_ix ON public.mdl_tool_brickfield_cache_acts USING btree (status);


--
-- Name: mdl_toolbriccachchec_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbriccachchec_cou_ix ON public.mdl_tool_brickfield_cache_check USING btree (courseid);


--
-- Name: mdl_toolbriccachchec_err_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbriccachchec_err_ix ON public.mdl_tool_brickfield_cache_check USING btree (errorcount);


--
-- Name: mdl_toolbriccachchec_sta_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbriccachchec_sta_ix ON public.mdl_tool_brickfield_cache_check USING btree (status);


--
-- Name: mdl_toolbricchec_che2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricchec_che2_ix ON public.mdl_tool_brickfield_checks USING btree (checkgroup);


--
-- Name: mdl_toolbricchec_che_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricchec_che_ix ON public.mdl_tool_brickfield_checks USING btree (checktype);


--
-- Name: mdl_toolbricchec_sta_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricchec_sta_ix ON public.mdl_tool_brickfield_checks USING btree (status);


--
-- Name: mdl_toolbriccont_are_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbriccont_are_ix ON public.mdl_tool_brickfield_content USING btree (areaid);


--
-- Name: mdl_toolbriccont_iscare_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbriccont_iscare_ix ON public.mdl_tool_brickfield_content USING btree (iscurrent, areaid);


--
-- Name: mdl_toolbriccont_sta_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbriccont_sta_ix ON public.mdl_tool_brickfield_content USING btree (status);


--
-- Name: mdl_toolbricerro_res_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricerro_res_ix ON public.mdl_tool_brickfield_errors USING btree (resultid);


--
-- Name: mdl_toolbricproc_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricproc_tim_ix ON public.mdl_tool_brickfield_process USING btree (timecompleted);


--
-- Name: mdl_toolbricresu_che_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricresu_che_ix ON public.mdl_tool_brickfield_results USING btree (checkid);


--
-- Name: mdl_toolbricresu_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricresu_con_ix ON public.mdl_tool_brickfield_results USING btree (contentid);


--
-- Name: mdl_toolbricresu_conche_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricresu_conche_ix ON public.mdl_tool_brickfield_results USING btree (contentid, checkid);


--
-- Name: mdl_toolbricsche_conins_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_toolbricsche_conins_uix ON public.mdl_tool_brickfield_schedule USING btree (contextlevel, instanceid);


--
-- Name: mdl_toolbricsche_sta_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricsche_sta_ix ON public.mdl_tool_brickfield_schedule USING btree (status);


--
-- Name: mdl_toolbricsumm_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricsumm_cou_ix ON public.mdl_tool_brickfield_summary USING btree (courseid);


--
-- Name: mdl_toolbricsumm_sta_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolbricsumm_sta_ix ON public.mdl_tool_brickfield_summary USING btree (status);


--
-- Name: mdl_toolcoho_cohroluse_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_toolcoho_cohroluse_uix ON public.mdl_tool_cohortroles USING btree (cohortid, roleid, userid);


--
-- Name: mdl_toolcust_com_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolcust_com_ix ON public.mdl_tool_customlang USING btree (componentid);


--
-- Name: mdl_toolcust_lancomstr_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_toolcust_lancomstr_uix ON public.mdl_tool_customlang USING btree (lang, componentid, stringid);


--
-- Name: mdl_tooldatactxe_con_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_tooldatactxe_con_uix ON public.mdl_tool_dataprivacy_ctxexpired USING btree (contextid);


--
-- Name: mdl_tooldatactxi_cat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tooldatactxi_cat_ix ON public.mdl_tool_dataprivacy_ctxinstance USING btree (categoryid);


--
-- Name: mdl_tooldatactxi_con_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_tooldatactxi_con_uix ON public.mdl_tool_dataprivacy_ctxinstance USING btree (contextid);


--
-- Name: mdl_tooldatactxi_pur_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tooldatactxi_pur_ix ON public.mdl_tool_dataprivacy_ctxinstance USING btree (purposeid);


--
-- Name: mdl_tooldatactxl_cat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tooldatactxl_cat_ix ON public.mdl_tool_dataprivacy_ctxlevel USING btree (categoryid);


--
-- Name: mdl_tooldatactxl_con_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_tooldatactxl_con_uix ON public.mdl_tool_dataprivacy_ctxlevel USING btree (contextlevel);


--
-- Name: mdl_tooldatactxl_pur_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tooldatactxl_pur_ix ON public.mdl_tool_dataprivacy_ctxlevel USING btree (purposeid);


--
-- Name: mdl_tooldatactxlctx_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tooldatactxlctx_con_ix ON public.mdl_tool_dataprivacy_ctxlst_ctx USING btree (contextlistid);


--
-- Name: mdl_tooldatapurp_pur_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tooldatapurp_pur_ix ON public.mdl_tool_dataprivacy_purposerole USING btree (purposeid);


--
-- Name: mdl_tooldatapurp_purrol_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_tooldatapurp_purrol_uix ON public.mdl_tool_dataprivacy_purposerole USING btree (purposeid, roleid);


--
-- Name: mdl_tooldatapurp_rol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tooldatapurp_rol_ix ON public.mdl_tool_dataprivacy_purposerole USING btree (roleid);


--
-- Name: mdl_tooldatapurp_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tooldatapurp_use_ix ON public.mdl_tool_dataprivacy_purposerole USING btree (usermodified);


--
-- Name: mdl_tooldatarequ_dpo_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tooldatarequ_dpo_ix ON public.mdl_tool_dataprivacy_request USING btree (dpo);


--
-- Name: mdl_tooldatarequ_req_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tooldatarequ_req_ix ON public.mdl_tool_dataprivacy_request USING btree (requestedby);


--
-- Name: mdl_tooldatarequ_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tooldatarequ_use2_ix ON public.mdl_tool_dataprivacy_request USING btree (usermodified);


--
-- Name: mdl_tooldatarequ_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tooldatarequ_use_ix ON public.mdl_tool_dataprivacy_request USING btree (userid);


--
-- Name: mdl_tooldatarqstctxl_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tooldatarqstctxl_con_ix ON public.mdl_tool_dataprivacy_rqst_ctxlst USING btree (contextlistid);


--
-- Name: mdl_tooldatarqstctxl_req_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tooldatarqstctxl_req_ix ON public.mdl_tool_dataprivacy_rqst_ctxlst USING btree (requestid);


--
-- Name: mdl_tooldatarqstctxl_reqco_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_tooldatarqstctxl_reqco_uix ON public.mdl_tool_dataprivacy_rqst_ctxlst USING btree (requestid, contextlistid);


--
-- Name: mdl_toolmfa_fac_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolmfa_fac_ix ON public.mdl_tool_mfa USING btree (factor);


--
-- Name: mdl_toolmfa_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolmfa_use_ix ON public.mdl_tool_mfa USING btree (userid);


--
-- Name: mdl_toolmfa_usefacloc_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolmfa_usefacloc_ix ON public.mdl_tool_mfa USING btree (userid, factor, lockcounter);


--
-- Name: mdl_toolmfaauth_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolmfaauth_use_ix ON public.mdl_tool_mfa_auth USING btree (userid);


--
-- Name: mdl_toolmfasecr_exp_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolmfasecr_exp_ix ON public.mdl_tool_mfa_secrets USING btree (expiry);


--
-- Name: mdl_toolmfasecr_fac_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolmfasecr_fac_ix ON public.mdl_tool_mfa_secrets USING btree (factor);


--
-- Name: mdl_toolmfasecr_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolmfasecr_use_ix ON public.mdl_tool_mfa_secrets USING btree (userid);


--
-- Name: mdl_toolmonieven_con2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolmonieven_con2_ix ON public.mdl_tool_monitor_events USING btree (contextinstanceid);


--
-- Name: mdl_toolmonieven_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolmonieven_con_ix ON public.mdl_tool_monitor_events USING btree (contextid);


--
-- Name: mdl_toolmonieven_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolmonieven_cou_ix ON public.mdl_tool_monitor_events USING btree (courseid);


--
-- Name: mdl_toolmonihist_sid_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolmonihist_sid_ix ON public.mdl_tool_monitor_history USING btree (sid);


--
-- Name: mdl_toolmonihist_sidusetim_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_toolmonihist_sidusetim_uix ON public.mdl_tool_monitor_history USING btree (sid, userid, timesent);


--
-- Name: mdl_toolmonirule_couuse_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolmonirule_couuse_ix ON public.mdl_tool_monitor_rules USING btree (courseid, userid);


--
-- Name: mdl_toolmonirule_eve_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolmonirule_eve_ix ON public.mdl_tool_monitor_rules USING btree (eventname);


--
-- Name: mdl_toolmonisubs_couuse_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolmonisubs_couuse_ix ON public.mdl_tool_monitor_subscriptions USING btree (courseid, userid);


--
-- Name: mdl_toolmonisubs_rul_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolmonisubs_rul_ix ON public.mdl_tool_monitor_subscriptions USING btree (ruleid);


--
-- Name: mdl_toolpoli_cur_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolpoli_cur_ix ON public.mdl_tool_policy USING btree (currentversionid);


--
-- Name: mdl_toolpoliacce_pol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolpoliacce_pol_ix ON public.mdl_tool_policy_acceptances USING btree (policyversionid);


--
-- Name: mdl_toolpoliacce_poluse_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_toolpoliacce_poluse_uix ON public.mdl_tool_policy_acceptances USING btree (policyversionid, userid);


--
-- Name: mdl_toolpoliacce_use2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolpoliacce_use2_ix ON public.mdl_tool_policy_acceptances USING btree (usermodified);


--
-- Name: mdl_toolpoliacce_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolpoliacce_use_ix ON public.mdl_tool_policy_acceptances USING btree (userid);


--
-- Name: mdl_toolpolivers_pol_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolpolivers_pol_ix ON public.mdl_tool_policy_versions USING btree (policyid);


--
-- Name: mdl_toolpolivers_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolpolivers_use_ix ON public.mdl_tool_policy_versions USING btree (usermodified);


--
-- Name: mdl_toolrecycate_cat_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolrecycate_cat_ix ON public.mdl_tool_recyclebin_category USING btree (categoryid);


--
-- Name: mdl_toolrecycate_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolrecycate_tim_ix ON public.mdl_tool_recyclebin_category USING btree (timecreated);


--
-- Name: mdl_toolrecycour_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolrecycour_cou_ix ON public.mdl_tool_recyclebin_course USING btree (courseid);


--
-- Name: mdl_toolrecycour_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_toolrecycour_tim_ix ON public.mdl_tool_recyclebin_course USING btree (timecreated);


--
-- Name: mdl_tooluserstep_tou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tooluserstep_tou_ix ON public.mdl_tool_usertours_steps USING btree (tourid);


--
-- Name: mdl_tooluserstep_tousor_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_tooluserstep_tousor_ix ON public.mdl_tool_usertours_steps USING btree (tourid, sortorder);


--
-- Name: mdl_upgrlog_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_upgrlog_tim_ix ON public.mdl_upgrade_log USING btree (timemodified);


--
-- Name: mdl_upgrlog_typtim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_upgrlog_typtim_ix ON public.mdl_upgrade_log USING btree (type, timemodified);


--
-- Name: mdl_upgrlog_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_upgrlog_use_ix ON public.mdl_upgrade_log USING btree (userid);


--
-- Name: mdl_url_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_url_cou_ix ON public.mdl_url USING btree (course);


--
-- Name: mdl_user_alt_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_user_alt_ix ON public.mdl_user USING btree (alternatename);


--
-- Name: mdl_user_aut_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_user_aut_ix ON public.mdl_user USING btree (auth);


--
-- Name: mdl_user_cit_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_user_cit_ix ON public.mdl_user USING btree (city);


--
-- Name: mdl_user_con_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_user_con_ix ON public.mdl_user USING btree (confirmed);


--
-- Name: mdl_user_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_user_cou_ix ON public.mdl_user USING btree (country);


--
-- Name: mdl_user_del_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_user_del_ix ON public.mdl_user USING btree (deleted);


--
-- Name: mdl_user_ema_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_user_ema_ix ON public.mdl_user USING btree (email);


--
-- Name: mdl_user_fir2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_user_fir2_ix ON public.mdl_user USING btree (firstnamephonetic);


--
-- Name: mdl_user_fir_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_user_fir_ix ON public.mdl_user USING btree (firstname);


--
-- Name: mdl_user_idn_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_user_idn_ix ON public.mdl_user USING btree (idnumber);


--
-- Name: mdl_user_las2_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_user_las2_ix ON public.mdl_user USING btree (lastaccess);


--
-- Name: mdl_user_las3_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_user_las3_ix ON public.mdl_user USING btree (lastnamephonetic);


--
-- Name: mdl_user_las_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_user_las_ix ON public.mdl_user USING btree (lastname);


--
-- Name: mdl_user_mid_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_user_mid_ix ON public.mdl_user USING btree (middlename);


--
-- Name: mdl_user_mneuse_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_user_mneuse_uix ON public.mdl_user USING btree (mnethostid, username);


--
-- Name: mdl_userdevi_pususe_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_userdevi_pususe_uix ON public.mdl_user_devices USING btree (pushid, userid);


--
-- Name: mdl_userdevi_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_userdevi_use_ix ON public.mdl_user_devices USING btree (userid);


--
-- Name: mdl_userdevi_uuiuse_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_userdevi_uuiuse_ix ON public.mdl_user_devices USING btree (uuid, userid);


--
-- Name: mdl_userenro_enr_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_userenro_enr_ix ON public.mdl_user_enrolments USING btree (enrolid);


--
-- Name: mdl_userenro_enruse_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_userenro_enruse_uix ON public.mdl_user_enrolments USING btree (enrolid, userid);


--
-- Name: mdl_userenro_mod_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_userenro_mod_ix ON public.mdl_user_enrolments USING btree (modifierid);


--
-- Name: mdl_userenro_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_userenro_use_ix ON public.mdl_user_enrolments USING btree (userid);


--
-- Name: mdl_userinfodata_usefie_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_userinfodata_usefie_uix ON public.mdl_user_info_data USING btree (userid, fieldid);


--
-- Name: mdl_userlast_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_userlast_cou_ix ON public.mdl_user_lastaccess USING btree (courseid);


--
-- Name: mdl_userlast_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_userlast_use_ix ON public.mdl_user_lastaccess USING btree (userid);


--
-- Name: mdl_userlast_usecou_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_userlast_usecou_uix ON public.mdl_user_lastaccess USING btree (userid, courseid);


--
-- Name: mdl_userpasshist_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_userpasshist_use_ix ON public.mdl_user_password_history USING btree (userid);


--
-- Name: mdl_userpassrese_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_userpassrese_use_ix ON public.mdl_user_password_resets USING btree (userid);


--
-- Name: mdl_userpref_nam_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_userpref_nam_ix ON public.mdl_user_preferences USING btree (name);


--
-- Name: mdl_userpref_usenam_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_userpref_usenam_uix ON public.mdl_user_preferences USING btree (userid, name);


--
-- Name: mdl_userprivkey_scrval_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_userprivkey_scrval_ix ON public.mdl_user_private_key USING btree (script, value);


--
-- Name: mdl_userprivkey_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_userprivkey_use_ix ON public.mdl_user_private_key USING btree (userid);


--
-- Name: mdl_wiki_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_wiki_cou_ix ON public.mdl_wiki USING btree (course);


--
-- Name: mdl_wikilink_fro_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_wikilink_fro_ix ON public.mdl_wiki_links USING btree (frompageid);


--
-- Name: mdl_wikilink_sub_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_wikilink_sub_ix ON public.mdl_wiki_links USING btree (subwikiid);


--
-- Name: mdl_wikipage_sub_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_wikipage_sub_ix ON public.mdl_wiki_pages USING btree (subwikiid);


--
-- Name: mdl_wikipage_subtituse_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_wikipage_subtituse_uix ON public.mdl_wiki_pages USING btree (subwikiid, title, userid);


--
-- Name: mdl_wikisubw_wik_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_wikisubw_wik_ix ON public.mdl_wiki_subwikis USING btree (wikiid);


--
-- Name: mdl_wikisubw_wikgrouse_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_wikisubw_wikgrouse_uix ON public.mdl_wiki_subwikis USING btree (wikiid, groupid, userid);


--
-- Name: mdl_wikisyno_pagpag_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_wikisyno_pagpag_uix ON public.mdl_wiki_synonyms USING btree (pageid, pagesynonym);


--
-- Name: mdl_wikivers_pag_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_wikivers_pag_ix ON public.mdl_wiki_versions USING btree (pageid);


--
-- Name: mdl_work_cou_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_work_cou_ix ON public.mdl_workshop USING btree (course);


--
-- Name: mdl_workaccu_wor_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_workaccu_wor_ix ON public.mdl_workshopform_accumulative USING btree (workshopid);


--
-- Name: mdl_workaggr_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_workaggr_use_ix ON public.mdl_workshop_aggregations USING btree (userid);


--
-- Name: mdl_workaggr_wor_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_workaggr_wor_ix ON public.mdl_workshop_aggregations USING btree (workshopid);


--
-- Name: mdl_workaggr_woruse_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_workaggr_woruse_uix ON public.mdl_workshop_aggregations USING btree (workshopid, userid);


--
-- Name: mdl_workasse_gra_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_workasse_gra_ix ON public.mdl_workshop_assessments USING btree (gradinggradeoverby);


--
-- Name: mdl_workasse_rev_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_workasse_rev_ix ON public.mdl_workshop_assessments USING btree (reviewerid);


--
-- Name: mdl_workasse_sub_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_workasse_sub_ix ON public.mdl_workshop_assessments USING btree (submissionid);


--
-- Name: mdl_workbestsett_wor_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_workbestsett_wor_uix ON public.mdl_workshopeval_best_settings USING btree (workshopid);


--
-- Name: mdl_workcomm_wor_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_workcomm_wor_ix ON public.mdl_workshopform_comments USING btree (workshopid);


--
-- Name: mdl_workgrad_ass_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_workgrad_ass_ix ON public.mdl_workshop_grades USING btree (assessmentid);


--
-- Name: mdl_workgrad_assstrdim_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_workgrad_assstrdim_uix ON public.mdl_workshop_grades USING btree (assessmentid, strategy, dimensionid);


--
-- Name: mdl_worknume_wor_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_worknume_wor_ix ON public.mdl_workshopform_numerrors USING btree (workshopid);


--
-- Name: mdl_worknumemap_wor_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_worknumemap_wor_ix ON public.mdl_workshopform_numerrors_map USING btree (workshopid);


--
-- Name: mdl_worknumemap_wornon_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_worknumemap_wornon_uix ON public.mdl_workshopform_numerrors_map USING btree (workshopid, nonegative);


--
-- Name: mdl_workrubr_wor_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_workrubr_wor_ix ON public.mdl_workshopform_rubric USING btree (workshopid);


--
-- Name: mdl_workrubrconf_wor_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_workrubrconf_wor_uix ON public.mdl_workshopform_rubric_config USING btree (workshopid);


--
-- Name: mdl_workrubrleve_dim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_workrubrleve_dim_ix ON public.mdl_workshopform_rubric_levels USING btree (dimensionid);


--
-- Name: mdl_worksche_wor_uix; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mdl_worksche_wor_uix ON public.mdl_workshopallocation_scheduled USING btree (workshopid);


--
-- Name: mdl_worksubm_aut_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_worksubm_aut_ix ON public.mdl_workshop_submissions USING btree (authorid);


--
-- Name: mdl_worksubm_gra_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_worksubm_gra_ix ON public.mdl_workshop_submissions USING btree (gradeoverby);


--
-- Name: mdl_worksubm_wor_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_worksubm_wor_ix ON public.mdl_workshop_submissions USING btree (workshopid);


--
-- Name: mdl_xapistat_comite_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_xapistat_comite_ix ON public.mdl_xapi_states USING btree (component, itemid);


--
-- Name: mdl_xapistat_tim_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_xapistat_tim_ix ON public.mdl_xapi_states USING btree (timemodified);


--
-- Name: mdl_xapistat_use_ix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mdl_xapistat_use_ix ON public.mdl_xapi_states USING btree (userid);


--
-- PostgreSQL database dump complete
--


