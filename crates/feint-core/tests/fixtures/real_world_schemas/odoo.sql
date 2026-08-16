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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auth_totp_device; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_totp_device (
    id integer NOT NULL,
    name character varying NOT NULL,
    user_id integer NOT NULL,
    scope character varying,
    index character varying(8),
    key character varying,
    create_date timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
    CONSTRAINT auth_totp_device_index_check CHECK ((char_length((index)::text) = 8))
);


--
-- Name: auth_totp_device_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auth_totp_device_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auth_totp_device_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.auth_totp_device_id_seq OWNED BY public.auth_totp_device.id;


--
-- Name: auth_totp_wizard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_totp_wizard (
    id integer NOT NULL,
    user_id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    secret character varying NOT NULL,
    url character varying,
    code character varying(7),
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    qrcode bytea
);


--
-- Name: TABLE auth_totp_wizard; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.auth_totp_wizard IS '2-Factor Setup Wizard';


--
-- Name: COLUMN auth_totp_wizard.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.auth_totp_wizard.user_id IS 'User';


--
-- Name: COLUMN auth_totp_wizard.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.auth_totp_wizard.create_uid IS 'Created by';


--
-- Name: COLUMN auth_totp_wizard.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.auth_totp_wizard.write_uid IS 'Last Updated by';


--
-- Name: COLUMN auth_totp_wizard.secret; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.auth_totp_wizard.secret IS 'Secret';


--
-- Name: COLUMN auth_totp_wizard.url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.auth_totp_wizard.url IS 'Url';


--
-- Name: COLUMN auth_totp_wizard.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.auth_totp_wizard.code IS 'Verification Code';


--
-- Name: COLUMN auth_totp_wizard.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.auth_totp_wizard.create_date IS 'Created on';


--
-- Name: COLUMN auth_totp_wizard.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.auth_totp_wizard.write_date IS 'Last Updated on';


--
-- Name: COLUMN auth_totp_wizard.qrcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.auth_totp_wizard.qrcode IS 'Qrcode';


--
-- Name: auth_totp_wizard_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auth_totp_wizard_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auth_totp_wizard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.auth_totp_wizard_id_seq OWNED BY public.auth_totp_wizard.id;


--
-- Name: base_cache_signaling_assets; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_cache_signaling_assets
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_cache_signaling_default; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_cache_signaling_default
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_cache_signaling_routing; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_cache_signaling_routing
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_cache_signaling_templates; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_cache_signaling_templates
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_document_layout; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_document_layout (
    id integer NOT NULL,
    company_id integer NOT NULL,
    report_layout_id integer,
    create_uid integer,
    write_uid integer,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE base_document_layout; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.base_document_layout IS 'Company Document Layout';


--
-- Name: COLUMN base_document_layout.company_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_document_layout.company_id IS 'Company';


--
-- Name: COLUMN base_document_layout.report_layout_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_document_layout.report_layout_id IS 'Report Layout';


--
-- Name: COLUMN base_document_layout.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_document_layout.create_uid IS 'Created by';


--
-- Name: COLUMN base_document_layout.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_document_layout.write_uid IS 'Last Updated by';


--
-- Name: COLUMN base_document_layout.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_document_layout.create_date IS 'Created on';


--
-- Name: COLUMN base_document_layout.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_document_layout.write_date IS 'Last Updated on';


--
-- Name: base_document_layout_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_document_layout_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_document_layout_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.base_document_layout_id_seq OWNED BY public.base_document_layout.id;


--
-- Name: base_enable_profiling_wizard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_enable_profiling_wizard (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    duration character varying,
    expiration timestamp without time zone,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE base_enable_profiling_wizard; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.base_enable_profiling_wizard IS 'Enable profiling for some time';


--
-- Name: COLUMN base_enable_profiling_wizard.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_enable_profiling_wizard.create_uid IS 'Created by';


--
-- Name: COLUMN base_enable_profiling_wizard.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_enable_profiling_wizard.write_uid IS 'Last Updated by';


--
-- Name: COLUMN base_enable_profiling_wizard.duration; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_enable_profiling_wizard.duration IS 'Enable profiling for';


--
-- Name: COLUMN base_enable_profiling_wizard.expiration; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_enable_profiling_wizard.expiration IS 'Enable profiling until';


--
-- Name: COLUMN base_enable_profiling_wizard.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_enable_profiling_wizard.create_date IS 'Created on';


--
-- Name: COLUMN base_enable_profiling_wizard.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_enable_profiling_wizard.write_date IS 'Last Updated on';


--
-- Name: base_enable_profiling_wizard_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_enable_profiling_wizard_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_enable_profiling_wizard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.base_enable_profiling_wizard_id_seq OWNED BY public.base_enable_profiling_wizard.id;


--
-- Name: base_import_import; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_import_import (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    res_model character varying,
    file_name character varying,
    file_type character varying,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    file bytea
);


--
-- Name: TABLE base_import_import; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.base_import_import IS 'Base Import';


--
-- Name: COLUMN base_import_import.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_import.create_uid IS 'Created by';


--
-- Name: COLUMN base_import_import.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_import.write_uid IS 'Last Updated by';


--
-- Name: COLUMN base_import_import.res_model; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_import.res_model IS 'Model';


--
-- Name: COLUMN base_import_import.file_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_import.file_name IS 'File Name';


--
-- Name: COLUMN base_import_import.file_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_import.file_type IS 'File Type';


--
-- Name: COLUMN base_import_import.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_import.create_date IS 'Created on';


--
-- Name: COLUMN base_import_import.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_import.write_date IS 'Last Updated on';


--
-- Name: COLUMN base_import_import.file; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_import.file IS 'File';


--
-- Name: base_import_import_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_import_import_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_import_import_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.base_import_import_id_seq OWNED BY public.base_import_import.id;


--
-- Name: base_import_mapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_import_mapping (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    res_model character varying,
    column_name character varying,
    field_name character varying,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE base_import_mapping; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.base_import_mapping IS 'Base Import Mapping';


--
-- Name: COLUMN base_import_mapping.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_mapping.create_uid IS 'Created by';


--
-- Name: COLUMN base_import_mapping.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_mapping.write_uid IS 'Last Updated by';


--
-- Name: COLUMN base_import_mapping.res_model; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_mapping.res_model IS 'Res Model';


--
-- Name: COLUMN base_import_mapping.column_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_mapping.column_name IS 'Column Name';


--
-- Name: COLUMN base_import_mapping.field_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_mapping.field_name IS 'Field Name';


--
-- Name: COLUMN base_import_mapping.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_mapping.create_date IS 'Created on';


--
-- Name: COLUMN base_import_mapping.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_mapping.write_date IS 'Last Updated on';


--
-- Name: base_import_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_import_mapping_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_import_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.base_import_mapping_id_seq OWNED BY public.base_import_mapping.id;


--
-- Name: base_import_module; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_import_module (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    state character varying,
    import_message text,
    modules_dependencies text,
    force boolean,
    with_demo boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    module_file bytea NOT NULL
);


--
-- Name: TABLE base_import_module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.base_import_module IS 'Import Module';


--
-- Name: COLUMN base_import_module.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_module.create_uid IS 'Created by';


--
-- Name: COLUMN base_import_module.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_module.write_uid IS 'Last Updated by';


--
-- Name: COLUMN base_import_module.state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_module.state IS 'Status';


--
-- Name: COLUMN base_import_module.import_message; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_module.import_message IS 'Import Message';


--
-- Name: COLUMN base_import_module.modules_dependencies; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_module.modules_dependencies IS 'Modules Dependencies';


--
-- Name: COLUMN base_import_module.force; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_module.force IS 'Force init';


--
-- Name: COLUMN base_import_module.with_demo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_module.with_demo IS 'Import demo data of module';


--
-- Name: COLUMN base_import_module.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_module.create_date IS 'Created on';


--
-- Name: COLUMN base_import_module.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_module.write_date IS 'Last Updated on';


--
-- Name: COLUMN base_import_module.module_file; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_import_module.module_file IS 'Module .ZIP file';


--
-- Name: base_import_module_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_import_module_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_import_module_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.base_import_module_id_seq OWNED BY public.base_import_module.id;


--
-- Name: base_language_export; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_language_export (
    id integer NOT NULL,
    model_id integer,
    create_uid integer,
    write_uid integer,
    name character varying,
    lang character varying NOT NULL,
    format character varying NOT NULL,
    export_type character varying NOT NULL,
    domain character varying,
    state character varying,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    data bytea
);


--
-- Name: TABLE base_language_export; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.base_language_export IS 'Language Export';


--
-- Name: COLUMN base_language_export.model_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_export.model_id IS 'Model to Export';


--
-- Name: COLUMN base_language_export.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_export.create_uid IS 'Created by';


--
-- Name: COLUMN base_language_export.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_export.write_uid IS 'Last Updated by';


--
-- Name: COLUMN base_language_export.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_export.name IS 'File Name';


--
-- Name: COLUMN base_language_export.lang; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_export.lang IS 'Language';


--
-- Name: COLUMN base_language_export.format; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_export.format IS 'File Format';


--
-- Name: COLUMN base_language_export.export_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_export.export_type IS 'Export Type';


--
-- Name: COLUMN base_language_export.domain; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_export.domain IS 'Model Domain';


--
-- Name: COLUMN base_language_export.state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_export.state IS 'State';


--
-- Name: COLUMN base_language_export.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_export.create_date IS 'Created on';


--
-- Name: COLUMN base_language_export.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_export.write_date IS 'Last Updated on';


--
-- Name: COLUMN base_language_export.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_export.data IS 'File';


--
-- Name: base_language_export_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_language_export_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_language_export_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.base_language_export_id_seq OWNED BY public.base_language_export.id;


--
-- Name: base_language_import; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_language_import (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    code character varying(6) NOT NULL,
    filename character varying NOT NULL,
    overwrite boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    data bytea NOT NULL
);


--
-- Name: TABLE base_language_import; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.base_language_import IS 'Language Import';


--
-- Name: COLUMN base_language_import.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_import.create_uid IS 'Created by';


--
-- Name: COLUMN base_language_import.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_import.write_uid IS 'Last Updated by';


--
-- Name: COLUMN base_language_import.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_import.name IS 'Language Name';


--
-- Name: COLUMN base_language_import.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_import.code IS 'ISO Code';


--
-- Name: COLUMN base_language_import.filename; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_import.filename IS 'File Name';


--
-- Name: COLUMN base_language_import.overwrite; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_import.overwrite IS 'Overwrite Existing Terms';


--
-- Name: COLUMN base_language_import.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_import.create_date IS 'Created on';


--
-- Name: COLUMN base_language_import.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_import.write_date IS 'Last Updated on';


--
-- Name: COLUMN base_language_import.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_import.data IS 'File';


--
-- Name: base_language_import_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_language_import_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_language_import_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.base_language_import_id_seq OWNED BY public.base_language_import.id;


--
-- Name: base_language_install; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_language_install (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    overwrite boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE base_language_install; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.base_language_install IS 'Install Language';


--
-- Name: COLUMN base_language_install.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_install.create_uid IS 'Created by';


--
-- Name: COLUMN base_language_install.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_install.write_uid IS 'Last Updated by';


--
-- Name: COLUMN base_language_install.overwrite; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_install.overwrite IS 'Overwrite Existing Terms';


--
-- Name: COLUMN base_language_install.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_install.create_date IS 'Created on';


--
-- Name: COLUMN base_language_install.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_language_install.write_date IS 'Last Updated on';


--
-- Name: base_language_install_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_language_install_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_language_install_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.base_language_install_id_seq OWNED BY public.base_language_install.id;


--
-- Name: base_module_uninstall; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_module_uninstall (
    id integer NOT NULL,
    module_id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    show_all boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE base_module_uninstall; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.base_module_uninstall IS 'Module Uninstall';


--
-- Name: COLUMN base_module_uninstall.module_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_uninstall.module_id IS 'Module';


--
-- Name: COLUMN base_module_uninstall.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_uninstall.create_uid IS 'Created by';


--
-- Name: COLUMN base_module_uninstall.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_uninstall.write_uid IS 'Last Updated by';


--
-- Name: COLUMN base_module_uninstall.show_all; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_uninstall.show_all IS 'Show All';


--
-- Name: COLUMN base_module_uninstall.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_uninstall.create_date IS 'Created on';


--
-- Name: COLUMN base_module_uninstall.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_uninstall.write_date IS 'Last Updated on';


--
-- Name: base_module_uninstall_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_module_uninstall_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_module_uninstall_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.base_module_uninstall_id_seq OWNED BY public.base_module_uninstall.id;


--
-- Name: base_module_update; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_module_update (
    id integer NOT NULL,
    updated integer,
    added integer,
    create_uid integer,
    write_uid integer,
    state character varying,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE base_module_update; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.base_module_update IS 'Update Module';


--
-- Name: COLUMN base_module_update.updated; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_update.updated IS 'Number of modules updated';


--
-- Name: COLUMN base_module_update.added; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_update.added IS 'Number of modules added';


--
-- Name: COLUMN base_module_update.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_update.create_uid IS 'Created by';


--
-- Name: COLUMN base_module_update.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_update.write_uid IS 'Last Updated by';


--
-- Name: COLUMN base_module_update.state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_update.state IS 'Status';


--
-- Name: COLUMN base_module_update.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_update.create_date IS 'Created on';


--
-- Name: COLUMN base_module_update.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_update.write_date IS 'Last Updated on';


--
-- Name: base_module_update_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_module_update_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_module_update_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.base_module_update_id_seq OWNED BY public.base_module_update.id;


--
-- Name: base_module_upgrade; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_module_upgrade (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    module_info text,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE base_module_upgrade; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.base_module_upgrade IS 'Upgrade Module';


--
-- Name: COLUMN base_module_upgrade.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_upgrade.create_uid IS 'Created by';


--
-- Name: COLUMN base_module_upgrade.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_upgrade.write_uid IS 'Last Updated by';


--
-- Name: COLUMN base_module_upgrade.module_info; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_upgrade.module_info IS 'Apps to Update';


--
-- Name: COLUMN base_module_upgrade.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_upgrade.create_date IS 'Created on';


--
-- Name: COLUMN base_module_upgrade.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_module_upgrade.write_date IS 'Last Updated on';


--
-- Name: base_module_upgrade_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_module_upgrade_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_module_upgrade_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.base_module_upgrade_id_seq OWNED BY public.base_module_upgrade.id;


--
-- Name: base_partner_merge_automatic_wizard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_partner_merge_automatic_wizard (
    id integer NOT NULL,
    number_group integer,
    current_line_id integer,
    dst_partner_id integer,
    maximum_group integer,
    create_uid integer,
    write_uid integer,
    state character varying NOT NULL,
    group_by_email boolean,
    group_by_name boolean,
    group_by_is_company boolean,
    group_by_vat boolean,
    group_by_parent_id boolean,
    exclude_contact boolean,
    exclude_journal_item boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE base_partner_merge_automatic_wizard; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.base_partner_merge_automatic_wizard IS 'Merge Partner Wizard';


--
-- Name: COLUMN base_partner_merge_automatic_wizard.number_group; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_automatic_wizard.number_group IS 'Group of Contacts';


--
-- Name: COLUMN base_partner_merge_automatic_wizard.current_line_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_automatic_wizard.current_line_id IS 'Current Line';


--
-- Name: COLUMN base_partner_merge_automatic_wizard.dst_partner_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_automatic_wizard.dst_partner_id IS 'Destination Contact';


--
-- Name: COLUMN base_partner_merge_automatic_wizard.maximum_group; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_automatic_wizard.maximum_group IS 'Maximum of Group of Contacts';


--
-- Name: COLUMN base_partner_merge_automatic_wizard.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_automatic_wizard.create_uid IS 'Created by';


--
-- Name: COLUMN base_partner_merge_automatic_wizard.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_automatic_wizard.write_uid IS 'Last Updated by';


--
-- Name: COLUMN base_partner_merge_automatic_wizard.state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_automatic_wizard.state IS 'State';


--
-- Name: COLUMN base_partner_merge_automatic_wizard.group_by_email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_automatic_wizard.group_by_email IS 'Email';


--
-- Name: COLUMN base_partner_merge_automatic_wizard.group_by_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_automatic_wizard.group_by_name IS 'Name';


--
-- Name: COLUMN base_partner_merge_automatic_wizard.group_by_is_company; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_automatic_wizard.group_by_is_company IS 'Is Company';


--
-- Name: COLUMN base_partner_merge_automatic_wizard.group_by_vat; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_automatic_wizard.group_by_vat IS 'VAT';


--
-- Name: COLUMN base_partner_merge_automatic_wizard.group_by_parent_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_automatic_wizard.group_by_parent_id IS 'Parent Company';


--
-- Name: COLUMN base_partner_merge_automatic_wizard.exclude_contact; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_automatic_wizard.exclude_contact IS 'A user associated to the contact';


--
-- Name: COLUMN base_partner_merge_automatic_wizard.exclude_journal_item; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_automatic_wizard.exclude_journal_item IS 'Journal Items associated to the contact';


--
-- Name: COLUMN base_partner_merge_automatic_wizard.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_automatic_wizard.create_date IS 'Created on';


--
-- Name: COLUMN base_partner_merge_automatic_wizard.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_automatic_wizard.write_date IS 'Last Updated on';


--
-- Name: base_partner_merge_automatic_wizard_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_partner_merge_automatic_wizard_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_partner_merge_automatic_wizard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.base_partner_merge_automatic_wizard_id_seq OWNED BY public.base_partner_merge_automatic_wizard.id;


--
-- Name: base_partner_merge_automatic_wizard_res_partner_rel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_partner_merge_automatic_wizard_res_partner_rel (
    base_partner_merge_automatic_wizard_id integer NOT NULL,
    res_partner_id integer NOT NULL
);


--
-- Name: TABLE base_partner_merge_automatic_wizard_res_partner_rel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.base_partner_merge_automatic_wizard_res_partner_rel IS 'RELATION BETWEEN base_partner_merge_automatic_wizard AND res_partner';


--
-- Name: base_partner_merge_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_partner_merge_line (
    id integer NOT NULL,
    wizard_id integer,
    min_id integer,
    create_uid integer,
    write_uid integer,
    aggr_ids character varying NOT NULL,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE base_partner_merge_line; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.base_partner_merge_line IS 'Merge Partner Line';


--
-- Name: COLUMN base_partner_merge_line.wizard_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_line.wizard_id IS 'Wizard';


--
-- Name: COLUMN base_partner_merge_line.min_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_line.min_id IS 'MinID';


--
-- Name: COLUMN base_partner_merge_line.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_line.create_uid IS 'Created by';


--
-- Name: COLUMN base_partner_merge_line.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_line.write_uid IS 'Last Updated by';


--
-- Name: COLUMN base_partner_merge_line.aggr_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_line.aggr_ids IS 'Ids';


--
-- Name: COLUMN base_partner_merge_line.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_line.create_date IS 'Created on';


--
-- Name: COLUMN base_partner_merge_line.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.base_partner_merge_line.write_date IS 'Last Updated on';


--
-- Name: base_partner_merge_line_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_partner_merge_line_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: base_partner_merge_line_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.base_partner_merge_line_id_seq OWNED BY public.base_partner_merge_line.id;


--
-- Name: base_registry_signaling; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.base_registry_signaling
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bus_bus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bus_bus (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    channel character varying,
    message character varying,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE bus_bus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.bus_bus IS 'Communication Bus';


--
-- Name: COLUMN bus_bus.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.bus_bus.create_uid IS 'Created by';


--
-- Name: COLUMN bus_bus.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.bus_bus.write_uid IS 'Last Updated by';


--
-- Name: COLUMN bus_bus.channel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.bus_bus.channel IS 'Channel';


--
-- Name: COLUMN bus_bus.message; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.bus_bus.message IS 'Message';


--
-- Name: COLUMN bus_bus.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.bus_bus.create_date IS 'Created on';


--
-- Name: COLUMN bus_bus.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.bus_bus.write_date IS 'Last Updated on';


--
-- Name: bus_bus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bus_bus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bus_bus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bus_bus_id_seq OWNED BY public.bus_bus.id;


--
-- Name: bus_presence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bus_presence (
    id integer NOT NULL,
    user_id integer,
    status character varying,
    last_poll timestamp without time zone,
    last_presence timestamp without time zone
);


--
-- Name: TABLE bus_presence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.bus_presence IS 'User Presence';


--
-- Name: COLUMN bus_presence.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.bus_presence.user_id IS 'Users';


--
-- Name: COLUMN bus_presence.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.bus_presence.status IS 'IM Status';


--
-- Name: COLUMN bus_presence.last_poll; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.bus_presence.last_poll IS 'Last Poll';


--
-- Name: COLUMN bus_presence.last_presence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.bus_presence.last_presence IS 'Last Presence';


--
-- Name: bus_presence_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bus_presence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bus_presence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bus_presence_id_seq OWNED BY public.bus_presence.id;


--
-- Name: change_password_own; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.change_password_own (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    new_password character varying,
    confirm_password character varying,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE change_password_own; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.change_password_own IS 'User, change own password wizard';


--
-- Name: COLUMN change_password_own.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_own.create_uid IS 'Created by';


--
-- Name: COLUMN change_password_own.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_own.write_uid IS 'Last Updated by';


--
-- Name: COLUMN change_password_own.new_password; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_own.new_password IS 'New Password';


--
-- Name: COLUMN change_password_own.confirm_password; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_own.confirm_password IS 'New Password (Confirmation)';


--
-- Name: COLUMN change_password_own.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_own.create_date IS 'Created on';


--
-- Name: COLUMN change_password_own.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_own.write_date IS 'Last Updated on';


--
-- Name: change_password_own_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.change_password_own_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_password_own_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.change_password_own_id_seq OWNED BY public.change_password_own.id;


--
-- Name: change_password_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.change_password_user (
    id integer NOT NULL,
    wizard_id integer NOT NULL,
    user_id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    user_login character varying,
    new_passwd character varying,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE change_password_user; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.change_password_user IS 'User, Change Password Wizard';


--
-- Name: COLUMN change_password_user.wizard_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_user.wizard_id IS 'Wizard';


--
-- Name: COLUMN change_password_user.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_user.user_id IS 'User';


--
-- Name: COLUMN change_password_user.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_user.create_uid IS 'Created by';


--
-- Name: COLUMN change_password_user.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_user.write_uid IS 'Last Updated by';


--
-- Name: COLUMN change_password_user.user_login; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_user.user_login IS 'User Login';


--
-- Name: COLUMN change_password_user.new_passwd; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_user.new_passwd IS 'New Password';


--
-- Name: COLUMN change_password_user.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_user.create_date IS 'Created on';


--
-- Name: COLUMN change_password_user.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_user.write_date IS 'Last Updated on';


--
-- Name: change_password_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.change_password_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_password_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.change_password_user_id_seq OWNED BY public.change_password_user.id;


--
-- Name: change_password_wizard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.change_password_wizard (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE change_password_wizard; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.change_password_wizard IS 'Change Password Wizard';


--
-- Name: COLUMN change_password_wizard.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_wizard.create_uid IS 'Created by';


--
-- Name: COLUMN change_password_wizard.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_wizard.write_uid IS 'Last Updated by';


--
-- Name: COLUMN change_password_wizard.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_wizard.create_date IS 'Created on';


--
-- Name: COLUMN change_password_wizard.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.change_password_wizard.write_date IS 'Last Updated on';


--
-- Name: change_password_wizard_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.change_password_wizard_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_password_wizard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.change_password_wizard_id_seq OWNED BY public.change_password_wizard.id;


--
-- Name: decimal_precision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.decimal_precision (
    id integer NOT NULL,
    digits integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE decimal_precision; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.decimal_precision IS 'Decimal Precision';


--
-- Name: COLUMN decimal_precision.digits; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.decimal_precision.digits IS 'Digits';


--
-- Name: COLUMN decimal_precision.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.decimal_precision.create_uid IS 'Created by';


--
-- Name: COLUMN decimal_precision.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.decimal_precision.write_uid IS 'Last Updated by';


--
-- Name: COLUMN decimal_precision.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.decimal_precision.name IS 'Usage';


--
-- Name: COLUMN decimal_precision.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.decimal_precision.create_date IS 'Created on';


--
-- Name: COLUMN decimal_precision.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.decimal_precision.write_date IS 'Last Updated on';


--
-- Name: decimal_precision_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.decimal_precision_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: decimal_precision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.decimal_precision_id_seq OWNED BY public.decimal_precision.id;


--
-- Name: iap_account; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.iap_account (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name character varying,
    service_name character varying,
    account_token character varying(43),
    show_token boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE iap_account; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.iap_account IS 'IAP Account';


--
-- Name: COLUMN iap_account.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account.create_uid IS 'Created by';


--
-- Name: COLUMN iap_account.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account.write_uid IS 'Last Updated by';


--
-- Name: COLUMN iap_account.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account.name IS 'Name';


--
-- Name: COLUMN iap_account.service_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account.service_name IS 'Service Name';


--
-- Name: COLUMN iap_account.account_token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account.account_token IS 'Account Token';


--
-- Name: COLUMN iap_account.show_token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account.show_token IS 'Show Token';


--
-- Name: COLUMN iap_account.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account.create_date IS 'Created on';


--
-- Name: COLUMN iap_account.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account.write_date IS 'Last Updated on';


--
-- Name: iap_account_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.iap_account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: iap_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.iap_account_id_seq OWNED BY public.iap_account.id;


--
-- Name: iap_account_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.iap_account_info (
    id integer NOT NULL,
    account_id integer,
    create_uid integer,
    write_uid integer,
    account_token character varying,
    account_uuid_hashed character varying,
    service_name character varying,
    description character varying,
    warning_email character varying,
    unit_name character varying,
    balance numeric,
    warn_me boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    warning_threshold double precision
);


--
-- Name: TABLE iap_account_info; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.iap_account_info IS 'IAP Account Info';


--
-- Name: COLUMN iap_account_info.account_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account_info.account_id IS 'IAP Account';


--
-- Name: COLUMN iap_account_info.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account_info.create_uid IS 'Created by';


--
-- Name: COLUMN iap_account_info.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account_info.write_uid IS 'Last Updated by';


--
-- Name: COLUMN iap_account_info.account_token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account_info.account_token IS 'Account Token';


--
-- Name: COLUMN iap_account_info.account_uuid_hashed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account_info.account_uuid_hashed IS 'Account UUID';


--
-- Name: COLUMN iap_account_info.service_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account_info.service_name IS 'Related Service';


--
-- Name: COLUMN iap_account_info.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account_info.description IS 'Description';


--
-- Name: COLUMN iap_account_info.warning_email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account_info.warning_email IS 'Warning Email';


--
-- Name: COLUMN iap_account_info.unit_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account_info.unit_name IS 'Unit Name';


--
-- Name: COLUMN iap_account_info.balance; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account_info.balance IS 'Balance';


--
-- Name: COLUMN iap_account_info.warn_me; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account_info.warn_me IS 'Warn me';


--
-- Name: COLUMN iap_account_info.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account_info.create_date IS 'Created on';


--
-- Name: COLUMN iap_account_info.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account_info.write_date IS 'Last Updated on';


--
-- Name: COLUMN iap_account_info.warning_threshold; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.iap_account_info.warning_threshold IS 'Threshold';


--
-- Name: iap_account_info_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.iap_account_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: iap_account_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.iap_account_info_id_seq OWNED BY public.iap_account_info.id;


--
-- Name: iap_account_res_company_rel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.iap_account_res_company_rel (
    iap_account_id integer NOT NULL,
    res_company_id integer NOT NULL
);


--
-- Name: TABLE iap_account_res_company_rel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.iap_account_res_company_rel IS 'RELATION BETWEEN iap_account AND res_company';


--
-- Name: ir_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_actions (
    id integer NOT NULL,
    binding_model_id integer,
    create_uid integer,
    write_uid integer,
    type character varying NOT NULL,
    binding_type character varying NOT NULL,
    binding_view_types character varying,
    name jsonb NOT NULL,
    help jsonb,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: COLUMN ir_actions.binding_model_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions.binding_model_id IS 'Binding Model';


--
-- Name: COLUMN ir_actions.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions.create_uid IS 'Created by';


--
-- Name: COLUMN ir_actions.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_actions.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions.type IS 'Action Type';


--
-- Name: COLUMN ir_actions.binding_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions.binding_type IS 'Binding Type';


--
-- Name: COLUMN ir_actions.binding_view_types; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions.binding_view_types IS 'Binding View Types';


--
-- Name: COLUMN ir_actions.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions.name IS 'Action Name';


--
-- Name: COLUMN ir_actions.help; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions.help IS 'Action Description';


--
-- Name: COLUMN ir_actions.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions.create_date IS 'Created on';


--
-- Name: COLUMN ir_actions.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions.write_date IS 'Last Updated on';


--
-- Name: ir_act_client; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_act_client (
    tag character varying NOT NULL,
    target character varying,
    res_model character varying,
    context character varying NOT NULL,
    params_store bytea
)
INHERITS (public.ir_actions);


--
-- Name: COLUMN ir_act_client.tag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_client.tag IS 'Client action tag';


--
-- Name: COLUMN ir_act_client.target; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_client.target IS 'Target Window';


--
-- Name: COLUMN ir_act_client.res_model; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_client.res_model IS 'Destination Model';


--
-- Name: COLUMN ir_act_client.context; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_client.context IS 'Context Value';


--
-- Name: COLUMN ir_act_client.params_store; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_client.params_store IS 'Params storage';


--
-- Name: ir_act_report_xml; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_act_report_xml (
    paperformat_id integer,
    model character varying NOT NULL,
    report_type character varying NOT NULL,
    report_name character varying NOT NULL,
    report_file character varying,
    attachment character varying,
    print_report_name jsonb,
    multi boolean,
    attachment_use boolean
)
INHERITS (public.ir_actions);


--
-- Name: COLUMN ir_act_report_xml.paperformat_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_report_xml.paperformat_id IS 'Paper Format';


--
-- Name: COLUMN ir_act_report_xml.model; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_report_xml.model IS 'Model Name';


--
-- Name: COLUMN ir_act_report_xml.report_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_report_xml.report_type IS 'Report Type';


--
-- Name: COLUMN ir_act_report_xml.report_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_report_xml.report_name IS 'Template Name';


--
-- Name: COLUMN ir_act_report_xml.report_file; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_report_xml.report_file IS 'Report File';


--
-- Name: COLUMN ir_act_report_xml.attachment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_report_xml.attachment IS 'Save as Attachment Prefix';


--
-- Name: COLUMN ir_act_report_xml.print_report_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_report_xml.print_report_name IS 'Printed Report Name';


--
-- Name: COLUMN ir_act_report_xml.multi; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_report_xml.multi IS 'On Multiple Doc.';


--
-- Name: COLUMN ir_act_report_xml.attachment_use; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_report_xml.attachment_use IS 'Reload from Attachment';


--
-- Name: ir_act_server; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_act_server (
    sequence integer,
    model_id integer NOT NULL,
    crud_model_id integer,
    link_field_id integer,
    update_field_id integer,
    update_related_model_id integer,
    selection_value integer,
    usage character varying NOT NULL,
    state character varying NOT NULL,
    model_name character varying,
    update_path character varying,
    update_m2m_operation character varying,
    update_boolean_value character varying,
    evaluation_type character varying,
    resource_ref character varying,
    webhook_url character varying,
    code text,
    value text
)
INHERITS (public.ir_actions);


--
-- Name: COLUMN ir_act_server.sequence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.sequence IS 'Sequence';


--
-- Name: COLUMN ir_act_server.model_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.model_id IS 'Model';


--
-- Name: COLUMN ir_act_server.crud_model_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.crud_model_id IS 'Record to Create';


--
-- Name: COLUMN ir_act_server.link_field_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.link_field_id IS 'Link Field';


--
-- Name: COLUMN ir_act_server.update_field_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.update_field_id IS 'Field to Update';


--
-- Name: COLUMN ir_act_server.update_related_model_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.update_related_model_id IS 'Update Related Model';


--
-- Name: COLUMN ir_act_server.selection_value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.selection_value IS 'Custom Value';


--
-- Name: COLUMN ir_act_server.usage; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.usage IS 'Usage';


--
-- Name: COLUMN ir_act_server.state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.state IS 'Type';


--
-- Name: COLUMN ir_act_server.model_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.model_name IS 'Model Name';


--
-- Name: COLUMN ir_act_server.update_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.update_path IS 'Field to Update Path';


--
-- Name: COLUMN ir_act_server.update_m2m_operation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.update_m2m_operation IS 'Many2many Operations';


--
-- Name: COLUMN ir_act_server.update_boolean_value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.update_boolean_value IS 'Boolean Value';


--
-- Name: COLUMN ir_act_server.evaluation_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.evaluation_type IS 'Value Type';


--
-- Name: COLUMN ir_act_server.resource_ref; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.resource_ref IS 'Record';


--
-- Name: COLUMN ir_act_server.webhook_url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.webhook_url IS 'Webhook URL';


--
-- Name: COLUMN ir_act_server.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.code IS 'Python Code';


--
-- Name: COLUMN ir_act_server.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_server.value IS 'Value';


--
-- Name: ir_act_server_group_rel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_act_server_group_rel (
    act_id integer NOT NULL,
    gid integer NOT NULL
);


--
-- Name: TABLE ir_act_server_group_rel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_act_server_group_rel IS 'RELATION BETWEEN ir_act_server AND res_groups';


--
-- Name: ir_act_server_webhook_field_rel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_act_server_webhook_field_rel (
    server_id integer NOT NULL,
    field_id integer NOT NULL
);


--
-- Name: TABLE ir_act_server_webhook_field_rel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_act_server_webhook_field_rel IS 'RELATION BETWEEN ir_act_server AND ir_model_fields';


--
-- Name: ir_act_url; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_act_url (
    target character varying NOT NULL,
    url text NOT NULL
)
INHERITS (public.ir_actions);


--
-- Name: COLUMN ir_act_url.target; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_url.target IS 'Action Target';


--
-- Name: COLUMN ir_act_url.url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_url.url IS 'Action URL';


--
-- Name: ir_act_window; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_act_window (
    view_id integer,
    res_id integer,
    "limit" integer,
    search_view_id integer,
    domain character varying,
    context character varying NOT NULL,
    res_model character varying NOT NULL,
    target character varying,
    view_mode character varying NOT NULL,
    mobile_view_mode character varying,
    usage character varying,
    filter boolean
)
INHERITS (public.ir_actions);


--
-- Name: COLUMN ir_act_window.view_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window.view_id IS 'View Ref.';


--
-- Name: COLUMN ir_act_window.res_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window.res_id IS 'Record ID';


--
-- Name: COLUMN ir_act_window."limit"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window."limit" IS 'Limit';


--
-- Name: COLUMN ir_act_window.search_view_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window.search_view_id IS 'Search View Ref.';


--
-- Name: COLUMN ir_act_window.domain; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window.domain IS 'Domain Value';


--
-- Name: COLUMN ir_act_window.context; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window.context IS 'Context Value';


--
-- Name: COLUMN ir_act_window.res_model; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window.res_model IS 'Destination Model';


--
-- Name: COLUMN ir_act_window.target; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window.target IS 'Target Window';


--
-- Name: COLUMN ir_act_window.view_mode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window.view_mode IS 'View Mode';


--
-- Name: COLUMN ir_act_window.mobile_view_mode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window.mobile_view_mode IS 'Mobile View Mode';


--
-- Name: COLUMN ir_act_window.usage; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window.usage IS 'Action Usage';


--
-- Name: COLUMN ir_act_window.filter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window.filter IS 'Filter';


--
-- Name: ir_act_window_group_rel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_act_window_group_rel (
    act_id integer NOT NULL,
    gid integer NOT NULL
);


--
-- Name: TABLE ir_act_window_group_rel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_act_window_group_rel IS 'RELATION BETWEEN ir_act_window AND res_groups';


--
-- Name: ir_act_window_view; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_act_window_view (
    id integer NOT NULL,
    sequence integer,
    view_id integer,
    act_window_id integer,
    create_uid integer,
    write_uid integer,
    view_mode character varying NOT NULL,
    multi boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_act_window_view; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_act_window_view IS 'Action Window View';


--
-- Name: COLUMN ir_act_window_view.sequence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window_view.sequence IS 'Sequence';


--
-- Name: COLUMN ir_act_window_view.view_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window_view.view_id IS 'View';


--
-- Name: COLUMN ir_act_window_view.act_window_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window_view.act_window_id IS 'Action';


--
-- Name: COLUMN ir_act_window_view.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window_view.create_uid IS 'Created by';


--
-- Name: COLUMN ir_act_window_view.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window_view.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_act_window_view.view_mode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window_view.view_mode IS 'View Type';


--
-- Name: COLUMN ir_act_window_view.multi; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window_view.multi IS 'On Multiple Doc.';


--
-- Name: COLUMN ir_act_window_view.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window_view.create_date IS 'Created on';


--
-- Name: COLUMN ir_act_window_view.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_act_window_view.write_date IS 'Last Updated on';


--
-- Name: ir_act_window_view_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_act_window_view_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_act_window_view_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_act_window_view_id_seq OWNED BY public.ir_act_window_view.id;


--
-- Name: ir_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_actions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_actions_id_seq OWNED BY public.ir_actions.id;


--
-- Name: ir_actions_todo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_actions_todo (
    id integer NOT NULL,
    action_id integer NOT NULL,
    sequence integer,
    create_uid integer,
    write_uid integer,
    state character varying NOT NULL,
    name character varying,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_actions_todo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_actions_todo IS 'Configuration Wizards';


--
-- Name: COLUMN ir_actions_todo.action_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions_todo.action_id IS 'Action';


--
-- Name: COLUMN ir_actions_todo.sequence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions_todo.sequence IS 'Sequence';


--
-- Name: COLUMN ir_actions_todo.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions_todo.create_uid IS 'Created by';


--
-- Name: COLUMN ir_actions_todo.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions_todo.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_actions_todo.state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions_todo.state IS 'Status';


--
-- Name: COLUMN ir_actions_todo.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions_todo.name IS 'Name';


--
-- Name: COLUMN ir_actions_todo.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions_todo.create_date IS 'Created on';


--
-- Name: COLUMN ir_actions_todo.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_actions_todo.write_date IS 'Last Updated on';


--
-- Name: ir_actions_todo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_actions_todo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_actions_todo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_actions_todo_id_seq OWNED BY public.ir_actions_todo.id;


--
-- Name: ir_asset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_asset (
    id integer NOT NULL,
    sequence integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    bundle character varying NOT NULL,
    directive character varying,
    path character varying NOT NULL,
    target character varying,
    active boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_asset; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_asset IS 'Asset';


--
-- Name: COLUMN ir_asset.sequence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_asset.sequence IS 'Sequence';


--
-- Name: COLUMN ir_asset.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_asset.create_uid IS 'Created by';


--
-- Name: COLUMN ir_asset.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_asset.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_asset.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_asset.name IS 'Name';


--
-- Name: COLUMN ir_asset.bundle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_asset.bundle IS 'Bundle name';


--
-- Name: COLUMN ir_asset.directive; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_asset.directive IS 'Directive';


--
-- Name: COLUMN ir_asset.path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_asset.path IS 'Path (or glob pattern)';


--
-- Name: COLUMN ir_asset.target; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_asset.target IS 'Target';


--
-- Name: COLUMN ir_asset.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_asset.active IS 'active';


--
-- Name: COLUMN ir_asset.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_asset.create_date IS 'Created on';


--
-- Name: COLUMN ir_asset.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_asset.write_date IS 'Last Updated on';


--
-- Name: ir_asset_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_asset_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_asset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_asset_id_seq OWNED BY public.ir_asset.id;


--
-- Name: ir_attachment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_attachment (
    id integer NOT NULL,
    res_id integer,
    company_id integer,
    file_size integer,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    res_model character varying,
    res_field character varying,
    type character varying NOT NULL,
    url character varying(1024),
    access_token character varying,
    store_fname character varying,
    checksum character varying(40),
    mimetype character varying,
    description text,
    index_content text,
    public boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    db_datas bytea,
    original_id integer
);


--
-- Name: TABLE ir_attachment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_attachment IS 'Attachment';


--
-- Name: COLUMN ir_attachment.res_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.res_id IS 'Resource ID';


--
-- Name: COLUMN ir_attachment.company_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.company_id IS 'Company';


--
-- Name: COLUMN ir_attachment.file_size; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.file_size IS 'File Size';


--
-- Name: COLUMN ir_attachment.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.create_uid IS 'Created by';


--
-- Name: COLUMN ir_attachment.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_attachment.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.name IS 'Name';


--
-- Name: COLUMN ir_attachment.res_model; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.res_model IS 'Resource Model';


--
-- Name: COLUMN ir_attachment.res_field; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.res_field IS 'Resource Field';


--
-- Name: COLUMN ir_attachment.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.type IS 'Type';


--
-- Name: COLUMN ir_attachment.url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.url IS 'Url';


--
-- Name: COLUMN ir_attachment.access_token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.access_token IS 'Access Token';


--
-- Name: COLUMN ir_attachment.store_fname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.store_fname IS 'Stored Filename';


--
-- Name: COLUMN ir_attachment.checksum; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.checksum IS 'Checksum/SHA1';


--
-- Name: COLUMN ir_attachment.mimetype; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.mimetype IS 'Mime Type';


--
-- Name: COLUMN ir_attachment.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.description IS 'Description';


--
-- Name: COLUMN ir_attachment.index_content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.index_content IS 'Indexed Content';


--
-- Name: COLUMN ir_attachment.public; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.public IS 'Is public document';


--
-- Name: COLUMN ir_attachment.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.create_date IS 'Created on';


--
-- Name: COLUMN ir_attachment.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.write_date IS 'Last Updated on';


--
-- Name: COLUMN ir_attachment.db_datas; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.db_datas IS 'Database Data';


--
-- Name: COLUMN ir_attachment.original_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_attachment.original_id IS 'Original (unoptimized, unresized) attachment';


--
-- Name: ir_attachment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_attachment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_attachment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_attachment_id_seq OWNED BY public.ir_attachment.id;


--
-- Name: ir_config_parameter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_config_parameter (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    key character varying NOT NULL,
    value text NOT NULL,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_config_parameter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_config_parameter IS 'System Parameter';


--
-- Name: COLUMN ir_config_parameter.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_config_parameter.create_uid IS 'Created by';


--
-- Name: COLUMN ir_config_parameter.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_config_parameter.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_config_parameter.key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_config_parameter.key IS 'Key';


--
-- Name: COLUMN ir_config_parameter.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_config_parameter.value IS 'Value';


--
-- Name: COLUMN ir_config_parameter.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_config_parameter.create_date IS 'Created on';


--
-- Name: COLUMN ir_config_parameter.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_config_parameter.write_date IS 'Last Updated on';


--
-- Name: ir_config_parameter_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_config_parameter_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_config_parameter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_config_parameter_id_seq OWNED BY public.ir_config_parameter.id;


--
-- Name: ir_cron; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_cron (
    id integer NOT NULL,
    ir_actions_server_id integer NOT NULL,
    user_id integer NOT NULL,
    interval_number integer,
    numbercall integer,
    priority integer,
    create_uid integer,
    write_uid integer,
    cron_name character varying,
    interval_type character varying,
    active boolean,
    doall boolean,
    nextcall timestamp without time zone NOT NULL,
    lastcall timestamp without time zone,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_cron; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_cron IS 'Scheduled Actions';


--
-- Name: COLUMN ir_cron.ir_actions_server_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron.ir_actions_server_id IS 'Server action';


--
-- Name: COLUMN ir_cron.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron.user_id IS 'Scheduler User';


--
-- Name: COLUMN ir_cron.interval_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron.interval_number IS 'Interval Number';


--
-- Name: COLUMN ir_cron.numbercall; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron.numbercall IS 'Number of Calls';


--
-- Name: COLUMN ir_cron.priority; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron.priority IS 'Priority';


--
-- Name: COLUMN ir_cron.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron.create_uid IS 'Created by';


--
-- Name: COLUMN ir_cron.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_cron.cron_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron.cron_name IS 'Name';


--
-- Name: COLUMN ir_cron.interval_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron.interval_type IS 'Interval Unit';


--
-- Name: COLUMN ir_cron.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron.active IS 'Active';


--
-- Name: COLUMN ir_cron.doall; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron.doall IS 'Repeat Missed';


--
-- Name: COLUMN ir_cron.nextcall; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron.nextcall IS 'Next Execution Date';


--
-- Name: COLUMN ir_cron.lastcall; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron.lastcall IS 'Last Execution Date';


--
-- Name: COLUMN ir_cron.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron.create_date IS 'Created on';


--
-- Name: COLUMN ir_cron.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron.write_date IS 'Last Updated on';


--
-- Name: ir_cron_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_cron_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_cron_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_cron_id_seq OWNED BY public.ir_cron.id;


--
-- Name: ir_cron_trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_cron_trigger (
    id integer NOT NULL,
    cron_id integer,
    create_uid integer,
    write_uid integer,
    call_at timestamp without time zone,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_cron_trigger; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_cron_trigger IS 'Triggered actions';


--
-- Name: COLUMN ir_cron_trigger.cron_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron_trigger.cron_id IS 'Cron';


--
-- Name: COLUMN ir_cron_trigger.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron_trigger.create_uid IS 'Created by';


--
-- Name: COLUMN ir_cron_trigger.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron_trigger.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_cron_trigger.call_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron_trigger.call_at IS 'Call At';


--
-- Name: COLUMN ir_cron_trigger.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron_trigger.create_date IS 'Created on';


--
-- Name: COLUMN ir_cron_trigger.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_cron_trigger.write_date IS 'Last Updated on';


--
-- Name: ir_cron_trigger_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_cron_trigger_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_cron_trigger_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_cron_trigger_id_seq OWNED BY public.ir_cron_trigger.id;


--
-- Name: ir_default; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_default (
    id integer NOT NULL,
    field_id integer NOT NULL,
    user_id integer,
    company_id integer,
    create_uid integer,
    write_uid integer,
    condition character varying,
    json_value character varying NOT NULL,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_default; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_default IS 'Default Values';


--
-- Name: COLUMN ir_default.field_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_default.field_id IS 'Field';


--
-- Name: COLUMN ir_default.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_default.user_id IS 'User';


--
-- Name: COLUMN ir_default.company_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_default.company_id IS 'Company';


--
-- Name: COLUMN ir_default.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_default.create_uid IS 'Created by';


--
-- Name: COLUMN ir_default.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_default.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_default.condition; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_default.condition IS 'Condition';


--
-- Name: COLUMN ir_default.json_value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_default.json_value IS 'Default Value (JSON format)';


--
-- Name: COLUMN ir_default.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_default.create_date IS 'Created on';


--
-- Name: COLUMN ir_default.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_default.write_date IS 'Last Updated on';


--
-- Name: ir_default_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_default_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_default_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_default_id_seq OWNED BY public.ir_default.id;


--
-- Name: ir_demo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_demo (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_demo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_demo IS 'Demo';


--
-- Name: COLUMN ir_demo.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_demo.create_uid IS 'Created by';


--
-- Name: COLUMN ir_demo.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_demo.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_demo.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_demo.create_date IS 'Created on';


--
-- Name: COLUMN ir_demo.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_demo.write_date IS 'Last Updated on';


--
-- Name: ir_demo_failure; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_demo_failure (
    id integer NOT NULL,
    module_id integer NOT NULL,
    wizard_id integer,
    create_uid integer,
    write_uid integer,
    error character varying,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_demo_failure; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_demo_failure IS 'Demo failure';


--
-- Name: COLUMN ir_demo_failure.module_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_demo_failure.module_id IS 'Module';


--
-- Name: COLUMN ir_demo_failure.wizard_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_demo_failure.wizard_id IS 'Wizard';


--
-- Name: COLUMN ir_demo_failure.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_demo_failure.create_uid IS 'Created by';


--
-- Name: COLUMN ir_demo_failure.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_demo_failure.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_demo_failure.error; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_demo_failure.error IS 'Error';


--
-- Name: COLUMN ir_demo_failure.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_demo_failure.create_date IS 'Created on';


--
-- Name: COLUMN ir_demo_failure.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_demo_failure.write_date IS 'Last Updated on';


--
-- Name: ir_demo_failure_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_demo_failure_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_demo_failure_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_demo_failure_id_seq OWNED BY public.ir_demo_failure.id;


--
-- Name: ir_demo_failure_wizard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_demo_failure_wizard (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_demo_failure_wizard; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_demo_failure_wizard IS 'Demo Failure wizard';


--
-- Name: COLUMN ir_demo_failure_wizard.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_demo_failure_wizard.create_uid IS 'Created by';


--
-- Name: COLUMN ir_demo_failure_wizard.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_demo_failure_wizard.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_demo_failure_wizard.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_demo_failure_wizard.create_date IS 'Created on';


--
-- Name: COLUMN ir_demo_failure_wizard.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_demo_failure_wizard.write_date IS 'Last Updated on';


--
-- Name: ir_demo_failure_wizard_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_demo_failure_wizard_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_demo_failure_wizard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_demo_failure_wizard_id_seq OWNED BY public.ir_demo_failure_wizard.id;


--
-- Name: ir_demo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_demo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_demo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_demo_id_seq OWNED BY public.ir_demo.id;


--
-- Name: ir_exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_exports (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name character varying,
    resource character varying,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_exports; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_exports IS 'Exports';


--
-- Name: COLUMN ir_exports.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_exports.create_uid IS 'Created by';


--
-- Name: COLUMN ir_exports.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_exports.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_exports.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_exports.name IS 'Export Name';


--
-- Name: COLUMN ir_exports.resource; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_exports.resource IS 'Resource';


--
-- Name: COLUMN ir_exports.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_exports.create_date IS 'Created on';


--
-- Name: COLUMN ir_exports.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_exports.write_date IS 'Last Updated on';


--
-- Name: ir_exports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_exports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_exports_id_seq OWNED BY public.ir_exports.id;


--
-- Name: ir_exports_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_exports_line (
    id integer NOT NULL,
    export_id integer,
    create_uid integer,
    write_uid integer,
    name character varying,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_exports_line; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_exports_line IS 'Exports Line';


--
-- Name: COLUMN ir_exports_line.export_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_exports_line.export_id IS 'Export';


--
-- Name: COLUMN ir_exports_line.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_exports_line.create_uid IS 'Created by';


--
-- Name: COLUMN ir_exports_line.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_exports_line.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_exports_line.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_exports_line.name IS 'Field Name';


--
-- Name: COLUMN ir_exports_line.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_exports_line.create_date IS 'Created on';


--
-- Name: COLUMN ir_exports_line.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_exports_line.write_date IS 'Last Updated on';


--
-- Name: ir_exports_line_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_exports_line_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_exports_line_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_exports_line_id_seq OWNED BY public.ir_exports_line.id;


--
-- Name: ir_filters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_filters (
    id integer NOT NULL,
    user_id integer,
    action_id integer,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    model_id character varying NOT NULL,
    domain text NOT NULL,
    context text NOT NULL,
    sort text NOT NULL,
    is_default boolean,
    active boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_filters; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_filters IS 'Filters';


--
-- Name: COLUMN ir_filters.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_filters.user_id IS 'User';


--
-- Name: COLUMN ir_filters.action_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_filters.action_id IS 'Action';


--
-- Name: COLUMN ir_filters.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_filters.create_uid IS 'Created by';


--
-- Name: COLUMN ir_filters.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_filters.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_filters.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_filters.name IS 'Filter Name';


--
-- Name: COLUMN ir_filters.model_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_filters.model_id IS 'Model';


--
-- Name: COLUMN ir_filters.domain; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_filters.domain IS 'Domain';


--
-- Name: COLUMN ir_filters.context; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_filters.context IS 'Context';


--
-- Name: COLUMN ir_filters.sort; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_filters.sort IS 'Sort';


--
-- Name: COLUMN ir_filters.is_default; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_filters.is_default IS 'Default Filter';


--
-- Name: COLUMN ir_filters.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_filters.active IS 'Active';


--
-- Name: COLUMN ir_filters.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_filters.create_date IS 'Created on';


--
-- Name: COLUMN ir_filters.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_filters.write_date IS 'Last Updated on';


--
-- Name: ir_filters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_filters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_filters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_filters_id_seq OWNED BY public.ir_filters.id;


--
-- Name: ir_logging; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_logging (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    type character varying NOT NULL,
    dbname character varying,
    level character varying,
    path character varying NOT NULL,
    func character varying NOT NULL,
    line character varying NOT NULL,
    message text NOT NULL,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_logging; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_logging IS 'Logging';


--
-- Name: COLUMN ir_logging.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_logging.create_uid IS 'Created by';


--
-- Name: COLUMN ir_logging.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_logging.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_logging.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_logging.name IS 'Name';


--
-- Name: COLUMN ir_logging.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_logging.type IS 'Type';


--
-- Name: COLUMN ir_logging.dbname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_logging.dbname IS 'Database Name';


--
-- Name: COLUMN ir_logging.level; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_logging.level IS 'Level';


--
-- Name: COLUMN ir_logging.path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_logging.path IS 'Path';


--
-- Name: COLUMN ir_logging.func; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_logging.func IS 'Function';


--
-- Name: COLUMN ir_logging.line; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_logging.line IS 'Line';


--
-- Name: COLUMN ir_logging.message; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_logging.message IS 'Message';


--
-- Name: COLUMN ir_logging.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_logging.create_date IS 'Created on';


--
-- Name: COLUMN ir_logging.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_logging.write_date IS 'Last Updated on';


--
-- Name: ir_logging_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_logging_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_logging_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_logging_id_seq OWNED BY public.ir_logging.id;


--
-- Name: ir_mail_server; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_mail_server (
    id integer NOT NULL,
    smtp_port integer,
    sequence integer,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    from_filter character varying,
    smtp_host character varying,
    smtp_authentication character varying NOT NULL,
    smtp_user character varying,
    smtp_pass character varying,
    smtp_encryption character varying NOT NULL,
    smtp_debug boolean,
    active boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    smtp_ssl_certificate bytea,
    smtp_ssl_private_key bytea
);


--
-- Name: TABLE ir_mail_server; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_mail_server IS 'Mail Server';


--
-- Name: COLUMN ir_mail_server.smtp_port; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.smtp_port IS 'SMTP Port';


--
-- Name: COLUMN ir_mail_server.sequence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.sequence IS 'Priority';


--
-- Name: COLUMN ir_mail_server.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.create_uid IS 'Created by';


--
-- Name: COLUMN ir_mail_server.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_mail_server.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.name IS 'Name';


--
-- Name: COLUMN ir_mail_server.from_filter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.from_filter IS 'FROM Filtering';


--
-- Name: COLUMN ir_mail_server.smtp_host; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.smtp_host IS 'SMTP Server';


--
-- Name: COLUMN ir_mail_server.smtp_authentication; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.smtp_authentication IS 'Authenticate with';


--
-- Name: COLUMN ir_mail_server.smtp_user; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.smtp_user IS 'Username';


--
-- Name: COLUMN ir_mail_server.smtp_pass; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.smtp_pass IS 'Password';


--
-- Name: COLUMN ir_mail_server.smtp_encryption; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.smtp_encryption IS 'Connection Encryption';


--
-- Name: COLUMN ir_mail_server.smtp_debug; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.smtp_debug IS 'Debugging';


--
-- Name: COLUMN ir_mail_server.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.active IS 'Active';


--
-- Name: COLUMN ir_mail_server.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.create_date IS 'Created on';


--
-- Name: COLUMN ir_mail_server.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.write_date IS 'Last Updated on';


--
-- Name: COLUMN ir_mail_server.smtp_ssl_certificate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.smtp_ssl_certificate IS 'SSL Certificate';


--
-- Name: COLUMN ir_mail_server.smtp_ssl_private_key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_mail_server.smtp_ssl_private_key IS 'SSL Private Key';


--
-- Name: ir_mail_server_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_mail_server_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_mail_server_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_mail_server_id_seq OWNED BY public.ir_mail_server.id;


--
-- Name: ir_model; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_model (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    model character varying NOT NULL,
    "order" character varying NOT NULL,
    state character varying,
    name jsonb NOT NULL,
    info text,
    transient boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_model; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_model IS 'Models';


--
-- Name: COLUMN ir_model.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model.create_uid IS 'Created by';


--
-- Name: COLUMN ir_model.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_model.model; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model.model IS 'Model';


--
-- Name: COLUMN ir_model."order"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model."order" IS 'Order';


--
-- Name: COLUMN ir_model.state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model.state IS 'Type';


--
-- Name: COLUMN ir_model.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model.name IS 'Model Description';


--
-- Name: COLUMN ir_model.info; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model.info IS 'Information';


--
-- Name: COLUMN ir_model.transient; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model.transient IS 'Transient Model';


--
-- Name: COLUMN ir_model.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model.create_date IS 'Created on';


--
-- Name: COLUMN ir_model.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model.write_date IS 'Last Updated on';


--
-- Name: ir_model_access; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_model_access (
    id integer NOT NULL,
    model_id integer NOT NULL,
    group_id integer,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    active boolean,
    perm_read boolean,
    perm_write boolean,
    perm_create boolean,
    perm_unlink boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_model_access; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_model_access IS 'Model Access';


--
-- Name: COLUMN ir_model_access.model_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_access.model_id IS 'Model';


--
-- Name: COLUMN ir_model_access.group_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_access.group_id IS 'Group';


--
-- Name: COLUMN ir_model_access.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_access.create_uid IS 'Created by';


--
-- Name: COLUMN ir_model_access.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_access.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_model_access.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_access.name IS 'Name';


--
-- Name: COLUMN ir_model_access.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_access.active IS 'Active';


--
-- Name: COLUMN ir_model_access.perm_read; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_access.perm_read IS 'Read Access';


--
-- Name: COLUMN ir_model_access.perm_write; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_access.perm_write IS 'Write Access';


--
-- Name: COLUMN ir_model_access.perm_create; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_access.perm_create IS 'Create Access';


--
-- Name: COLUMN ir_model_access.perm_unlink; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_access.perm_unlink IS 'Delete Access';


--
-- Name: COLUMN ir_model_access.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_access.create_date IS 'Created on';


--
-- Name: COLUMN ir_model_access.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_access.write_date IS 'Last Updated on';


--
-- Name: ir_model_access_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_model_access_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_model_access_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_model_access_id_seq OWNED BY public.ir_model_access.id;


--
-- Name: ir_model_constraint; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_model_constraint (
    id integer NOT NULL,
    model integer NOT NULL,
    module integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    definition character varying,
    type character varying(1) NOT NULL,
    message jsonb,
    write_date timestamp without time zone,
    create_date timestamp without time zone
);


--
-- Name: TABLE ir_model_constraint; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_model_constraint IS 'Model Constraint';


--
-- Name: COLUMN ir_model_constraint.model; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_constraint.model IS 'Model';


--
-- Name: COLUMN ir_model_constraint.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_constraint.module IS 'Module';


--
-- Name: COLUMN ir_model_constraint.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_constraint.create_uid IS 'Created by';


--
-- Name: COLUMN ir_model_constraint.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_constraint.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_model_constraint.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_constraint.name IS 'Constraint';


--
-- Name: COLUMN ir_model_constraint.definition; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_constraint.definition IS 'Definition';


--
-- Name: COLUMN ir_model_constraint.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_constraint.type IS 'Constraint Type';


--
-- Name: COLUMN ir_model_constraint.message; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_constraint.message IS 'Message';


--
-- Name: COLUMN ir_model_constraint.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_constraint.write_date IS 'Write Date';


--
-- Name: COLUMN ir_model_constraint.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_constraint.create_date IS 'Create Date';


--
-- Name: ir_model_constraint_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_model_constraint_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_model_constraint_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_model_constraint_id_seq OWNED BY public.ir_model_constraint.id;


--
-- Name: ir_model_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_model_data (
    id integer NOT NULL,
    create_uid integer,
    create_date timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text),
    write_date timestamp without time zone DEFAULT (now() AT TIME ZONE 'UTC'::text),
    write_uid integer,
    res_id integer,
    noupdate boolean DEFAULT false,
    name character varying NOT NULL,
    module character varying NOT NULL,
    model character varying NOT NULL,
    CONSTRAINT ir_model_data_name_nospaces CHECK (((name)::text !~~ '% %'::text))
);


--
-- Name: CONSTRAINT ir_model_data_name_nospaces ON ir_model_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT ir_model_data_name_nospaces ON public.ir_model_data IS 'CHECK(name NOT LIKE ''% %'')';


--
-- Name: ir_model_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_model_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_model_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_model_data_id_seq OWNED BY public.ir_model_data.id;


--
-- Name: ir_model_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_model_fields (
    id integer NOT NULL,
    relation_field_id integer,
    model_id integer NOT NULL,
    related_field_id integer,
    size integer,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    complete_name character varying,
    model character varying NOT NULL,
    relation character varying,
    relation_field character varying,
    ttype character varying NOT NULL,
    related character varying,
    state character varying NOT NULL,
    on_delete character varying,
    domain character varying,
    relation_table character varying,
    column1 character varying,
    column2 character varying,
    depends character varying,
    currency_field character varying,
    field_description jsonb NOT NULL,
    help jsonb,
    compute text,
    copied boolean,
    required boolean,
    readonly boolean,
    index boolean,
    translate boolean,
    group_expand boolean,
    selectable boolean,
    store boolean,
    sanitize boolean,
    sanitize_overridable boolean,
    sanitize_tags boolean,
    sanitize_attributes boolean,
    sanitize_style boolean,
    sanitize_form boolean,
    strip_style boolean,
    strip_classes boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    CONSTRAINT ir_model_fields_name_manual_field CHECK ((((state)::text <> 'manual'::text) OR ((name)::text ~~ 'x\_%'::text))),
    CONSTRAINT ir_model_fields_size_gt_zero CHECK ((size >= 0))
);


--
-- Name: TABLE ir_model_fields; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_model_fields IS 'Fields';


--
-- Name: COLUMN ir_model_fields.relation_field_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.relation_field_id IS 'Relation field';


--
-- Name: COLUMN ir_model_fields.model_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.model_id IS 'Model';


--
-- Name: COLUMN ir_model_fields.related_field_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.related_field_id IS 'Related field';


--
-- Name: COLUMN ir_model_fields.size; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.size IS 'Size';


--
-- Name: COLUMN ir_model_fields.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.create_uid IS 'Created by';


--
-- Name: COLUMN ir_model_fields.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_model_fields.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.name IS 'Field Name';


--
-- Name: COLUMN ir_model_fields.complete_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.complete_name IS 'Complete Name';


--
-- Name: COLUMN ir_model_fields.model; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.model IS 'Model Name';


--
-- Name: COLUMN ir_model_fields.relation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.relation IS 'Related Model';


--
-- Name: COLUMN ir_model_fields.relation_field; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.relation_field IS 'Relation Field';


--
-- Name: COLUMN ir_model_fields.ttype; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.ttype IS 'Field Type';


--
-- Name: COLUMN ir_model_fields.related; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.related IS 'Related Field';


--
-- Name: COLUMN ir_model_fields.state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.state IS 'Type';


--
-- Name: COLUMN ir_model_fields.on_delete; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.on_delete IS 'On Delete';


--
-- Name: COLUMN ir_model_fields.domain; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.domain IS 'Domain';


--
-- Name: COLUMN ir_model_fields.relation_table; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.relation_table IS 'Relation Table';


--
-- Name: COLUMN ir_model_fields.column1; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.column1 IS 'Column 1';


--
-- Name: COLUMN ir_model_fields.column2; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.column2 IS 'Column 2';


--
-- Name: COLUMN ir_model_fields.depends; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.depends IS 'Dependencies';


--
-- Name: COLUMN ir_model_fields.currency_field; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.currency_field IS 'Currency field';


--
-- Name: COLUMN ir_model_fields.field_description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.field_description IS 'Field Label';


--
-- Name: COLUMN ir_model_fields.help; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.help IS 'Field Help';


--
-- Name: COLUMN ir_model_fields.compute; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.compute IS 'Compute';


--
-- Name: COLUMN ir_model_fields.copied; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.copied IS 'Copied';


--
-- Name: COLUMN ir_model_fields.required; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.required IS 'Required';


--
-- Name: COLUMN ir_model_fields.readonly; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.readonly IS 'Readonly';


--
-- Name: COLUMN ir_model_fields.index; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.index IS 'Indexed';


--
-- Name: COLUMN ir_model_fields.translate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.translate IS 'Translatable';


--
-- Name: COLUMN ir_model_fields.group_expand; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.group_expand IS 'Expand Groups';


--
-- Name: COLUMN ir_model_fields.selectable; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.selectable IS 'Selectable';


--
-- Name: COLUMN ir_model_fields.store; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.store IS 'Stored';


--
-- Name: COLUMN ir_model_fields.sanitize; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.sanitize IS 'Sanitize HTML';


--
-- Name: COLUMN ir_model_fields.sanitize_overridable; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.sanitize_overridable IS 'Sanitize HTML overridable';


--
-- Name: COLUMN ir_model_fields.sanitize_tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.sanitize_tags IS 'Sanitize HTML Tags';


--
-- Name: COLUMN ir_model_fields.sanitize_attributes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.sanitize_attributes IS 'Sanitize HTML Attributes';


--
-- Name: COLUMN ir_model_fields.sanitize_style; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.sanitize_style IS 'Sanitize HTML Style';


--
-- Name: COLUMN ir_model_fields.sanitize_form; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.sanitize_form IS 'Sanitize HTML Form';


--
-- Name: COLUMN ir_model_fields.strip_style; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.strip_style IS 'Strip Style Attribute';


--
-- Name: COLUMN ir_model_fields.strip_classes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.strip_classes IS 'Strip Class Attribute';


--
-- Name: COLUMN ir_model_fields.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.create_date IS 'Created on';


--
-- Name: COLUMN ir_model_fields.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields.write_date IS 'Last Updated on';


--
-- Name: CONSTRAINT ir_model_fields_name_manual_field ON ir_model_fields; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT ir_model_fields_name_manual_field ON public.ir_model_fields IS 'CHECK (state != ''manual'' OR name LIKE ''x\_%'')';


--
-- Name: CONSTRAINT ir_model_fields_size_gt_zero ON ir_model_fields; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT ir_model_fields_size_gt_zero ON public.ir_model_fields IS 'CHECK (size>=0)';


--
-- Name: ir_model_fields_group_rel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_model_fields_group_rel (
    field_id integer NOT NULL,
    group_id integer NOT NULL
);


--
-- Name: TABLE ir_model_fields_group_rel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_model_fields_group_rel IS 'RELATION BETWEEN ir_model_fields AND res_groups';


--
-- Name: ir_model_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_model_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_model_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_model_fields_id_seq OWNED BY public.ir_model_fields.id;


--
-- Name: ir_model_fields_selection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_model_fields_selection (
    id integer NOT NULL,
    field_id integer NOT NULL,
    sequence integer,
    create_uid integer,
    write_uid integer,
    value character varying NOT NULL,
    name jsonb NOT NULL,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_model_fields_selection; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_model_fields_selection IS 'Fields Selection';


--
-- Name: COLUMN ir_model_fields_selection.field_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields_selection.field_id IS 'Field';


--
-- Name: COLUMN ir_model_fields_selection.sequence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields_selection.sequence IS 'Sequence';


--
-- Name: COLUMN ir_model_fields_selection.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields_selection.create_uid IS 'Created by';


--
-- Name: COLUMN ir_model_fields_selection.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields_selection.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_model_fields_selection.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields_selection.value IS 'Value';


--
-- Name: COLUMN ir_model_fields_selection.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields_selection.name IS 'Name';


--
-- Name: COLUMN ir_model_fields_selection.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields_selection.create_date IS 'Created on';


--
-- Name: COLUMN ir_model_fields_selection.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_fields_selection.write_date IS 'Last Updated on';


--
-- Name: ir_model_fields_selection_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_model_fields_selection_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_model_fields_selection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_model_fields_selection_id_seq OWNED BY public.ir_model_fields_selection.id;


--
-- Name: ir_model_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_model_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_model_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_model_id_seq OWNED BY public.ir_model.id;


--
-- Name: ir_model_inherit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_model_inherit (
    id integer NOT NULL,
    model_id integer NOT NULL,
    parent_id integer NOT NULL,
    parent_field_id integer
);


--
-- Name: TABLE ir_model_inherit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_model_inherit IS 'Model Inheritance Tree';


--
-- Name: COLUMN ir_model_inherit.model_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_inherit.model_id IS 'Model';


--
-- Name: COLUMN ir_model_inherit.parent_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_inherit.parent_id IS 'Parent';


--
-- Name: COLUMN ir_model_inherit.parent_field_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_inherit.parent_field_id IS 'Parent Field';


--
-- Name: ir_model_inherit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_model_inherit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_model_inherit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_model_inherit_id_seq OWNED BY public.ir_model_inherit.id;


--
-- Name: ir_model_relation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_model_relation (
    id integer NOT NULL,
    model integer NOT NULL,
    module integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    write_date timestamp without time zone,
    create_date timestamp without time zone
);


--
-- Name: TABLE ir_model_relation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_model_relation IS 'Relation Model';


--
-- Name: COLUMN ir_model_relation.model; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_relation.model IS 'Model';


--
-- Name: COLUMN ir_model_relation.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_relation.module IS 'Module';


--
-- Name: COLUMN ir_model_relation.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_relation.create_uid IS 'Created by';


--
-- Name: COLUMN ir_model_relation.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_relation.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_model_relation.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_relation.name IS 'Relation Name';


--
-- Name: COLUMN ir_model_relation.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_relation.write_date IS 'Write Date';


--
-- Name: COLUMN ir_model_relation.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_model_relation.create_date IS 'Create Date';


--
-- Name: ir_model_relation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_model_relation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_model_relation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_model_relation_id_seq OWNED BY public.ir_model_relation.id;


--
-- Name: ir_module_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_module_category (
    id integer NOT NULL,
    create_uid integer,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    write_uid integer,
    parent_id integer,
    name jsonb NOT NULL,
    sequence integer,
    description jsonb,
    visible boolean,
    exclusive boolean
);


--
-- Name: COLUMN ir_module_category.sequence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_category.sequence IS 'Sequence';


--
-- Name: COLUMN ir_module_category.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_category.description IS 'Description';


--
-- Name: COLUMN ir_module_category.visible; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_category.visible IS 'Visible';


--
-- Name: COLUMN ir_module_category.exclusive; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_category.exclusive IS 'Exclusive';


--
-- Name: ir_module_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_module_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_module_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_module_category_id_seq OWNED BY public.ir_module_category.id;


--
-- Name: ir_module_module; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_module_module (
    id integer NOT NULL,
    create_uid integer,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    write_uid integer,
    website character varying,
    summary jsonb,
    name character varying NOT NULL,
    author character varying,
    icon character varying,
    state character varying(16),
    latest_version character varying,
    shortdesc jsonb,
    category_id integer,
    description jsonb,
    application boolean DEFAULT false,
    demo boolean DEFAULT false,
    web boolean DEFAULT false,
    license character varying(32),
    sequence integer DEFAULT 100,
    auto_install boolean DEFAULT false,
    to_buy boolean DEFAULT false,
    maintainer character varying,
    published_version character varying,
    url character varying,
    contributors text,
    menus_by_module text,
    reports_by_module text,
    views_by_module text,
    module_type character varying,
    imported boolean
);


--
-- Name: COLUMN ir_module_module.maintainer; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_module.maintainer IS 'Maintainer';


--
-- Name: COLUMN ir_module_module.published_version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_module.published_version IS 'Published Version';


--
-- Name: COLUMN ir_module_module.url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_module.url IS 'URL';


--
-- Name: COLUMN ir_module_module.contributors; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_module.contributors IS 'Contributors';


--
-- Name: COLUMN ir_module_module.menus_by_module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_module.menus_by_module IS 'Menus';


--
-- Name: COLUMN ir_module_module.reports_by_module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_module.reports_by_module IS 'Reports';


--
-- Name: COLUMN ir_module_module.views_by_module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_module.views_by_module IS 'Views';


--
-- Name: COLUMN ir_module_module.module_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_module.module_type IS 'Module Type';


--
-- Name: COLUMN ir_module_module.imported; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_module.imported IS 'Imported Module';


--
-- Name: ir_module_module_dependency; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_module_module_dependency (
    id integer NOT NULL,
    name character varying,
    module_id integer,
    auto_install_required boolean DEFAULT true
);


--
-- Name: ir_module_module_dependency_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_module_module_dependency_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_module_module_dependency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_module_module_dependency_id_seq OWNED BY public.ir_module_module_dependency.id;


--
-- Name: ir_module_module_exclusion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_module_module_exclusion (
    id integer NOT NULL,
    module_id integer,
    create_uid integer,
    write_uid integer,
    name character varying,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_module_module_exclusion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_module_module_exclusion IS 'Module exclusion';


--
-- Name: COLUMN ir_module_module_exclusion.module_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_module_exclusion.module_id IS 'Module';


--
-- Name: COLUMN ir_module_module_exclusion.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_module_exclusion.create_uid IS 'Created by';


--
-- Name: COLUMN ir_module_module_exclusion.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_module_exclusion.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_module_module_exclusion.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_module_exclusion.name IS 'Name';


--
-- Name: COLUMN ir_module_module_exclusion.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_module_exclusion.create_date IS 'Created on';


--
-- Name: COLUMN ir_module_module_exclusion.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_module_module_exclusion.write_date IS 'Last Updated on';


--
-- Name: ir_module_module_exclusion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_module_module_exclusion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_module_module_exclusion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_module_module_exclusion_id_seq OWNED BY public.ir_module_module_exclusion.id;


--
-- Name: ir_module_module_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_module_module_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_module_module_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_module_module_id_seq OWNED BY public.ir_module_module.id;


--
-- Name: ir_profile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_profile (
    id integer NOT NULL,
    sql_count integer,
    entry_count integer,
    session character varying,
    name character varying,
    init_stack_trace text,
    sql text,
    traces_async text,
    traces_sync text,
    qweb text,
    create_date timestamp without time zone,
    duration double precision
);


--
-- Name: TABLE ir_profile; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_profile IS 'Profiling results';


--
-- Name: COLUMN ir_profile.sql_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_profile.sql_count IS 'Queries Count';


--
-- Name: COLUMN ir_profile.entry_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_profile.entry_count IS 'Entry count';


--
-- Name: COLUMN ir_profile.session; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_profile.session IS 'Session';


--
-- Name: COLUMN ir_profile.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_profile.name IS 'Description';


--
-- Name: COLUMN ir_profile.init_stack_trace; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_profile.init_stack_trace IS 'Initial stack trace';


--
-- Name: COLUMN ir_profile.sql; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_profile.sql IS 'Sql';


--
-- Name: COLUMN ir_profile.traces_async; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_profile.traces_async IS 'Traces Async';


--
-- Name: COLUMN ir_profile.traces_sync; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_profile.traces_sync IS 'Traces Sync';


--
-- Name: COLUMN ir_profile.qweb; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_profile.qweb IS 'Qweb';


--
-- Name: COLUMN ir_profile.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_profile.create_date IS 'Creation Date';


--
-- Name: COLUMN ir_profile.duration; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_profile.duration IS 'Duration';


--
-- Name: ir_profile_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_profile_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_profile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_profile_id_seq OWNED BY public.ir_profile.id;


--
-- Name: ir_property; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_property (
    id integer NOT NULL,
    company_id integer,
    fields_id integer NOT NULL,
    value_integer integer,
    create_uid integer,
    write_uid integer,
    name character varying,
    res_id character varying,
    value_reference character varying,
    type character varying NOT NULL,
    value_text text,
    value_datetime timestamp without time zone,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    value_float double precision,
    value_binary bytea
);


--
-- Name: TABLE ir_property; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_property IS 'Company Property';


--
-- Name: COLUMN ir_property.company_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_property.company_id IS 'Company';


--
-- Name: COLUMN ir_property.fields_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_property.fields_id IS 'Field';


--
-- Name: COLUMN ir_property.value_integer; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_property.value_integer IS 'Value Integer';


--
-- Name: COLUMN ir_property.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_property.create_uid IS 'Created by';


--
-- Name: COLUMN ir_property.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_property.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_property.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_property.name IS 'Name';


--
-- Name: COLUMN ir_property.res_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_property.res_id IS 'Resource';


--
-- Name: COLUMN ir_property.value_reference; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_property.value_reference IS 'Value Reference';


--
-- Name: COLUMN ir_property.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_property.type IS 'Type';


--
-- Name: COLUMN ir_property.value_text; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_property.value_text IS 'Value Text';


--
-- Name: COLUMN ir_property.value_datetime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_property.value_datetime IS 'Value Datetime';


--
-- Name: COLUMN ir_property.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_property.create_date IS 'Created on';


--
-- Name: COLUMN ir_property.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_property.write_date IS 'Last Updated on';


--
-- Name: COLUMN ir_property.value_float; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_property.value_float IS 'Value Float';


--
-- Name: COLUMN ir_property.value_binary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_property.value_binary IS 'Value Binary';


--
-- Name: ir_property_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_property_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_property_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_property_id_seq OWNED BY public.ir_property.id;


--
-- Name: ir_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_rule (
    id integer NOT NULL,
    model_id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name character varying,
    domain_force text,
    active boolean,
    perm_read boolean,
    perm_write boolean,
    perm_create boolean,
    perm_unlink boolean,
    global boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    CONSTRAINT ir_rule_no_access_rights CHECK (((perm_read <> false) OR (perm_write <> false) OR (perm_create <> false) OR (perm_unlink <> false)))
);


--
-- Name: TABLE ir_rule; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_rule IS 'Record Rule';


--
-- Name: COLUMN ir_rule.model_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_rule.model_id IS 'Model';


--
-- Name: COLUMN ir_rule.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_rule.create_uid IS 'Created by';


--
-- Name: COLUMN ir_rule.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_rule.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_rule.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_rule.name IS 'Name';


--
-- Name: COLUMN ir_rule.domain_force; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_rule.domain_force IS 'Domain';


--
-- Name: COLUMN ir_rule.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_rule.active IS 'Active';


--
-- Name: COLUMN ir_rule.perm_read; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_rule.perm_read IS 'Read';


--
-- Name: COLUMN ir_rule.perm_write; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_rule.perm_write IS 'Write';


--
-- Name: COLUMN ir_rule.perm_create; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_rule.perm_create IS 'Create';


--
-- Name: COLUMN ir_rule.perm_unlink; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_rule.perm_unlink IS 'Delete';


--
-- Name: COLUMN ir_rule.global; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_rule.global IS 'Global';


--
-- Name: COLUMN ir_rule.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_rule.create_date IS 'Created on';


--
-- Name: COLUMN ir_rule.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_rule.write_date IS 'Last Updated on';


--
-- Name: CONSTRAINT ir_rule_no_access_rights ON ir_rule; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT ir_rule_no_access_rights ON public.ir_rule IS 'CHECK (perm_read!=False or perm_write!=False or perm_create!=False or perm_unlink!=False)';


--
-- Name: ir_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_rule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_rule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_rule_id_seq OWNED BY public.ir_rule.id;


--
-- Name: ir_sequence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_sequence (
    id integer NOT NULL,
    number_next integer NOT NULL,
    number_increment integer NOT NULL,
    padding integer NOT NULL,
    company_id integer,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    code character varying,
    implementation character varying NOT NULL,
    prefix character varying,
    suffix character varying,
    active boolean,
    use_date_range boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_sequence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_sequence IS 'Sequence';


--
-- Name: COLUMN ir_sequence.number_next; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence.number_next IS 'Next Number';


--
-- Name: COLUMN ir_sequence.number_increment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence.number_increment IS 'Step';


--
-- Name: COLUMN ir_sequence.padding; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence.padding IS 'Sequence Size';


--
-- Name: COLUMN ir_sequence.company_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence.company_id IS 'Company';


--
-- Name: COLUMN ir_sequence.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence.create_uid IS 'Created by';


--
-- Name: COLUMN ir_sequence.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_sequence.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence.name IS 'Name';


--
-- Name: COLUMN ir_sequence.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence.code IS 'Sequence Code';


--
-- Name: COLUMN ir_sequence.implementation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence.implementation IS 'Implementation';


--
-- Name: COLUMN ir_sequence.prefix; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence.prefix IS 'Prefix';


--
-- Name: COLUMN ir_sequence.suffix; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence.suffix IS 'Suffix';


--
-- Name: COLUMN ir_sequence.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence.active IS 'Active';


--
-- Name: COLUMN ir_sequence.use_date_range; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence.use_date_range IS 'Use subsequences per date_range';


--
-- Name: COLUMN ir_sequence.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence.create_date IS 'Created on';


--
-- Name: COLUMN ir_sequence.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence.write_date IS 'Last Updated on';


--
-- Name: ir_sequence_date_range; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_sequence_date_range (
    id integer NOT NULL,
    sequence_id integer NOT NULL,
    number_next integer NOT NULL,
    create_uid integer,
    write_uid integer,
    date_from date NOT NULL,
    date_to date NOT NULL,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_sequence_date_range; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_sequence_date_range IS 'Sequence Date Range';


--
-- Name: COLUMN ir_sequence_date_range.sequence_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence_date_range.sequence_id IS 'Main Sequence';


--
-- Name: COLUMN ir_sequence_date_range.number_next; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence_date_range.number_next IS 'Next Number';


--
-- Name: COLUMN ir_sequence_date_range.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence_date_range.create_uid IS 'Created by';


--
-- Name: COLUMN ir_sequence_date_range.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence_date_range.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_sequence_date_range.date_from; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence_date_range.date_from IS 'From';


--
-- Name: COLUMN ir_sequence_date_range.date_to; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence_date_range.date_to IS 'To';


--
-- Name: COLUMN ir_sequence_date_range.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence_date_range.create_date IS 'Created on';


--
-- Name: COLUMN ir_sequence_date_range.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_sequence_date_range.write_date IS 'Last Updated on';


--
-- Name: ir_sequence_date_range_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_sequence_date_range_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_sequence_date_range_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_sequence_date_range_id_seq OWNED BY public.ir_sequence_date_range.id;


--
-- Name: ir_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_sequence_id_seq OWNED BY public.ir_sequence.id;


--
-- Name: ir_ui_menu; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_ui_menu (
    id integer NOT NULL,
    sequence integer,
    parent_id integer,
    create_uid integer,
    write_uid integer,
    parent_path character varying,
    web_icon character varying,
    action character varying,
    name jsonb NOT NULL,
    active boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_ui_menu; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_ui_menu IS 'Menu';


--
-- Name: COLUMN ir_ui_menu.sequence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_menu.sequence IS 'Sequence';


--
-- Name: COLUMN ir_ui_menu.parent_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_menu.parent_id IS 'Parent Menu';


--
-- Name: COLUMN ir_ui_menu.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_menu.create_uid IS 'Created by';


--
-- Name: COLUMN ir_ui_menu.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_menu.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_ui_menu.parent_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_menu.parent_path IS 'Parent Path';


--
-- Name: COLUMN ir_ui_menu.web_icon; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_menu.web_icon IS 'Web Icon File';


--
-- Name: COLUMN ir_ui_menu.action; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_menu.action IS 'Action';


--
-- Name: COLUMN ir_ui_menu.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_menu.name IS 'Menu';


--
-- Name: COLUMN ir_ui_menu.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_menu.active IS 'Active';


--
-- Name: COLUMN ir_ui_menu.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_menu.create_date IS 'Created on';


--
-- Name: COLUMN ir_ui_menu.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_menu.write_date IS 'Last Updated on';


--
-- Name: ir_ui_menu_group_rel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_ui_menu_group_rel (
    menu_id integer NOT NULL,
    gid integer NOT NULL
);


--
-- Name: TABLE ir_ui_menu_group_rel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_ui_menu_group_rel IS 'RELATION BETWEEN ir_ui_menu AND res_groups';


--
-- Name: ir_ui_menu_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_ui_menu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_ui_menu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_ui_menu_id_seq OWNED BY public.ir_ui_menu.id;


--
-- Name: ir_ui_view; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_ui_view (
    id integer NOT NULL,
    priority integer NOT NULL,
    inherit_id integer,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    model character varying,
    key character varying,
    type character varying,
    arch_fs character varying,
    mode character varying NOT NULL,
    arch_db jsonb,
    arch_prev text,
    arch_updated boolean,
    active boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    CONSTRAINT ir_ui_view_inheritance_mode CHECK ((((mode)::text <> 'extension'::text) OR (inherit_id IS NOT NULL))),
    CONSTRAINT ir_ui_view_qweb_required_key CHECK ((((type)::text <> 'qweb'::text) OR (key IS NOT NULL)))
);


--
-- Name: TABLE ir_ui_view; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_ui_view IS 'View';


--
-- Name: COLUMN ir_ui_view.priority; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view.priority IS 'Sequence';


--
-- Name: COLUMN ir_ui_view.inherit_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view.inherit_id IS 'Inherited View';


--
-- Name: COLUMN ir_ui_view.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view.create_uid IS 'Created by';


--
-- Name: COLUMN ir_ui_view.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_ui_view.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view.name IS 'View Name';


--
-- Name: COLUMN ir_ui_view.model; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view.model IS 'Model';


--
-- Name: COLUMN ir_ui_view.key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view.key IS 'Key';


--
-- Name: COLUMN ir_ui_view.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view.type IS 'View Type';


--
-- Name: COLUMN ir_ui_view.arch_fs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view.arch_fs IS 'Arch Filename';


--
-- Name: COLUMN ir_ui_view.mode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view.mode IS 'View inheritance mode';


--
-- Name: COLUMN ir_ui_view.arch_db; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view.arch_db IS 'Arch Blob';


--
-- Name: COLUMN ir_ui_view.arch_prev; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view.arch_prev IS 'Previous View Architecture';


--
-- Name: COLUMN ir_ui_view.arch_updated; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view.arch_updated IS 'Modified Architecture';


--
-- Name: COLUMN ir_ui_view.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view.active IS 'Active';


--
-- Name: COLUMN ir_ui_view.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view.create_date IS 'Created on';


--
-- Name: COLUMN ir_ui_view.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view.write_date IS 'Last Updated on';


--
-- Name: CONSTRAINT ir_ui_view_inheritance_mode ON ir_ui_view; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT ir_ui_view_inheritance_mode ON public.ir_ui_view IS 'CHECK (mode != ''extension'' OR inherit_id IS NOT NULL)';


--
-- Name: CONSTRAINT ir_ui_view_qweb_required_key ON ir_ui_view; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT ir_ui_view_qweb_required_key ON public.ir_ui_view IS 'CHECK (type != ''qweb'' OR key IS NOT NULL)';


--
-- Name: ir_ui_view_custom; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_ui_view_custom (
    id integer NOT NULL,
    ref_id integer NOT NULL,
    user_id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    arch text NOT NULL,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE ir_ui_view_custom; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_ui_view_custom IS 'Custom View';


--
-- Name: COLUMN ir_ui_view_custom.ref_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view_custom.ref_id IS 'Original View';


--
-- Name: COLUMN ir_ui_view_custom.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view_custom.user_id IS 'User';


--
-- Name: COLUMN ir_ui_view_custom.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view_custom.create_uid IS 'Created by';


--
-- Name: COLUMN ir_ui_view_custom.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view_custom.write_uid IS 'Last Updated by';


--
-- Name: COLUMN ir_ui_view_custom.arch; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view_custom.arch IS 'View Architecture';


--
-- Name: COLUMN ir_ui_view_custom.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view_custom.create_date IS 'Created on';


--
-- Name: COLUMN ir_ui_view_custom.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ir_ui_view_custom.write_date IS 'Last Updated on';


--
-- Name: ir_ui_view_custom_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_ui_view_custom_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_ui_view_custom_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_ui_view_custom_id_seq OWNED BY public.ir_ui_view_custom.id;


--
-- Name: ir_ui_view_group_rel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_ui_view_group_rel (
    view_id integer NOT NULL,
    group_id integer NOT NULL
);


--
-- Name: TABLE ir_ui_view_group_rel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ir_ui_view_group_rel IS 'RELATION BETWEEN ir_ui_view AND res_groups';


--
-- Name: ir_ui_view_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ir_ui_view_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ir_ui_view_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ir_ui_view_id_seq OWNED BY public.ir_ui_view.id;


--
-- Name: rel_modules_langexport; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rel_modules_langexport (
    wiz_id integer NOT NULL,
    module_id integer NOT NULL
);


--
-- Name: TABLE rel_modules_langexport; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.rel_modules_langexport IS 'RELATION BETWEEN base_language_export AND ir_module_module';


--
-- Name: rel_server_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rel_server_actions (
    server_id integer NOT NULL,
    action_id integer NOT NULL
);


--
-- Name: TABLE rel_server_actions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.rel_server_actions IS 'RELATION BETWEEN ir_act_server AND ir_act_server';


--
-- Name: report_layout; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_layout (
    id integer NOT NULL,
    view_id integer NOT NULL,
    sequence integer,
    create_uid integer,
    write_uid integer,
    image character varying,
    pdf character varying,
    name character varying,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE report_layout; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.report_layout IS 'Report Layout';


--
-- Name: COLUMN report_layout.view_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_layout.view_id IS 'Document Template';


--
-- Name: COLUMN report_layout.sequence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_layout.sequence IS 'Sequence';


--
-- Name: COLUMN report_layout.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_layout.create_uid IS 'Created by';


--
-- Name: COLUMN report_layout.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_layout.write_uid IS 'Last Updated by';


--
-- Name: COLUMN report_layout.image; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_layout.image IS 'Preview image src';


--
-- Name: COLUMN report_layout.pdf; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_layout.pdf IS 'Preview pdf src';


--
-- Name: COLUMN report_layout.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_layout.name IS 'Name';


--
-- Name: COLUMN report_layout.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_layout.create_date IS 'Created on';


--
-- Name: COLUMN report_layout.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_layout.write_date IS 'Last Updated on';


--
-- Name: report_layout_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.report_layout_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_layout_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.report_layout_id_seq OWNED BY public.report_layout.id;


--
-- Name: report_paperformat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_paperformat (
    id integer NOT NULL,
    page_height integer,
    page_width integer,
    header_spacing integer,
    dpi integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    format character varying,
    orientation character varying,
    "default" boolean,
    header_line boolean,
    disable_shrinking boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    margin_top double precision,
    margin_bottom double precision,
    margin_left double precision,
    margin_right double precision
);


--
-- Name: TABLE report_paperformat; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.report_paperformat IS 'Paper Format Config';


--
-- Name: COLUMN report_paperformat.page_height; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.page_height IS 'Page height (mm)';


--
-- Name: COLUMN report_paperformat.page_width; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.page_width IS 'Page width (mm)';


--
-- Name: COLUMN report_paperformat.header_spacing; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.header_spacing IS 'Header spacing';


--
-- Name: COLUMN report_paperformat.dpi; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.dpi IS 'Output DPI';


--
-- Name: COLUMN report_paperformat.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.create_uid IS 'Created by';


--
-- Name: COLUMN report_paperformat.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.write_uid IS 'Last Updated by';


--
-- Name: COLUMN report_paperformat.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.name IS 'Name';


--
-- Name: COLUMN report_paperformat.format; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.format IS 'Paper size';


--
-- Name: COLUMN report_paperformat.orientation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.orientation IS 'Orientation';


--
-- Name: COLUMN report_paperformat."default"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat."default" IS 'Default paper format?';


--
-- Name: COLUMN report_paperformat.header_line; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.header_line IS 'Display a header line';


--
-- Name: COLUMN report_paperformat.disable_shrinking; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.disable_shrinking IS 'Disable smart shrinking';


--
-- Name: COLUMN report_paperformat.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.create_date IS 'Created on';


--
-- Name: COLUMN report_paperformat.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.write_date IS 'Last Updated on';


--
-- Name: COLUMN report_paperformat.margin_top; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.margin_top IS 'Top Margin (mm)';


--
-- Name: COLUMN report_paperformat.margin_bottom; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.margin_bottom IS 'Bottom Margin (mm)';


--
-- Name: COLUMN report_paperformat.margin_left; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.margin_left IS 'Left Margin (mm)';


--
-- Name: COLUMN report_paperformat.margin_right; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.report_paperformat.margin_right IS 'Right Margin (mm)';


--
-- Name: report_paperformat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.report_paperformat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_paperformat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.report_paperformat_id_seq OWNED BY public.report_paperformat.id;


--
-- Name: res_bank; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_bank (
    id integer NOT NULL,
    state integer,
    country integer,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    street character varying,
    street2 character varying,
    zip character varying,
    city character varying,
    email character varying,
    phone character varying,
    bic character varying,
    active boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE res_bank; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_bank IS 'Bank';


--
-- Name: COLUMN res_bank.state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_bank.state IS 'Fed. State';


--
-- Name: COLUMN res_bank.country; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_bank.country IS 'Country';


--
-- Name: COLUMN res_bank.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_bank.create_uid IS 'Created by';


--
-- Name: COLUMN res_bank.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_bank.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_bank.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_bank.name IS 'Name';


--
-- Name: COLUMN res_bank.street; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_bank.street IS 'Street';


--
-- Name: COLUMN res_bank.street2; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_bank.street2 IS 'Street2';


--
-- Name: COLUMN res_bank.zip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_bank.zip IS 'Zip';


--
-- Name: COLUMN res_bank.city; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_bank.city IS 'City';


--
-- Name: COLUMN res_bank.email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_bank.email IS 'Email';


--
-- Name: COLUMN res_bank.phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_bank.phone IS 'Phone';


--
-- Name: COLUMN res_bank.bic; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_bank.bic IS 'Bank Identifier Code';


--
-- Name: COLUMN res_bank.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_bank.active IS 'Active';


--
-- Name: COLUMN res_bank.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_bank.create_date IS 'Created on';


--
-- Name: COLUMN res_bank.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_bank.write_date IS 'Last Updated on';


--
-- Name: res_bank_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_bank_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_bank_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_bank_id_seq OWNED BY public.res_bank.id;


--
-- Name: res_company; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_company (
    id integer NOT NULL,
    name character varying NOT NULL,
    partner_id integer NOT NULL,
    currency_id integer NOT NULL,
    sequence integer,
    create_date timestamp without time zone,
    parent_path character varying,
    parent_id integer,
    paperformat_id integer,
    external_report_layout_id integer,
    create_uid integer,
    write_uid integer,
    email character varying,
    phone character varying,
    mobile character varying,
    font character varying,
    primary_color character varying,
    secondary_color character varying,
    layout_background character varying NOT NULL,
    report_header jsonb,
    report_footer jsonb,
    company_details jsonb,
    active boolean,
    uses_default_logo boolean,
    write_date timestamp without time zone,
    logo_web bytea
);


--
-- Name: COLUMN res_company.parent_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.parent_id IS 'Parent Company';


--
-- Name: COLUMN res_company.paperformat_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.paperformat_id IS 'Paper format';


--
-- Name: COLUMN res_company.external_report_layout_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.external_report_layout_id IS 'Document Template';


--
-- Name: COLUMN res_company.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.create_uid IS 'Created by';


--
-- Name: COLUMN res_company.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_company.email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.email IS 'Email';


--
-- Name: COLUMN res_company.phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.phone IS 'Phone';


--
-- Name: COLUMN res_company.mobile; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.mobile IS 'Mobile';


--
-- Name: COLUMN res_company.font; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.font IS 'Font';


--
-- Name: COLUMN res_company.primary_color; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.primary_color IS 'Primary Color';


--
-- Name: COLUMN res_company.secondary_color; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.secondary_color IS 'Secondary Color';


--
-- Name: COLUMN res_company.layout_background; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.layout_background IS 'Layout Background';


--
-- Name: COLUMN res_company.report_header; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.report_header IS 'Company Tagline';


--
-- Name: COLUMN res_company.report_footer; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.report_footer IS 'Report Footer';


--
-- Name: COLUMN res_company.company_details; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.company_details IS 'Company Details';


--
-- Name: COLUMN res_company.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.active IS 'Active';


--
-- Name: COLUMN res_company.uses_default_logo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.uses_default_logo IS 'Uses Default Logo';


--
-- Name: COLUMN res_company.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.write_date IS 'Last Updated on';


--
-- Name: COLUMN res_company.logo_web; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_company.logo_web IS 'Logo Web';


--
-- Name: res_company_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_company_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_company_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_company_id_seq OWNED BY public.res_company.id;


--
-- Name: res_company_users_rel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_company_users_rel (
    cid integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: TABLE res_company_users_rel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_company_users_rel IS 'RELATION BETWEEN res_company AND res_users';


--
-- Name: res_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_config (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE res_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_config IS 'Config';


--
-- Name: COLUMN res_config.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config.create_uid IS 'Created by';


--
-- Name: COLUMN res_config.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_config.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config.create_date IS 'Created on';


--
-- Name: COLUMN res_config.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config.write_date IS 'Last Updated on';


--
-- Name: res_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_config_id_seq OWNED BY public.res_config.id;


--
-- Name: res_config_installer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_config_installer (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE res_config_installer; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_config_installer IS 'Config Installer';


--
-- Name: COLUMN res_config_installer.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_installer.create_uid IS 'Created by';


--
-- Name: COLUMN res_config_installer.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_installer.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_config_installer.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_installer.create_date IS 'Created on';


--
-- Name: COLUMN res_config_installer.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_installer.write_date IS 'Last Updated on';


--
-- Name: res_config_installer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_config_installer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_config_installer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_config_installer_id_seq OWNED BY public.res_config_installer.id;


--
-- Name: res_config_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_config_settings (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    web_app_name character varying,
    company_id integer NOT NULL,
    user_default_rights boolean,
    module_base_import boolean,
    module_google_calendar boolean,
    module_microsoft_calendar boolean,
    module_mail_plugin boolean,
    module_auth_oauth boolean,
    module_auth_ldap boolean,
    module_account_inter_company_rules boolean,
    module_voip boolean,
    module_web_unsplash boolean,
    module_partner_autocomplete boolean,
    module_base_geolocalize boolean,
    module_google_recaptcha boolean,
    module_website_cf_turnstile boolean,
    group_multi_currency boolean,
    show_effect boolean,
    module_product_images boolean,
    profiling_enabled_until timestamp without time zone,
    unsplash_access_key character varying,
    unsplash_app_id character varying
);


--
-- Name: TABLE res_config_settings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_config_settings IS 'Config Settings';


--
-- Name: COLUMN res_config_settings.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.create_uid IS 'Created by';


--
-- Name: COLUMN res_config_settings.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_config_settings.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.create_date IS 'Created on';


--
-- Name: COLUMN res_config_settings.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.write_date IS 'Last Updated on';


--
-- Name: COLUMN res_config_settings.web_app_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.web_app_name IS 'Web App Name';


--
-- Name: COLUMN res_config_settings.company_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.company_id IS 'Company';


--
-- Name: COLUMN res_config_settings.user_default_rights; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.user_default_rights IS 'Default Access Rights';


--
-- Name: COLUMN res_config_settings.module_base_import; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.module_base_import IS 'Allow users to import data from CSV/XLS/XLSX/ODS files';


--
-- Name: COLUMN res_config_settings.module_google_calendar; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.module_google_calendar IS 'Allow the users to synchronize their calendar  with Google Calendar';


--
-- Name: COLUMN res_config_settings.module_microsoft_calendar; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.module_microsoft_calendar IS 'Allow the users to synchronize their calendar with Outlook Calendar';


--
-- Name: COLUMN res_config_settings.module_mail_plugin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.module_mail_plugin IS 'Allow integration with the mail plugins';


--
-- Name: COLUMN res_config_settings.module_auth_oauth; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.module_auth_oauth IS 'Use external authentication providers (OAuth)';


--
-- Name: COLUMN res_config_settings.module_auth_ldap; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.module_auth_ldap IS 'LDAP Authentication';


--
-- Name: COLUMN res_config_settings.module_account_inter_company_rules; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.module_account_inter_company_rules IS 'Manage Inter Company';


--
-- Name: COLUMN res_config_settings.module_voip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.module_voip IS 'Asterisk (VoIP)';


--
-- Name: COLUMN res_config_settings.module_web_unsplash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.module_web_unsplash IS 'Unsplash Image Library';


--
-- Name: COLUMN res_config_settings.module_partner_autocomplete; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.module_partner_autocomplete IS 'Partner Autocomplete';


--
-- Name: COLUMN res_config_settings.module_base_geolocalize; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.module_base_geolocalize IS 'GeoLocalize';


--
-- Name: COLUMN res_config_settings.module_google_recaptcha; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.module_google_recaptcha IS 'reCAPTCHA';


--
-- Name: COLUMN res_config_settings.module_website_cf_turnstile; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.module_website_cf_turnstile IS 'Cloudflare Turnstile';


--
-- Name: COLUMN res_config_settings.group_multi_currency; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.group_multi_currency IS 'Multi-Currencies';


--
-- Name: COLUMN res_config_settings.show_effect; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.show_effect IS 'Show Effect';


--
-- Name: COLUMN res_config_settings.module_product_images; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.module_product_images IS 'Get product pictures using barcode';


--
-- Name: COLUMN res_config_settings.profiling_enabled_until; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.profiling_enabled_until IS 'Profiling enabled until';


--
-- Name: COLUMN res_config_settings.unsplash_access_key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.unsplash_access_key IS 'Access Key';


--
-- Name: COLUMN res_config_settings.unsplash_app_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_config_settings.unsplash_app_id IS 'Application ID';


--
-- Name: res_config_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_config_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_config_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_config_settings_id_seq OWNED BY public.res_config_settings.id;


--
-- Name: res_country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_country (
    id integer NOT NULL,
    address_view_id integer,
    currency_id integer,
    phone_code integer,
    create_uid integer,
    write_uid integer,
    code character varying(2) NOT NULL,
    name_position character varying,
    name jsonb NOT NULL,
    vat_label jsonb,
    address_format text,
    state_required boolean,
    zip_required boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE res_country; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_country IS 'Country';


--
-- Name: COLUMN res_country.address_view_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country.address_view_id IS 'Input View';


--
-- Name: COLUMN res_country.currency_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country.currency_id IS 'Currency';


--
-- Name: COLUMN res_country.phone_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country.phone_code IS 'Country Calling Code';


--
-- Name: COLUMN res_country.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country.create_uid IS 'Created by';


--
-- Name: COLUMN res_country.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_country.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country.code IS 'Country Code';


--
-- Name: COLUMN res_country.name_position; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country.name_position IS 'Customer Name Position';


--
-- Name: COLUMN res_country.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country.name IS 'Country Name';


--
-- Name: COLUMN res_country.vat_label; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country.vat_label IS 'Vat Label';


--
-- Name: COLUMN res_country.address_format; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country.address_format IS 'Layout in Reports';


--
-- Name: COLUMN res_country.state_required; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country.state_required IS 'State Required';


--
-- Name: COLUMN res_country.zip_required; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country.zip_required IS 'Zip Required';


--
-- Name: COLUMN res_country.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country.create_date IS 'Created on';


--
-- Name: COLUMN res_country.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country.write_date IS 'Last Updated on';


--
-- Name: res_country_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_country_group (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name jsonb NOT NULL,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE res_country_group; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_country_group IS 'Country Group';


--
-- Name: COLUMN res_country_group.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country_group.create_uid IS 'Created by';


--
-- Name: COLUMN res_country_group.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country_group.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_country_group.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country_group.name IS 'Name';


--
-- Name: COLUMN res_country_group.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country_group.create_date IS 'Created on';


--
-- Name: COLUMN res_country_group.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country_group.write_date IS 'Last Updated on';


--
-- Name: res_country_group_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_country_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_country_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_country_group_id_seq OWNED BY public.res_country_group.id;


--
-- Name: res_country_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_country_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_country_id_seq OWNED BY public.res_country.id;


--
-- Name: res_country_res_country_group_rel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_country_res_country_group_rel (
    res_country_id integer NOT NULL,
    res_country_group_id integer NOT NULL
);


--
-- Name: TABLE res_country_res_country_group_rel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_country_res_country_group_rel IS 'RELATION BETWEEN res_country AND res_country_group';


--
-- Name: res_country_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_country_state (
    id integer NOT NULL,
    country_id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    code character varying NOT NULL,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE res_country_state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_country_state IS 'Country state';


--
-- Name: COLUMN res_country_state.country_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country_state.country_id IS 'Country';


--
-- Name: COLUMN res_country_state.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country_state.create_uid IS 'Created by';


--
-- Name: COLUMN res_country_state.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country_state.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_country_state.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country_state.name IS 'State Name';


--
-- Name: COLUMN res_country_state.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country_state.code IS 'State Code';


--
-- Name: COLUMN res_country_state.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country_state.create_date IS 'Created on';


--
-- Name: COLUMN res_country_state.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_country_state.write_date IS 'Last Updated on';


--
-- Name: res_country_state_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_country_state_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_country_state_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_country_state_id_seq OWNED BY public.res_country_state.id;


--
-- Name: res_currency; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_currency (
    id integer NOT NULL,
    name character varying NOT NULL,
    symbol character varying NOT NULL,
    decimal_places integer,
    create_uid integer,
    write_uid integer,
    full_name character varying,
    "position" character varying,
    currency_unit_label character varying,
    currency_subunit_label character varying,
    rounding numeric,
    active boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    CONSTRAINT res_currency_rounding_gt_zero CHECK ((rounding > (0)::numeric))
);


--
-- Name: COLUMN res_currency.decimal_places; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency.decimal_places IS 'Decimal Places';


--
-- Name: COLUMN res_currency.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency.create_uid IS 'Created by';


--
-- Name: COLUMN res_currency.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_currency.full_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency.full_name IS 'Name';


--
-- Name: COLUMN res_currency."position"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency."position" IS 'Symbol Position';


--
-- Name: COLUMN res_currency.currency_unit_label; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency.currency_unit_label IS 'Currency Unit';


--
-- Name: COLUMN res_currency.currency_subunit_label; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency.currency_subunit_label IS 'Currency Subunit';


--
-- Name: COLUMN res_currency.rounding; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency.rounding IS 'Rounding Factor';


--
-- Name: COLUMN res_currency.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency.active IS 'Active';


--
-- Name: COLUMN res_currency.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency.create_date IS 'Created on';


--
-- Name: COLUMN res_currency.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency.write_date IS 'Last Updated on';


--
-- Name: CONSTRAINT res_currency_rounding_gt_zero ON res_currency; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT res_currency_rounding_gt_zero ON public.res_currency IS 'CHECK (rounding>0)';


--
-- Name: res_currency_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_currency_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_currency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_currency_id_seq OWNED BY public.res_currency.id;


--
-- Name: res_currency_rate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_currency_rate (
    id integer NOT NULL,
    currency_id integer NOT NULL,
    company_id integer,
    create_uid integer,
    write_uid integer,
    name date NOT NULL,
    rate numeric,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    CONSTRAINT res_currency_rate_currency_rate_check CHECK ((rate > (0)::numeric))
);


--
-- Name: TABLE res_currency_rate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_currency_rate IS 'Currency Rate';


--
-- Name: COLUMN res_currency_rate.currency_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency_rate.currency_id IS 'Currency';


--
-- Name: COLUMN res_currency_rate.company_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency_rate.company_id IS 'Company';


--
-- Name: COLUMN res_currency_rate.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency_rate.create_uid IS 'Created by';


--
-- Name: COLUMN res_currency_rate.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency_rate.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_currency_rate.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency_rate.name IS 'Date';


--
-- Name: COLUMN res_currency_rate.rate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency_rate.rate IS 'Technical Rate';


--
-- Name: COLUMN res_currency_rate.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency_rate.create_date IS 'Created on';


--
-- Name: COLUMN res_currency_rate.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_currency_rate.write_date IS 'Last Updated on';


--
-- Name: CONSTRAINT res_currency_rate_currency_rate_check ON res_currency_rate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT res_currency_rate_currency_rate_check ON public.res_currency_rate IS 'CHECK (rate>0)';


--
-- Name: res_currency_rate_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_currency_rate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_currency_rate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_currency_rate_id_seq OWNED BY public.res_currency_rate.id;


--
-- Name: res_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_groups (
    id integer NOT NULL,
    name jsonb NOT NULL,
    category_id integer,
    color integer,
    create_uid integer,
    write_uid integer,
    comment jsonb,
    share boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: COLUMN res_groups.category_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_groups.category_id IS 'Application';


--
-- Name: COLUMN res_groups.color; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_groups.color IS 'Color Index';


--
-- Name: COLUMN res_groups.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_groups.create_uid IS 'Created by';


--
-- Name: COLUMN res_groups.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_groups.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_groups.comment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_groups.comment IS 'Comment';


--
-- Name: COLUMN res_groups.share; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_groups.share IS 'Share Group';


--
-- Name: COLUMN res_groups.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_groups.create_date IS 'Created on';


--
-- Name: COLUMN res_groups.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_groups.write_date IS 'Last Updated on';


--
-- Name: res_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_groups_id_seq OWNED BY public.res_groups.id;


--
-- Name: res_groups_implied_rel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_groups_implied_rel (
    gid integer NOT NULL,
    hid integer NOT NULL
);


--
-- Name: TABLE res_groups_implied_rel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_groups_implied_rel IS 'RELATION BETWEEN res_groups AND res_groups';


--
-- Name: res_groups_report_rel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_groups_report_rel (
    uid integer NOT NULL,
    gid integer NOT NULL
);


--
-- Name: TABLE res_groups_report_rel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_groups_report_rel IS 'RELATION BETWEEN ir_act_report_xml AND res_groups';


--
-- Name: res_groups_users_rel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_groups_users_rel (
    gid integer NOT NULL,
    uid integer NOT NULL
);


--
-- Name: TABLE res_groups_users_rel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_groups_users_rel IS 'RELATION BETWEEN res_groups AND res_users';


--
-- Name: res_lang; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_lang (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    code character varying NOT NULL,
    iso_code character varying,
    url_code character varying NOT NULL,
    direction character varying NOT NULL,
    date_format character varying NOT NULL,
    time_format character varying NOT NULL,
    week_start character varying NOT NULL,
    "grouping" character varying NOT NULL,
    decimal_point character varying NOT NULL,
    thousands_sep character varying,
    active boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE res_lang; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_lang IS 'Languages';


--
-- Name: COLUMN res_lang.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_lang.create_uid IS 'Created by';


--
-- Name: COLUMN res_lang.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_lang.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_lang.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_lang.name IS 'Name';


--
-- Name: COLUMN res_lang.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_lang.code IS 'Locale Code';


--
-- Name: COLUMN res_lang.iso_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_lang.iso_code IS 'ISO code';


--
-- Name: COLUMN res_lang.url_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_lang.url_code IS 'URL Code';


--
-- Name: COLUMN res_lang.direction; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_lang.direction IS 'Direction';


--
-- Name: COLUMN res_lang.date_format; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_lang.date_format IS 'Date Format';


--
-- Name: COLUMN res_lang.time_format; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_lang.time_format IS 'Time Format';


--
-- Name: COLUMN res_lang.week_start; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_lang.week_start IS 'First Day of Week';


--
-- Name: COLUMN res_lang."grouping"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_lang."grouping" IS 'Separator Format';


--
-- Name: COLUMN res_lang.decimal_point; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_lang.decimal_point IS 'Decimal Separator';


--
-- Name: COLUMN res_lang.thousands_sep; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_lang.thousands_sep IS 'Thousands Separator';


--
-- Name: COLUMN res_lang.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_lang.active IS 'Active';


--
-- Name: COLUMN res_lang.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_lang.create_date IS 'Created on';


--
-- Name: COLUMN res_lang.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_lang.write_date IS 'Last Updated on';


--
-- Name: res_lang_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_lang_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_lang_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_lang_id_seq OWNED BY public.res_lang.id;


--
-- Name: res_lang_install_rel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_lang_install_rel (
    language_wizard_id integer NOT NULL,
    lang_id integer NOT NULL
);


--
-- Name: TABLE res_lang_install_rel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_lang_install_rel IS 'RELATION BETWEEN base_language_install AND res_lang';


--
-- Name: res_partner; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_partner (
    id integer NOT NULL,
    company_id integer,
    create_date timestamp without time zone,
    name character varying,
    title integer,
    parent_id integer,
    user_id integer,
    state_id integer,
    country_id integer,
    industry_id integer,
    color integer,
    commercial_partner_id integer,
    create_uid integer,
    write_uid integer,
    complete_name character varying,
    ref character varying,
    lang character varying,
    tz character varying,
    vat character varying,
    company_registry character varying,
    website character varying,
    function character varying,
    type character varying,
    street character varying,
    street2 character varying,
    zip character varying,
    city character varying,
    email character varying,
    phone character varying,
    mobile character varying,
    commercial_company_name character varying,
    company_name character varying,
    date date,
    comment text,
    partner_latitude numeric,
    partner_longitude numeric,
    active boolean,
    employee boolean,
    is_company boolean,
    partner_share boolean,
    write_date timestamp without time zone,
    CONSTRAINT res_partner_check_name CHECK (((((type)::text = 'contact'::text) AND (name IS NOT NULL)) OR ((type)::text <> 'contact'::text)))
);


--
-- Name: COLUMN res_partner.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.title IS 'Title';


--
-- Name: COLUMN res_partner.parent_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.parent_id IS 'Related Company';


--
-- Name: COLUMN res_partner.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.user_id IS 'Salesperson';


--
-- Name: COLUMN res_partner.state_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.state_id IS 'State';


--
-- Name: COLUMN res_partner.country_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.country_id IS 'Country';


--
-- Name: COLUMN res_partner.industry_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.industry_id IS 'Industry';


--
-- Name: COLUMN res_partner.color; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.color IS 'Color Index';


--
-- Name: COLUMN res_partner.commercial_partner_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.commercial_partner_id IS 'Commercial Entity';


--
-- Name: COLUMN res_partner.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.create_uid IS 'Created by';


--
-- Name: COLUMN res_partner.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_partner.complete_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.complete_name IS 'Complete Name';


--
-- Name: COLUMN res_partner.ref; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.ref IS 'Reference';


--
-- Name: COLUMN res_partner.lang; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.lang IS 'Language';


--
-- Name: COLUMN res_partner.tz; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.tz IS 'Timezone';


--
-- Name: COLUMN res_partner.vat; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.vat IS 'Tax ID';


--
-- Name: COLUMN res_partner.company_registry; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.company_registry IS 'Company ID';


--
-- Name: COLUMN res_partner.website; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.website IS 'Website Link';


--
-- Name: COLUMN res_partner.function; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.function IS 'Job Position';


--
-- Name: COLUMN res_partner.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.type IS 'Address Type';


--
-- Name: COLUMN res_partner.street; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.street IS 'Street';


--
-- Name: COLUMN res_partner.street2; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.street2 IS 'Street2';


--
-- Name: COLUMN res_partner.zip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.zip IS 'Zip';


--
-- Name: COLUMN res_partner.city; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.city IS 'City';


--
-- Name: COLUMN res_partner.email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.email IS 'Email';


--
-- Name: COLUMN res_partner.phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.phone IS 'Phone';


--
-- Name: COLUMN res_partner.mobile; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.mobile IS 'Mobile';


--
-- Name: COLUMN res_partner.commercial_company_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.commercial_company_name IS 'Company Name Entity';


--
-- Name: COLUMN res_partner.company_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.company_name IS 'Company Name';


--
-- Name: COLUMN res_partner.date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.date IS 'Date';


--
-- Name: COLUMN res_partner.comment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.comment IS 'Notes';


--
-- Name: COLUMN res_partner.partner_latitude; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.partner_latitude IS 'Geo Latitude';


--
-- Name: COLUMN res_partner.partner_longitude; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.partner_longitude IS 'Geo Longitude';


--
-- Name: COLUMN res_partner.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.active IS 'Active';


--
-- Name: COLUMN res_partner.employee; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.employee IS 'Employee';


--
-- Name: COLUMN res_partner.is_company; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.is_company IS 'Is a Company';


--
-- Name: COLUMN res_partner.partner_share; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.partner_share IS 'Share Partner';


--
-- Name: COLUMN res_partner.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner.write_date IS 'Last Updated on';


--
-- Name: CONSTRAINT res_partner_check_name ON res_partner; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT res_partner_check_name ON public.res_partner IS 'CHECK( (type=''contact'' AND name IS NOT NULL) or (type!=''contact'') )';


--
-- Name: res_partner_bank; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_partner_bank (
    id integer NOT NULL,
    partner_id integer NOT NULL,
    bank_id integer,
    sequence integer,
    currency_id integer,
    company_id integer,
    create_uid integer,
    write_uid integer,
    acc_number character varying NOT NULL,
    sanitized_acc_number character varying,
    acc_holder_name character varying,
    active boolean,
    allow_out_payment boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE res_partner_bank; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_partner_bank IS 'Bank Accounts';


--
-- Name: COLUMN res_partner_bank.partner_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_bank.partner_id IS 'Account Holder';


--
-- Name: COLUMN res_partner_bank.bank_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_bank.bank_id IS 'Bank';


--
-- Name: COLUMN res_partner_bank.sequence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_bank.sequence IS 'Sequence';


--
-- Name: COLUMN res_partner_bank.currency_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_bank.currency_id IS 'Currency';


--
-- Name: COLUMN res_partner_bank.company_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_bank.company_id IS 'Company';


--
-- Name: COLUMN res_partner_bank.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_bank.create_uid IS 'Created by';


--
-- Name: COLUMN res_partner_bank.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_bank.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_partner_bank.acc_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_bank.acc_number IS 'Account Number';


--
-- Name: COLUMN res_partner_bank.sanitized_acc_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_bank.sanitized_acc_number IS 'Sanitized Account Number';


--
-- Name: COLUMN res_partner_bank.acc_holder_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_bank.acc_holder_name IS 'Account Holder Name';


--
-- Name: COLUMN res_partner_bank.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_bank.active IS 'Active';


--
-- Name: COLUMN res_partner_bank.allow_out_payment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_bank.allow_out_payment IS 'Send Money';


--
-- Name: COLUMN res_partner_bank.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_bank.create_date IS 'Created on';


--
-- Name: COLUMN res_partner_bank.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_bank.write_date IS 'Last Updated on';


--
-- Name: res_partner_bank_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_partner_bank_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_partner_bank_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_partner_bank_id_seq OWNED BY public.res_partner_bank.id;


--
-- Name: res_partner_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_partner_category (
    id integer NOT NULL,
    color integer,
    parent_id integer,
    create_uid integer,
    write_uid integer,
    parent_path character varying,
    name jsonb NOT NULL,
    active boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE res_partner_category; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_partner_category IS 'Partner Tags';


--
-- Name: COLUMN res_partner_category.color; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_category.color IS 'Color';


--
-- Name: COLUMN res_partner_category.parent_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_category.parent_id IS 'Parent Category';


--
-- Name: COLUMN res_partner_category.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_category.create_uid IS 'Created by';


--
-- Name: COLUMN res_partner_category.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_category.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_partner_category.parent_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_category.parent_path IS 'Parent Path';


--
-- Name: COLUMN res_partner_category.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_category.name IS 'Tag Name';


--
-- Name: COLUMN res_partner_category.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_category.active IS 'Active';


--
-- Name: COLUMN res_partner_category.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_category.create_date IS 'Created on';


--
-- Name: COLUMN res_partner_category.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_category.write_date IS 'Last Updated on';


--
-- Name: res_partner_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_partner_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_partner_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_partner_category_id_seq OWNED BY public.res_partner_category.id;


--
-- Name: res_partner_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_partner_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_partner_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_partner_id_seq OWNED BY public.res_partner.id;


--
-- Name: res_partner_industry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_partner_industry (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name jsonb,
    full_name jsonb,
    active boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE res_partner_industry; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_partner_industry IS 'Industry';


--
-- Name: COLUMN res_partner_industry.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_industry.create_uid IS 'Created by';


--
-- Name: COLUMN res_partner_industry.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_industry.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_partner_industry.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_industry.name IS 'Name';


--
-- Name: COLUMN res_partner_industry.full_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_industry.full_name IS 'Full Name';


--
-- Name: COLUMN res_partner_industry.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_industry.active IS 'Active';


--
-- Name: COLUMN res_partner_industry.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_industry.create_date IS 'Created on';


--
-- Name: COLUMN res_partner_industry.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_industry.write_date IS 'Last Updated on';


--
-- Name: res_partner_industry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_partner_industry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_partner_industry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_partner_industry_id_seq OWNED BY public.res_partner_industry.id;


--
-- Name: res_partner_res_partner_category_rel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_partner_res_partner_category_rel (
    category_id integer NOT NULL,
    partner_id integer NOT NULL
);


--
-- Name: TABLE res_partner_res_partner_category_rel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_partner_res_partner_category_rel IS 'RELATION BETWEEN res_partner_category AND res_partner';


--
-- Name: res_partner_title; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_partner_title (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name jsonb NOT NULL,
    shortcut jsonb,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE res_partner_title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_partner_title IS 'Partner Title';


--
-- Name: COLUMN res_partner_title.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_title.create_uid IS 'Created by';


--
-- Name: COLUMN res_partner_title.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_title.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_partner_title.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_title.name IS 'Title';


--
-- Name: COLUMN res_partner_title.shortcut; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_title.shortcut IS 'Abbreviation';


--
-- Name: COLUMN res_partner_title.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_title.create_date IS 'Created on';


--
-- Name: COLUMN res_partner_title.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_partner_title.write_date IS 'Last Updated on';


--
-- Name: res_partner_title_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_partner_title_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_partner_title_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_partner_title_id_seq OWNED BY public.res_partner_title.id;


--
-- Name: res_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_users (
    id integer NOT NULL,
    company_id integer NOT NULL,
    partner_id integer NOT NULL,
    active boolean DEFAULT true,
    create_date timestamp without time zone,
    login character varying NOT NULL,
    password character varying,
    action_id integer,
    create_uid integer,
    write_uid integer,
    signature text,
    share boolean,
    write_date timestamp without time zone,
    totp_secret character varying
);


--
-- Name: COLUMN res_users.action_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users.action_id IS 'Home Action';


--
-- Name: COLUMN res_users.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users.create_uid IS 'Created by';


--
-- Name: COLUMN res_users.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_users.signature; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users.signature IS 'Email Signature';


--
-- Name: COLUMN res_users.share; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users.share IS 'Share User';


--
-- Name: COLUMN res_users.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users.write_date IS 'Last Updated on';


--
-- Name: res_users_apikeys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_users_apikeys (
    id integer NOT NULL,
    name character varying NOT NULL,
    user_id integer NOT NULL,
    scope character varying,
    index character varying(8),
    key character varying,
    create_date timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
    CONSTRAINT res_users_apikeys_index_check CHECK ((char_length((index)::text) = 8))
);


--
-- Name: res_users_apikeys_description; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_users_apikeys_description (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE res_users_apikeys_description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_users_apikeys_description IS 'API Key Description';


--
-- Name: COLUMN res_users_apikeys_description.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_apikeys_description.create_uid IS 'Created by';


--
-- Name: COLUMN res_users_apikeys_description.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_apikeys_description.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_users_apikeys_description.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_apikeys_description.name IS 'Description';


--
-- Name: COLUMN res_users_apikeys_description.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_apikeys_description.create_date IS 'Created on';


--
-- Name: COLUMN res_users_apikeys_description.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_apikeys_description.write_date IS 'Last Updated on';


--
-- Name: res_users_apikeys_description_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_users_apikeys_description_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_users_apikeys_description_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_users_apikeys_description_id_seq OWNED BY public.res_users_apikeys_description.id;


--
-- Name: res_users_apikeys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_users_apikeys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_users_apikeys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_users_apikeys_id_seq OWNED BY public.res_users_apikeys.id;


--
-- Name: res_users_deletion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_users_deletion (
    id integer NOT NULL,
    user_id integer,
    user_id_int integer,
    create_uid integer,
    write_uid integer,
    state character varying NOT NULL,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE res_users_deletion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_users_deletion IS 'Users Deletion Request';


--
-- Name: COLUMN res_users_deletion.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_deletion.user_id IS 'User';


--
-- Name: COLUMN res_users_deletion.user_id_int; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_deletion.user_id_int IS 'User Id';


--
-- Name: COLUMN res_users_deletion.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_deletion.create_uid IS 'Created by';


--
-- Name: COLUMN res_users_deletion.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_deletion.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_users_deletion.state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_deletion.state IS 'State';


--
-- Name: COLUMN res_users_deletion.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_deletion.create_date IS 'Created on';


--
-- Name: COLUMN res_users_deletion.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_deletion.write_date IS 'Last Updated on';


--
-- Name: res_users_deletion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_users_deletion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_users_deletion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_users_deletion_id_seq OWNED BY public.res_users_deletion.id;


--
-- Name: res_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_users_id_seq OWNED BY public.res_users.id;


--
-- Name: res_users_identitycheck; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_users_identitycheck (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    request character varying,
    password character varying,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE res_users_identitycheck; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_users_identitycheck IS 'Password Check Wizard';


--
-- Name: COLUMN res_users_identitycheck.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_identitycheck.create_uid IS 'Created by';


--
-- Name: COLUMN res_users_identitycheck.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_identitycheck.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_users_identitycheck.request; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_identitycheck.request IS 'Request';


--
-- Name: COLUMN res_users_identitycheck.password; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_identitycheck.password IS 'Password';


--
-- Name: COLUMN res_users_identitycheck.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_identitycheck.create_date IS 'Created on';


--
-- Name: COLUMN res_users_identitycheck.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_identitycheck.write_date IS 'Last Updated on';


--
-- Name: res_users_identitycheck_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_users_identitycheck_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_users_identitycheck_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_users_identitycheck_id_seq OWNED BY public.res_users_identitycheck.id;


--
-- Name: res_users_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_users_log (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE res_users_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_users_log IS 'Users Log';


--
-- Name: COLUMN res_users_log.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_log.create_uid IS 'Created by';


--
-- Name: COLUMN res_users_log.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_log.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_users_log.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_log.create_date IS 'Created on';


--
-- Name: COLUMN res_users_log.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_log.write_date IS 'Last Updated on';


--
-- Name: res_users_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_users_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_users_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_users_log_id_seq OWNED BY public.res_users_log.id;


--
-- Name: res_users_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.res_users_settings (
    id integer NOT NULL,
    user_id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE res_users_settings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.res_users_settings IS 'User Settings';


--
-- Name: COLUMN res_users_settings.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_settings.user_id IS 'User';


--
-- Name: COLUMN res_users_settings.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_settings.create_uid IS 'Created by';


--
-- Name: COLUMN res_users_settings.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_settings.write_uid IS 'Last Updated by';


--
-- Name: COLUMN res_users_settings.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_settings.create_date IS 'Created on';


--
-- Name: COLUMN res_users_settings.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.res_users_settings.write_date IS 'Last Updated on';


--
-- Name: res_users_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.res_users_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: res_users_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.res_users_settings_id_seq OWNED BY public.res_users_settings.id;


--
-- Name: reset_view_arch_wizard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reset_view_arch_wizard (
    id integer NOT NULL,
    view_id integer,
    compare_view_id integer,
    create_uid integer,
    write_uid integer,
    reset_mode character varying NOT NULL,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE reset_view_arch_wizard; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.reset_view_arch_wizard IS 'Reset View Architecture Wizard';


--
-- Name: COLUMN reset_view_arch_wizard.view_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reset_view_arch_wizard.view_id IS 'View';


--
-- Name: COLUMN reset_view_arch_wizard.compare_view_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reset_view_arch_wizard.compare_view_id IS 'Compare To View';


--
-- Name: COLUMN reset_view_arch_wizard.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reset_view_arch_wizard.create_uid IS 'Created by';


--
-- Name: COLUMN reset_view_arch_wizard.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reset_view_arch_wizard.write_uid IS 'Last Updated by';


--
-- Name: COLUMN reset_view_arch_wizard.reset_mode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reset_view_arch_wizard.reset_mode IS 'Reset Mode';


--
-- Name: COLUMN reset_view_arch_wizard.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reset_view_arch_wizard.create_date IS 'Created on';


--
-- Name: COLUMN reset_view_arch_wizard.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reset_view_arch_wizard.write_date IS 'Last Updated on';


--
-- Name: reset_view_arch_wizard_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reset_view_arch_wizard_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reset_view_arch_wizard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reset_view_arch_wizard_id_seq OWNED BY public.reset_view_arch_wizard.id;


--
-- Name: rule_group_rel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rule_group_rel (
    rule_group_id integer NOT NULL,
    group_id integer NOT NULL
);


--
-- Name: TABLE rule_group_rel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.rule_group_rel IS 'RELATION BETWEEN ir_rule AND res_groups';


--
-- Name: web_editor_converter_test; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.web_editor_converter_test (
    id integer NOT NULL,
    "integer" integer,
    many2one integer,
    create_uid integer,
    write_uid integer,
    "char" character varying,
    selection_str character varying,
    date date,
    html text,
    text text,
    "numeric" numeric,
    datetime timestamp without time zone,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    "float" double precision,
    "binary" bytea
);


--
-- Name: TABLE web_editor_converter_test; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.web_editor_converter_test IS 'Web Editor Converter Test';


--
-- Name: COLUMN web_editor_converter_test."integer"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test."integer" IS 'Integer';


--
-- Name: COLUMN web_editor_converter_test.many2one; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test.many2one IS 'Many2One';


--
-- Name: COLUMN web_editor_converter_test.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test.create_uid IS 'Created by';


--
-- Name: COLUMN web_editor_converter_test.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test.write_uid IS 'Last Updated by';


--
-- Name: COLUMN web_editor_converter_test."char"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test."char" IS 'Char';


--
-- Name: COLUMN web_editor_converter_test.selection_str; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test.selection_str IS 'Lorsqu''un pancake prend l''avion à destination de Toronto et qu''il fait une escale technique à St Claude, on dit:';


--
-- Name: COLUMN web_editor_converter_test.date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test.date IS 'Date';


--
-- Name: COLUMN web_editor_converter_test.html; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test.html IS 'Html';


--
-- Name: COLUMN web_editor_converter_test.text; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test.text IS 'Text';


--
-- Name: COLUMN web_editor_converter_test."numeric"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test."numeric" IS 'Numeric';


--
-- Name: COLUMN web_editor_converter_test.datetime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test.datetime IS 'Datetime';


--
-- Name: COLUMN web_editor_converter_test.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test.create_date IS 'Created on';


--
-- Name: COLUMN web_editor_converter_test.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test.write_date IS 'Last Updated on';


--
-- Name: COLUMN web_editor_converter_test."float"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test."float" IS 'Float';


--
-- Name: COLUMN web_editor_converter_test."binary"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test."binary" IS 'Binary';


--
-- Name: web_editor_converter_test_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.web_editor_converter_test_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_editor_converter_test_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.web_editor_converter_test_id_seq OWNED BY public.web_editor_converter_test.id;


--
-- Name: web_editor_converter_test_sub; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.web_editor_converter_test_sub (
    id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name character varying,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE web_editor_converter_test_sub; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.web_editor_converter_test_sub IS 'Web Editor Converter Subtest';


--
-- Name: COLUMN web_editor_converter_test_sub.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test_sub.create_uid IS 'Created by';


--
-- Name: COLUMN web_editor_converter_test_sub.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test_sub.write_uid IS 'Last Updated by';


--
-- Name: COLUMN web_editor_converter_test_sub.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test_sub.name IS 'Name';


--
-- Name: COLUMN web_editor_converter_test_sub.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test_sub.create_date IS 'Created on';


--
-- Name: COLUMN web_editor_converter_test_sub.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_editor_converter_test_sub.write_date IS 'Last Updated on';


--
-- Name: web_editor_converter_test_sub_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.web_editor_converter_test_sub_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_editor_converter_test_sub_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.web_editor_converter_test_sub_id_seq OWNED BY public.web_editor_converter_test_sub.id;


--
-- Name: web_tour_tour; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.web_tour_tour (
    id integer NOT NULL,
    user_id integer,
    name character varying NOT NULL
);


--
-- Name: TABLE web_tour_tour; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.web_tour_tour IS 'Tours';


--
-- Name: COLUMN web_tour_tour.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_tour_tour.user_id IS 'Consumed by';


--
-- Name: COLUMN web_tour_tour.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.web_tour_tour.name IS 'Tour name';


--
-- Name: web_tour_tour_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.web_tour_tour_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_tour_tour_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.web_tour_tour_id_seq OWNED BY public.web_tour_tour.id;


--
-- Name: wizard_ir_model_menu_create; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wizard_ir_model_menu_create (
    id integer NOT NULL,
    menu_id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    name character varying NOT NULL,
    create_date timestamp without time zone,
    write_date timestamp without time zone
);


--
-- Name: TABLE wizard_ir_model_menu_create; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.wizard_ir_model_menu_create IS 'Create Menu Wizard';


--
-- Name: COLUMN wizard_ir_model_menu_create.menu_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.wizard_ir_model_menu_create.menu_id IS 'Parent Menu';


--
-- Name: COLUMN wizard_ir_model_menu_create.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.wizard_ir_model_menu_create.create_uid IS 'Created by';


--
-- Name: COLUMN wizard_ir_model_menu_create.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.wizard_ir_model_menu_create.write_uid IS 'Last Updated by';


--
-- Name: COLUMN wizard_ir_model_menu_create.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.wizard_ir_model_menu_create.name IS 'Menu Name';


--
-- Name: COLUMN wizard_ir_model_menu_create.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.wizard_ir_model_menu_create.create_date IS 'Created on';


--
-- Name: COLUMN wizard_ir_model_menu_create.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.wizard_ir_model_menu_create.write_date IS 'Last Updated on';


--
-- Name: wizard_ir_model_menu_create_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wizard_ir_model_menu_create_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wizard_ir_model_menu_create_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wizard_ir_model_menu_create_id_seq OWNED BY public.wizard_ir_model_menu_create.id;


--
-- Name: auth_totp_device id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_totp_device ALTER COLUMN id SET DEFAULT nextval('public.auth_totp_device_id_seq'::regclass);


--
-- Name: auth_totp_wizard id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_totp_wizard ALTER COLUMN id SET DEFAULT nextval('public.auth_totp_wizard_id_seq'::regclass);


--
-- Name: base_document_layout id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_document_layout ALTER COLUMN id SET DEFAULT nextval('public.base_document_layout_id_seq'::regclass);


--
-- Name: base_enable_profiling_wizard id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_enable_profiling_wizard ALTER COLUMN id SET DEFAULT nextval('public.base_enable_profiling_wizard_id_seq'::regclass);


--
-- Name: base_import_import id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_import_import ALTER COLUMN id SET DEFAULT nextval('public.base_import_import_id_seq'::regclass);


--
-- Name: base_import_mapping id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_import_mapping ALTER COLUMN id SET DEFAULT nextval('public.base_import_mapping_id_seq'::regclass);


--
-- Name: base_import_module id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_import_module ALTER COLUMN id SET DEFAULT nextval('public.base_import_module_id_seq'::regclass);


--
-- Name: base_language_export id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_language_export ALTER COLUMN id SET DEFAULT nextval('public.base_language_export_id_seq'::regclass);


--
-- Name: base_language_import id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_language_import ALTER COLUMN id SET DEFAULT nextval('public.base_language_import_id_seq'::regclass);


--
-- Name: base_language_install id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_language_install ALTER COLUMN id SET DEFAULT nextval('public.base_language_install_id_seq'::regclass);


--
-- Name: base_module_uninstall id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_module_uninstall ALTER COLUMN id SET DEFAULT nextval('public.base_module_uninstall_id_seq'::regclass);


--
-- Name: base_module_update id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_module_update ALTER COLUMN id SET DEFAULT nextval('public.base_module_update_id_seq'::regclass);


--
-- Name: base_module_upgrade id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_module_upgrade ALTER COLUMN id SET DEFAULT nextval('public.base_module_upgrade_id_seq'::regclass);


--
-- Name: base_partner_merge_automatic_wizard id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_partner_merge_automatic_wizard ALTER COLUMN id SET DEFAULT nextval('public.base_partner_merge_automatic_wizard_id_seq'::regclass);


--
-- Name: base_partner_merge_line id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_partner_merge_line ALTER COLUMN id SET DEFAULT nextval('public.base_partner_merge_line_id_seq'::regclass);


--
-- Name: bus_bus id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bus_bus ALTER COLUMN id SET DEFAULT nextval('public.bus_bus_id_seq'::regclass);


--
-- Name: bus_presence id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bus_presence ALTER COLUMN id SET DEFAULT nextval('public.bus_presence_id_seq'::regclass);


--
-- Name: change_password_own id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_password_own ALTER COLUMN id SET DEFAULT nextval('public.change_password_own_id_seq'::regclass);


--
-- Name: change_password_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_password_user ALTER COLUMN id SET DEFAULT nextval('public.change_password_user_id_seq'::regclass);


--
-- Name: change_password_wizard id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_password_wizard ALTER COLUMN id SET DEFAULT nextval('public.change_password_wizard_id_seq'::regclass);


--
-- Name: decimal_precision id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decimal_precision ALTER COLUMN id SET DEFAULT nextval('public.decimal_precision_id_seq'::regclass);


--
-- Name: iap_account id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.iap_account ALTER COLUMN id SET DEFAULT nextval('public.iap_account_id_seq'::regclass);


--
-- Name: iap_account_info id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.iap_account_info ALTER COLUMN id SET DEFAULT nextval('public.iap_account_info_id_seq'::regclass);


--
-- Name: ir_act_client id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_client ALTER COLUMN id SET DEFAULT nextval('public.ir_actions_id_seq'::regclass);


--
-- Name: ir_act_report_xml id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_report_xml ALTER COLUMN id SET DEFAULT nextval('public.ir_actions_id_seq'::regclass);


--
-- Name: ir_act_server id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server ALTER COLUMN id SET DEFAULT nextval('public.ir_actions_id_seq'::regclass);


--
-- Name: ir_act_url id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_url ALTER COLUMN id SET DEFAULT nextval('public.ir_actions_id_seq'::regclass);


--
-- Name: ir_act_window id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_window ALTER COLUMN id SET DEFAULT nextval('public.ir_actions_id_seq'::regclass);


--
-- Name: ir_act_window_view id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_window_view ALTER COLUMN id SET DEFAULT nextval('public.ir_act_window_view_id_seq'::regclass);


--
-- Name: ir_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_actions ALTER COLUMN id SET DEFAULT nextval('public.ir_actions_id_seq'::regclass);


--
-- Name: ir_actions_todo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_actions_todo ALTER COLUMN id SET DEFAULT nextval('public.ir_actions_todo_id_seq'::regclass);


--
-- Name: ir_asset id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_asset ALTER COLUMN id SET DEFAULT nextval('public.ir_asset_id_seq'::regclass);


--
-- Name: ir_attachment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_attachment ALTER COLUMN id SET DEFAULT nextval('public.ir_attachment_id_seq'::regclass);


--
-- Name: ir_config_parameter id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_config_parameter ALTER COLUMN id SET DEFAULT nextval('public.ir_config_parameter_id_seq'::regclass);


--
-- Name: ir_cron id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_cron ALTER COLUMN id SET DEFAULT nextval('public.ir_cron_id_seq'::regclass);


--
-- Name: ir_cron_trigger id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_cron_trigger ALTER COLUMN id SET DEFAULT nextval('public.ir_cron_trigger_id_seq'::regclass);


--
-- Name: ir_default id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_default ALTER COLUMN id SET DEFAULT nextval('public.ir_default_id_seq'::regclass);


--
-- Name: ir_demo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_demo ALTER COLUMN id SET DEFAULT nextval('public.ir_demo_id_seq'::regclass);


--
-- Name: ir_demo_failure id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_demo_failure ALTER COLUMN id SET DEFAULT nextval('public.ir_demo_failure_id_seq'::regclass);


--
-- Name: ir_demo_failure_wizard id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_demo_failure_wizard ALTER COLUMN id SET DEFAULT nextval('public.ir_demo_failure_wizard_id_seq'::regclass);


--
-- Name: ir_exports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_exports ALTER COLUMN id SET DEFAULT nextval('public.ir_exports_id_seq'::regclass);


--
-- Name: ir_exports_line id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_exports_line ALTER COLUMN id SET DEFAULT nextval('public.ir_exports_line_id_seq'::regclass);


--
-- Name: ir_filters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_filters ALTER COLUMN id SET DEFAULT nextval('public.ir_filters_id_seq'::regclass);


--
-- Name: ir_logging id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_logging ALTER COLUMN id SET DEFAULT nextval('public.ir_logging_id_seq'::regclass);


--
-- Name: ir_mail_server id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_mail_server ALTER COLUMN id SET DEFAULT nextval('public.ir_mail_server_id_seq'::regclass);


--
-- Name: ir_model id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model ALTER COLUMN id SET DEFAULT nextval('public.ir_model_id_seq'::regclass);


--
-- Name: ir_model_access id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_access ALTER COLUMN id SET DEFAULT nextval('public.ir_model_access_id_seq'::regclass);


--
-- Name: ir_model_constraint id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_constraint ALTER COLUMN id SET DEFAULT nextval('public.ir_model_constraint_id_seq'::regclass);


--
-- Name: ir_model_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_data ALTER COLUMN id SET DEFAULT nextval('public.ir_model_data_id_seq'::regclass);


--
-- Name: ir_model_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields ALTER COLUMN id SET DEFAULT nextval('public.ir_model_fields_id_seq'::regclass);


--
-- Name: ir_model_fields_selection id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields_selection ALTER COLUMN id SET DEFAULT nextval('public.ir_model_fields_selection_id_seq'::regclass);


--
-- Name: ir_model_inherit id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_inherit ALTER COLUMN id SET DEFAULT nextval('public.ir_model_inherit_id_seq'::regclass);


--
-- Name: ir_model_relation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_relation ALTER COLUMN id SET DEFAULT nextval('public.ir_model_relation_id_seq'::regclass);


--
-- Name: ir_module_category id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_category ALTER COLUMN id SET DEFAULT nextval('public.ir_module_category_id_seq'::regclass);


--
-- Name: ir_module_module id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_module ALTER COLUMN id SET DEFAULT nextval('public.ir_module_module_id_seq'::regclass);


--
-- Name: ir_module_module_dependency id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_module_dependency ALTER COLUMN id SET DEFAULT nextval('public.ir_module_module_dependency_id_seq'::regclass);


--
-- Name: ir_module_module_exclusion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_module_exclusion ALTER COLUMN id SET DEFAULT nextval('public.ir_module_module_exclusion_id_seq'::regclass);


--
-- Name: ir_profile id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_profile ALTER COLUMN id SET DEFAULT nextval('public.ir_profile_id_seq'::regclass);


--
-- Name: ir_property id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_property ALTER COLUMN id SET DEFAULT nextval('public.ir_property_id_seq'::regclass);


--
-- Name: ir_rule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_rule ALTER COLUMN id SET DEFAULT nextval('public.ir_rule_id_seq'::regclass);


--
-- Name: ir_sequence id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_sequence ALTER COLUMN id SET DEFAULT nextval('public.ir_sequence_id_seq'::regclass);


--
-- Name: ir_sequence_date_range id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_sequence_date_range ALTER COLUMN id SET DEFAULT nextval('public.ir_sequence_date_range_id_seq'::regclass);


--
-- Name: ir_ui_menu id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_menu ALTER COLUMN id SET DEFAULT nextval('public.ir_ui_menu_id_seq'::regclass);


--
-- Name: ir_ui_view id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_view ALTER COLUMN id SET DEFAULT nextval('public.ir_ui_view_id_seq'::regclass);


--
-- Name: ir_ui_view_custom id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_view_custom ALTER COLUMN id SET DEFAULT nextval('public.ir_ui_view_custom_id_seq'::regclass);


--
-- Name: report_layout id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_layout ALTER COLUMN id SET DEFAULT nextval('public.report_layout_id_seq'::regclass);


--
-- Name: report_paperformat id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_paperformat ALTER COLUMN id SET DEFAULT nextval('public.report_paperformat_id_seq'::regclass);


--
-- Name: res_bank id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_bank ALTER COLUMN id SET DEFAULT nextval('public.res_bank_id_seq'::regclass);


--
-- Name: res_company id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_company ALTER COLUMN id SET DEFAULT nextval('public.res_company_id_seq'::regclass);


--
-- Name: res_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_config ALTER COLUMN id SET DEFAULT nextval('public.res_config_id_seq'::regclass);


--
-- Name: res_config_installer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_config_installer ALTER COLUMN id SET DEFAULT nextval('public.res_config_installer_id_seq'::regclass);


--
-- Name: res_config_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_config_settings ALTER COLUMN id SET DEFAULT nextval('public.res_config_settings_id_seq'::regclass);


--
-- Name: res_country id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country ALTER COLUMN id SET DEFAULT nextval('public.res_country_id_seq'::regclass);


--
-- Name: res_country_group id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country_group ALTER COLUMN id SET DEFAULT nextval('public.res_country_group_id_seq'::regclass);


--
-- Name: res_country_state id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country_state ALTER COLUMN id SET DEFAULT nextval('public.res_country_state_id_seq'::regclass);


--
-- Name: res_currency id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_currency ALTER COLUMN id SET DEFAULT nextval('public.res_currency_id_seq'::regclass);


--
-- Name: res_currency_rate id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_currency_rate ALTER COLUMN id SET DEFAULT nextval('public.res_currency_rate_id_seq'::regclass);


--
-- Name: res_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_groups ALTER COLUMN id SET DEFAULT nextval('public.res_groups_id_seq'::regclass);


--
-- Name: res_lang id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_lang ALTER COLUMN id SET DEFAULT nextval('public.res_lang_id_seq'::regclass);


--
-- Name: res_partner id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner ALTER COLUMN id SET DEFAULT nextval('public.res_partner_id_seq'::regclass);


--
-- Name: res_partner_bank id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_bank ALTER COLUMN id SET DEFAULT nextval('public.res_partner_bank_id_seq'::regclass);


--
-- Name: res_partner_category id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_category ALTER COLUMN id SET DEFAULT nextval('public.res_partner_category_id_seq'::regclass);


--
-- Name: res_partner_industry id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_industry ALTER COLUMN id SET DEFAULT nextval('public.res_partner_industry_id_seq'::regclass);


--
-- Name: res_partner_title id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_title ALTER COLUMN id SET DEFAULT nextval('public.res_partner_title_id_seq'::regclass);


--
-- Name: res_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users ALTER COLUMN id SET DEFAULT nextval('public.res_users_id_seq'::regclass);


--
-- Name: res_users_apikeys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_apikeys ALTER COLUMN id SET DEFAULT nextval('public.res_users_apikeys_id_seq'::regclass);


--
-- Name: res_users_apikeys_description id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_apikeys_description ALTER COLUMN id SET DEFAULT nextval('public.res_users_apikeys_description_id_seq'::regclass);


--
-- Name: res_users_deletion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_deletion ALTER COLUMN id SET DEFAULT nextval('public.res_users_deletion_id_seq'::regclass);


--
-- Name: res_users_identitycheck id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_identitycheck ALTER COLUMN id SET DEFAULT nextval('public.res_users_identitycheck_id_seq'::regclass);


--
-- Name: res_users_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_log ALTER COLUMN id SET DEFAULT nextval('public.res_users_log_id_seq'::regclass);


--
-- Name: res_users_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_settings ALTER COLUMN id SET DEFAULT nextval('public.res_users_settings_id_seq'::regclass);


--
-- Name: reset_view_arch_wizard id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reset_view_arch_wizard ALTER COLUMN id SET DEFAULT nextval('public.reset_view_arch_wizard_id_seq'::regclass);


--
-- Name: web_editor_converter_test id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_editor_converter_test ALTER COLUMN id SET DEFAULT nextval('public.web_editor_converter_test_id_seq'::regclass);


--
-- Name: web_editor_converter_test_sub id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_editor_converter_test_sub ALTER COLUMN id SET DEFAULT nextval('public.web_editor_converter_test_sub_id_seq'::regclass);


--
-- Name: web_tour_tour id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_tour_tour ALTER COLUMN id SET DEFAULT nextval('public.web_tour_tour_id_seq'::regclass);


--
-- Name: wizard_ir_model_menu_create id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wizard_ir_model_menu_create ALTER COLUMN id SET DEFAULT nextval('public.wizard_ir_model_menu_create_id_seq'::regclass);


--
-- Name: auth_totp_device auth_totp_device_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_totp_device
    ADD CONSTRAINT auth_totp_device_pkey PRIMARY KEY (id);


--
-- Name: auth_totp_wizard auth_totp_wizard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_totp_wizard
    ADD CONSTRAINT auth_totp_wizard_pkey PRIMARY KEY (id);


--
-- Name: base_document_layout base_document_layout_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_document_layout
    ADD CONSTRAINT base_document_layout_pkey PRIMARY KEY (id);


--
-- Name: base_enable_profiling_wizard base_enable_profiling_wizard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_enable_profiling_wizard
    ADD CONSTRAINT base_enable_profiling_wizard_pkey PRIMARY KEY (id);


--
-- Name: base_import_import base_import_import_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_import_import
    ADD CONSTRAINT base_import_import_pkey PRIMARY KEY (id);


--
-- Name: base_import_mapping base_import_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_import_mapping
    ADD CONSTRAINT base_import_mapping_pkey PRIMARY KEY (id);


--
-- Name: base_import_module base_import_module_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_import_module
    ADD CONSTRAINT base_import_module_pkey PRIMARY KEY (id);


--
-- Name: base_language_export base_language_export_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_language_export
    ADD CONSTRAINT base_language_export_pkey PRIMARY KEY (id);


--
-- Name: base_language_import base_language_import_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_language_import
    ADD CONSTRAINT base_language_import_pkey PRIMARY KEY (id);


--
-- Name: base_language_install base_language_install_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_language_install
    ADD CONSTRAINT base_language_install_pkey PRIMARY KEY (id);


--
-- Name: base_module_uninstall base_module_uninstall_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_module_uninstall
    ADD CONSTRAINT base_module_uninstall_pkey PRIMARY KEY (id);


--
-- Name: base_module_update base_module_update_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_module_update
    ADD CONSTRAINT base_module_update_pkey PRIMARY KEY (id);


--
-- Name: base_module_upgrade base_module_upgrade_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_module_upgrade
    ADD CONSTRAINT base_module_upgrade_pkey PRIMARY KEY (id);


--
-- Name: base_partner_merge_automatic_wizard base_partner_merge_automatic_wizard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_partner_merge_automatic_wizard
    ADD CONSTRAINT base_partner_merge_automatic_wizard_pkey PRIMARY KEY (id);


--
-- Name: base_partner_merge_automatic_wizard_res_partner_rel base_partner_merge_automatic_wizard_res_partner_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_partner_merge_automatic_wizard_res_partner_rel
    ADD CONSTRAINT base_partner_merge_automatic_wizard_res_partner_rel_pkey PRIMARY KEY (base_partner_merge_automatic_wizard_id, res_partner_id);


--
-- Name: base_partner_merge_line base_partner_merge_line_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_partner_merge_line
    ADD CONSTRAINT base_partner_merge_line_pkey PRIMARY KEY (id);


--
-- Name: bus_bus bus_bus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bus_bus
    ADD CONSTRAINT bus_bus_pkey PRIMARY KEY (id);


--
-- Name: bus_presence bus_presence_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bus_presence
    ADD CONSTRAINT bus_presence_pkey PRIMARY KEY (id);


--
-- Name: change_password_own change_password_own_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_password_own
    ADD CONSTRAINT change_password_own_pkey PRIMARY KEY (id);


--
-- Name: change_password_user change_password_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_password_user
    ADD CONSTRAINT change_password_user_pkey PRIMARY KEY (id);


--
-- Name: change_password_wizard change_password_wizard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_password_wizard
    ADD CONSTRAINT change_password_wizard_pkey PRIMARY KEY (id);


--
-- Name: decimal_precision decimal_precision_name_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decimal_precision
    ADD CONSTRAINT decimal_precision_name_uniq UNIQUE (name);


--
-- Name: CONSTRAINT decimal_precision_name_uniq ON decimal_precision; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT decimal_precision_name_uniq ON public.decimal_precision IS 'unique (name)';


--
-- Name: decimal_precision decimal_precision_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decimal_precision
    ADD CONSTRAINT decimal_precision_pkey PRIMARY KEY (id);


--
-- Name: iap_account_info iap_account_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.iap_account_info
    ADD CONSTRAINT iap_account_info_pkey PRIMARY KEY (id);


--
-- Name: iap_account iap_account_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.iap_account
    ADD CONSTRAINT iap_account_pkey PRIMARY KEY (id);


--
-- Name: iap_account_res_company_rel iap_account_res_company_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.iap_account_res_company_rel
    ADD CONSTRAINT iap_account_res_company_rel_pkey PRIMARY KEY (iap_account_id, res_company_id);


--
-- Name: ir_act_client ir_act_client_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_client
    ADD CONSTRAINT ir_act_client_pkey PRIMARY KEY (id);


--
-- Name: ir_act_report_xml ir_act_report_xml_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_report_xml
    ADD CONSTRAINT ir_act_report_xml_pkey PRIMARY KEY (id);


--
-- Name: ir_act_server_group_rel ir_act_server_group_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server_group_rel
    ADD CONSTRAINT ir_act_server_group_rel_pkey PRIMARY KEY (act_id, gid);


--
-- Name: ir_act_server ir_act_server_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server
    ADD CONSTRAINT ir_act_server_pkey PRIMARY KEY (id);


--
-- Name: ir_act_server_webhook_field_rel ir_act_server_webhook_field_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server_webhook_field_rel
    ADD CONSTRAINT ir_act_server_webhook_field_rel_pkey PRIMARY KEY (server_id, field_id);


--
-- Name: ir_act_url ir_act_url_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_url
    ADD CONSTRAINT ir_act_url_pkey PRIMARY KEY (id);


--
-- Name: ir_act_window_group_rel ir_act_window_group_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_window_group_rel
    ADD CONSTRAINT ir_act_window_group_rel_pkey PRIMARY KEY (act_id, gid);


--
-- Name: ir_act_window ir_act_window_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_window
    ADD CONSTRAINT ir_act_window_pkey PRIMARY KEY (id);


--
-- Name: ir_act_window_view ir_act_window_view_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_window_view
    ADD CONSTRAINT ir_act_window_view_pkey PRIMARY KEY (id);


--
-- Name: ir_actions ir_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_actions
    ADD CONSTRAINT ir_actions_pkey PRIMARY KEY (id);


--
-- Name: ir_actions_todo ir_actions_todo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_actions_todo
    ADD CONSTRAINT ir_actions_todo_pkey PRIMARY KEY (id);


--
-- Name: ir_asset ir_asset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_asset
    ADD CONSTRAINT ir_asset_pkey PRIMARY KEY (id);


--
-- Name: ir_attachment ir_attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_attachment
    ADD CONSTRAINT ir_attachment_pkey PRIMARY KEY (id);


--
-- Name: ir_config_parameter ir_config_parameter_key_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_config_parameter
    ADD CONSTRAINT ir_config_parameter_key_uniq UNIQUE (key);


--
-- Name: CONSTRAINT ir_config_parameter_key_uniq ON ir_config_parameter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT ir_config_parameter_key_uniq ON public.ir_config_parameter IS 'unique (key)';


--
-- Name: ir_config_parameter ir_config_parameter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_config_parameter
    ADD CONSTRAINT ir_config_parameter_pkey PRIMARY KEY (id);


--
-- Name: ir_cron ir_cron_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_cron
    ADD CONSTRAINT ir_cron_pkey PRIMARY KEY (id);


--
-- Name: ir_cron_trigger ir_cron_trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_cron_trigger
    ADD CONSTRAINT ir_cron_trigger_pkey PRIMARY KEY (id);


--
-- Name: ir_default ir_default_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_default
    ADD CONSTRAINT ir_default_pkey PRIMARY KEY (id);


--
-- Name: ir_demo_failure ir_demo_failure_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_demo_failure
    ADD CONSTRAINT ir_demo_failure_pkey PRIMARY KEY (id);


--
-- Name: ir_demo_failure_wizard ir_demo_failure_wizard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_demo_failure_wizard
    ADD CONSTRAINT ir_demo_failure_wizard_pkey PRIMARY KEY (id);


--
-- Name: ir_demo ir_demo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_demo
    ADD CONSTRAINT ir_demo_pkey PRIMARY KEY (id);


--
-- Name: ir_exports_line ir_exports_line_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_exports_line
    ADD CONSTRAINT ir_exports_line_pkey PRIMARY KEY (id);


--
-- Name: ir_exports ir_exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_exports
    ADD CONSTRAINT ir_exports_pkey PRIMARY KEY (id);


--
-- Name: ir_filters ir_filters_name_model_uid_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_filters
    ADD CONSTRAINT ir_filters_name_model_uid_unique UNIQUE (model_id, user_id, action_id, name);


--
-- Name: CONSTRAINT ir_filters_name_model_uid_unique ON ir_filters; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT ir_filters_name_model_uid_unique ON public.ir_filters IS 'unique (model_id, user_id, action_id, name)';


--
-- Name: ir_filters ir_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_filters
    ADD CONSTRAINT ir_filters_pkey PRIMARY KEY (id);


--
-- Name: ir_logging ir_logging_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_logging
    ADD CONSTRAINT ir_logging_pkey PRIMARY KEY (id);


--
-- Name: ir_mail_server ir_mail_server_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_mail_server
    ADD CONSTRAINT ir_mail_server_pkey PRIMARY KEY (id);


--
-- Name: ir_model_access ir_model_access_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_access
    ADD CONSTRAINT ir_model_access_pkey PRIMARY KEY (id);


--
-- Name: ir_model_constraint ir_model_constraint_module_name_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_constraint
    ADD CONSTRAINT ir_model_constraint_module_name_uniq UNIQUE (name, module);


--
-- Name: CONSTRAINT ir_model_constraint_module_name_uniq ON ir_model_constraint; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT ir_model_constraint_module_name_uniq ON public.ir_model_constraint IS 'unique(name, module)';


--
-- Name: ir_model_constraint ir_model_constraint_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_constraint
    ADD CONSTRAINT ir_model_constraint_pkey PRIMARY KEY (id);


--
-- Name: ir_model_data ir_model_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_data
    ADD CONSTRAINT ir_model_data_pkey PRIMARY KEY (id);


--
-- Name: ir_model_fields_group_rel ir_model_fields_group_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields_group_rel
    ADD CONSTRAINT ir_model_fields_group_rel_pkey PRIMARY KEY (field_id, group_id);


--
-- Name: ir_model_fields ir_model_fields_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields
    ADD CONSTRAINT ir_model_fields_name_unique UNIQUE (model, name);


--
-- Name: CONSTRAINT ir_model_fields_name_unique ON ir_model_fields; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT ir_model_fields_name_unique ON public.ir_model_fields IS 'UNIQUE(model, name)';


--
-- Name: ir_model_fields ir_model_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields
    ADD CONSTRAINT ir_model_fields_pkey PRIMARY KEY (id);


--
-- Name: ir_model_fields_selection ir_model_fields_selection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields_selection
    ADD CONSTRAINT ir_model_fields_selection_pkey PRIMARY KEY (id);


--
-- Name: ir_model_fields_selection ir_model_fields_selection_selection_field_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields_selection
    ADD CONSTRAINT ir_model_fields_selection_selection_field_uniq UNIQUE (field_id, value);


--
-- Name: CONSTRAINT ir_model_fields_selection_selection_field_uniq ON ir_model_fields_selection; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT ir_model_fields_selection_selection_field_uniq ON public.ir_model_fields_selection IS 'unique(field_id, value)';


--
-- Name: ir_model_inherit ir_model_inherit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_inherit
    ADD CONSTRAINT ir_model_inherit_pkey PRIMARY KEY (id);


--
-- Name: ir_model_inherit ir_model_inherit_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_inherit
    ADD CONSTRAINT ir_model_inherit_uniq UNIQUE (model_id, parent_id);


--
-- Name: CONSTRAINT ir_model_inherit_uniq ON ir_model_inherit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT ir_model_inherit_uniq ON public.ir_model_inherit IS 'UNIQUE(model_id, parent_id)';


--
-- Name: ir_model ir_model_obj_name_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model
    ADD CONSTRAINT ir_model_obj_name_uniq UNIQUE (model);


--
-- Name: CONSTRAINT ir_model_obj_name_uniq ON ir_model; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT ir_model_obj_name_uniq ON public.ir_model IS 'unique (model)';


--
-- Name: ir_model ir_model_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model
    ADD CONSTRAINT ir_model_pkey PRIMARY KEY (id);


--
-- Name: ir_model_relation ir_model_relation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_relation
    ADD CONSTRAINT ir_model_relation_pkey PRIMARY KEY (id);


--
-- Name: ir_module_category ir_module_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_category
    ADD CONSTRAINT ir_module_category_pkey PRIMARY KEY (id);


--
-- Name: ir_module_module_dependency ir_module_module_dependency_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_module_dependency
    ADD CONSTRAINT ir_module_module_dependency_pkey PRIMARY KEY (id);


--
-- Name: ir_module_module_exclusion ir_module_module_exclusion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_module_exclusion
    ADD CONSTRAINT ir_module_module_exclusion_pkey PRIMARY KEY (id);


--
-- Name: ir_module_module ir_module_module_name_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_module
    ADD CONSTRAINT ir_module_module_name_uniq UNIQUE (name);


--
-- Name: CONSTRAINT ir_module_module_name_uniq ON ir_module_module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT ir_module_module_name_uniq ON public.ir_module_module IS 'UNIQUE (name)';


--
-- Name: ir_module_module ir_module_module_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_module
    ADD CONSTRAINT ir_module_module_pkey PRIMARY KEY (id);


--
-- Name: ir_profile ir_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_profile
    ADD CONSTRAINT ir_profile_pkey PRIMARY KEY (id);


--
-- Name: ir_property ir_property_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_property
    ADD CONSTRAINT ir_property_pkey PRIMARY KEY (id);


--
-- Name: ir_rule ir_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_rule
    ADD CONSTRAINT ir_rule_pkey PRIMARY KEY (id);


--
-- Name: ir_sequence_date_range ir_sequence_date_range_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_sequence_date_range
    ADD CONSTRAINT ir_sequence_date_range_pkey PRIMARY KEY (id);


--
-- Name: ir_sequence_date_range ir_sequence_date_range_unique_range_per_sequence; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_sequence_date_range
    ADD CONSTRAINT ir_sequence_date_range_unique_range_per_sequence UNIQUE (sequence_id, date_from, date_to);


--
-- Name: CONSTRAINT ir_sequence_date_range_unique_range_per_sequence ON ir_sequence_date_range; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT ir_sequence_date_range_unique_range_per_sequence ON public.ir_sequence_date_range IS 'UNIQUE(sequence_id, date_from, date_to)';


--
-- Name: ir_sequence ir_sequence_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_sequence
    ADD CONSTRAINT ir_sequence_pkey PRIMARY KEY (id);


--
-- Name: ir_ui_menu_group_rel ir_ui_menu_group_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_menu_group_rel
    ADD CONSTRAINT ir_ui_menu_group_rel_pkey PRIMARY KEY (menu_id, gid);


--
-- Name: ir_ui_menu ir_ui_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_menu
    ADD CONSTRAINT ir_ui_menu_pkey PRIMARY KEY (id);


--
-- Name: ir_ui_view_custom ir_ui_view_custom_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_view_custom
    ADD CONSTRAINT ir_ui_view_custom_pkey PRIMARY KEY (id);


--
-- Name: ir_ui_view_group_rel ir_ui_view_group_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_view_group_rel
    ADD CONSTRAINT ir_ui_view_group_rel_pkey PRIMARY KEY (view_id, group_id);


--
-- Name: ir_ui_view ir_ui_view_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_view
    ADD CONSTRAINT ir_ui_view_pkey PRIMARY KEY (id);


--
-- Name: rel_modules_langexport rel_modules_langexport_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rel_modules_langexport
    ADD CONSTRAINT rel_modules_langexport_pkey PRIMARY KEY (wiz_id, module_id);


--
-- Name: rel_server_actions rel_server_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rel_server_actions
    ADD CONSTRAINT rel_server_actions_pkey PRIMARY KEY (server_id, action_id);


--
-- Name: report_layout report_layout_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_layout
    ADD CONSTRAINT report_layout_pkey PRIMARY KEY (id);


--
-- Name: report_paperformat report_paperformat_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_paperformat
    ADD CONSTRAINT report_paperformat_pkey PRIMARY KEY (id);


--
-- Name: res_bank res_bank_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_bank
    ADD CONSTRAINT res_bank_pkey PRIMARY KEY (id);


--
-- Name: res_company res_company_name_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_company
    ADD CONSTRAINT res_company_name_uniq UNIQUE (name);


--
-- Name: CONSTRAINT res_company_name_uniq ON res_company; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT res_company_name_uniq ON public.res_company IS 'unique (name)';


--
-- Name: res_company res_company_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_company
    ADD CONSTRAINT res_company_pkey PRIMARY KEY (id);


--
-- Name: res_company_users_rel res_company_users_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_company_users_rel
    ADD CONSTRAINT res_company_users_rel_pkey PRIMARY KEY (cid, user_id);


--
-- Name: res_config_installer res_config_installer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_config_installer
    ADD CONSTRAINT res_config_installer_pkey PRIMARY KEY (id);


--
-- Name: res_config res_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_config
    ADD CONSTRAINT res_config_pkey PRIMARY KEY (id);


--
-- Name: res_config_settings res_config_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_config_settings
    ADD CONSTRAINT res_config_settings_pkey PRIMARY KEY (id);


--
-- Name: res_country res_country_code_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country
    ADD CONSTRAINT res_country_code_uniq UNIQUE (code);


--
-- Name: CONSTRAINT res_country_code_uniq ON res_country; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT res_country_code_uniq ON public.res_country IS 'unique (code)';


--
-- Name: res_country_group res_country_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country_group
    ADD CONSTRAINT res_country_group_pkey PRIMARY KEY (id);


--
-- Name: res_country res_country_name_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country
    ADD CONSTRAINT res_country_name_uniq UNIQUE (name);


--
-- Name: CONSTRAINT res_country_name_uniq ON res_country; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT res_country_name_uniq ON public.res_country IS 'unique (name)';


--
-- Name: res_country res_country_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country
    ADD CONSTRAINT res_country_pkey PRIMARY KEY (id);


--
-- Name: res_country_res_country_group_rel res_country_res_country_group_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country_res_country_group_rel
    ADD CONSTRAINT res_country_res_country_group_rel_pkey PRIMARY KEY (res_country_id, res_country_group_id);


--
-- Name: res_country_state res_country_state_name_code_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country_state
    ADD CONSTRAINT res_country_state_name_code_uniq UNIQUE (country_id, code);


--
-- Name: CONSTRAINT res_country_state_name_code_uniq ON res_country_state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT res_country_state_name_code_uniq ON public.res_country_state IS 'unique(country_id, code)';


--
-- Name: res_country_state res_country_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country_state
    ADD CONSTRAINT res_country_state_pkey PRIMARY KEY (id);


--
-- Name: res_currency res_currency_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_currency
    ADD CONSTRAINT res_currency_pkey PRIMARY KEY (id);


--
-- Name: res_currency_rate res_currency_rate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_currency_rate
    ADD CONSTRAINT res_currency_rate_pkey PRIMARY KEY (id);


--
-- Name: res_currency_rate res_currency_rate_unique_name_per_day; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_currency_rate
    ADD CONSTRAINT res_currency_rate_unique_name_per_day UNIQUE (name, currency_id, company_id);


--
-- Name: CONSTRAINT res_currency_rate_unique_name_per_day ON res_currency_rate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT res_currency_rate_unique_name_per_day ON public.res_currency_rate IS 'unique (name,currency_id,company_id)';


--
-- Name: res_currency res_currency_unique_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_currency
    ADD CONSTRAINT res_currency_unique_name UNIQUE (name);


--
-- Name: CONSTRAINT res_currency_unique_name ON res_currency; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT res_currency_unique_name ON public.res_currency IS 'unique (name)';


--
-- Name: res_groups_implied_rel res_groups_implied_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_groups_implied_rel
    ADD CONSTRAINT res_groups_implied_rel_pkey PRIMARY KEY (gid, hid);


--
-- Name: res_groups res_groups_name_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_groups
    ADD CONSTRAINT res_groups_name_uniq UNIQUE (category_id, name);


--
-- Name: CONSTRAINT res_groups_name_uniq ON res_groups; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT res_groups_name_uniq ON public.res_groups IS 'unique (category_id, name)';


--
-- Name: res_groups res_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_groups
    ADD CONSTRAINT res_groups_pkey PRIMARY KEY (id);


--
-- Name: res_groups_report_rel res_groups_report_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_groups_report_rel
    ADD CONSTRAINT res_groups_report_rel_pkey PRIMARY KEY (uid, gid);


--
-- Name: res_groups_users_rel res_groups_users_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_groups_users_rel
    ADD CONSTRAINT res_groups_users_rel_pkey PRIMARY KEY (gid, uid);


--
-- Name: res_lang res_lang_code_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_lang
    ADD CONSTRAINT res_lang_code_uniq UNIQUE (code);


--
-- Name: CONSTRAINT res_lang_code_uniq ON res_lang; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT res_lang_code_uniq ON public.res_lang IS 'unique(code)';


--
-- Name: res_lang_install_rel res_lang_install_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_lang_install_rel
    ADD CONSTRAINT res_lang_install_rel_pkey PRIMARY KEY (language_wizard_id, lang_id);


--
-- Name: res_lang res_lang_name_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_lang
    ADD CONSTRAINT res_lang_name_uniq UNIQUE (name);


--
-- Name: CONSTRAINT res_lang_name_uniq ON res_lang; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT res_lang_name_uniq ON public.res_lang IS 'unique(name)';


--
-- Name: res_lang res_lang_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_lang
    ADD CONSTRAINT res_lang_pkey PRIMARY KEY (id);


--
-- Name: res_lang res_lang_url_code_uniq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_lang
    ADD CONSTRAINT res_lang_url_code_uniq UNIQUE (url_code);


--
-- Name: CONSTRAINT res_lang_url_code_uniq ON res_lang; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT res_lang_url_code_uniq ON public.res_lang IS 'unique(url_code)';


--
-- Name: res_partner_bank res_partner_bank_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_bank
    ADD CONSTRAINT res_partner_bank_pkey PRIMARY KEY (id);


--
-- Name: res_partner_bank res_partner_bank_unique_number; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_bank
    ADD CONSTRAINT res_partner_bank_unique_number UNIQUE (sanitized_acc_number, partner_id);


--
-- Name: CONSTRAINT res_partner_bank_unique_number ON res_partner_bank; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT res_partner_bank_unique_number ON public.res_partner_bank IS 'unique(sanitized_acc_number, partner_id)';


--
-- Name: res_partner_category res_partner_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_category
    ADD CONSTRAINT res_partner_category_pkey PRIMARY KEY (id);


--
-- Name: res_partner_industry res_partner_industry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_industry
    ADD CONSTRAINT res_partner_industry_pkey PRIMARY KEY (id);


--
-- Name: res_partner res_partner_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner
    ADD CONSTRAINT res_partner_pkey PRIMARY KEY (id);


--
-- Name: res_partner_res_partner_category_rel res_partner_res_partner_category_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_res_partner_category_rel
    ADD CONSTRAINT res_partner_res_partner_category_rel_pkey PRIMARY KEY (category_id, partner_id);


--
-- Name: res_partner_title res_partner_title_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_title
    ADD CONSTRAINT res_partner_title_pkey PRIMARY KEY (id);


--
-- Name: res_users_apikeys_description res_users_apikeys_description_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_apikeys_description
    ADD CONSTRAINT res_users_apikeys_description_pkey PRIMARY KEY (id);


--
-- Name: res_users_apikeys res_users_apikeys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_apikeys
    ADD CONSTRAINT res_users_apikeys_pkey PRIMARY KEY (id);


--
-- Name: res_users_deletion res_users_deletion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_deletion
    ADD CONSTRAINT res_users_deletion_pkey PRIMARY KEY (id);


--
-- Name: res_users_identitycheck res_users_identitycheck_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_identitycheck
    ADD CONSTRAINT res_users_identitycheck_pkey PRIMARY KEY (id);


--
-- Name: res_users_log res_users_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_log
    ADD CONSTRAINT res_users_log_pkey PRIMARY KEY (id);


--
-- Name: res_users res_users_login_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users
    ADD CONSTRAINT res_users_login_key UNIQUE (login);


--
-- Name: res_users res_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users
    ADD CONSTRAINT res_users_pkey PRIMARY KEY (id);


--
-- Name: res_users_settings res_users_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_settings
    ADD CONSTRAINT res_users_settings_pkey PRIMARY KEY (id);


--
-- Name: res_users_settings res_users_settings_unique_user_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_settings
    ADD CONSTRAINT res_users_settings_unique_user_id UNIQUE (user_id);


--
-- Name: CONSTRAINT res_users_settings_unique_user_id ON res_users_settings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT res_users_settings_unique_user_id ON public.res_users_settings IS 'UNIQUE(user_id)';


--
-- Name: reset_view_arch_wizard reset_view_arch_wizard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reset_view_arch_wizard
    ADD CONSTRAINT reset_view_arch_wizard_pkey PRIMARY KEY (id);


--
-- Name: rule_group_rel rule_group_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_group_rel
    ADD CONSTRAINT rule_group_rel_pkey PRIMARY KEY (rule_group_id, group_id);


--
-- Name: web_editor_converter_test web_editor_converter_test_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_editor_converter_test
    ADD CONSTRAINT web_editor_converter_test_pkey PRIMARY KEY (id);


--
-- Name: web_editor_converter_test_sub web_editor_converter_test_sub_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_editor_converter_test_sub
    ADD CONSTRAINT web_editor_converter_test_sub_pkey PRIMARY KEY (id);


--
-- Name: web_tour_tour web_tour_tour_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_tour_tour
    ADD CONSTRAINT web_tour_tour_pkey PRIMARY KEY (id);


--
-- Name: wizard_ir_model_menu_create wizard_ir_model_menu_create_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wizard_ir_model_menu_create
    ADD CONSTRAINT wizard_ir_model_menu_create_pkey PRIMARY KEY (id);


--
-- Name: act_window_view_unique_mode_per_action; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX act_window_view_unique_mode_per_action ON public.ir_act_window_view USING btree (act_window_id, view_mode);


--
-- Name: auth_totp_device_user_id_index_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_totp_device_user_id_index_idx ON public.auth_totp_device USING btree (user_id, index);


--
-- Name: base_import_mapping__res_model_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX base_import_mapping__res_model_index ON public.base_import_mapping USING btree (res_model);


--
-- Name: base_partner_merge_automatic__res_partner_id_base_partner_m_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX base_partner_merge_automatic__res_partner_id_base_partner_m_idx ON public.base_partner_merge_automatic_wizard_res_partner_rel USING btree (res_partner_id, base_partner_merge_automatic_wizard_id);


--
-- Name: bus_presence_user_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX bus_presence_user_unique ON public.bus_presence USING btree (user_id) WHERE (user_id IS NOT NULL);


--
-- Name: iap_account_res_company_rel_res_company_id_iap_account_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX iap_account_res_company_rel_res_company_id_iap_account_id_idx ON public.iap_account_res_company_rel USING btree (res_company_id, iap_account_id);


--
-- Name: ir_act_server__model_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_act_server__model_id_index ON public.ir_act_server USING btree (model_id);


--
-- Name: ir_act_server_group_rel_gid_act_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_act_server_group_rel_gid_act_id_idx ON public.ir_act_server_group_rel USING btree (gid, act_id);


--
-- Name: ir_act_server_webhook_field_rel_field_id_server_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_act_server_webhook_field_rel_field_id_server_id_idx ON public.ir_act_server_webhook_field_rel USING btree (field_id, server_id);


--
-- Name: ir_act_window_group_rel_gid_act_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_act_window_group_rel_gid_act_id_idx ON public.ir_act_window_group_rel USING btree (gid, act_id);


--
-- Name: ir_actions_todo__action_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_actions_todo__action_id_index ON public.ir_actions_todo USING btree (action_id);


--
-- Name: ir_attachment__store_fname_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_attachment__store_fname_index ON public.ir_attachment USING btree (store_fname);


--
-- Name: ir_attachment__url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_attachment__url_index ON public.ir_attachment USING btree (url) WHERE (url IS NOT NULL);


--
-- Name: ir_attachment_res_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_attachment_res_idx ON public.ir_attachment USING btree (res_model, res_id);


--
-- Name: ir_cron_trigger__call_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_cron_trigger__call_at_index ON public.ir_cron_trigger USING btree (call_at);


--
-- Name: ir_cron_trigger__cron_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_cron_trigger__cron_id_index ON public.ir_cron_trigger USING btree (cron_id);


--
-- Name: ir_default__company_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_default__company_id_index ON public.ir_default USING btree (company_id);


--
-- Name: ir_default__field_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_default__field_id_index ON public.ir_default USING btree (field_id);


--
-- Name: ir_default__user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_default__user_id_index ON public.ir_default USING btree (user_id);


--
-- Name: ir_exports__resource_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_exports__resource_index ON public.ir_exports USING btree (resource);


--
-- Name: ir_exports_line__export_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_exports_line__export_id_index ON public.ir_exports_line USING btree (export_id);


--
-- Name: ir_filters_name_model_uid_unique_action_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ir_filters_name_model_uid_unique_action_index ON public.ir_filters USING btree (model_id, COALESCE(user_id, '-1'::integer), COALESCE(action_id, '-1'::integer), lower((name)::text));


--
-- Name: ir_logging__dbname_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_logging__dbname_index ON public.ir_logging USING btree (dbname);


--
-- Name: ir_logging__level_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_logging__level_index ON public.ir_logging USING btree (level);


--
-- Name: ir_logging__type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_logging__type_index ON public.ir_logging USING btree (type);


--
-- Name: ir_mail_server__name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_mail_server__name_index ON public.ir_mail_server USING btree (name);


--
-- Name: ir_model_access__group_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_access__group_id_index ON public.ir_model_access USING btree (group_id);


--
-- Name: ir_model_access__model_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_access__model_id_index ON public.ir_model_access USING btree (model_id);


--
-- Name: ir_model_access__name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_access__name_index ON public.ir_model_access USING btree (name);


--
-- Name: ir_model_constraint__model_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_constraint__model_index ON public.ir_model_constraint USING btree (model);


--
-- Name: ir_model_constraint__module_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_constraint__module_index ON public.ir_model_constraint USING btree (module);


--
-- Name: ir_model_constraint__name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_constraint__name_index ON public.ir_model_constraint USING btree (name);


--
-- Name: ir_model_constraint__type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_constraint__type_index ON public.ir_model_constraint USING btree (type);


--
-- Name: ir_model_data_model_res_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_data_model_res_id_index ON public.ir_model_data USING btree (model, res_id);


--
-- Name: ir_model_data_module_name_uniq_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ir_model_data_module_name_uniq_index ON public.ir_model_data USING btree (module, name);


--
-- Name: ir_model_fields__complete_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_fields__complete_name_index ON public.ir_model_fields USING btree (complete_name);


--
-- Name: ir_model_fields__model_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_fields__model_id_index ON public.ir_model_fields USING btree (model_id);


--
-- Name: ir_model_fields__model_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_fields__model_index ON public.ir_model_fields USING btree (model);


--
-- Name: ir_model_fields__name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_fields__name_index ON public.ir_model_fields USING btree (name);


--
-- Name: ir_model_fields__state_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_fields__state_index ON public.ir_model_fields USING btree (state);


--
-- Name: ir_model_fields_group_rel_group_id_field_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_fields_group_rel_group_id_field_id_idx ON public.ir_model_fields_group_rel USING btree (group_id, field_id);


--
-- Name: ir_model_fields_selection__field_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_fields_selection__field_id_index ON public.ir_model_fields_selection USING btree (field_id);


--
-- Name: ir_model_relation__model_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_relation__model_index ON public.ir_model_relation USING btree (model);


--
-- Name: ir_model_relation__module_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_relation__module_index ON public.ir_model_relation USING btree (module);


--
-- Name: ir_model_relation__name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_model_relation__name_index ON public.ir_model_relation USING btree (name);


--
-- Name: ir_module_category__parent_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_module_category__parent_id_index ON public.ir_module_category USING btree (parent_id);


--
-- Name: ir_module_module__category_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_module_module__category_id_index ON public.ir_module_module USING btree (category_id);


--
-- Name: ir_module_module__state_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_module_module__state_index ON public.ir_module_module USING btree (state);


--
-- Name: ir_module_module_dependency__name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_module_module_dependency__name_index ON public.ir_module_module_dependency USING btree (name);


--
-- Name: ir_module_module_exclusion__name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_module_module_exclusion__name_index ON public.ir_module_module_exclusion USING btree (name);


--
-- Name: ir_profile__session_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_profile__session_index ON public.ir_profile USING btree (session);


--
-- Name: ir_property__company_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_property__company_id_index ON public.ir_property USING btree (company_id);


--
-- Name: ir_property__name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_property__name_index ON public.ir_property USING btree (name);


--
-- Name: ir_property__res_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_property__res_id_index ON public.ir_property USING btree (res_id);


--
-- Name: ir_property__type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_property__type_index ON public.ir_property USING btree (type);


--
-- Name: ir_property_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ir_property_unique_index ON public.ir_property USING btree (fields_id, COALESCE(company_id, 0), COALESCE(res_id, ''::character varying));


--
-- Name: ir_rule__model_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_rule__model_id_index ON public.ir_rule USING btree (model_id);


--
-- Name: ir_rule__name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_rule__name_index ON public.ir_rule USING btree (name);


--
-- Name: ir_ui_menu__parent_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_ui_menu__parent_id_index ON public.ir_ui_menu USING btree (parent_id);


--
-- Name: ir_ui_menu__parent_path_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_ui_menu__parent_path_index ON public.ir_ui_menu USING btree (parent_path);


--
-- Name: ir_ui_menu_group_rel_gid_menu_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_ui_menu_group_rel_gid_menu_id_idx ON public.ir_ui_menu_group_rel USING btree (gid, menu_id);


--
-- Name: ir_ui_view__inherit_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_ui_view__inherit_id_index ON public.ir_ui_view USING btree (inherit_id);


--
-- Name: ir_ui_view__key_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_ui_view__key_index ON public.ir_ui_view USING btree (key) WHERE (key IS NOT NULL);


--
-- Name: ir_ui_view__model_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_ui_view__model_index ON public.ir_ui_view USING btree (model);


--
-- Name: ir_ui_view_custom__ref_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_ui_view_custom__ref_id_index ON public.ir_ui_view_custom USING btree (ref_id);


--
-- Name: ir_ui_view_custom__user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_ui_view_custom__user_id_index ON public.ir_ui_view_custom USING btree (user_id);


--
-- Name: ir_ui_view_custom_user_id_ref_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_ui_view_custom_user_id_ref_id ON public.ir_ui_view_custom USING btree (user_id, ref_id);


--
-- Name: ir_ui_view_group_rel_group_id_view_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_ui_view_group_rel_group_id_view_id_idx ON public.ir_ui_view_group_rel USING btree (group_id, view_id);


--
-- Name: ir_ui_view_model_type_inherit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_ui_view_model_type_inherit_id ON public.ir_ui_view USING btree (model, inherit_id);


--
-- Name: rel_modules_langexport_module_id_wiz_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rel_modules_langexport_module_id_wiz_id_idx ON public.rel_modules_langexport USING btree (module_id, wiz_id);


--
-- Name: rel_server_actions_action_id_server_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rel_server_actions_action_id_server_id_idx ON public.rel_server_actions USING btree (action_id, server_id);


--
-- Name: res_bank__bic_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_bank__bic_index ON public.res_bank USING btree (bic);


--
-- Name: res_company__parent_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_company__parent_id_index ON public.res_company USING btree (parent_id);


--
-- Name: res_company__parent_path_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_company__parent_path_index ON public.res_company USING btree (parent_path);


--
-- Name: res_company_users_rel_user_id_cid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_company_users_rel_user_id_cid_idx ON public.res_company_users_rel USING btree (user_id, cid);


--
-- Name: res_country_res_country_group_res_country_group_id_res_coun_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_country_res_country_group_res_country_group_id_res_coun_idx ON public.res_country_res_country_group_rel USING btree (res_country_group_id, res_country_id);


--
-- Name: res_currency_rate__name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_currency_rate__name_index ON public.res_currency_rate USING btree (name);


--
-- Name: res_groups__category_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_groups__category_id_index ON public.res_groups USING btree (category_id);


--
-- Name: res_groups_implied_rel_hid_gid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_groups_implied_rel_hid_gid_idx ON public.res_groups_implied_rel USING btree (hid, gid);


--
-- Name: res_groups_report_rel_gid_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_groups_report_rel_gid_uid_idx ON public.res_groups_report_rel USING btree (gid, uid);


--
-- Name: res_groups_users_rel_uid_gid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_groups_users_rel_uid_gid_idx ON public.res_groups_users_rel USING btree (uid, gid);


--
-- Name: res_lang_install_rel_lang_id_language_wizard_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_lang_install_rel_lang_id_language_wizard_id_idx ON public.res_lang_install_rel USING btree (lang_id, language_wizard_id);


--
-- Name: res_partner__commercial_partner_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_partner__commercial_partner_id_index ON public.res_partner USING btree (commercial_partner_id);


--
-- Name: res_partner__company_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_partner__company_id_index ON public.res_partner USING btree (company_id);


--
-- Name: res_partner__complete_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_partner__complete_name_index ON public.res_partner USING btree (complete_name);


--
-- Name: res_partner__date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_partner__date_index ON public.res_partner USING btree (date);


--
-- Name: res_partner__name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_partner__name_index ON public.res_partner USING btree (name);


--
-- Name: res_partner__parent_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_partner__parent_id_index ON public.res_partner USING btree (parent_id);


--
-- Name: res_partner__ref_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_partner__ref_index ON public.res_partner USING btree (ref);


--
-- Name: res_partner__vat_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_partner__vat_index ON public.res_partner USING btree (vat);


--
-- Name: res_partner_bank__partner_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_partner_bank__partner_id_index ON public.res_partner_bank USING btree (partner_id);


--
-- Name: res_partner_category__parent_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_partner_category__parent_id_index ON public.res_partner_category USING btree (parent_id);


--
-- Name: res_partner_category__parent_path_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_partner_category__parent_path_index ON public.res_partner_category USING btree (parent_path);


--
-- Name: res_partner_res_partner_category_rel_partner_id_category_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_partner_res_partner_category_rel_partner_id_category_id_idx ON public.res_partner_res_partner_category_rel USING btree (partner_id, category_id);


--
-- Name: res_users__partner_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_users__partner_id_index ON public.res_users USING btree (partner_id);


--
-- Name: res_users_apikeys_user_id_index_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX res_users_apikeys_user_id_index_idx ON public.res_users_apikeys USING btree (user_id, index);


--
-- Name: rule_group_rel_group_id_rule_group_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rule_group_rel_group_id_rule_group_id_idx ON public.rule_group_rel USING btree (group_id, rule_group_id);


--
-- Name: auth_totp_device auth_totp_device_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_totp_device
    ADD CONSTRAINT auth_totp_device_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.res_users(id) ON DELETE CASCADE;


--
-- Name: auth_totp_wizard auth_totp_wizard_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_totp_wizard
    ADD CONSTRAINT auth_totp_wizard_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: auth_totp_wizard auth_totp_wizard_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_totp_wizard
    ADD CONSTRAINT auth_totp_wizard_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.res_users(id) ON DELETE CASCADE;


--
-- Name: auth_totp_wizard auth_totp_wizard_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_totp_wizard
    ADD CONSTRAINT auth_totp_wizard_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_document_layout base_document_layout_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_document_layout
    ADD CONSTRAINT base_document_layout_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.res_company(id) ON DELETE CASCADE;


--
-- Name: base_document_layout base_document_layout_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_document_layout
    ADD CONSTRAINT base_document_layout_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_document_layout base_document_layout_report_layout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_document_layout
    ADD CONSTRAINT base_document_layout_report_layout_id_fkey FOREIGN KEY (report_layout_id) REFERENCES public.report_layout(id) ON DELETE SET NULL;


--
-- Name: base_document_layout base_document_layout_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_document_layout
    ADD CONSTRAINT base_document_layout_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_enable_profiling_wizard base_enable_profiling_wizard_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_enable_profiling_wizard
    ADD CONSTRAINT base_enable_profiling_wizard_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_enable_profiling_wizard base_enable_profiling_wizard_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_enable_profiling_wizard
    ADD CONSTRAINT base_enable_profiling_wizard_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_import_import base_import_import_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_import_import
    ADD CONSTRAINT base_import_import_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_import_import base_import_import_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_import_import
    ADD CONSTRAINT base_import_import_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_import_mapping base_import_mapping_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_import_mapping
    ADD CONSTRAINT base_import_mapping_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_import_mapping base_import_mapping_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_import_mapping
    ADD CONSTRAINT base_import_mapping_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_import_module base_import_module_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_import_module
    ADD CONSTRAINT base_import_module_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_import_module base_import_module_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_import_module
    ADD CONSTRAINT base_import_module_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_language_export base_language_export_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_language_export
    ADD CONSTRAINT base_language_export_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_language_export base_language_export_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_language_export
    ADD CONSTRAINT base_language_export_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.ir_model(id) ON DELETE SET NULL;


--
-- Name: base_language_export base_language_export_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_language_export
    ADD CONSTRAINT base_language_export_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_language_import base_language_import_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_language_import
    ADD CONSTRAINT base_language_import_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_language_import base_language_import_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_language_import
    ADD CONSTRAINT base_language_import_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_language_install base_language_install_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_language_install
    ADD CONSTRAINT base_language_install_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_language_install base_language_install_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_language_install
    ADD CONSTRAINT base_language_install_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_module_uninstall base_module_uninstall_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_module_uninstall
    ADD CONSTRAINT base_module_uninstall_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_module_uninstall base_module_uninstall_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_module_uninstall
    ADD CONSTRAINT base_module_uninstall_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.ir_module_module(id) ON DELETE CASCADE;


--
-- Name: base_module_uninstall base_module_uninstall_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_module_uninstall
    ADD CONSTRAINT base_module_uninstall_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_module_update base_module_update_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_module_update
    ADD CONSTRAINT base_module_update_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_module_update base_module_update_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_module_update
    ADD CONSTRAINT base_module_update_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_module_upgrade base_module_upgrade_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_module_upgrade
    ADD CONSTRAINT base_module_upgrade_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_module_upgrade base_module_upgrade_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_module_upgrade
    ADD CONSTRAINT base_module_upgrade_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_partner_merge_automatic_wizard_res_partner_rel base_partner_merge_automatic__base_partner_merge_automatic_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_partner_merge_automatic_wizard_res_partner_rel
    ADD CONSTRAINT base_partner_merge_automatic__base_partner_merge_automatic_fkey FOREIGN KEY (base_partner_merge_automatic_wizard_id) REFERENCES public.base_partner_merge_automatic_wizard(id) ON DELETE CASCADE;


--
-- Name: base_partner_merge_automatic_wizard base_partner_merge_automatic_wizard_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_partner_merge_automatic_wizard
    ADD CONSTRAINT base_partner_merge_automatic_wizard_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_partner_merge_automatic_wizard base_partner_merge_automatic_wizard_current_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_partner_merge_automatic_wizard
    ADD CONSTRAINT base_partner_merge_automatic_wizard_current_line_id_fkey FOREIGN KEY (current_line_id) REFERENCES public.base_partner_merge_line(id) ON DELETE SET NULL;


--
-- Name: base_partner_merge_automatic_wizard base_partner_merge_automatic_wizard_dst_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_partner_merge_automatic_wizard
    ADD CONSTRAINT base_partner_merge_automatic_wizard_dst_partner_id_fkey FOREIGN KEY (dst_partner_id) REFERENCES public.res_partner(id) ON DELETE SET NULL;


--
-- Name: base_partner_merge_automatic_wizard_res_partner_rel base_partner_merge_automatic_wizard_res_par_res_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_partner_merge_automatic_wizard_res_partner_rel
    ADD CONSTRAINT base_partner_merge_automatic_wizard_res_par_res_partner_id_fkey FOREIGN KEY (res_partner_id) REFERENCES public.res_partner(id) ON DELETE CASCADE;


--
-- Name: base_partner_merge_automatic_wizard base_partner_merge_automatic_wizard_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_partner_merge_automatic_wizard
    ADD CONSTRAINT base_partner_merge_automatic_wizard_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_partner_merge_line base_partner_merge_line_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_partner_merge_line
    ADD CONSTRAINT base_partner_merge_line_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: base_partner_merge_line base_partner_merge_line_wizard_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_partner_merge_line
    ADD CONSTRAINT base_partner_merge_line_wizard_id_fkey FOREIGN KEY (wizard_id) REFERENCES public.base_partner_merge_automatic_wizard(id) ON DELETE SET NULL;


--
-- Name: base_partner_merge_line base_partner_merge_line_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.base_partner_merge_line
    ADD CONSTRAINT base_partner_merge_line_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: bus_bus bus_bus_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bus_bus
    ADD CONSTRAINT bus_bus_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: bus_bus bus_bus_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bus_bus
    ADD CONSTRAINT bus_bus_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: bus_presence bus_presence_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bus_presence
    ADD CONSTRAINT bus_presence_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.res_users(id) ON DELETE CASCADE;


--
-- Name: change_password_own change_password_own_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_password_own
    ADD CONSTRAINT change_password_own_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: change_password_own change_password_own_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_password_own
    ADD CONSTRAINT change_password_own_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: change_password_user change_password_user_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_password_user
    ADD CONSTRAINT change_password_user_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: change_password_user change_password_user_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_password_user
    ADD CONSTRAINT change_password_user_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.res_users(id) ON DELETE CASCADE;


--
-- Name: change_password_user change_password_user_wizard_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_password_user
    ADD CONSTRAINT change_password_user_wizard_id_fkey FOREIGN KEY (wizard_id) REFERENCES public.change_password_wizard(id) ON DELETE CASCADE;


--
-- Name: change_password_user change_password_user_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_password_user
    ADD CONSTRAINT change_password_user_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: change_password_wizard change_password_wizard_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_password_wizard
    ADD CONSTRAINT change_password_wizard_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: change_password_wizard change_password_wizard_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_password_wizard
    ADD CONSTRAINT change_password_wizard_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: decimal_precision decimal_precision_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decimal_precision
    ADD CONSTRAINT decimal_precision_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: decimal_precision decimal_precision_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decimal_precision
    ADD CONSTRAINT decimal_precision_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: iap_account iap_account_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.iap_account
    ADD CONSTRAINT iap_account_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: iap_account_info iap_account_info_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.iap_account_info
    ADD CONSTRAINT iap_account_info_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.iap_account(id) ON DELETE SET NULL;


--
-- Name: iap_account_info iap_account_info_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.iap_account_info
    ADD CONSTRAINT iap_account_info_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: iap_account_info iap_account_info_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.iap_account_info
    ADD CONSTRAINT iap_account_info_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: iap_account_res_company_rel iap_account_res_company_rel_iap_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.iap_account_res_company_rel
    ADD CONSTRAINT iap_account_res_company_rel_iap_account_id_fkey FOREIGN KEY (iap_account_id) REFERENCES public.iap_account(id) ON DELETE CASCADE;


--
-- Name: iap_account_res_company_rel iap_account_res_company_rel_res_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.iap_account_res_company_rel
    ADD CONSTRAINT iap_account_res_company_rel_res_company_id_fkey FOREIGN KEY (res_company_id) REFERENCES public.res_company(id) ON DELETE CASCADE;


--
-- Name: iap_account iap_account_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.iap_account
    ADD CONSTRAINT iap_account_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_act_client ir_act_client_binding_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_client
    ADD CONSTRAINT ir_act_client_binding_model_id_fkey FOREIGN KEY (binding_model_id) REFERENCES public.ir_model(id) ON DELETE CASCADE;


--
-- Name: ir_act_client ir_act_client_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_client
    ADD CONSTRAINT ir_act_client_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_act_client ir_act_client_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_client
    ADD CONSTRAINT ir_act_client_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_act_report_xml ir_act_report_xml_binding_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_report_xml
    ADD CONSTRAINT ir_act_report_xml_binding_model_id_fkey FOREIGN KEY (binding_model_id) REFERENCES public.ir_model(id) ON DELETE CASCADE;


--
-- Name: ir_act_report_xml ir_act_report_xml_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_report_xml
    ADD CONSTRAINT ir_act_report_xml_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_act_report_xml ir_act_report_xml_paperformat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_report_xml
    ADD CONSTRAINT ir_act_report_xml_paperformat_id_fkey FOREIGN KEY (paperformat_id) REFERENCES public.report_paperformat(id) ON DELETE SET NULL;


--
-- Name: ir_act_report_xml ir_act_report_xml_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_report_xml
    ADD CONSTRAINT ir_act_report_xml_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_act_server ir_act_server_binding_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server
    ADD CONSTRAINT ir_act_server_binding_model_id_fkey FOREIGN KEY (binding_model_id) REFERENCES public.ir_model(id) ON DELETE CASCADE;


--
-- Name: ir_act_server ir_act_server_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server
    ADD CONSTRAINT ir_act_server_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_act_server ir_act_server_crud_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server
    ADD CONSTRAINT ir_act_server_crud_model_id_fkey FOREIGN KEY (crud_model_id) REFERENCES public.ir_model(id) ON DELETE SET NULL;


--
-- Name: ir_act_server_group_rel ir_act_server_group_rel_act_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server_group_rel
    ADD CONSTRAINT ir_act_server_group_rel_act_id_fkey FOREIGN KEY (act_id) REFERENCES public.ir_act_server(id) ON DELETE CASCADE;


--
-- Name: ir_act_server_group_rel ir_act_server_group_rel_gid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server_group_rel
    ADD CONSTRAINT ir_act_server_group_rel_gid_fkey FOREIGN KEY (gid) REFERENCES public.res_groups(id) ON DELETE CASCADE;


--
-- Name: ir_act_server ir_act_server_link_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server
    ADD CONSTRAINT ir_act_server_link_field_id_fkey FOREIGN KEY (link_field_id) REFERENCES public.ir_model_fields(id) ON DELETE SET NULL;


--
-- Name: ir_act_server ir_act_server_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server
    ADD CONSTRAINT ir_act_server_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.ir_model(id) ON DELETE CASCADE;


--
-- Name: ir_act_server ir_act_server_selection_value_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server
    ADD CONSTRAINT ir_act_server_selection_value_fkey FOREIGN KEY (selection_value) REFERENCES public.ir_model_fields_selection(id) ON DELETE CASCADE;


--
-- Name: ir_act_server ir_act_server_update_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server
    ADD CONSTRAINT ir_act_server_update_field_id_fkey FOREIGN KEY (update_field_id) REFERENCES public.ir_model_fields(id) ON DELETE CASCADE;


--
-- Name: ir_act_server ir_act_server_update_related_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server
    ADD CONSTRAINT ir_act_server_update_related_model_id_fkey FOREIGN KEY (update_related_model_id) REFERENCES public.ir_model(id) ON DELETE SET NULL;


--
-- Name: ir_act_server_webhook_field_rel ir_act_server_webhook_field_rel_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server_webhook_field_rel
    ADD CONSTRAINT ir_act_server_webhook_field_rel_field_id_fkey FOREIGN KEY (field_id) REFERENCES public.ir_model_fields(id) ON DELETE CASCADE;


--
-- Name: ir_act_server_webhook_field_rel ir_act_server_webhook_field_rel_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server_webhook_field_rel
    ADD CONSTRAINT ir_act_server_webhook_field_rel_server_id_fkey FOREIGN KEY (server_id) REFERENCES public.ir_act_server(id) ON DELETE CASCADE;


--
-- Name: ir_act_server ir_act_server_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_server
    ADD CONSTRAINT ir_act_server_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_act_url ir_act_url_binding_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_url
    ADD CONSTRAINT ir_act_url_binding_model_id_fkey FOREIGN KEY (binding_model_id) REFERENCES public.ir_model(id) ON DELETE CASCADE;


--
-- Name: ir_act_url ir_act_url_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_url
    ADD CONSTRAINT ir_act_url_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_act_url ir_act_url_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_url
    ADD CONSTRAINT ir_act_url_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_act_window ir_act_window_binding_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_window
    ADD CONSTRAINT ir_act_window_binding_model_id_fkey FOREIGN KEY (binding_model_id) REFERENCES public.ir_model(id) ON DELETE CASCADE;


--
-- Name: ir_act_window ir_act_window_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_window
    ADD CONSTRAINT ir_act_window_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_act_window_group_rel ir_act_window_group_rel_act_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_window_group_rel
    ADD CONSTRAINT ir_act_window_group_rel_act_id_fkey FOREIGN KEY (act_id) REFERENCES public.ir_act_window(id) ON DELETE CASCADE;


--
-- Name: ir_act_window_group_rel ir_act_window_group_rel_gid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_window_group_rel
    ADD CONSTRAINT ir_act_window_group_rel_gid_fkey FOREIGN KEY (gid) REFERENCES public.res_groups(id) ON DELETE CASCADE;


--
-- Name: ir_act_window ir_act_window_search_view_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_window
    ADD CONSTRAINT ir_act_window_search_view_id_fkey FOREIGN KEY (search_view_id) REFERENCES public.ir_ui_view(id) ON DELETE SET NULL;


--
-- Name: ir_act_window_view ir_act_window_view_act_window_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_window_view
    ADD CONSTRAINT ir_act_window_view_act_window_id_fkey FOREIGN KEY (act_window_id) REFERENCES public.ir_act_window(id) ON DELETE CASCADE;


--
-- Name: ir_act_window_view ir_act_window_view_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_window_view
    ADD CONSTRAINT ir_act_window_view_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_act_window ir_act_window_view_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_window
    ADD CONSTRAINT ir_act_window_view_id_fkey FOREIGN KEY (view_id) REFERENCES public.ir_ui_view(id) ON DELETE SET NULL;


--
-- Name: ir_act_window_view ir_act_window_view_view_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_window_view
    ADD CONSTRAINT ir_act_window_view_view_id_fkey FOREIGN KEY (view_id) REFERENCES public.ir_ui_view(id) ON DELETE SET NULL;


--
-- Name: ir_act_window_view ir_act_window_view_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_window_view
    ADD CONSTRAINT ir_act_window_view_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_act_window ir_act_window_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_act_window
    ADD CONSTRAINT ir_act_window_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_actions ir_actions_binding_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_actions
    ADD CONSTRAINT ir_actions_binding_model_id_fkey FOREIGN KEY (binding_model_id) REFERENCES public.ir_model(id) ON DELETE CASCADE;


--
-- Name: ir_actions ir_actions_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_actions
    ADD CONSTRAINT ir_actions_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_actions_todo ir_actions_todo_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_actions_todo
    ADD CONSTRAINT ir_actions_todo_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_actions_todo ir_actions_todo_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_actions_todo
    ADD CONSTRAINT ir_actions_todo_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_actions ir_actions_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_actions
    ADD CONSTRAINT ir_actions_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_asset ir_asset_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_asset
    ADD CONSTRAINT ir_asset_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_asset ir_asset_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_asset
    ADD CONSTRAINT ir_asset_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_attachment ir_attachment_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_attachment
    ADD CONSTRAINT ir_attachment_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.res_company(id) ON DELETE SET NULL;


--
-- Name: ir_attachment ir_attachment_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_attachment
    ADD CONSTRAINT ir_attachment_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_attachment ir_attachment_original_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_attachment
    ADD CONSTRAINT ir_attachment_original_id_fkey FOREIGN KEY (original_id) REFERENCES public.ir_attachment(id) ON DELETE SET NULL;


--
-- Name: ir_attachment ir_attachment_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_attachment
    ADD CONSTRAINT ir_attachment_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_config_parameter ir_config_parameter_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_config_parameter
    ADD CONSTRAINT ir_config_parameter_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_config_parameter ir_config_parameter_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_config_parameter
    ADD CONSTRAINT ir_config_parameter_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_cron ir_cron_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_cron
    ADD CONSTRAINT ir_cron_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_cron ir_cron_ir_actions_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_cron
    ADD CONSTRAINT ir_cron_ir_actions_server_id_fkey FOREIGN KEY (ir_actions_server_id) REFERENCES public.ir_act_server(id) ON DELETE RESTRICT;


--
-- Name: ir_cron_trigger ir_cron_trigger_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_cron_trigger
    ADD CONSTRAINT ir_cron_trigger_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_cron_trigger ir_cron_trigger_cron_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_cron_trigger
    ADD CONSTRAINT ir_cron_trigger_cron_id_fkey FOREIGN KEY (cron_id) REFERENCES public.ir_cron(id) ON DELETE SET NULL;


--
-- Name: ir_cron_trigger ir_cron_trigger_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_cron_trigger
    ADD CONSTRAINT ir_cron_trigger_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_cron ir_cron_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_cron
    ADD CONSTRAINT ir_cron_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.res_users(id) ON DELETE RESTRICT;


--
-- Name: ir_cron ir_cron_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_cron
    ADD CONSTRAINT ir_cron_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_default ir_default_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_default
    ADD CONSTRAINT ir_default_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.res_company(id) ON DELETE CASCADE;


--
-- Name: ir_default ir_default_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_default
    ADD CONSTRAINT ir_default_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_default ir_default_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_default
    ADD CONSTRAINT ir_default_field_id_fkey FOREIGN KEY (field_id) REFERENCES public.ir_model_fields(id) ON DELETE CASCADE;


--
-- Name: ir_default ir_default_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_default
    ADD CONSTRAINT ir_default_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.res_users(id) ON DELETE CASCADE;


--
-- Name: ir_default ir_default_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_default
    ADD CONSTRAINT ir_default_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_demo ir_demo_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_demo
    ADD CONSTRAINT ir_demo_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_demo_failure ir_demo_failure_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_demo_failure
    ADD CONSTRAINT ir_demo_failure_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_demo_failure ir_demo_failure_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_demo_failure
    ADD CONSTRAINT ir_demo_failure_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.ir_module_module(id) ON DELETE CASCADE;


--
-- Name: ir_demo_failure_wizard ir_demo_failure_wizard_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_demo_failure_wizard
    ADD CONSTRAINT ir_demo_failure_wizard_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_demo_failure ir_demo_failure_wizard_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_demo_failure
    ADD CONSTRAINT ir_demo_failure_wizard_id_fkey FOREIGN KEY (wizard_id) REFERENCES public.ir_demo_failure_wizard(id) ON DELETE SET NULL;


--
-- Name: ir_demo_failure_wizard ir_demo_failure_wizard_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_demo_failure_wizard
    ADD CONSTRAINT ir_demo_failure_wizard_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_demo_failure ir_demo_failure_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_demo_failure
    ADD CONSTRAINT ir_demo_failure_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_demo ir_demo_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_demo
    ADD CONSTRAINT ir_demo_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_exports ir_exports_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_exports
    ADD CONSTRAINT ir_exports_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_exports_line ir_exports_line_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_exports_line
    ADD CONSTRAINT ir_exports_line_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_exports_line ir_exports_line_export_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_exports_line
    ADD CONSTRAINT ir_exports_line_export_id_fkey FOREIGN KEY (export_id) REFERENCES public.ir_exports(id) ON DELETE CASCADE;


--
-- Name: ir_exports_line ir_exports_line_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_exports_line
    ADD CONSTRAINT ir_exports_line_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_exports ir_exports_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_exports
    ADD CONSTRAINT ir_exports_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_filters ir_filters_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_filters
    ADD CONSTRAINT ir_filters_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_filters ir_filters_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_filters
    ADD CONSTRAINT ir_filters_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.res_users(id) ON DELETE CASCADE;


--
-- Name: ir_filters ir_filters_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_filters
    ADD CONSTRAINT ir_filters_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_mail_server ir_mail_server_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_mail_server
    ADD CONSTRAINT ir_mail_server_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_mail_server ir_mail_server_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_mail_server
    ADD CONSTRAINT ir_mail_server_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_model_access ir_model_access_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_access
    ADD CONSTRAINT ir_model_access_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_model_access ir_model_access_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_access
    ADD CONSTRAINT ir_model_access_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.res_groups(id) ON DELETE RESTRICT;


--
-- Name: ir_model_access ir_model_access_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_access
    ADD CONSTRAINT ir_model_access_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.ir_model(id) ON DELETE CASCADE;


--
-- Name: ir_model_access ir_model_access_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_access
    ADD CONSTRAINT ir_model_access_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_model_constraint ir_model_constraint_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_constraint
    ADD CONSTRAINT ir_model_constraint_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_model_constraint ir_model_constraint_model_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_constraint
    ADD CONSTRAINT ir_model_constraint_model_fkey FOREIGN KEY (model) REFERENCES public.ir_model(id) ON DELETE CASCADE;


--
-- Name: ir_model_constraint ir_model_constraint_module_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_constraint
    ADD CONSTRAINT ir_model_constraint_module_fkey FOREIGN KEY (module) REFERENCES public.ir_module_module(id) ON DELETE CASCADE;


--
-- Name: ir_model_constraint ir_model_constraint_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_constraint
    ADD CONSTRAINT ir_model_constraint_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_model ir_model_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model
    ADD CONSTRAINT ir_model_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_model_data ir_model_data_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_data
    ADD CONSTRAINT ir_model_data_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_model_data ir_model_data_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_data
    ADD CONSTRAINT ir_model_data_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_model_fields ir_model_fields_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields
    ADD CONSTRAINT ir_model_fields_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_model_fields_group_rel ir_model_fields_group_rel_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields_group_rel
    ADD CONSTRAINT ir_model_fields_group_rel_field_id_fkey FOREIGN KEY (field_id) REFERENCES public.ir_model_fields(id) ON DELETE CASCADE;


--
-- Name: ir_model_fields_group_rel ir_model_fields_group_rel_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields_group_rel
    ADD CONSTRAINT ir_model_fields_group_rel_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.res_groups(id) ON DELETE CASCADE;


--
-- Name: ir_model_fields ir_model_fields_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields
    ADD CONSTRAINT ir_model_fields_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.ir_model(id) ON DELETE CASCADE;


--
-- Name: ir_model_fields ir_model_fields_related_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields
    ADD CONSTRAINT ir_model_fields_related_field_id_fkey FOREIGN KEY (related_field_id) REFERENCES public.ir_model_fields(id) ON DELETE CASCADE;


--
-- Name: ir_model_fields ir_model_fields_relation_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields
    ADD CONSTRAINT ir_model_fields_relation_field_id_fkey FOREIGN KEY (relation_field_id) REFERENCES public.ir_model_fields(id) ON DELETE CASCADE;


--
-- Name: ir_model_fields_selection ir_model_fields_selection_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields_selection
    ADD CONSTRAINT ir_model_fields_selection_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_model_fields_selection ir_model_fields_selection_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields_selection
    ADD CONSTRAINT ir_model_fields_selection_field_id_fkey FOREIGN KEY (field_id) REFERENCES public.ir_model_fields(id) ON DELETE CASCADE;


--
-- Name: ir_model_fields_selection ir_model_fields_selection_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields_selection
    ADD CONSTRAINT ir_model_fields_selection_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_model_fields ir_model_fields_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_fields
    ADD CONSTRAINT ir_model_fields_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_model_inherit ir_model_inherit_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_inherit
    ADD CONSTRAINT ir_model_inherit_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.ir_model(id) ON DELETE CASCADE;


--
-- Name: ir_model_inherit ir_model_inherit_parent_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_inherit
    ADD CONSTRAINT ir_model_inherit_parent_field_id_fkey FOREIGN KEY (parent_field_id) REFERENCES public.ir_model_fields(id) ON DELETE CASCADE;


--
-- Name: ir_model_inherit ir_model_inherit_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_inherit
    ADD CONSTRAINT ir_model_inherit_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.ir_model(id) ON DELETE CASCADE;


--
-- Name: ir_model_relation ir_model_relation_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_relation
    ADD CONSTRAINT ir_model_relation_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_model_relation ir_model_relation_model_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_relation
    ADD CONSTRAINT ir_model_relation_model_fkey FOREIGN KEY (model) REFERENCES public.ir_model(id) ON DELETE CASCADE;


--
-- Name: ir_model_relation ir_model_relation_module_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_relation
    ADD CONSTRAINT ir_model_relation_module_fkey FOREIGN KEY (module) REFERENCES public.ir_module_module(id) ON DELETE CASCADE;


--
-- Name: ir_model_relation ir_model_relation_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model_relation
    ADD CONSTRAINT ir_model_relation_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_model ir_model_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_model
    ADD CONSTRAINT ir_model_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_module_category ir_module_category_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_category
    ADD CONSTRAINT ir_module_category_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_module_category ir_module_category_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_category
    ADD CONSTRAINT ir_module_category_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.ir_module_category(id) ON DELETE SET NULL;


--
-- Name: ir_module_category ir_module_category_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_category
    ADD CONSTRAINT ir_module_category_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_module_module ir_module_module_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_module
    ADD CONSTRAINT ir_module_module_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.ir_module_category(id) ON DELETE SET NULL;


--
-- Name: ir_module_module ir_module_module_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_module
    ADD CONSTRAINT ir_module_module_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_module_module_dependency ir_module_module_dependency_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_module_dependency
    ADD CONSTRAINT ir_module_module_dependency_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.ir_module_module(id) ON DELETE CASCADE;


--
-- Name: ir_module_module_exclusion ir_module_module_exclusion_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_module_exclusion
    ADD CONSTRAINT ir_module_module_exclusion_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_module_module_exclusion ir_module_module_exclusion_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_module_exclusion
    ADD CONSTRAINT ir_module_module_exclusion_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.ir_module_module(id) ON DELETE CASCADE;


--
-- Name: ir_module_module_exclusion ir_module_module_exclusion_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_module_exclusion
    ADD CONSTRAINT ir_module_module_exclusion_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_module_module ir_module_module_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_module_module
    ADD CONSTRAINT ir_module_module_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_property ir_property_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_property
    ADD CONSTRAINT ir_property_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.res_company(id) ON DELETE SET NULL;


--
-- Name: ir_property ir_property_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_property
    ADD CONSTRAINT ir_property_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_property ir_property_fields_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_property
    ADD CONSTRAINT ir_property_fields_id_fkey FOREIGN KEY (fields_id) REFERENCES public.ir_model_fields(id) ON DELETE CASCADE;


--
-- Name: ir_property ir_property_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_property
    ADD CONSTRAINT ir_property_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_rule ir_rule_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_rule
    ADD CONSTRAINT ir_rule_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_rule ir_rule_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_rule
    ADD CONSTRAINT ir_rule_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.ir_model(id) ON DELETE CASCADE;


--
-- Name: ir_rule ir_rule_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_rule
    ADD CONSTRAINT ir_rule_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_sequence ir_sequence_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_sequence
    ADD CONSTRAINT ir_sequence_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.res_company(id) ON DELETE SET NULL;


--
-- Name: ir_sequence ir_sequence_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_sequence
    ADD CONSTRAINT ir_sequence_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_sequence_date_range ir_sequence_date_range_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_sequence_date_range
    ADD CONSTRAINT ir_sequence_date_range_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_sequence_date_range ir_sequence_date_range_sequence_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_sequence_date_range
    ADD CONSTRAINT ir_sequence_date_range_sequence_id_fkey FOREIGN KEY (sequence_id) REFERENCES public.ir_sequence(id) ON DELETE CASCADE;


--
-- Name: ir_sequence_date_range ir_sequence_date_range_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_sequence_date_range
    ADD CONSTRAINT ir_sequence_date_range_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_sequence ir_sequence_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_sequence
    ADD CONSTRAINT ir_sequence_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_ui_menu ir_ui_menu_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_menu
    ADD CONSTRAINT ir_ui_menu_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_ui_menu_group_rel ir_ui_menu_group_rel_gid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_menu_group_rel
    ADD CONSTRAINT ir_ui_menu_group_rel_gid_fkey FOREIGN KEY (gid) REFERENCES public.res_groups(id) ON DELETE CASCADE;


--
-- Name: ir_ui_menu_group_rel ir_ui_menu_group_rel_menu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_menu_group_rel
    ADD CONSTRAINT ir_ui_menu_group_rel_menu_id_fkey FOREIGN KEY (menu_id) REFERENCES public.ir_ui_menu(id) ON DELETE CASCADE;


--
-- Name: ir_ui_menu ir_ui_menu_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_menu
    ADD CONSTRAINT ir_ui_menu_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.ir_ui_menu(id) ON DELETE RESTRICT;


--
-- Name: ir_ui_menu ir_ui_menu_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_menu
    ADD CONSTRAINT ir_ui_menu_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_ui_view ir_ui_view_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_view
    ADD CONSTRAINT ir_ui_view_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_ui_view_custom ir_ui_view_custom_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_view_custom
    ADD CONSTRAINT ir_ui_view_custom_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_ui_view_custom ir_ui_view_custom_ref_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_view_custom
    ADD CONSTRAINT ir_ui_view_custom_ref_id_fkey FOREIGN KEY (ref_id) REFERENCES public.ir_ui_view(id) ON DELETE CASCADE;


--
-- Name: ir_ui_view_custom ir_ui_view_custom_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_view_custom
    ADD CONSTRAINT ir_ui_view_custom_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.res_users(id) ON DELETE CASCADE;


--
-- Name: ir_ui_view_custom ir_ui_view_custom_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_view_custom
    ADD CONSTRAINT ir_ui_view_custom_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: ir_ui_view_group_rel ir_ui_view_group_rel_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_view_group_rel
    ADD CONSTRAINT ir_ui_view_group_rel_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.res_groups(id) ON DELETE CASCADE;


--
-- Name: ir_ui_view_group_rel ir_ui_view_group_rel_view_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_view_group_rel
    ADD CONSTRAINT ir_ui_view_group_rel_view_id_fkey FOREIGN KEY (view_id) REFERENCES public.ir_ui_view(id) ON DELETE CASCADE;


--
-- Name: ir_ui_view ir_ui_view_inherit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_view
    ADD CONSTRAINT ir_ui_view_inherit_id_fkey FOREIGN KEY (inherit_id) REFERENCES public.ir_ui_view(id) ON DELETE RESTRICT;


--
-- Name: ir_ui_view ir_ui_view_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_ui_view
    ADD CONSTRAINT ir_ui_view_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: rel_modules_langexport rel_modules_langexport_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rel_modules_langexport
    ADD CONSTRAINT rel_modules_langexport_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.ir_module_module(id) ON DELETE CASCADE;


--
-- Name: rel_modules_langexport rel_modules_langexport_wiz_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rel_modules_langexport
    ADD CONSTRAINT rel_modules_langexport_wiz_id_fkey FOREIGN KEY (wiz_id) REFERENCES public.base_language_export(id) ON DELETE CASCADE;


--
-- Name: rel_server_actions rel_server_actions_action_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rel_server_actions
    ADD CONSTRAINT rel_server_actions_action_id_fkey FOREIGN KEY (action_id) REFERENCES public.ir_act_server(id) ON DELETE CASCADE;


--
-- Name: rel_server_actions rel_server_actions_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rel_server_actions
    ADD CONSTRAINT rel_server_actions_server_id_fkey FOREIGN KEY (server_id) REFERENCES public.ir_act_server(id) ON DELETE CASCADE;


--
-- Name: report_layout report_layout_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_layout
    ADD CONSTRAINT report_layout_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: report_layout report_layout_view_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_layout
    ADD CONSTRAINT report_layout_view_id_fkey FOREIGN KEY (view_id) REFERENCES public.ir_ui_view(id) ON DELETE RESTRICT;


--
-- Name: report_layout report_layout_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_layout
    ADD CONSTRAINT report_layout_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: report_paperformat report_paperformat_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_paperformat
    ADD CONSTRAINT report_paperformat_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: report_paperformat report_paperformat_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_paperformat
    ADD CONSTRAINT report_paperformat_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_bank res_bank_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_bank
    ADD CONSTRAINT res_bank_country_fkey FOREIGN KEY (country) REFERENCES public.res_country(id) ON DELETE SET NULL;


--
-- Name: res_bank res_bank_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_bank
    ADD CONSTRAINT res_bank_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_bank res_bank_state_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_bank
    ADD CONSTRAINT res_bank_state_fkey FOREIGN KEY (state) REFERENCES public.res_country_state(id) ON DELETE SET NULL;


--
-- Name: res_bank res_bank_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_bank
    ADD CONSTRAINT res_bank_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_company res_company_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_company
    ADD CONSTRAINT res_company_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_company res_company_currency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_company
    ADD CONSTRAINT res_company_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.res_currency(id) ON DELETE RESTRICT;


--
-- Name: res_company res_company_external_report_layout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_company
    ADD CONSTRAINT res_company_external_report_layout_id_fkey FOREIGN KEY (external_report_layout_id) REFERENCES public.ir_ui_view(id) ON DELETE SET NULL;


--
-- Name: res_company res_company_paperformat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_company
    ADD CONSTRAINT res_company_paperformat_id_fkey FOREIGN KEY (paperformat_id) REFERENCES public.report_paperformat(id) ON DELETE SET NULL;


--
-- Name: res_company res_company_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_company
    ADD CONSTRAINT res_company_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.res_company(id) ON DELETE SET NULL;


--
-- Name: res_company res_company_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_company
    ADD CONSTRAINT res_company_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.res_partner(id) ON DELETE RESTRICT;


--
-- Name: res_company_users_rel res_company_users_rel_cid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_company_users_rel
    ADD CONSTRAINT res_company_users_rel_cid_fkey FOREIGN KEY (cid) REFERENCES public.res_company(id) ON DELETE CASCADE;


--
-- Name: res_company_users_rel res_company_users_rel_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_company_users_rel
    ADD CONSTRAINT res_company_users_rel_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.res_users(id) ON DELETE CASCADE;


--
-- Name: res_company res_company_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_company
    ADD CONSTRAINT res_company_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_config res_config_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_config
    ADD CONSTRAINT res_config_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_config_installer res_config_installer_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_config_installer
    ADD CONSTRAINT res_config_installer_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_config_installer res_config_installer_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_config_installer
    ADD CONSTRAINT res_config_installer_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_config_settings res_config_settings_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_config_settings
    ADD CONSTRAINT res_config_settings_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.res_company(id) ON DELETE CASCADE;


--
-- Name: res_config_settings res_config_settings_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_config_settings
    ADD CONSTRAINT res_config_settings_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_config_settings res_config_settings_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_config_settings
    ADD CONSTRAINT res_config_settings_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_config res_config_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_config
    ADD CONSTRAINT res_config_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_country res_country_address_view_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country
    ADD CONSTRAINT res_country_address_view_id_fkey FOREIGN KEY (address_view_id) REFERENCES public.ir_ui_view(id) ON DELETE SET NULL;


--
-- Name: res_country res_country_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country
    ADD CONSTRAINT res_country_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_country res_country_currency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country
    ADD CONSTRAINT res_country_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.res_currency(id) ON DELETE SET NULL;


--
-- Name: res_country_group res_country_group_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country_group
    ADD CONSTRAINT res_country_group_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_country_group res_country_group_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country_group
    ADD CONSTRAINT res_country_group_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_country_res_country_group_rel res_country_res_country_group_rel_res_country_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country_res_country_group_rel
    ADD CONSTRAINT res_country_res_country_group_rel_res_country_group_id_fkey FOREIGN KEY (res_country_group_id) REFERENCES public.res_country_group(id) ON DELETE CASCADE;


--
-- Name: res_country_res_country_group_rel res_country_res_country_group_rel_res_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country_res_country_group_rel
    ADD CONSTRAINT res_country_res_country_group_rel_res_country_id_fkey FOREIGN KEY (res_country_id) REFERENCES public.res_country(id) ON DELETE CASCADE;


--
-- Name: res_country_state res_country_state_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country_state
    ADD CONSTRAINT res_country_state_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.res_country(id) ON DELETE RESTRICT;


--
-- Name: res_country_state res_country_state_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country_state
    ADD CONSTRAINT res_country_state_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_country_state res_country_state_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country_state
    ADD CONSTRAINT res_country_state_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_country res_country_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_country
    ADD CONSTRAINT res_country_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_currency res_currency_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_currency
    ADD CONSTRAINT res_currency_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_currency_rate res_currency_rate_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_currency_rate
    ADD CONSTRAINT res_currency_rate_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.res_company(id) ON DELETE SET NULL;


--
-- Name: res_currency_rate res_currency_rate_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_currency_rate
    ADD CONSTRAINT res_currency_rate_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_currency_rate res_currency_rate_currency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_currency_rate
    ADD CONSTRAINT res_currency_rate_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.res_currency(id) ON DELETE CASCADE;


--
-- Name: res_currency_rate res_currency_rate_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_currency_rate
    ADD CONSTRAINT res_currency_rate_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_currency res_currency_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_currency
    ADD CONSTRAINT res_currency_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_groups res_groups_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_groups
    ADD CONSTRAINT res_groups_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.ir_module_category(id) ON DELETE SET NULL;


--
-- Name: res_groups res_groups_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_groups
    ADD CONSTRAINT res_groups_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_groups_implied_rel res_groups_implied_rel_gid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_groups_implied_rel
    ADD CONSTRAINT res_groups_implied_rel_gid_fkey FOREIGN KEY (gid) REFERENCES public.res_groups(id) ON DELETE CASCADE;


--
-- Name: res_groups_implied_rel res_groups_implied_rel_hid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_groups_implied_rel
    ADD CONSTRAINT res_groups_implied_rel_hid_fkey FOREIGN KEY (hid) REFERENCES public.res_groups(id) ON DELETE CASCADE;


--
-- Name: res_groups_report_rel res_groups_report_rel_gid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_groups_report_rel
    ADD CONSTRAINT res_groups_report_rel_gid_fkey FOREIGN KEY (gid) REFERENCES public.res_groups(id) ON DELETE CASCADE;


--
-- Name: res_groups_report_rel res_groups_report_rel_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_groups_report_rel
    ADD CONSTRAINT res_groups_report_rel_uid_fkey FOREIGN KEY (uid) REFERENCES public.ir_act_report_xml(id) ON DELETE CASCADE;


--
-- Name: res_groups_users_rel res_groups_users_rel_gid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_groups_users_rel
    ADD CONSTRAINT res_groups_users_rel_gid_fkey FOREIGN KEY (gid) REFERENCES public.res_groups(id) ON DELETE CASCADE;


--
-- Name: res_groups_users_rel res_groups_users_rel_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_groups_users_rel
    ADD CONSTRAINT res_groups_users_rel_uid_fkey FOREIGN KEY (uid) REFERENCES public.res_users(id) ON DELETE CASCADE;


--
-- Name: res_groups res_groups_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_groups
    ADD CONSTRAINT res_groups_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_lang res_lang_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_lang
    ADD CONSTRAINT res_lang_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_lang_install_rel res_lang_install_rel_lang_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_lang_install_rel
    ADD CONSTRAINT res_lang_install_rel_lang_id_fkey FOREIGN KEY (lang_id) REFERENCES public.res_lang(id) ON DELETE CASCADE;


--
-- Name: res_lang_install_rel res_lang_install_rel_language_wizard_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_lang_install_rel
    ADD CONSTRAINT res_lang_install_rel_language_wizard_id_fkey FOREIGN KEY (language_wizard_id) REFERENCES public.base_language_install(id) ON DELETE CASCADE;


--
-- Name: res_lang res_lang_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_lang
    ADD CONSTRAINT res_lang_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_partner_bank res_partner_bank_bank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_bank
    ADD CONSTRAINT res_partner_bank_bank_id_fkey FOREIGN KEY (bank_id) REFERENCES public.res_bank(id) ON DELETE SET NULL;


--
-- Name: res_partner_bank res_partner_bank_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_bank
    ADD CONSTRAINT res_partner_bank_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.res_company(id) ON DELETE SET NULL;


--
-- Name: res_partner_bank res_partner_bank_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_bank
    ADD CONSTRAINT res_partner_bank_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_partner_bank res_partner_bank_currency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_bank
    ADD CONSTRAINT res_partner_bank_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.res_currency(id) ON DELETE SET NULL;


--
-- Name: res_partner_bank res_partner_bank_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_bank
    ADD CONSTRAINT res_partner_bank_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.res_partner(id) ON DELETE CASCADE;


--
-- Name: res_partner_bank res_partner_bank_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_bank
    ADD CONSTRAINT res_partner_bank_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_partner_category res_partner_category_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_category
    ADD CONSTRAINT res_partner_category_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_partner_category res_partner_category_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_category
    ADD CONSTRAINT res_partner_category_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.res_partner_category(id) ON DELETE CASCADE;


--
-- Name: res_partner_category res_partner_category_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_category
    ADD CONSTRAINT res_partner_category_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_partner res_partner_commercial_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner
    ADD CONSTRAINT res_partner_commercial_partner_id_fkey FOREIGN KEY (commercial_partner_id) REFERENCES public.res_partner(id) ON DELETE SET NULL;


--
-- Name: res_partner res_partner_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner
    ADD CONSTRAINT res_partner_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.res_company(id) ON DELETE SET NULL;


--
-- Name: res_partner res_partner_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner
    ADD CONSTRAINT res_partner_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.res_country(id) ON DELETE RESTRICT;


--
-- Name: res_partner res_partner_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner
    ADD CONSTRAINT res_partner_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_partner_industry res_partner_industry_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_industry
    ADD CONSTRAINT res_partner_industry_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_partner res_partner_industry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner
    ADD CONSTRAINT res_partner_industry_id_fkey FOREIGN KEY (industry_id) REFERENCES public.res_partner_industry(id) ON DELETE SET NULL;


--
-- Name: res_partner_industry res_partner_industry_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_industry
    ADD CONSTRAINT res_partner_industry_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_partner res_partner_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner
    ADD CONSTRAINT res_partner_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.res_partner(id) ON DELETE SET NULL;


--
-- Name: res_partner_res_partner_category_rel res_partner_res_partner_category_rel_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_res_partner_category_rel
    ADD CONSTRAINT res_partner_res_partner_category_rel_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.res_partner_category(id) ON DELETE CASCADE;


--
-- Name: res_partner_res_partner_category_rel res_partner_res_partner_category_rel_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_res_partner_category_rel
    ADD CONSTRAINT res_partner_res_partner_category_rel_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.res_partner(id) ON DELETE CASCADE;


--
-- Name: res_partner res_partner_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner
    ADD CONSTRAINT res_partner_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.res_country_state(id) ON DELETE RESTRICT;


--
-- Name: res_partner_title res_partner_title_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_title
    ADD CONSTRAINT res_partner_title_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_partner res_partner_title_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner
    ADD CONSTRAINT res_partner_title_fkey FOREIGN KEY (title) REFERENCES public.res_partner_title(id) ON DELETE SET NULL;


--
-- Name: res_partner_title res_partner_title_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner_title
    ADD CONSTRAINT res_partner_title_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_partner res_partner_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner
    ADD CONSTRAINT res_partner_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_partner res_partner_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_partner
    ADD CONSTRAINT res_partner_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_users_apikeys_description res_users_apikeys_description_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_apikeys_description
    ADD CONSTRAINT res_users_apikeys_description_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_users_apikeys_description res_users_apikeys_description_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_apikeys_description
    ADD CONSTRAINT res_users_apikeys_description_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_users_apikeys res_users_apikeys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_apikeys
    ADD CONSTRAINT res_users_apikeys_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.res_users(id) ON DELETE CASCADE;


--
-- Name: res_users res_users_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users
    ADD CONSTRAINT res_users_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.res_company(id) ON DELETE RESTRICT;


--
-- Name: res_users res_users_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users
    ADD CONSTRAINT res_users_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_users_deletion res_users_deletion_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_deletion
    ADD CONSTRAINT res_users_deletion_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_users_deletion res_users_deletion_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_deletion
    ADD CONSTRAINT res_users_deletion_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_users_deletion res_users_deletion_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_deletion
    ADD CONSTRAINT res_users_deletion_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_users_identitycheck res_users_identitycheck_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_identitycheck
    ADD CONSTRAINT res_users_identitycheck_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_users_identitycheck res_users_identitycheck_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_identitycheck
    ADD CONSTRAINT res_users_identitycheck_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_users_log res_users_log_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_log
    ADD CONSTRAINT res_users_log_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_users_log res_users_log_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_log
    ADD CONSTRAINT res_users_log_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_users res_users_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users
    ADD CONSTRAINT res_users_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.res_partner(id) ON DELETE RESTRICT;


--
-- Name: res_users_settings res_users_settings_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_settings
    ADD CONSTRAINT res_users_settings_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_users_settings res_users_settings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_settings
    ADD CONSTRAINT res_users_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.res_users(id) ON DELETE CASCADE;


--
-- Name: res_users_settings res_users_settings_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users_settings
    ADD CONSTRAINT res_users_settings_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: res_users res_users_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.res_users
    ADD CONSTRAINT res_users_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: reset_view_arch_wizard reset_view_arch_wizard_compare_view_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reset_view_arch_wizard
    ADD CONSTRAINT reset_view_arch_wizard_compare_view_id_fkey FOREIGN KEY (compare_view_id) REFERENCES public.ir_ui_view(id) ON DELETE SET NULL;


--
-- Name: reset_view_arch_wizard reset_view_arch_wizard_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reset_view_arch_wizard
    ADD CONSTRAINT reset_view_arch_wizard_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: reset_view_arch_wizard reset_view_arch_wizard_view_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reset_view_arch_wizard
    ADD CONSTRAINT reset_view_arch_wizard_view_id_fkey FOREIGN KEY (view_id) REFERENCES public.ir_ui_view(id) ON DELETE SET NULL;


--
-- Name: reset_view_arch_wizard reset_view_arch_wizard_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reset_view_arch_wizard
    ADD CONSTRAINT reset_view_arch_wizard_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: rule_group_rel rule_group_rel_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_group_rel
    ADD CONSTRAINT rule_group_rel_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.res_groups(id) ON DELETE RESTRICT;


--
-- Name: rule_group_rel rule_group_rel_rule_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_group_rel
    ADD CONSTRAINT rule_group_rel_rule_group_id_fkey FOREIGN KEY (rule_group_id) REFERENCES public.ir_rule(id) ON DELETE CASCADE;


--
-- Name: web_editor_converter_test web_editor_converter_test_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_editor_converter_test
    ADD CONSTRAINT web_editor_converter_test_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: web_editor_converter_test web_editor_converter_test_many2one_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_editor_converter_test
    ADD CONSTRAINT web_editor_converter_test_many2one_fkey FOREIGN KEY (many2one) REFERENCES public.web_editor_converter_test_sub(id) ON DELETE SET NULL;


--
-- Name: web_editor_converter_test_sub web_editor_converter_test_sub_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_editor_converter_test_sub
    ADD CONSTRAINT web_editor_converter_test_sub_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: web_editor_converter_test_sub web_editor_converter_test_sub_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_editor_converter_test_sub
    ADD CONSTRAINT web_editor_converter_test_sub_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: web_editor_converter_test web_editor_converter_test_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_editor_converter_test
    ADD CONSTRAINT web_editor_converter_test_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: web_tour_tour web_tour_tour_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_tour_tour
    ADD CONSTRAINT web_tour_tour_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: wizard_ir_model_menu_create wizard_ir_model_menu_create_create_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wizard_ir_model_menu_create
    ADD CONSTRAINT wizard_ir_model_menu_create_create_uid_fkey FOREIGN KEY (create_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- Name: wizard_ir_model_menu_create wizard_ir_model_menu_create_menu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wizard_ir_model_menu_create
    ADD CONSTRAINT wizard_ir_model_menu_create_menu_id_fkey FOREIGN KEY (menu_id) REFERENCES public.ir_ui_menu(id) ON DELETE CASCADE;


--
-- Name: wizard_ir_model_menu_create wizard_ir_model_menu_create_write_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wizard_ir_model_menu_create
    ADD CONSTRAINT wizard_ir_model_menu_create_write_uid_fkey FOREIGN KEY (write_uid) REFERENCES public.res_users(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--


