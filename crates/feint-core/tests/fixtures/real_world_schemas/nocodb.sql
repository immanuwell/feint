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
-- Name: nc_addons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_addons (
    id character varying(20) NOT NULL,
    addon_key character varying(255) NOT NULL,
    title character varying(255),
    description text,
    stripe_product_id character varying(255) NOT NULL,
    prices text,
    is_active boolean DEFAULT true,
    meta text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_api_token_scopes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_api_token_scopes (
    id character varying(20) NOT NULL,
    fk_api_token_id character varying(20) NOT NULL,
    resource_type character varying(20) NOT NULL,
    resource_id character varying(20) NOT NULL,
    permissions text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_api_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_api_tokens (
    id integer NOT NULL,
    base_id character varying(20),
    db_alias character varying(255),
    description character varying(255),
    permissions text,
    token text,
    expiry character varying(255),
    enabled boolean DEFAULT true,
    fk_user_id character varying(20),
    fk_workspace_id character varying(20),
    fk_sso_client_id character varying(20),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    token_hash character varying(64),
    token_prefix character varying(20),
    last_used_at timestamp with time zone
);


--
-- Name: nc_api_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nc_api_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nc_api_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nc_api_tokens_id_seq OWNED BY public.nc_api_tokens.id;


--
-- Name: nc_audit_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_audit_v2 (
    id uuid NOT NULL,
    "user" character varying(255),
    ip character varying(255),
    source_id character varying(20),
    base_id character varying(20),
    fk_model_id character varying(20),
    row_id character varying(255),
    op_type character varying(255),
    op_sub_type character varying(255),
    status character varying(255),
    description text,
    details text,
    fk_user_id character varying(20),
    fk_ref_id character varying(20),
    fk_parent_id uuid,
    fk_workspace_id character varying(20),
    fk_org_id character varying(20),
    user_agent text,
    version smallint DEFAULT '0'::smallint,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    old_id character varying(20)
);


--
-- Name: nc_automation_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_automation_executions (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_workflow_id character varying(20) NOT NULL,
    workflow_data text,
    execution_data text,
    finished boolean DEFAULT false,
    started_at timestamp with time zone,
    finished_at timestamp with time zone,
    status character varying(50),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    resume_at timestamp with time zone,
    error_notified_at timestamp with time zone
);


--
-- Name: nc_automation_subscribers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_automation_subscribers (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_automation_id character varying(20),
    fk_user_id character varying(20),
    notify_on_error boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_automations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_automations (
    id character varying(20) NOT NULL,
    title character varying(255),
    description text,
    meta text,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    "order" real,
    type character varying(20),
    created_by character varying(20),
    updated_by character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    enabled boolean DEFAULT false,
    nodes text,
    edges text,
    draft text,
    config text,
    script text,
    draft_reminder_sent_at timestamp with time zone,
    deleted boolean
);


--
-- Name: nc_base_users_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_base_users_v2 (
    base_id character varying(20) NOT NULL,
    fk_user_id character varying(20) NOT NULL,
    roles text,
    starred boolean,
    pinned boolean,
    "group" character varying(255),
    color character varying(255),
    "order" real,
    hidden real,
    opened_date timestamp with time zone,
    invited_by character varying(20),
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_base_variables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_base_variables (
    id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    key character varying(255),
    value text,
    description text,
    inheritance character varying(20) DEFAULT 'fixed'::character varying,
    type character varying(20) DEFAULT 'text'::character varying,
    "order" real,
    default_value text,
    is_overridden boolean DEFAULT false,
    is_inherited boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_bases_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_bases_v2 (
    id character varying(128) NOT NULL,
    title character varying(255),
    prefix character varying(255),
    status character varying(255),
    description text,
    meta text,
    color character varying(255),
    uuid character varying(255),
    password character varying(255),
    roles character varying(255),
    deleted boolean DEFAULT false,
    is_meta boolean,
    "order" real,
    type character varying(200),
    fk_workspace_id character varying(20),
    is_snapshot boolean DEFAULT false,
    fk_custom_url_id character varying(20),
    version smallint DEFAULT '2'::smallint,
    default_role character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    managed_app_master boolean DEFAULT false,
    managed_app_id character varying(20),
    managed_app_version_id character varying(20),
    auto_update boolean DEFAULT true,
    is_sandbox_production boolean DEFAULT false,
    is_sandbox boolean DEFAULT false
);


--
-- Name: nc_bookmark_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_bookmark_groups (
    id character varying(20) NOT NULL,
    fk_user_id character varying(20) NOT NULL,
    name character varying(100) NOT NULL,
    "order" real DEFAULT '0'::real,
    meta text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_bookmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_bookmarks (
    id character varying(20) NOT NULL,
    fk_user_id character varying(20) NOT NULL,
    fk_group_id character varying(20) NOT NULL,
    title character varying(255) DEFAULT NULL::character varying,
    target_type character varying(20) NOT NULL,
    target_id character varying(128) NOT NULL,
    icon character varying(255) DEFAULT NULL::character varying,
    icon_color character varying(50) DEFAULT NULL::character varying,
    icon_type character varying(20) DEFAULT NULL::character varying,
    "order" real DEFAULT '0'::real,
    meta text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_calendar_view_columns_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_calendar_view_columns_v2 (
    id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    source_id character varying(20),
    fk_view_id character varying(20),
    fk_column_id character varying(20),
    show boolean,
    bold boolean,
    underline boolean,
    italic boolean,
    "order" real,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_calendar_view_range_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_calendar_view_range_v2 (
    id character varying(20) NOT NULL,
    fk_view_id character varying(20),
    fk_to_column_id character varying(20),
    label character varying(40),
    fk_from_column_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_calendar_view_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_calendar_view_v2 (
    fk_view_id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    source_id character varying(20),
    title character varying(255),
    fk_cover_image_col_id character varying(20),
    meta text,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: nc_chat_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_chat_messages (
    id character varying(20) NOT NULL,
    fk_session_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20) NOT NULL,
    role character varying(20) NOT NULL,
    content text,
    parts text,
    model character varying(100),
    input_tokens integer DEFAULT 0,
    output_tokens integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    base_id character varying(20),
    bt_span_id character varying(100),
    files text,
    created_files text,
    ui_context_record text
);


--
-- Name: nc_chat_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_chat_sessions (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20) NOT NULL,
    fk_user_id character varying(20),
    title character varying(255),
    summary text,
    total_input_tokens integer DEFAULT 0,
    total_output_tokens integer DEFAULT 0,
    message_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    meta text,
    base_id character varying(20)
);


--
-- Name: nc_col_barcode_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_col_barcode_v2 (
    id character varying(20) NOT NULL,
    fk_column_id character varying(20),
    fk_barcode_value_column_id character varying(20),
    barcode_format character varying(15),
    deleted boolean,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    error text
);


--
-- Name: nc_col_button_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_col_button_v2 (
    id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    type character varying(255),
    label text,
    theme character varying(255),
    color character varying(255),
    icon character varying(255),
    formula text,
    formula_raw text,
    error character varying(255),
    parsed_tree text,
    fk_webhook_id character varying(20),
    fk_column_id character varying(20),
    fk_integration_id character varying(20),
    model character varying(255),
    output_column_ids text,
    fk_workspace_id character varying(20),
    fk_script_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_col_formula_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_col_formula_v2 (
    id character varying(20) NOT NULL,
    fk_column_id character varying(20),
    formula text NOT NULL,
    formula_raw text,
    error text,
    deleted boolean,
    "order" real,
    parsed_tree text,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_col_long_text_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_col_long_text_v2 (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_model_id character varying(20),
    fk_column_id character varying(20),
    fk_integration_id character varying(20),
    model character varying(255),
    prompt text,
    prompt_raw text,
    error text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_col_lookup_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_col_lookup_v2 (
    id character varying(20) NOT NULL,
    fk_column_id character varying(20),
    fk_relation_column_id character varying(20),
    fk_lookup_column_id character varying(20),
    deleted boolean,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    error text
);


--
-- Name: nc_col_qrcode_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_col_qrcode_v2 (
    id character varying(20) NOT NULL,
    fk_column_id character varying(20),
    fk_qr_value_column_id character varying(20),
    deleted boolean,
    "order" real,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    error text
);


--
-- Name: nc_col_relations_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_col_relations_v2 (
    id character varying(20) NOT NULL,
    ref_db_alias character varying(255),
    type character varying(255),
    virtual boolean,
    db_type character varying(255),
    fk_column_id character varying(20),
    fk_related_model_id character varying(20),
    fk_child_column_id character varying(20),
    fk_parent_column_id character varying(20),
    fk_mm_model_id character varying(20),
    fk_mm_child_column_id character varying(20),
    fk_mm_parent_column_id character varying(20),
    ur character varying(255),
    dr character varying(255),
    fk_index_name character varying(255),
    deleted boolean,
    fk_target_view_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    fk_related_base_id character varying(20),
    fk_mm_base_id character varying(20),
    fk_related_source_id character varying(20),
    fk_mm_source_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version integer DEFAULT 1,
    fk_display_value_column_id character varying(20),
    fk_mm_child_order_column_id character varying(20),
    fk_mm_parent_order_column_id character varying(20)
);


--
-- Name: nc_col_rollup_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_col_rollup_v2 (
    id character varying(20) NOT NULL,
    fk_column_id character varying(20),
    fk_relation_column_id character varying(20),
    fk_rollup_column_id character varying(20),
    rollup_function character varying(255),
    deleted boolean,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    error text
);


--
-- Name: nc_col_select_options_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_col_select_options_v2 (
    id character varying(20) NOT NULL,
    fk_column_id character varying(20),
    title character varying(255),
    color character varying(255),
    "order" real,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_columns_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_columns_v2 (
    id character varying(20) NOT NULL,
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_model_id character varying(20),
    title character varying(255),
    column_name character varying(255),
    uidt character varying(255),
    dt character varying(255),
    np character varying(255),
    ns character varying(255),
    clen character varying(255),
    cop character varying(255),
    pk boolean,
    pv boolean,
    rqd boolean,
    un boolean,
    ct text,
    ai boolean,
    "unique" boolean,
    cdf text,
    cc text,
    csn character varying(255),
    dtx character varying(255),
    dtxp text,
    dtxs character varying(255),
    au boolean,
    validate text,
    virtual boolean,
    deleted boolean,
    system boolean DEFAULT false,
    "order" real,
    meta text,
    description text,
    readonly boolean DEFAULT false,
    fk_workspace_id character varying(20),
    custom_index_name character varying(64),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    internal_meta text
);


--
-- Name: nc_comment_reactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_comment_reactions (
    id character varying(20) NOT NULL,
    row_id character varying(255),
    comment_id character varying(20),
    source_id character varying(20),
    fk_model_id character varying(20),
    base_id character varying(20) NOT NULL,
    reaction character varying(255),
    created_by character varying(255),
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_comments (
    id character varying(20) NOT NULL,
    row_id character varying(255),
    comment text,
    created_by character varying(20),
    created_by_email character varying(255),
    resolved_by character varying(20),
    resolved_by_email character varying(255),
    parent_comment_id character varying(20),
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_model_id character varying(20),
    is_deleted boolean,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fk_doc_id character varying(20),
    anchor_id character varying(20),
    attachments text,
    meta text
);


--
-- Name: nc_custom_urls_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_custom_urls_v2 (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_model_id character varying(20),
    view_id character varying(20),
    original_path character varying(255),
    custom_path character varying(255),
    fk_dashboard_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_dashboards_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_dashboards_v2 (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    meta text,
    "order" integer,
    created_by character varying(20),
    owned_by character varying(20),
    uuid character varying(255),
    password character varying(255),
    fk_custom_url_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted boolean
);


--
-- Name: nc_data_reflection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_data_reflection (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    username character varying(255),
    password character varying(255),
    database character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_date_dependency_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_date_dependency_v2 (
    id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    fk_model_id character varying(20),
    fk_start_date_field_id character varying(20),
    fk_end_date_field_id character varying(20),
    fk_duration_field_id character varying(20),
    fk_dependency_linkrow_field_id character varying(20),
    dependency_linkrow_role character varying(20) DEFAULT 'predecessors'::character varying,
    dependency_connection_type character varying(20) DEFAULT 'end-to-start'::character varying,
    dependency_buffer_type character varying(20) DEFAULT 'none'::character varying,
    dependency_buffer_days integer DEFAULT 0,
    include_weekends boolean DEFAULT true,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fk_gantt_view_id character varying(20)
);


--
-- Name: nc_db_servers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_db_servers (
    id character varying(20) NOT NULL,
    title character varying(255),
    is_shared boolean DEFAULT true,
    max_tenant_count integer,
    current_tenant_count integer DEFAULT 0,
    config text,
    conditions text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_dependency_tracker; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_dependency_tracker (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    source_type character varying(50) NOT NULL,
    source_id character varying(20) NOT NULL,
    dependent_type character varying(50) NOT NULL,
    dependent_id character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    queryable_field_0 text,
    queryable_field_1 text,
    meta text,
    queryable_field_2 timestamp with time zone
);


--
-- Name: nc_disabled_models_for_role_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_disabled_models_for_role_v2 (
    id character varying(20) NOT NULL,
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_view_id character varying(20),
    role character varying(45),
    disabled boolean DEFAULT true,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_doc_content_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_doc_content_v2 (
    fk_doc_id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    content jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    yjs_state bytea
);


--
-- Name: nc_doc_revisions_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_doc_revisions_v2 (
    id character varying(40) NOT NULL,
    fk_doc_id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    version integer NOT NULL,
    content jsonb,
    title character varying(255),
    created_by character varying(20),
    fk_tab_id character varying(36),
    source character varying(16) DEFAULT 'auto'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_docs_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_docs_v2 (
    id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    title character varying(512),
    meta text,
    "order" real,
    parent_id character varying(20),
    deleted boolean DEFAULT false,
    has_children boolean DEFAULT false,
    version integer DEFAULT 1,
    created_by character varying(20),
    updated_by character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_extensions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_extensions (
    id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    fk_user_id character varying(20),
    extension_id character varying(255),
    title character varying(255),
    kv_store text,
    meta text,
    "order" real,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted boolean
);


--
-- Name: nc_file_references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_file_references (
    id character varying(20) NOT NULL,
    storage character varying(255),
    file_url text,
    file_size integer,
    fk_user_id character varying(20),
    fk_workspace_id character varying(20),
    base_id character varying(20),
    source_id character varying(20),
    fk_model_id character varying(20),
    fk_column_id character varying(20),
    is_external boolean DEFAULT false,
    deleted boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fk_doc_id character varying(20),
    fk_session_id character varying(20),
    soft_deleted boolean DEFAULT false,
    fk_row_id character varying(255),
    fk_revision_id character varying(40),
    fk_comment_id character varying(20)
);


--
-- Name: nc_filter_exp_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_filter_exp_v2 (
    id character varying(20) NOT NULL,
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_view_id character varying(20),
    fk_hook_id character varying(20),
    fk_column_id character varying(20),
    fk_parent_id character varying(20),
    logical_op character varying(255),
    comparison_op character varying(255),
    value text,
    is_group boolean,
    "order" real,
    comparison_sub_op character varying(255),
    fk_link_col_id character varying(20),
    fk_value_col_id character varying(20),
    fk_parent_column_id character varying(20),
    fk_workspace_id character varying(20),
    fk_row_color_condition_id character varying(20),
    fk_widget_id character varying(20),
    meta text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    enabled boolean DEFAULT true,
    fk_rls_policy_id character varying(20),
    fk_level_id character varying(20),
    fk_button_col_id character varying(20)
);


--
-- Name: nc_follower; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_follower (
    fk_user_id character varying(20) NOT NULL,
    fk_follower_id character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_form_view_columns_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_form_view_columns_v2 (
    id character varying(20) NOT NULL,
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_view_id character varying(20),
    fk_column_id character varying(20),
    uuid character varying(255),
    label text,
    help text,
    description text,
    required boolean,
    show boolean,
    "order" real,
    meta text,
    enable_scanner boolean,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    row_id character varying(32)
);


--
-- Name: nc_form_view_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_form_view_v2 (
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_view_id character varying(20) NOT NULL,
    heading character varying(255),
    subheading text,
    success_msg text,
    redirect_url text,
    redirect_after_secs character varying(255),
    email text,
    submit_another_form boolean,
    show_blank_form boolean,
    uuid character varying(255),
    banner_image_url text,
    logo_url text,
    meta text,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    starts_at timestamp with time zone,
    expires_at timestamp with time zone,
    save_draft_to_browser boolean DEFAULT true
);


--
-- Name: nc_gallery_view_columns_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_gallery_view_columns_v2 (
    id character varying(20) NOT NULL,
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_view_id character varying(20),
    fk_column_id character varying(20),
    uuid character varying(255),
    label character varying(255),
    help character varying(255),
    show boolean,
    "order" real,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_gallery_view_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_gallery_view_v2 (
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_view_id character varying(20) NOT NULL,
    next_enabled boolean,
    prev_enabled boolean,
    cover_image_idx integer,
    fk_cover_image_col_id character varying(20),
    cover_image character varying(255),
    restrict_types character varying(255),
    restrict_size character varying(255),
    restrict_number character varying(255),
    public boolean,
    dimensions character varying(255),
    responsive_columns character varying(255),
    meta text,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_gantt_view_columns_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_gantt_view_columns_v2 (
    id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    source_id character varying(20),
    fk_view_id character varying(20),
    fk_column_id character varying(20),
    show boolean,
    bold boolean,
    underline boolean,
    italic boolean,
    "order" real,
    group_by boolean,
    group_by_order real,
    group_by_sort character varying(4),
    aggregation character varying(20),
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    group_by_enabled boolean
);


--
-- Name: nc_gantt_view_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_gantt_view_v2 (
    fk_view_id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    source_id character varying(20),
    title character varying(255),
    meta text,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_gcp_marketplace_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_gcp_marketplace_accounts (
    id character varying(20) NOT NULL,
    procurement_account_id character varying(255) NOT NULL,
    fk_user_id character varying(20),
    state character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    link_token character varying(64),
    link_token_expires_at timestamp with time zone,
    meta text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_gcp_marketplace_entitlements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_gcp_marketplace_entitlements (
    id character varying(20) NOT NULL,
    entitlement_id character varying(255) NOT NULL,
    fk_gcp_account_id character varying(20) NOT NULL,
    fk_installation_id character varying(20),
    plan character varying(255),
    state character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    meta text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_grid_view_columns_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_grid_view_columns_v2 (
    id character varying(20) NOT NULL,
    fk_view_id character varying(20),
    fk_column_id character varying(20),
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    uuid character varying(255),
    label character varying(255),
    help character varying(255),
    width character varying(255) DEFAULT '200px'::character varying,
    show boolean,
    "order" real,
    group_by boolean,
    group_by_order real,
    group_by_sort character varying(255),
    aggregation character varying(30) DEFAULT NULL::character varying,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    group_by_enabled boolean
);


--
-- Name: nc_grid_view_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_grid_view_v2 (
    fk_view_id character varying(20) NOT NULL,
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    uuid character varying(255),
    meta text,
    row_height integer,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_hook_logs_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_hook_logs_v2 (
    id character varying(20) NOT NULL,
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_hook_id character varying(20),
    type character varying(255),
    event character varying(255),
    operation character varying(255),
    test_call boolean DEFAULT true,
    payload text,
    conditions text,
    notification text,
    error_code character varying(255),
    error_message character varying(255),
    error text,
    execution_time integer,
    response text,
    triggered_by character varying(255),
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    error_notified_at timestamp with time zone
);


--
-- Name: nc_hook_trigger_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_hook_trigger_fields (
    fk_hook_id character varying(20) NOT NULL,
    fk_column_id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_hooks_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_hooks_v2 (
    id character varying(20) NOT NULL,
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_model_id character varying(20),
    title character varying(255),
    description character varying(255),
    env character varying(255) DEFAULT 'all'::character varying,
    type character varying(255),
    event character varying(255),
    operation character varying(255),
    async boolean DEFAULT false,
    payload boolean DEFAULT true,
    url text,
    headers text,
    condition boolean DEFAULT false,
    notification text,
    retries integer DEFAULT 0,
    retry_interval integer DEFAULT 60000,
    timeout integer DEFAULT 60000,
    active boolean DEFAULT true,
    version character varying(255),
    trigger_field boolean DEFAULT false,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted boolean,
    comment_config text
);


--
-- Name: nc_installations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_installations (
    id character varying(20) NOT NULL,
    fk_subscription_id character varying(20),
    licensed_to character varying(255) NOT NULL,
    license_key character varying(255) NOT NULL,
    installation_secret character varying(255),
    installed_at timestamp with time zone,
    last_seen_at timestamp with time zone,
    expires_at timestamp with time zone,
    license_type character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'active'::character varying NOT NULL,
    seat_count integer DEFAULT 0 NOT NULL,
    config text,
    meta text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fk_user_id character varying(20),
    min_seats integer DEFAULT 1 NOT NULL
);


--
-- Name: nc_integration_links_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_integration_links_v2 (
    id character varying(20) NOT NULL,
    fk_integration_id character varying(20),
    base_id character varying(20),
    fk_workspace_id character varying(20),
    created_by character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_integrations_store_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_integrations_store_v2 (
    id character varying(20) NOT NULL,
    fk_integration_id character varying(20),
    type character varying(20),
    sub_type character varying(20),
    fk_workspace_id character varying(20),
    fk_user_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    slot_0 text,
    slot_1 text,
    slot_2 text,
    slot_3 text,
    slot_4 text,
    slot_5 integer,
    slot_6 integer,
    slot_7 integer,
    slot_8 integer,
    slot_9 integer
);


--
-- Name: nc_integrations_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_integrations_v2 (
    id character varying(20) NOT NULL,
    title character varying(128),
    config text,
    meta text,
    type character varying(20),
    sub_type character varying(20),
    fk_workspace_id character varying(20),
    is_private boolean DEFAULT false,
    deleted boolean DEFAULT false,
    created_by character varying(20),
    "order" real,
    is_default boolean DEFAULT false,
    is_encrypted boolean DEFAULT false,
    is_global boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_restricted boolean DEFAULT false
);


--
-- Name: nc_interface_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_interface_pages (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_interface_id character varying(20) NOT NULL,
    fk_model_id character varying(20),
    title character varying(255) NOT NULL,
    layout character varying(30) NOT NULL,
    meta text,
    show_in_nav boolean DEFAULT true,
    visual_variant character varying(20),
    config text,
    published_config text,
    is_published boolean DEFAULT false,
    keep_as_draft boolean DEFAULT false,
    draft_modified_at timestamp with time zone,
    published_at timestamp with time zone,
    error boolean DEFAULT false,
    uuid character varying(255),
    password character varying(255),
    "order" real,
    created_by character varying(20),
    deleted boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_interfaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_interfaces (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    meta text,
    "order" real,
    hidden boolean,
    first_published_at timestamp with time zone,
    last_published_at timestamp with time zone,
    created_by character varying(20),
    owned_by character varying(20),
    deleted boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_jobs (
    id character varying(20) NOT NULL,
    job character varying(255),
    status character varying(20),
    result text,
    fk_user_id character varying(20),
    fk_workspace_id character varying(20),
    base_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_kanban_view_columns_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_kanban_view_columns_v2 (
    id character varying(20) NOT NULL,
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_view_id character varying(20),
    fk_column_id character varying(20),
    uuid character varying(255),
    label character varying(255),
    help character varying(255),
    show boolean,
    "order" real,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_kanban_view_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_kanban_view_v2 (
    fk_view_id character varying(20) NOT NULL,
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    show boolean,
    "order" real,
    uuid character varying(255),
    title character varying(255),
    public boolean,
    password character varying(255),
    show_all_fields boolean,
    fk_grp_col_id character varying(20),
    fk_cover_image_col_id character varying(20),
    meta text,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_list_view_columns_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_list_view_columns_v2 (
    id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    source_id character varying(128),
    fk_view_id character varying(20),
    fk_column_id character varying(20),
    fk_level_id character varying(20),
    show boolean,
    "order" real,
    width character varying(255),
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_list_view_levels_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_list_view_levels_v2 (
    id character varying(20) NOT NULL,
    fk_view_id character varying(20),
    level integer,
    fk_model_id character varying(20),
    fk_link_column_id character varying(20),
    enable_nested_records boolean,
    fk_self_link_column_id character varying(20),
    wrap_headers boolean,
    meta text,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_list_view_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_list_view_v2 (
    fk_view_id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    source_id character varying(128),
    title character varying(255),
    show_empty_parents boolean,
    row_height integer,
    fk_prefix_column_id character varying(20),
    meta text,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_mail_sends; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_mail_sends (
    id character varying(20) NOT NULL,
    event character varying(64) NOT NULL,
    fk_user_id character varying(20),
    to_email character varying(320) NOT NULL,
    subject text,
    status character varying(16) NOT NULL,
    dedupe_key character varying(255),
    payload_json text,
    ses_message_id character varying(128),
    error text,
    attempts integer DEFAULT 0 NOT NULL,
    scheduled_for timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    sent_at timestamp with time zone
);


--
-- Name: nc_managed_app_deployment_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_managed_app_deployment_logs (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    fk_managed_app_id character varying(20) NOT NULL,
    from_version_id character varying(20),
    to_version_id character varying(20) NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    deployment_type character varying(20) NOT NULL,
    error_message text,
    deployment_log text,
    meta text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    started_at timestamp with time zone,
    completed_at timestamp with time zone
);


--
-- Name: nc_managed_app_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_managed_app_versions (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20) NOT NULL,
    fk_managed_app_id character varying(20) NOT NULL,
    version character varying(20) NOT NULL,
    version_number integer NOT NULL,
    status character varying(20) DEFAULT 'draft'::character varying NOT NULL,
    schema text,
    release_notes text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    published_at timestamp with time zone
);


--
-- Name: nc_managed_apps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_managed_apps (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    created_by character varying(20) NOT NULL,
    visibility character varying(20) DEFAULT 'private'::character varying NOT NULL,
    category character varying(255),
    install_count integer DEFAULT 0,
    meta text,
    deleted boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    published_at timestamp with time zone
);


--
-- Name: nc_map_view_columns_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_map_view_columns_v2 (
    id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    project_id character varying(128),
    fk_view_id character varying(20),
    fk_column_id character varying(20),
    uuid character varying(255),
    label character varying(255),
    help character varying(255),
    show boolean,
    "order" real,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    source_id character varying(20)
);


--
-- Name: nc_map_view_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_map_view_v2 (
    fk_view_id character varying(20) NOT NULL,
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    uuid character varying(255),
    title character varying(255),
    fk_geo_data_col_id character varying(20),
    meta text,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: nc_mcp_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_mcp_tokens (
    id character varying(20) NOT NULL,
    title character varying(512),
    base_id character varying(20) NOT NULL,
    token character varying(32),
    fk_workspace_id character varying(20),
    "order" real,
    fk_user_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_model_stats_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_model_stats_v2 (
    fk_workspace_id character varying(20) NOT NULL,
    fk_model_id character varying(20) NOT NULL,
    row_count integer DEFAULT 0,
    is_external boolean DEFAULT false,
    base_id character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_models_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_models_v2 (
    id character varying(20) NOT NULL,
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    table_name character varying(255),
    title character varying(255),
    type character varying(255) DEFAULT 'table'::character varying,
    meta text,
    schema text,
    enabled boolean DEFAULT true,
    mm boolean DEFAULT false,
    tags character varying(255),
    pinned boolean,
    deleted boolean,
    "order" real,
    description text,
    synced boolean DEFAULT false,
    fk_workspace_id character varying(20),
    created_by character varying(20),
    owned_by character varying(20),
    uuid character varying(255),
    password character varying(255),
    fk_custom_url_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    parent_id character varying(20),
    updated_by character varying(20),
    has_children boolean DEFAULT false,
    doc_version integer DEFAULT 1,
    trash_disabled boolean,
    trash_retention_days integer
);


--
-- Name: nc_oauth_authorization_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_oauth_authorization_codes (
    code character varying(32) NOT NULL,
    fk_client_id character varying(32),
    fk_user_id character varying(20),
    code_challenge character varying(255),
    code_challenge_method character varying(10) DEFAULT 'S256'::character varying,
    redirect_uri character varying(255),
    scope character varying(255),
    state character varying(1024),
    resource character varying(255),
    granted_resources text,
    expires_at timestamp with time zone NOT NULL,
    is_used boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_oauth_clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_oauth_clients (
    client_id character varying(32) NOT NULL,
    client_secret character varying(128),
    client_type character varying(255),
    client_name character varying(255),
    client_description text,
    client_uri character varying(255),
    logo_uri character varying(255),
    redirect_uris text,
    allowed_grant_types text,
    response_types text,
    allowed_scopes text,
    registration_access_token character varying(255),
    registration_client_uri character varying(255),
    client_id_issued_at bigint,
    client_secret_expires_at bigint,
    fk_user_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_oauth_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_oauth_tokens (
    id character varying(20) NOT NULL,
    fk_client_id character varying(32),
    fk_user_id character varying(20),
    access_token text,
    access_token_expires_at timestamp with time zone,
    refresh_token text,
    refresh_token_expires_at timestamp with time zone,
    resource character varying(255),
    audience character varying(255),
    granted_resources text,
    scope character varying(255),
    is_revoked boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_used_at timestamp with time zone
);


--
-- Name: nc_operation_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_operation_logs (
    id character varying(20) NOT NULL,
    seq bigint NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20),
    fk_user_id character varying(20),
    tab_id character varying(100),
    forward_op character varying(80),
    forward_op_version smallint,
    forward_params text,
    inverse_op character varying(80),
    inverse_op_version smallint,
    inverse_params text,
    entity_type character varying(40),
    entity_id character varying(20),
    entity_title character varying(255),
    description text,
    scope_type character varying(32),
    scope_id character varying(36),
    status character varying(20) DEFAULT 'active'::character varying,
    error text,
    undone_at timestamp with time zone,
    meta text,
    cleanup_due_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_org; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_org (
    id character varying(20) NOT NULL,
    title character varying(255),
    slug character varying(255),
    fk_user_id character varying(20),
    meta text,
    image character varying(255),
    is_share_enabled boolean DEFAULT false,
    deleted boolean DEFAULT false,
    "order" real,
    fk_db_instance_id character varying(20),
    stripe_customer_id character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_org_domain; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_org_domain (
    id character varying(20) NOT NULL,
    fk_org_id character varying(20),
    fk_user_id character varying(20),
    domain character varying(255),
    verified boolean,
    txt_value character varying(255),
    last_verified timestamp with time zone,
    deleted boolean DEFAULT false,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_org_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_org_users (
    fk_org_id character varying(20) NOT NULL,
    fk_user_id character varying(20) NOT NULL,
    roles character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted boolean DEFAULT false,
    deleted_at timestamp with time zone,
    scim_external_id character varying(255),
    scim_managed boolean DEFAULT false,
    scim_user_name character varying(255),
    scim_meta text
);


--
-- Name: nc_permission_subjects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_permission_subjects (
    fk_permission_id character varying(20) NOT NULL,
    subject_type character varying(255) NOT NULL,
    subject_id character varying(255) NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    hierarchy_scope character varying(30)
);


--
-- Name: nc_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_permissions (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    entity character varying(255),
    entity_id character varying(255),
    permission character varying(255),
    created_by character varying(20),
    enforce_for_form boolean DEFAULT true,
    enforce_for_automation boolean DEFAULT true,
    granted_type character varying(255),
    granted_role character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_plans (
    id character varying(20) NOT NULL,
    title character varying(255),
    description text,
    stripe_product_id character varying(255) NOT NULL,
    is_active boolean DEFAULT true,
    prices text,
    meta text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    license_type character varying(40)
);


--
-- Name: nc_plugins_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_plugins_v2 (
    id character varying(20) NOT NULL,
    title character varying(45),
    description text,
    active boolean DEFAULT false,
    rating real,
    version character varying(255),
    docs character varying(255),
    status character varying(255) DEFAULT 'install'::character varying,
    status_details character varying(255),
    logo character varying(255),
    icon character varying(255),
    tags character varying(255),
    category character varying(255),
    input_schema text,
    input text,
    creator character varying(255),
    creator_website character varying(255),
    price character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_principal_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_principal_assignments (
    resource_type character varying(20) NOT NULL,
    resource_id character varying(20) NOT NULL,
    principal_type character varying(20) NOT NULL,
    principal_ref_id character varying(20) NOT NULL,
    roles character varying(255) NOT NULL,
    deleted boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    hierarchy_scope character varying(30)
);


--
-- Name: nc_record_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_record_templates (
    id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    fk_model_id character varying(20) NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    template_data text NOT NULL,
    usage_count integer DEFAULT 0,
    enabled boolean DEFAULT true,
    created_by character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_rls_policies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_rls_policies (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    source_id character varying(20),
    fk_model_id character varying(20) NOT NULL,
    title character varying(255),
    enabled boolean DEFAULT true,
    is_default boolean DEFAULT false,
    default_behavior character varying(20),
    "order" real,
    meta text,
    created_by character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_rls_policy_subjects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_rls_policy_subjects (
    fk_rls_policy_id character varying(20) NOT NULL,
    subject_type character varying(255) NOT NULL,
    subject_id character varying(255) NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    hierarchy_scope character varying(30)
);


--
-- Name: nc_row_color_conditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_row_color_conditions (
    id character varying(20) NOT NULL,
    fk_view_id character varying(20),
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    color character varying(20),
    nc_order real,
    is_set_as_background boolean,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    type character varying(20) DEFAULT 'row'::character varying,
    fk_target_column_id character varying(20)
);


--
-- Name: nc_sandbox_changelog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_sandbox_changelog (
    id character varying(20) NOT NULL,
    seq bigint NOT NULL,
    fk_sandbox_id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    event character varying(80) NOT NULL,
    entity_type character varying(40) NOT NULL,
    entity_id character varying(20),
    entity_title character varying(255),
    parent_entity_id character varying(20),
    parent_entity_title character varying(255),
    created_by character varying(20) NOT NULL,
    description text,
    meta text,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    merged_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_sandboxes_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_sandboxes_v2 (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20) NOT NULL,
    production_base_id character varying(20) NOT NULL,
    sandbox_base_id character varying(20) NOT NULL,
    created_by character varying(20) NOT NULL,
    meta text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    merge_state character varying(20) DEFAULT 'idle'::character varying NOT NULL,
    merge_error text,
    merge_started_at timestamp with time zone
);


--
-- Name: nc_scim_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_scim_config (
    id character varying(20) NOT NULL,
    enabled boolean DEFAULT false,
    provisioning_token text NOT NULL,
    role_mapping text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    default_role character varying(50) DEFAULT 'no-access'::character varying,
    fk_org_id character varying(20)
);


--
-- Name: nc_scripts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_scripts (
    id character varying(20) NOT NULL,
    title text,
    description text,
    meta text,
    "order" real,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    script text,
    config text,
    created_by character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_snapshot_schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_snapshot_schedules (
    id character varying(20) NOT NULL,
    base_id character varying(20),
    fk_workspace_id character varying(20),
    enabled boolean DEFAULT false,
    frequency character varying(20),
    config text,
    cron_expression character varying(255),
    timezone character varying(255),
    keep_last integer,
    delete_after_days integer,
    next_run_at timestamp with time zone,
    last_run_at timestamp with time zone,
    created_by character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_snapshots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_snapshots (
    id character varying(20) NOT NULL,
    title character varying(512),
    base_id character varying(20),
    snapshot_base_id character varying(20),
    fk_workspace_id character varying(20),
    created_by character varying(20),
    status character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_auto boolean DEFAULT false
);


--
-- Name: nc_sort_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_sort_v2 (
    id character varying(20) NOT NULL,
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_view_id character varying(20),
    fk_column_id character varying(20),
    direction character varying(255) DEFAULT 'false'::character varying,
    "order" real,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fk_level_id character varying(20),
    enabled boolean,
    fk_lookup_col_id character varying(20)
);


--
-- Name: nc_sources_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_sources_v2 (
    id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    alias character varying(255),
    config text,
    meta text,
    is_meta boolean,
    type character varying(255),
    inflection_column character varying(255),
    inflection_table character varying(255),
    enabled boolean DEFAULT true,
    "order" real,
    description character varying(255),
    erd_uuid character varying(255),
    deleted boolean DEFAULT false,
    is_schema_readonly boolean DEFAULT false,
    is_data_readonly boolean DEFAULT false,
    is_local boolean DEFAULT false,
    fk_sql_executor_id character varying(20),
    fk_workspace_id character varying(20),
    fk_integration_id character varying(20),
    is_encrypted boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_sql_executor_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_sql_executor_v2 (
    id character varying(20) NOT NULL,
    domain character varying(50),
    status character varying(20),
    priority integer,
    capacity integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_sso_client; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_sso_client (
    id character varying(20) NOT NULL,
    type character varying(20),
    title character varying(255),
    enabled boolean DEFAULT true,
    config text,
    fk_user_id character varying(20),
    fk_org_id character varying(20),
    deleted boolean DEFAULT false,
    "order" real,
    domain_name character varying(255),
    domain_name_verified boolean,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_sso_client_domain; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_sso_client_domain (
    fk_sso_client_id character varying(20) NOT NULL,
    fk_org_domain_id character varying(20),
    enabled boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_store; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_store (
    id integer NOT NULL,
    base_id character varying(255),
    db_alias character varying(255) DEFAULT 'db'::character varying,
    key character varying(255),
    value text,
    type character varying(255),
    env character varying(255),
    tag character varying(255),
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: nc_store_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nc_store_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nc_store_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nc_store_id_seq OWNED BY public.nc_store.id;


--
-- Name: nc_subscription_addons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_subscription_addons (
    id character varying(20) NOT NULL,
    fk_subscription_id character varying(20) NOT NULL,
    fk_addon_id character varying(20) NOT NULL,
    addon_key character varying(255) NOT NULL,
    stripe_subscription_item_id character varying(255),
    stripe_price_id character varying(255),
    seat_count integer DEFAULT 1,
    status character varying(255) DEFAULT 'active'::character varying,
    meta text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_subscriptions (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    fk_org_id character varying(20),
    fk_plan_id character varying(20) NOT NULL,
    fk_user_id character varying(20),
    stripe_subscription_id character varying(255),
    stripe_price_id character varying(255),
    seat_count integer DEFAULT 1 NOT NULL,
    status character varying(255),
    billing_cycle_anchor timestamp with time zone,
    start_at timestamp with time zone,
    trial_end_at timestamp with time zone,
    canceled_at timestamp with time zone,
    period character varying(255),
    upcoming_invoice_at timestamp with time zone,
    upcoming_invoice_due_at timestamp with time zone,
    upcoming_invoice_amount integer,
    upcoming_invoice_currency character varying(255),
    stripe_schedule_id character varying(255),
    schedule_phase_start timestamp with time zone,
    schedule_stripe_price_id character varying(255),
    schedule_fk_plan_id character varying(20),
    schedule_period character varying(255),
    schedule_type character varying(255),
    meta text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_paid_seat_count integer
);


--
-- Name: nc_sync_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_sync_configs (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_integration_id character varying(20),
    fk_model_id character varying(20),
    sync_type character varying(255),
    sync_trigger character varying(255),
    sync_trigger_cron character varying(255),
    sync_trigger_secret character varying(255),
    sync_job_id character varying(255),
    last_sync_at timestamp with time zone,
    next_sync_at timestamp with time zone,
    title character varying(255),
    sync_category character varying(255),
    fk_parent_sync_config_id character varying(20),
    on_delete_action character varying(255) DEFAULT 'mark_deleted'::character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(20),
    updated_by character varying(20),
    meta text,
    deleted boolean DEFAULT false
);


--
-- Name: nc_sync_logs_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_sync_logs_v2 (
    id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    fk_sync_source_id character varying(20),
    time_taken integer,
    status character varying(255),
    status_details text,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_sync_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_sync_mappings (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_sync_config_id character varying(20),
    target_table character varying(255),
    fk_model_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_sync_source_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_sync_source_v2 (
    id character varying(20) NOT NULL,
    title character varying(255),
    type character varying(255),
    details text,
    deleted boolean,
    enabled boolean DEFAULT true,
    "order" real,
    base_id character varying(20) NOT NULL,
    fk_user_id character varying(20),
    source_id character varying(20),
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_table_sync_column_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_table_sync_column_mappings (
    id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    fk_table_sync_id character varying(20),
    fk_table_sync_mapping_id character varying(20),
    source_workspace_id character varying(20),
    source_base_id character varying(20),
    source_table_id character varying(20),
    source_column_id character varying(20),
    dest_base_id character varying(20),
    dest_table_id character varying(20),
    dest_column_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_table_sync_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_table_sync_mappings (
    id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    fk_table_sync_id character varying(20),
    source_workspace_id character varying(20),
    source_base_id character varying(20),
    source_table_id character varying(20),
    source_view_id character varying(20),
    source_uuid character varying(255),
    source_password_hash text,
    dest_base_id character varying(20),
    dest_table_id character varying(20),
    role character varying(16),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_table_syncs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_table_syncs (
    id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20) NOT NULL,
    title character varying(255) NOT NULL,
    selected_fields text,
    on_delete_action character varying(32),
    sync_trigger character varying(32),
    status character varying(16) DEFAULT 'active'::character varying,
    last_error text,
    last_synced_at timestamp with time zone,
    sync_job_id character varying(255),
    source_input_mode character varying(16) DEFAULT 'browse'::character varying NOT NULL,
    created_by character varying(20),
    updated_by character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted boolean DEFAULT false
);


--
-- Name: nc_teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_teams (
    id character varying(20) NOT NULL,
    title character varying(255) NOT NULL,
    meta text,
    fk_org_id character varying(20),
    fk_workspace_id character varying(20),
    created_by character varying(20),
    deleted boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    scim_external_id character varying(255),
    scim_managed boolean DEFAULT false,
    scim_display_name character varying(255),
    scim_meta text,
    fk_parent_team_id character varying(20),
    depth integer DEFAULT 0,
    path text
);


--
-- Name: nc_timeline_view_columns_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_timeline_view_columns_v2 (
    id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    source_id character varying(20),
    fk_view_id character varying(20),
    fk_column_id character varying(20),
    show boolean,
    bold boolean,
    underline boolean,
    italic boolean,
    "order" real,
    group_by boolean,
    group_by_order real,
    group_by_sort character varying(4),
    aggregation character varying(20),
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_timeline_view_range_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_timeline_view_range_v2 (
    id character varying(20) NOT NULL,
    fk_view_id character varying(20),
    fk_from_column_id character varying(20),
    fk_to_column_id character varying(20),
    label character varying(40),
    base_id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_timeline_view_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_timeline_view_v2 (
    fk_view_id character varying(20) NOT NULL,
    base_id character varying(20) NOT NULL,
    source_id character varying(20),
    title character varying(255),
    meta text,
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_trash; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_trash (
    id character varying(20) NOT NULL,
    name character varying(255),
    parent_name character varying(255),
    resource_type character varying(255),
    resource_id character varying(255),
    parent_type character varying(255),
    parent_id character varying(20),
    deleted_by character varying(20),
    deleted_at timestamp with time zone,
    cleanup_due_at timestamp with time zone,
    related_items text,
    meta text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL
);


--
-- Name: nc_usage_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_usage_stats (
    fk_workspace_id character varying(20) NOT NULL,
    usage_type character varying(255) NOT NULL,
    period_start timestamp with time zone NOT NULL,
    count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_user_comment_notifications_preference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_user_comment_notifications_preference (
    id character varying(20) NOT NULL,
    row_id character varying(255),
    user_id character varying(20),
    fk_model_id character varying(20),
    source_id character varying(20),
    base_id character varying(20),
    preferences character varying(255),
    fk_workspace_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_user_refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_user_refresh_tokens (
    fk_user_id character varying(20),
    token character varying(255),
    meta text,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_users_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_users_v2 (
    id character varying(20) NOT NULL,
    email character varying(255),
    password character varying(255),
    salt character varying(255),
    invite_token character varying(255),
    invite_token_expires character varying(255),
    reset_password_expires timestamp with time zone,
    reset_password_token character varying(255),
    email_verification_token character varying(255),
    email_verified boolean,
    roles character varying(255) DEFAULT 'editor'::character varying,
    token_version character varying(255),
    blocked boolean DEFAULT false,
    blocked_reason character varying(255),
    deleted_at timestamp with time zone,
    is_deleted boolean DEFAULT false,
    meta text,
    display_name character varying(255),
    user_name character varying(255),
    bio character varying(255),
    location character varying(255),
    website character varying(255),
    avatar character varying(255),
    is_new_user boolean,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    canonical_email character varying(255),
    stripe_customer_id character varying(255),
    totp_secret text,
    totp_enabled boolean DEFAULT false,
    totp_backup_codes text,
    last_active_at timestamp with time zone
);


--
-- Name: nc_view_sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_view_sections (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    source_id character varying(20),
    fk_model_id character varying(20) NOT NULL,
    title character varying(255) NOT NULL,
    "order" real,
    meta text,
    created_by character varying(20),
    updated_by character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: nc_views_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_views_v2 (
    id character varying(20) NOT NULL,
    source_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_model_id character varying(20),
    title character varying(255),
    type integer,
    is_default boolean,
    show_system_fields boolean,
    lock_type character varying(255) DEFAULT 'collaborative'::character varying,
    uuid character varying(255),
    password character varying(255),
    show boolean,
    "order" real,
    meta text,
    description text,
    created_by character varying(20),
    owned_by character varying(20),
    fk_workspace_id character varying(20),
    attachment_mode_column_id character varying(20),
    expanded_record_mode character varying(255),
    fk_custom_url_id character varying(20),
    row_coloring_mode character varying(10),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fk_view_section_id character varying(20),
    deleted boolean,
    allow_sync boolean DEFAULT false
);


--
-- Name: nc_widgets_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_widgets_v2 (
    id character varying(20) NOT NULL,
    fk_workspace_id character varying(20),
    base_id character varying(20) NOT NULL,
    fk_dashboard_id character varying(20) NOT NULL,
    fk_model_id character varying(20),
    fk_view_id character varying(20),
    title character varying(255) NOT NULL,
    description text,
    type character varying(50) NOT NULL,
    config text,
    meta text,
    "order" integer,
    "position" text,
    error boolean,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted boolean
);


--
-- Name: nc_workflows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nc_workflows (
    id character varying(20) NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    fk_workspace_id character varying(20),
    base_id character varying(20),
    enabled boolean DEFAULT false,
    nodes text,
    edges text,
    meta text,
    "order" real,
    created_by character varying(20),
    updated_by character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    draft text
);


--
-- Name: notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification (
    id character varying(20) NOT NULL,
    type character varying(40),
    body text,
    is_read boolean DEFAULT false,
    is_deleted boolean DEFAULT false,
    fk_user_id character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: workspace; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace (
    id character varying(20) NOT NULL,
    title character varying(255),
    description text,
    meta text,
    fk_user_id character varying(20),
    deleted boolean DEFAULT false,
    deleted_at timestamp with time zone,
    "order" real,
    status smallint DEFAULT '0'::smallint,
    message character varying(256),
    plan character varying(20) DEFAULT 'free'::character varying,
    infra_meta text,
    fk_org_id character varying(20),
    stripe_customer_id character varying(255),
    grace_period_start_at timestamp with time zone,
    api_grace_period_start_at timestamp with time zone,
    automation_grace_period_start_at timestamp with time zone,
    loyal boolean DEFAULT false,
    loyalty_discount_used boolean DEFAULT false,
    db_job_id character varying(20),
    fk_db_instance_id character varying(20),
    segment_code integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: workspace_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_user (
    fk_workspace_id character varying(20) NOT NULL,
    fk_user_id character varying(20) NOT NULL,
    roles character varying(255),
    invite_token character varying(255),
    invite_accepted boolean DEFAULT false,
    deleted boolean DEFAULT false,
    deleted_at timestamp with time zone,
    "order" real,
    invited_by character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    scim_external_id character varying(255),
    scim_managed boolean DEFAULT false,
    scim_user_name character varying(255),
    scim_meta text
);


--
-- Name: xc_knex_migrationsv0; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.xc_knex_migrationsv0 (
    id integer NOT NULL,
    name character varying(255),
    batch integer,
    migration_time timestamp with time zone
);


--
-- Name: xc_knex_migrationsv0_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.xc_knex_migrationsv0_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: xc_knex_migrationsv0_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.xc_knex_migrationsv0_id_seq OWNED BY public.xc_knex_migrationsv0.id;


--
-- Name: xc_knex_migrationsv0_lock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.xc_knex_migrationsv0_lock (
    index integer NOT NULL,
    is_locked integer
);


--
-- Name: xc_knex_migrationsv0_lock_index_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.xc_knex_migrationsv0_lock_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: xc_knex_migrationsv0_lock_index_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.xc_knex_migrationsv0_lock_index_seq OWNED BY public.xc_knex_migrationsv0_lock.index;


--
-- Name: nc_api_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_api_tokens ALTER COLUMN id SET DEFAULT nextval('public.nc_api_tokens_id_seq'::regclass);


--
-- Name: nc_store id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_store ALTER COLUMN id SET DEFAULT nextval('public.nc_store_id_seq'::regclass);


--
-- Name: xc_knex_migrationsv0 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.xc_knex_migrationsv0 ALTER COLUMN id SET DEFAULT nextval('public.xc_knex_migrationsv0_id_seq'::regclass);


--
-- Name: xc_knex_migrationsv0_lock index; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.xc_knex_migrationsv0_lock ALTER COLUMN index SET DEFAULT nextval('public.xc_knex_migrationsv0_lock_index_seq'::regclass);


--
-- Name: nc_api_token_scopes idx_api_token_scopes_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_api_token_scopes
    ADD CONSTRAINT idx_api_token_scopes_unique UNIQUE (fk_api_token_id, resource_type, resource_id);


--
-- Name: nc_api_tokens idx_api_tokens_hash; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_api_tokens
    ADD CONSTRAINT idx_api_tokens_hash UNIQUE (token_hash);


--
-- Name: nc_addons nc_addons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_addons
    ADD CONSTRAINT nc_addons_pkey PRIMARY KEY (id);


--
-- Name: nc_api_token_scopes nc_api_token_scopes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_api_token_scopes
    ADD CONSTRAINT nc_api_token_scopes_pkey PRIMARY KEY (id);


--
-- Name: nc_api_tokens nc_api_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_api_tokens
    ADD CONSTRAINT nc_api_tokens_pkey PRIMARY KEY (id);


--
-- Name: nc_audit_v2 nc_audit_v2_pkx; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_audit_v2
    ADD CONSTRAINT nc_audit_v2_pkx PRIMARY KEY (id);


--
-- Name: nc_automation_executions nc_automation_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_automation_executions
    ADD CONSTRAINT nc_automation_executions_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_automation_subscribers nc_automation_subscribers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_automation_subscribers
    ADD CONSTRAINT nc_automation_subscribers_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_automation_subscribers nc_automation_subscribers_unique_idx; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_automation_subscribers
    ADD CONSTRAINT nc_automation_subscribers_unique_idx UNIQUE (base_id, fk_automation_id, fk_user_id);


--
-- Name: nc_automations nc_automations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_automations
    ADD CONSTRAINT nc_automations_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_base_users_v2 nc_base_users_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_base_users_v2
    ADD CONSTRAINT nc_base_users_v2_pkey PRIMARY KEY (base_id, fk_user_id);


--
-- Name: nc_base_variables nc_base_variables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_base_variables
    ADD CONSTRAINT nc_base_variables_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_base_variables nc_base_variables_ws_base_key_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_base_variables
    ADD CONSTRAINT nc_base_variables_ws_base_key_unique UNIQUE (fk_workspace_id, base_id, key);


--
-- Name: nc_sources_v2 nc_bases_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_sources_v2
    ADD CONSTRAINT nc_bases_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_bookmark_groups nc_bookmark_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_bookmark_groups
    ADD CONSTRAINT nc_bookmark_groups_pkey PRIMARY KEY (id);


--
-- Name: nc_bookmarks nc_bookmarks_fk_user_id_target_type_target_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_bookmarks
    ADD CONSTRAINT nc_bookmarks_fk_user_id_target_type_target_id_unique UNIQUE (fk_user_id, target_type, target_id);


--
-- Name: nc_bookmarks nc_bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_bookmarks
    ADD CONSTRAINT nc_bookmarks_pkey PRIMARY KEY (id);


--
-- Name: nc_calendar_view_columns_v2 nc_calendar_view_columns_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_calendar_view_columns_v2
    ADD CONSTRAINT nc_calendar_view_columns_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_calendar_view_range_v2 nc_calendar_view_range_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_calendar_view_range_v2
    ADD CONSTRAINT nc_calendar_view_range_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_calendar_view_v2 nc_calendar_view_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_calendar_view_v2
    ADD CONSTRAINT nc_calendar_view_v2_pkey PRIMARY KEY (base_id, fk_view_id);


--
-- Name: nc_chat_messages nc_chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_chat_messages
    ADD CONSTRAINT nc_chat_messages_pkey PRIMARY KEY (fk_workspace_id, id);


--
-- Name: nc_chat_sessions nc_chat_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_chat_sessions
    ADD CONSTRAINT nc_chat_sessions_pkey PRIMARY KEY (fk_workspace_id, id);


--
-- Name: nc_col_barcode_v2 nc_col_barcode_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_col_barcode_v2
    ADD CONSTRAINT nc_col_barcode_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_col_button_v2 nc_col_button_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_col_button_v2
    ADD CONSTRAINT nc_col_button_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_col_formula_v2 nc_col_formula_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_col_formula_v2
    ADD CONSTRAINT nc_col_formula_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_col_long_text_v2 nc_col_long_text_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_col_long_text_v2
    ADD CONSTRAINT nc_col_long_text_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_col_lookup_v2 nc_col_lookup_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_col_lookup_v2
    ADD CONSTRAINT nc_col_lookup_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_col_qrcode_v2 nc_col_qrcode_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_col_qrcode_v2
    ADD CONSTRAINT nc_col_qrcode_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_col_relations_v2 nc_col_relations_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_col_relations_v2
    ADD CONSTRAINT nc_col_relations_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_col_rollup_v2 nc_col_rollup_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_col_rollup_v2
    ADD CONSTRAINT nc_col_rollup_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_col_select_options_v2 nc_col_select_options_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_col_select_options_v2
    ADD CONSTRAINT nc_col_select_options_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_columns_v2 nc_columns_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_columns_v2
    ADD CONSTRAINT nc_columns_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_comment_reactions nc_comment_reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_comment_reactions
    ADD CONSTRAINT nc_comment_reactions_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_comments nc_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_comments
    ADD CONSTRAINT nc_comments_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_custom_urls_v2 nc_custom_urls_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_custom_urls_v2
    ADD CONSTRAINT nc_custom_urls_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_dashboards_v2 nc_dashboards_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_dashboards_v2
    ADD CONSTRAINT nc_dashboards_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_data_reflection nc_data_reflection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_data_reflection
    ADD CONSTRAINT nc_data_reflection_pkey PRIMARY KEY (id);


--
-- Name: nc_date_dependency_v2 nc_date_dep_gantt_view_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_date_dependency_v2
    ADD CONSTRAINT nc_date_dep_gantt_view_id_unique UNIQUE (base_id, fk_gantt_view_id);


--
-- Name: nc_date_dependency_v2 nc_date_dependency_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_date_dependency_v2
    ADD CONSTRAINT nc_date_dependency_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_db_servers nc_db_servers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_db_servers
    ADD CONSTRAINT nc_db_servers_pkey PRIMARY KEY (id);


--
-- Name: nc_dependency_tracker nc_dependency_tracker_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_dependency_tracker
    ADD CONSTRAINT nc_dependency_tracker_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_disabled_models_for_role_v2 nc_disabled_models_for_role_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_disabled_models_for_role_v2
    ADD CONSTRAINT nc_disabled_models_for_role_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_doc_content_v2 nc_doc_content_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_doc_content_v2
    ADD CONSTRAINT nc_doc_content_v2_pkey PRIMARY KEY (base_id, fk_doc_id);


--
-- Name: nc_doc_revisions_v2 nc_doc_revisions_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_doc_revisions_v2
    ADD CONSTRAINT nc_doc_revisions_v2_pkey PRIMARY KEY (id);


--
-- Name: nc_docs_v2 nc_docs_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_docs_v2
    ADD CONSTRAINT nc_docs_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_extensions nc_extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_extensions
    ADD CONSTRAINT nc_extensions_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_file_references nc_file_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_file_references
    ADD CONSTRAINT nc_file_references_pkey PRIMARY KEY (id);


--
-- Name: nc_filter_exp_v2 nc_filter_exp_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_filter_exp_v2
    ADD CONSTRAINT nc_filter_exp_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_follower nc_follower_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_follower
    ADD CONSTRAINT nc_follower_pkey PRIMARY KEY (fk_user_id, fk_follower_id);


--
-- Name: nc_form_view_columns_v2 nc_form_view_columns_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_form_view_columns_v2
    ADD CONSTRAINT nc_form_view_columns_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_form_view_v2 nc_form_view_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_form_view_v2
    ADD CONSTRAINT nc_form_view_v2_pkey PRIMARY KEY (base_id, fk_view_id);


--
-- Name: nc_gallery_view_columns_v2 nc_gallery_view_columns_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_gallery_view_columns_v2
    ADD CONSTRAINT nc_gallery_view_columns_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_gallery_view_v2 nc_gallery_view_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_gallery_view_v2
    ADD CONSTRAINT nc_gallery_view_v2_pkey PRIMARY KEY (base_id, fk_view_id);


--
-- Name: nc_gantt_view_columns_v2 nc_gantt_view_columns_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_gantt_view_columns_v2
    ADD CONSTRAINT nc_gantt_view_columns_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_gantt_view_v2 nc_gantt_view_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_gantt_view_v2
    ADD CONSTRAINT nc_gantt_view_v2_pkey PRIMARY KEY (base_id, fk_view_id);


--
-- Name: nc_gcp_marketplace_accounts nc_gcp_marketplace_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_gcp_marketplace_accounts
    ADD CONSTRAINT nc_gcp_marketplace_accounts_pkey PRIMARY KEY (id);


--
-- Name: nc_gcp_marketplace_accounts nc_gcp_marketplace_accounts_procurement_account_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_gcp_marketplace_accounts
    ADD CONSTRAINT nc_gcp_marketplace_accounts_procurement_account_id_unique UNIQUE (procurement_account_id);


--
-- Name: nc_gcp_marketplace_entitlements nc_gcp_marketplace_entitlements_entitlement_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_gcp_marketplace_entitlements
    ADD CONSTRAINT nc_gcp_marketplace_entitlements_entitlement_id_unique UNIQUE (entitlement_id);


--
-- Name: nc_gcp_marketplace_entitlements nc_gcp_marketplace_entitlements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_gcp_marketplace_entitlements
    ADD CONSTRAINT nc_gcp_marketplace_entitlements_pkey PRIMARY KEY (id);


--
-- Name: nc_grid_view_columns_v2 nc_grid_view_columns_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_grid_view_columns_v2
    ADD CONSTRAINT nc_grid_view_columns_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_grid_view_v2 nc_grid_view_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_grid_view_v2
    ADD CONSTRAINT nc_grid_view_v2_pkey PRIMARY KEY (base_id, fk_view_id);


--
-- Name: nc_hook_logs_v2 nc_hook_logs_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_hook_logs_v2
    ADD CONSTRAINT nc_hook_logs_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_hook_trigger_fields nc_hook_trigger_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_hook_trigger_fields
    ADD CONSTRAINT nc_hook_trigger_fields_pkey PRIMARY KEY (fk_workspace_id, base_id, fk_hook_id, fk_column_id);


--
-- Name: nc_hooks_v2 nc_hooks_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_hooks_v2
    ADD CONSTRAINT nc_hooks_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_installations nc_installations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_installations
    ADD CONSTRAINT nc_installations_pkey PRIMARY KEY (id);


--
-- Name: nc_integration_links_v2 nc_integration_links_v2_fk_integration_id_base_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_integration_links_v2
    ADD CONSTRAINT nc_integration_links_v2_fk_integration_id_base_id_unique UNIQUE (fk_integration_id, base_id);


--
-- Name: nc_integration_links_v2 nc_integration_links_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_integration_links_v2
    ADD CONSTRAINT nc_integration_links_v2_pkey PRIMARY KEY (id);


--
-- Name: nc_integrations_store_v2 nc_integrations_store_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_integrations_store_v2
    ADD CONSTRAINT nc_integrations_store_v2_pkey PRIMARY KEY (id);


--
-- Name: nc_integrations_v2 nc_integrations_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_integrations_v2
    ADD CONSTRAINT nc_integrations_v2_pkey PRIMARY KEY (id);


--
-- Name: nc_interface_pages nc_interface_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_interface_pages
    ADD CONSTRAINT nc_interface_pages_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_interfaces nc_interfaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_interfaces
    ADD CONSTRAINT nc_interfaces_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_jobs nc_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_jobs
    ADD CONSTRAINT nc_jobs_pkey PRIMARY KEY (id);


--
-- Name: nc_kanban_view_columns_v2 nc_kanban_view_columns_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_kanban_view_columns_v2
    ADD CONSTRAINT nc_kanban_view_columns_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_kanban_view_v2 nc_kanban_view_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_kanban_view_v2
    ADD CONSTRAINT nc_kanban_view_v2_pkey PRIMARY KEY (base_id, fk_view_id);


--
-- Name: nc_mail_sends nc_mail_sends_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_mail_sends
    ADD CONSTRAINT nc_mail_sends_pkey PRIMARY KEY (id);


--
-- Name: nc_managed_app_versions nc_managed_app_versions_number_unique_idx; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_managed_app_versions
    ADD CONSTRAINT nc_managed_app_versions_number_unique_idx UNIQUE (fk_managed_app_id, version_number);


--
-- Name: nc_managed_app_versions nc_managed_app_versions_unique_idx; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_managed_app_versions
    ADD CONSTRAINT nc_managed_app_versions_unique_idx UNIQUE (fk_managed_app_id, version);


--
-- Name: nc_map_view_columns_v2 nc_map_view_columns_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_map_view_columns_v2
    ADD CONSTRAINT nc_map_view_columns_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_map_view_v2 nc_map_view_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_map_view_v2
    ADD CONSTRAINT nc_map_view_v2_pkey PRIMARY KEY (base_id, fk_view_id);


--
-- Name: nc_mcp_tokens nc_mcp_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_mcp_tokens
    ADD CONSTRAINT nc_mcp_tokens_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_model_stats_v2 nc_model_stats_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_model_stats_v2
    ADD CONSTRAINT nc_model_stats_v2_pkey PRIMARY KEY (fk_workspace_id, base_id, fk_model_id);


--
-- Name: nc_models_v2 nc_models_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_models_v2
    ADD CONSTRAINT nc_models_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_oauth_authorization_codes nc_oauth_authorization_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_oauth_authorization_codes
    ADD CONSTRAINT nc_oauth_authorization_codes_pkey PRIMARY KEY (code);


--
-- Name: nc_oauth_clients nc_oauth_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_oauth_clients
    ADD CONSTRAINT nc_oauth_clients_pkey PRIMARY KEY (client_id);


--
-- Name: nc_oauth_tokens nc_oauth_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_oauth_tokens
    ADD CONSTRAINT nc_oauth_tokens_pkey PRIMARY KEY (id);


--
-- Name: nc_operation_logs nc_operation_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_operation_logs
    ADD CONSTRAINT nc_operation_logs_pkey PRIMARY KEY (id);


--
-- Name: nc_org_domain nc_org_domain_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_org_domain
    ADD CONSTRAINT nc_org_domain_pkey PRIMARY KEY (id);


--
-- Name: nc_org nc_org_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_org
    ADD CONSTRAINT nc_org_pkey PRIMARY KEY (id);


--
-- Name: nc_org_users nc_org_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_org_users
    ADD CONSTRAINT nc_org_users_pkey PRIMARY KEY (fk_org_id, fk_user_id);


--
-- Name: nc_list_view_columns_v2 nc_outline_view_columns_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_list_view_columns_v2
    ADD CONSTRAINT nc_outline_view_columns_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_list_view_levels_v2 nc_outline_view_levels_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_list_view_levels_v2
    ADD CONSTRAINT nc_outline_view_levels_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_list_view_v2 nc_outline_view_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_list_view_v2
    ADD CONSTRAINT nc_outline_view_v2_pkey PRIMARY KEY (base_id, fk_view_id);


--
-- Name: nc_permission_subjects nc_permission_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_permission_subjects
    ADD CONSTRAINT nc_permission_subjects_pkey PRIMARY KEY (base_id, fk_permission_id, subject_type, subject_id);


--
-- Name: nc_permissions nc_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_permissions
    ADD CONSTRAINT nc_permissions_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_plans nc_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_plans
    ADD CONSTRAINT nc_plans_pkey PRIMARY KEY (id);


--
-- Name: nc_plugins_v2 nc_plugins_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_plugins_v2
    ADD CONSTRAINT nc_plugins_v2_pkey PRIMARY KEY (id);


--
-- Name: nc_principal_assignments nc_principal_assignments_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_principal_assignments
    ADD CONSTRAINT nc_principal_assignments_pk PRIMARY KEY (resource_type, resource_id, principal_type, principal_ref_id);


--
-- Name: nc_bases_v2 nc_projects_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_bases_v2
    ADD CONSTRAINT nc_projects_v2_pkey PRIMARY KEY (id);


--
-- Name: nc_record_templates nc_record_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_record_templates
    ADD CONSTRAINT nc_record_templates_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_rls_policies nc_rls_policies_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_rls_policies
    ADD CONSTRAINT nc_rls_policies_pk PRIMARY KEY (base_id, id);


--
-- Name: nc_rls_policy_subjects nc_rls_policy_subjects_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_rls_policy_subjects
    ADD CONSTRAINT nc_rls_policy_subjects_pk PRIMARY KEY (base_id, fk_rls_policy_id, subject_type, subject_id);


--
-- Name: nc_row_color_conditions nc_row_color_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_row_color_conditions
    ADD CONSTRAINT nc_row_color_conditions_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_sandbox_changelog nc_sandbox_changelog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_sandbox_changelog
    ADD CONSTRAINT nc_sandbox_changelog_pkey PRIMARY KEY (id);


--
-- Name: nc_managed_app_deployment_logs nc_sandbox_deployment_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_managed_app_deployment_logs
    ADD CONSTRAINT nc_sandbox_deployment_logs_pkey PRIMARY KEY (id);


--
-- Name: nc_managed_app_versions nc_sandbox_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_managed_app_versions
    ADD CONSTRAINT nc_sandbox_versions_pkey PRIMARY KEY (id);


--
-- Name: nc_managed_apps nc_sandboxes_base_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_managed_apps
    ADD CONSTRAINT nc_sandboxes_base_id_unique UNIQUE (base_id);


--
-- Name: nc_managed_apps nc_sandboxes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_managed_apps
    ADD CONSTRAINT nc_sandboxes_pkey PRIMARY KEY (id);


--
-- Name: nc_sandboxes_v2 nc_sandboxes_production_base_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_sandboxes_v2
    ADD CONSTRAINT nc_sandboxes_production_base_unique UNIQUE (production_base_id);


--
-- Name: nc_sandboxes_v2 nc_sandboxes_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_sandboxes_v2
    ADD CONSTRAINT nc_sandboxes_v2_pkey PRIMARY KEY (id);


--
-- Name: nc_scim_config nc_scim_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_scim_config
    ADD CONSTRAINT nc_scim_config_pkey PRIMARY KEY (id);


--
-- Name: nc_sandbox_changelog nc_scl_sandbox_seq_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_sandbox_changelog
    ADD CONSTRAINT nc_scl_sandbox_seq_unique UNIQUE (fk_sandbox_id, seq);


--
-- Name: nc_scripts nc_scripts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_scripts
    ADD CONSTRAINT nc_scripts_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_snapshot_schedules nc_snapshot_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_snapshot_schedules
    ADD CONSTRAINT nc_snapshot_schedules_pkey PRIMARY KEY (id);


--
-- Name: nc_snapshots nc_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_snapshots
    ADD CONSTRAINT nc_snapshots_pkey PRIMARY KEY (id);


--
-- Name: nc_sort_v2 nc_sort_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_sort_v2
    ADD CONSTRAINT nc_sort_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_sql_executor_v2 nc_sql_executor_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_sql_executor_v2
    ADD CONSTRAINT nc_sql_executor_v2_pkey PRIMARY KEY (id);


--
-- Name: nc_sso_client_domain nc_sso_client_domain_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_sso_client_domain
    ADD CONSTRAINT nc_sso_client_domain_pkey PRIMARY KEY (fk_sso_client_id);


--
-- Name: nc_sso_client nc_sso_client_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_sso_client
    ADD CONSTRAINT nc_sso_client_pkey PRIMARY KEY (id);


--
-- Name: nc_store nc_store_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_store
    ADD CONSTRAINT nc_store_pkey PRIMARY KEY (id);


--
-- Name: nc_subscription_addons nc_subscription_addons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_subscription_addons
    ADD CONSTRAINT nc_subscription_addons_pkey PRIMARY KEY (id);


--
-- Name: nc_subscriptions nc_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_subscriptions
    ADD CONSTRAINT nc_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: nc_sync_configs nc_sync_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_sync_configs
    ADD CONSTRAINT nc_sync_configs_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_sync_logs_v2 nc_sync_logs_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_sync_logs_v2
    ADD CONSTRAINT nc_sync_logs_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_sync_mappings nc_sync_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_sync_mappings
    ADD CONSTRAINT nc_sync_mappings_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_sync_source_v2 nc_sync_source_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_sync_source_v2
    ADD CONSTRAINT nc_sync_source_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_table_sync_column_mappings nc_table_sync_column_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_table_sync_column_mappings
    ADD CONSTRAINT nc_table_sync_column_mappings_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_table_sync_mappings nc_table_sync_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_table_sync_mappings
    ADD CONSTRAINT nc_table_sync_mappings_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_table_syncs nc_table_syncs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_table_syncs
    ADD CONSTRAINT nc_table_syncs_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_teams nc_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_teams
    ADD CONSTRAINT nc_teams_pkey PRIMARY KEY (id);


--
-- Name: nc_teams nc_teams_scim_external_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_teams
    ADD CONSTRAINT nc_teams_scim_external_id_unique UNIQUE (scim_external_id);


--
-- Name: nc_timeline_view_columns_v2 nc_timeline_view_columns_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_timeline_view_columns_v2
    ADD CONSTRAINT nc_timeline_view_columns_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_timeline_view_range_v2 nc_timeline_view_range_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_timeline_view_range_v2
    ADD CONSTRAINT nc_timeline_view_range_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_timeline_view_v2 nc_timeline_view_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_timeline_view_v2
    ADD CONSTRAINT nc_timeline_view_v2_pkey PRIMARY KEY (base_id, fk_view_id);


--
-- Name: nc_trash nc_trash_base_id_resource_type_resource_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_trash
    ADD CONSTRAINT nc_trash_base_id_resource_type_resource_id_unique UNIQUE (base_id, resource_type, resource_id);


--
-- Name: nc_trash nc_trash_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_trash
    ADD CONSTRAINT nc_trash_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_usage_stats nc_usage_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_usage_stats
    ADD CONSTRAINT nc_usage_stats_pkey PRIMARY KEY (fk_workspace_id, usage_type, period_start);


--
-- Name: nc_user_comment_notifications_preference nc_user_comment_notifications_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_user_comment_notifications_preference
    ADD CONSTRAINT nc_user_comment_notifications_preference_pkey PRIMARY KEY (id);


--
-- Name: nc_users_v2 nc_users_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_users_v2
    ADD CONSTRAINT nc_users_v2_pkey PRIMARY KEY (id);


--
-- Name: nc_view_sections nc_view_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_view_sections
    ADD CONSTRAINT nc_view_sections_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_views_v2 nc_views_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_views_v2
    ADD CONSTRAINT nc_views_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_widgets_v2 nc_widgets_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_widgets_v2
    ADD CONSTRAINT nc_widgets_v2_pkey PRIMARY KEY (base_id, id);


--
-- Name: nc_workflows nc_workflows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nc_workflows
    ADD CONSTRAINT nc_workflows_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: workspace workspace_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace
    ADD CONSTRAINT workspace_pkey PRIMARY KEY (id);


--
-- Name: workspace_user workspace_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_user
    ADD CONSTRAINT workspace_user_pkey PRIMARY KEY (fk_workspace_id, fk_user_id);


--
-- Name: xc_knex_migrationsv0_lock xc_knex_migrationsv0_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.xc_knex_migrationsv0_lock
    ADD CONSTRAINT xc_knex_migrationsv0_lock_pkey PRIMARY KEY (index);


--
-- Name: xc_knex_migrationsv0 xc_knex_migrationsv0_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.xc_knex_migrationsv0
    ADD CONSTRAINT xc_knex_migrationsv0_pkey PRIMARY KEY (id);


--
-- Name: idx_api_token_scopes_resource; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_api_token_scopes_resource ON public.nc_api_token_scopes USING btree (resource_type, resource_id);


--
-- Name: idx_api_token_scopes_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_api_token_scopes_token ON public.nc_api_token_scopes USING btree (fk_api_token_id);


--
-- Name: idx_nc_form_view_columns_row_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nc_form_view_columns_row_id ON public.nc_form_view_columns_v2 USING btree (row_id);


--
-- Name: nc_addons_addon_key_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_addons_addon_key_idx ON public.nc_addons USING btree (addon_key);


--
-- Name: nc_addons_stripe_product_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_addons_stripe_product_idx ON public.nc_addons USING btree (stripe_product_id);


--
-- Name: nc_api_tokens_fk_sso_client_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_api_tokens_fk_sso_client_id_index ON public.nc_api_tokens USING btree (fk_sso_client_id);


--
-- Name: nc_api_tokens_fk_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_api_tokens_fk_user_id_index ON public.nc_api_tokens USING btree (fk_user_id);


--
-- Name: nc_audit_v2_fk_org_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_audit_v2_fk_org_id_idx ON public.nc_audit_v2 USING btree (fk_org_id);


--
-- Name: nc_audit_v2_fk_workspace_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_audit_v2_fk_workspace_idx ON public.nc_audit_v2 USING btree (fk_workspace_id);


--
-- Name: nc_audit_v2_old_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_audit_v2_old_id_index ON public.nc_audit_v2 USING btree (old_id);


--
-- Name: nc_audit_v2_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_audit_v2_tenant_idx ON public.nc_audit_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_automation_executions_error_notify_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_automation_executions_error_notify_idx ON public.nc_automation_executions USING btree (status, error_notified_at);


--
-- Name: nc_automation_executions_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_automation_executions_oldpk_idx ON public.nc_automation_executions USING btree (id);


--
-- Name: nc_automation_executions_resume_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_automation_executions_resume_idx ON public.nc_automation_executions USING btree (fk_workspace_id, base_id, resume_at);


--
-- Name: nc_automation_subscribers_automation_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_automation_subscribers_automation_idx ON public.nc_automation_subscribers USING btree (fk_automation_id);


--
-- Name: nc_automation_subscribers_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_automation_subscribers_user_idx ON public.nc_automation_subscribers USING btree (fk_user_id);


--
-- Name: nc_automations_context_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_automations_context_idx ON public.nc_automations USING btree (base_id, fk_workspace_id);


--
-- Name: nc_automations_enabled_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_automations_enabled_idx ON public.nc_automations USING btree (enabled);


--
-- Name: nc_automations_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_automations_oldpk_idx ON public.nc_automations USING btree (id);


--
-- Name: nc_automations_order_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_automations_order_idx ON public.nc_automations USING btree (base_id, "order");


--
-- Name: nc_automations_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_automations_type_idx ON public.nc_automations USING btree (type);


--
-- Name: nc_base_users_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_base_users_v2_base_id_fk_workspace_id_index ON public.nc_base_users_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_base_users_v2_invited_by_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_base_users_v2_invited_by_index ON public.nc_base_users_v2 USING btree (invited_by);


--
-- Name: nc_base_variables_base_ws_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_base_variables_base_ws_index ON public.nc_base_variables USING btree (base_id, fk_workspace_id);


--
-- Name: nc_bases_is_sandbox_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_bases_is_sandbox_idx ON public.nc_bases_v2 USING btree (is_sandbox);


--
-- Name: nc_bases_is_sandbox_production_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_bases_is_sandbox_production_idx ON public.nc_bases_v2 USING btree (is_sandbox_production);


--
-- Name: nc_bases_managed_app_auto_update_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_bases_managed_app_auto_update_idx ON public.nc_bases_v2 USING btree (managed_app_id, auto_update);


--
-- Name: nc_bases_managed_app_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_bases_managed_app_id_idx ON public.nc_bases_v2 USING btree (managed_app_id);


--
-- Name: nc_bases_managed_app_master_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_bases_managed_app_master_idx ON public.nc_bases_v2 USING btree (managed_app_master);


--
-- Name: nc_bases_managed_app_version_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_bases_managed_app_version_id_idx ON public.nc_bases_v2 USING btree (managed_app_version_id);


--
-- Name: nc_bases_v2_fk_custom_url_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_bases_v2_fk_custom_url_id_index ON public.nc_bases_v2 USING btree (fk_custom_url_id);


--
-- Name: nc_bases_v2_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_bases_v2_fk_workspace_id_index ON public.nc_bases_v2 USING btree (fk_workspace_id);


--
-- Name: nc_bookmark_groups_fk_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_bookmark_groups_fk_user_id_index ON public.nc_bookmark_groups USING btree (fk_user_id);


--
-- Name: nc_bookmarks_fk_group_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_bookmarks_fk_group_id_index ON public.nc_bookmarks USING btree (fk_group_id);


--
-- Name: nc_bookmarks_fk_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_bookmarks_fk_user_id_index ON public.nc_bookmarks USING btree (fk_user_id);


--
-- Name: nc_calendar_view_columns_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_calendar_view_columns_v2_base_id_fk_workspace_id_index ON public.nc_calendar_view_columns_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_calendar_view_columns_v2_fk_view_id_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_calendar_view_columns_v2_fk_view_id_fk_column_id_index ON public.nc_calendar_view_columns_v2 USING btree (fk_view_id, fk_column_id);


--
-- Name: nc_calendar_view_columns_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_calendar_view_columns_v2_oldpk_idx ON public.nc_calendar_view_columns_v2 USING btree (id);


--
-- Name: nc_calendar_view_range_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_calendar_view_range_v2_base_id_fk_workspace_id_index ON public.nc_calendar_view_range_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_calendar_view_range_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_calendar_view_range_v2_oldpk_idx ON public.nc_calendar_view_range_v2 USING btree (id);


--
-- Name: nc_calendar_view_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_calendar_view_v2_base_id_fk_workspace_id_index ON public.nc_calendar_view_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_calendar_view_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_calendar_view_v2_oldpk_idx ON public.nc_calendar_view_v2 USING btree (fk_view_id);


--
-- Name: nc_chat_messages_session_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_chat_messages_session_idx ON public.nc_chat_messages USING btree (fk_session_id);


--
-- Name: nc_chat_sessions_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_chat_sessions_user_idx ON public.nc_chat_sessions USING btree (fk_user_id);


--
-- Name: nc_col_barcode_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_barcode_v2_base_id_fk_workspace_id_index ON public.nc_col_barcode_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_col_barcode_v2_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_barcode_v2_fk_column_id_index ON public.nc_col_barcode_v2 USING btree (fk_column_id);


--
-- Name: nc_col_barcode_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_barcode_v2_oldpk_idx ON public.nc_col_barcode_v2 USING btree (id);


--
-- Name: nc_col_button_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_button_context ON public.nc_col_button_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_col_button_v2_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_button_v2_fk_column_id_index ON public.nc_col_button_v2 USING btree (fk_column_id);


--
-- Name: nc_col_button_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_button_v2_oldpk_idx ON public.nc_col_button_v2 USING btree (id);


--
-- Name: nc_col_formula_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_formula_v2_base_id_fk_workspace_id_index ON public.nc_col_formula_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_col_formula_v2_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_formula_v2_fk_column_id_index ON public.nc_col_formula_v2 USING btree (fk_column_id);


--
-- Name: nc_col_formula_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_formula_v2_oldpk_idx ON public.nc_col_formula_v2 USING btree (id);


--
-- Name: nc_col_long_text_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_long_text_context ON public.nc_col_long_text_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_col_long_text_v2_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_long_text_v2_fk_column_id_index ON public.nc_col_long_text_v2 USING btree (fk_column_id);


--
-- Name: nc_col_long_text_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_long_text_v2_oldpk_idx ON public.nc_col_long_text_v2 USING btree (id);


--
-- Name: nc_col_lookup_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_lookup_v2_base_id_fk_workspace_id_index ON public.nc_col_lookup_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_col_lookup_v2_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_lookup_v2_fk_column_id_index ON public.nc_col_lookup_v2 USING btree (fk_column_id);


--
-- Name: nc_col_lookup_v2_fk_lookup_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_lookup_v2_fk_lookup_column_id_index ON public.nc_col_lookup_v2 USING btree (fk_lookup_column_id);


--
-- Name: nc_col_lookup_v2_fk_relation_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_lookup_v2_fk_relation_column_id_index ON public.nc_col_lookup_v2 USING btree (fk_relation_column_id);


--
-- Name: nc_col_lookup_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_lookup_v2_oldpk_idx ON public.nc_col_lookup_v2 USING btree (id);


--
-- Name: nc_col_qrcode_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_qrcode_v2_base_id_fk_workspace_id_index ON public.nc_col_qrcode_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_col_qrcode_v2_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_qrcode_v2_fk_column_id_index ON public.nc_col_qrcode_v2 USING btree (fk_column_id);


--
-- Name: nc_col_qrcode_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_qrcode_v2_oldpk_idx ON public.nc_col_qrcode_v2 USING btree (id);


--
-- Name: nc_col_relations_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_relations_v2_base_id_fk_workspace_id_index ON public.nc_col_relations_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_col_relations_v2_fk_child_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_relations_v2_fk_child_column_id_index ON public.nc_col_relations_v2 USING btree (fk_child_column_id);


--
-- Name: nc_col_relations_v2_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_relations_v2_fk_column_id_index ON public.nc_col_relations_v2 USING btree (fk_column_id);


--
-- Name: nc_col_relations_v2_fk_display_value_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_relations_v2_fk_display_value_column_id_index ON public.nc_col_relations_v2 USING btree (fk_display_value_column_id);


--
-- Name: nc_col_relations_v2_fk_mm_child_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_relations_v2_fk_mm_child_column_id_index ON public.nc_col_relations_v2 USING btree (fk_mm_child_column_id);


--
-- Name: nc_col_relations_v2_fk_mm_model_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_relations_v2_fk_mm_model_id_index ON public.nc_col_relations_v2 USING btree (fk_mm_model_id);


--
-- Name: nc_col_relations_v2_fk_mm_parent_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_relations_v2_fk_mm_parent_column_id_index ON public.nc_col_relations_v2 USING btree (fk_mm_parent_column_id);


--
-- Name: nc_col_relations_v2_fk_parent_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_relations_v2_fk_parent_column_id_index ON public.nc_col_relations_v2 USING btree (fk_parent_column_id);


--
-- Name: nc_col_relations_v2_fk_related_model_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_relations_v2_fk_related_model_id_index ON public.nc_col_relations_v2 USING btree (fk_related_model_id);


--
-- Name: nc_col_relations_v2_fk_target_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_relations_v2_fk_target_view_id_index ON public.nc_col_relations_v2 USING btree (fk_target_view_id);


--
-- Name: nc_col_relations_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_relations_v2_oldpk_idx ON public.nc_col_relations_v2 USING btree (id);


--
-- Name: nc_col_rollup_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_rollup_v2_base_id_fk_workspace_id_index ON public.nc_col_rollup_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_col_rollup_v2_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_rollup_v2_fk_column_id_index ON public.nc_col_rollup_v2 USING btree (fk_column_id);


--
-- Name: nc_col_rollup_v2_fk_relation_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_rollup_v2_fk_relation_column_id_index ON public.nc_col_rollup_v2 USING btree (fk_relation_column_id);


--
-- Name: nc_col_rollup_v2_fk_rollup_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_rollup_v2_fk_rollup_column_id_index ON public.nc_col_rollup_v2 USING btree (fk_rollup_column_id);


--
-- Name: nc_col_rollup_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_rollup_v2_oldpk_idx ON public.nc_col_rollup_v2 USING btree (id);


--
-- Name: nc_col_select_options_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_select_options_v2_base_id_fk_workspace_id_index ON public.nc_col_select_options_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_col_select_options_v2_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_select_options_v2_fk_column_id_index ON public.nc_col_select_options_v2 USING btree (fk_column_id);


--
-- Name: nc_col_select_options_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_col_select_options_v2_oldpk_idx ON public.nc_col_select_options_v2 USING btree (id);


--
-- Name: nc_columns_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_columns_v2_base_id_fk_workspace_id_index ON public.nc_columns_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_columns_v2_fk_model_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_columns_v2_fk_model_id_index ON public.nc_columns_v2 USING btree (fk_model_id);


--
-- Name: nc_columns_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_columns_v2_oldpk_idx ON public.nc_columns_v2 USING btree (id);


--
-- Name: nc_comment_reactions_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_comment_reactions_base_id_fk_workspace_id_index ON public.nc_comment_reactions USING btree (base_id, fk_workspace_id);


--
-- Name: nc_comment_reactions_comment_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_comment_reactions_comment_id_index ON public.nc_comment_reactions USING btree (comment_id);


--
-- Name: nc_comment_reactions_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_comment_reactions_oldpk_idx ON public.nc_comment_reactions USING btree (id);


--
-- Name: nc_comment_reactions_row_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_comment_reactions_row_id_index ON public.nc_comment_reactions USING btree (row_id);


--
-- Name: nc_comments_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_comments_base_id_fk_workspace_id_index ON public.nc_comments USING btree (base_id, fk_workspace_id);


--
-- Name: nc_comments_doc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_comments_doc_idx ON public.nc_comments USING btree (fk_doc_id);


--
-- Name: nc_comments_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_comments_oldpk_idx ON public.nc_comments USING btree (id);


--
-- Name: nc_comments_row_id_fk_model_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_comments_row_id_fk_model_id_index ON public.nc_comments USING btree (row_id, fk_model_id);


--
-- Name: nc_custom_urls_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_custom_urls_context ON public.nc_custom_urls_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_custom_urls_v2_custom_path_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_custom_urls_v2_custom_path_index ON public.nc_custom_urls_v2 USING btree (custom_path);


--
-- Name: nc_custom_urls_v2_fk_dashboard_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_custom_urls_v2_fk_dashboard_id_index ON public.nc_custom_urls_v2 USING btree (fk_dashboard_id);


--
-- Name: nc_custom_urls_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_custom_urls_v2_oldpk_idx ON public.nc_custom_urls_v2 USING btree (id);


--
-- Name: nc_dashboards_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_dashboards_context ON public.nc_dashboards_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_dashboards_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_dashboards_v2_oldpk_idx ON public.nc_dashboards_v2 USING btree (id);


--
-- Name: nc_data_reflection_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_data_reflection_fk_workspace_id_index ON public.nc_data_reflection USING btree (fk_workspace_id);


--
-- Name: nc_date_dep_context_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_date_dep_context_idx ON public.nc_date_dependency_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_date_dep_model_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_date_dep_model_idx ON public.nc_date_dependency_v2 USING btree (fk_model_id);


--
-- Name: nc_date_dep_model_view_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_date_dep_model_view_idx ON public.nc_date_dependency_v2 USING btree (fk_model_id, fk_gantt_view_id);


--
-- Name: nc_dependency_tracker_context_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_dependency_tracker_context_idx ON public.nc_dependency_tracker USING btree (base_id, fk_workspace_id);


--
-- Name: nc_dependency_tracker_dependent_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_dependency_tracker_dependent_idx ON public.nc_dependency_tracker USING btree (dependent_type, dependent_id);


--
-- Name: nc_dependency_tracker_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_dependency_tracker_oldpk_idx ON public.nc_dependency_tracker USING btree (id);


--
-- Name: nc_dependency_tracker_queryable_field_0_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_dependency_tracker_queryable_field_0_idx ON public.nc_dependency_tracker USING btree (queryable_field_0);


--
-- Name: nc_dependency_tracker_queryable_field_1_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_dependency_tracker_queryable_field_1_idx ON public.nc_dependency_tracker USING btree (queryable_field_1);


--
-- Name: nc_dependency_tracker_queryable_field_2_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_dependency_tracker_queryable_field_2_idx ON public.nc_dependency_tracker USING btree (queryable_field_2);


--
-- Name: nc_dependency_tracker_source_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_dependency_tracker_source_idx ON public.nc_dependency_tracker USING btree (source_type, source_id);


--
-- Name: nc_disabled_models_for_role_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_disabled_models_for_role_v2_base_id_fk_workspace_id_index ON public.nc_disabled_models_for_role_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_disabled_models_for_role_v2_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_disabled_models_for_role_v2_fk_view_id_index ON public.nc_disabled_models_for_role_v2 USING btree (fk_view_id);


--
-- Name: nc_disabled_models_for_role_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_disabled_models_for_role_v2_oldpk_idx ON public.nc_disabled_models_for_role_v2 USING btree (id);


--
-- Name: nc_doc_content_v2_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_doc_content_v2_tenant_idx ON public.nc_doc_content_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_doc_revisions_v2_doc_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_doc_revisions_v2_doc_created_idx ON public.nc_doc_revisions_v2 USING btree (fk_doc_id, created_at);


--
-- Name: nc_doc_revisions_v2_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_doc_revisions_v2_tenant_idx ON public.nc_doc_revisions_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_docs_v2_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_docs_v2_tenant_idx ON public.nc_docs_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_docs_v2_tree_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_docs_v2_tree_idx ON public.nc_docs_v2 USING btree (base_id, parent_id, "order");


--
-- Name: nc_extensions_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_extensions_base_id_fk_workspace_id_index ON public.nc_extensions USING btree (base_id, fk_workspace_id);


--
-- Name: nc_extensions_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_extensions_oldpk_idx ON public.nc_extensions USING btree (id);


--
-- Name: nc_filter_exp_rls_policy_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_filter_exp_rls_policy_idx ON public.nc_filter_exp_v2 USING btree (fk_rls_policy_id);


--
-- Name: nc_filter_exp_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_filter_exp_v2_base_id_fk_workspace_id_index ON public.nc_filter_exp_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_filter_exp_v2_fk_button_col_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_filter_exp_v2_fk_button_col_id_index ON public.nc_filter_exp_v2 USING btree (fk_button_col_id);


--
-- Name: nc_filter_exp_v2_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_filter_exp_v2_fk_column_id_index ON public.nc_filter_exp_v2 USING btree (fk_column_id);


--
-- Name: nc_filter_exp_v2_fk_hook_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_filter_exp_v2_fk_hook_id_index ON public.nc_filter_exp_v2 USING btree (fk_hook_id);


--
-- Name: nc_filter_exp_v2_fk_level_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_filter_exp_v2_fk_level_id_index ON public.nc_filter_exp_v2 USING btree (fk_level_id);


--
-- Name: nc_filter_exp_v2_fk_link_col_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_filter_exp_v2_fk_link_col_id_index ON public.nc_filter_exp_v2 USING btree (fk_link_col_id);


--
-- Name: nc_filter_exp_v2_fk_parent_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_filter_exp_v2_fk_parent_column_id_index ON public.nc_filter_exp_v2 USING btree (fk_parent_column_id);


--
-- Name: nc_filter_exp_v2_fk_parent_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_filter_exp_v2_fk_parent_id_index ON public.nc_filter_exp_v2 USING btree (fk_parent_id);


--
-- Name: nc_filter_exp_v2_fk_value_col_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_filter_exp_v2_fk_value_col_id_index ON public.nc_filter_exp_v2 USING btree (fk_value_col_id);


--
-- Name: nc_filter_exp_v2_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_filter_exp_v2_fk_view_id_index ON public.nc_filter_exp_v2 USING btree (fk_view_id);


--
-- Name: nc_filter_exp_v2_fk_widget_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_filter_exp_v2_fk_widget_id_index ON public.nc_filter_exp_v2 USING btree (fk_widget_id);


--
-- Name: nc_filter_exp_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_filter_exp_v2_oldpk_idx ON public.nc_filter_exp_v2 USING btree (id);


--
-- Name: nc_follower_fk_follower_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_follower_fk_follower_id_index ON public.nc_follower USING btree (fk_follower_id);


--
-- Name: nc_follower_fk_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_follower_fk_user_id_index ON public.nc_follower USING btree (fk_user_id);


--
-- Name: nc_form_view_columns_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_form_view_columns_v2_base_id_fk_workspace_id_index ON public.nc_form_view_columns_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_form_view_columns_v2_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_form_view_columns_v2_fk_column_id_index ON public.nc_form_view_columns_v2 USING btree (fk_column_id);


--
-- Name: nc_form_view_columns_v2_fk_view_id_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_form_view_columns_v2_fk_view_id_fk_column_id_index ON public.nc_form_view_columns_v2 USING btree (fk_view_id, fk_column_id);


--
-- Name: nc_form_view_columns_v2_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_form_view_columns_v2_fk_view_id_index ON public.nc_form_view_columns_v2 USING btree (fk_view_id);


--
-- Name: nc_form_view_columns_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_form_view_columns_v2_oldpk_idx ON public.nc_form_view_columns_v2 USING btree (id);


--
-- Name: nc_form_view_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_form_view_v2_base_id_fk_workspace_id_index ON public.nc_form_view_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_form_view_v2_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_form_view_v2_fk_view_id_index ON public.nc_form_view_v2 USING btree (fk_view_id);


--
-- Name: nc_form_view_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_form_view_v2_oldpk_idx ON public.nc_form_view_v2 USING btree (fk_view_id);


--
-- Name: nc_fr_comment_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_fr_comment_idx ON public.nc_file_references USING btree (base_id, fk_comment_id);


--
-- Name: nc_fr_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_fr_context ON public.nc_file_references USING btree (base_id, fk_workspace_id);


--
-- Name: nc_fr_doc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_fr_doc_idx ON public.nc_file_references USING btree (base_id, fk_doc_id);


--
-- Name: nc_fr_revision_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_fr_revision_idx ON public.nc_file_references USING btree (base_id, fk_revision_id) WHERE (fk_revision_id IS NOT NULL);


--
-- Name: nc_fr_row_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_fr_row_idx ON public.nc_file_references USING btree (base_id, fk_column_id, fk_row_id);


--
-- Name: nc_fr_session_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_fr_session_idx ON public.nc_file_references USING btree (base_id, fk_session_id);


--
-- Name: nc_gallery_view_columns_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gallery_view_columns_v2_base_id_fk_workspace_id_index ON public.nc_gallery_view_columns_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_gallery_view_columns_v2_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gallery_view_columns_v2_fk_column_id_index ON public.nc_gallery_view_columns_v2 USING btree (fk_column_id);


--
-- Name: nc_gallery_view_columns_v2_fk_view_id_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gallery_view_columns_v2_fk_view_id_fk_column_id_index ON public.nc_gallery_view_columns_v2 USING btree (fk_view_id, fk_column_id);


--
-- Name: nc_gallery_view_columns_v2_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gallery_view_columns_v2_fk_view_id_index ON public.nc_gallery_view_columns_v2 USING btree (fk_view_id);


--
-- Name: nc_gallery_view_columns_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gallery_view_columns_v2_oldpk_idx ON public.nc_gallery_view_columns_v2 USING btree (id);


--
-- Name: nc_gallery_view_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gallery_view_v2_base_id_fk_workspace_id_index ON public.nc_gallery_view_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_gallery_view_v2_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gallery_view_v2_fk_view_id_index ON public.nc_gallery_view_v2 USING btree (fk_view_id);


--
-- Name: nc_gallery_view_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gallery_view_v2_oldpk_idx ON public.nc_gallery_view_v2 USING btree (fk_view_id);


--
-- Name: nc_gantt_view_columns_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gantt_view_columns_v2_base_id_fk_workspace_id_index ON public.nc_gantt_view_columns_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_gantt_view_columns_v2_fk_view_id_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gantt_view_columns_v2_fk_view_id_fk_column_id_index ON public.nc_gantt_view_columns_v2 USING btree (fk_view_id, fk_column_id);


--
-- Name: nc_gantt_view_columns_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gantt_view_columns_v2_oldpk_idx ON public.nc_gantt_view_columns_v2 USING btree (id);


--
-- Name: nc_gantt_view_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gantt_view_v2_base_id_fk_workspace_id_index ON public.nc_gantt_view_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_gantt_view_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gantt_view_v2_oldpk_idx ON public.nc_gantt_view_v2 USING btree (fk_view_id);


--
-- Name: nc_gcp_mp_accounts_link_token_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gcp_mp_accounts_link_token_idx ON public.nc_gcp_marketplace_accounts USING btree (link_token);


--
-- Name: nc_gcp_mp_accounts_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gcp_mp_accounts_user_idx ON public.nc_gcp_marketplace_accounts USING btree (fk_user_id);


--
-- Name: nc_gcp_mp_ent_account_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gcp_mp_ent_account_idx ON public.nc_gcp_marketplace_entitlements USING btree (fk_gcp_account_id);


--
-- Name: nc_gcp_mp_ent_install_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_gcp_mp_ent_install_idx ON public.nc_gcp_marketplace_entitlements USING btree (fk_installation_id);


--
-- Name: nc_grid_view_columns_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_grid_view_columns_v2_base_id_fk_workspace_id_index ON public.nc_grid_view_columns_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_grid_view_columns_v2_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_grid_view_columns_v2_fk_column_id_index ON public.nc_grid_view_columns_v2 USING btree (fk_column_id);


--
-- Name: nc_grid_view_columns_v2_fk_view_id_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_grid_view_columns_v2_fk_view_id_fk_column_id_index ON public.nc_grid_view_columns_v2 USING btree (fk_view_id, fk_column_id);


--
-- Name: nc_grid_view_columns_v2_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_grid_view_columns_v2_fk_view_id_index ON public.nc_grid_view_columns_v2 USING btree (fk_view_id);


--
-- Name: nc_grid_view_columns_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_grid_view_columns_v2_oldpk_idx ON public.nc_grid_view_columns_v2 USING btree (id);


--
-- Name: nc_grid_view_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_grid_view_v2_base_id_fk_workspace_id_index ON public.nc_grid_view_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_grid_view_v2_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_grid_view_v2_fk_view_id_index ON public.nc_grid_view_v2 USING btree (fk_view_id);


--
-- Name: nc_grid_view_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_grid_view_v2_oldpk_idx ON public.nc_grid_view_v2 USING btree (fk_view_id);


--
-- Name: nc_hook_logs_error_notify_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_hook_logs_error_notify_idx ON public.nc_hook_logs_v2 USING btree (error_notified_at);


--
-- Name: nc_hook_logs_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_hook_logs_v2_base_id_fk_workspace_id_index ON public.nc_hook_logs_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_hook_logs_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_hook_logs_v2_oldpk_idx ON public.nc_hook_logs_v2 USING btree (id);


--
-- Name: nc_hooks_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_hooks_v2_base_id_fk_workspace_id_index ON public.nc_hooks_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_hooks_v2_fk_model_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_hooks_v2_fk_model_id_index ON public.nc_hooks_v2 USING btree (fk_model_id);


--
-- Name: nc_hooks_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_hooks_v2_oldpk_idx ON public.nc_hooks_v2 USING btree (id);


--
-- Name: nc_il_integration_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_il_integration_idx ON public.nc_integration_links_v2 USING btree (fk_integration_id);


--
-- Name: nc_il_ws_base_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_il_ws_base_idx ON public.nc_integration_links_v2 USING btree (fk_workspace_id, base_id);


--
-- Name: nc_installations_fk_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_installations_fk_user_id_idx ON public.nc_installations USING btree (fk_user_id);


--
-- Name: nc_installations_license_key_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_installations_license_key_idx ON public.nc_installations USING btree (license_key);


--
-- Name: nc_integrations_store_v2_fk_integration_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_integrations_store_v2_fk_integration_id_index ON public.nc_integrations_store_v2 USING btree (fk_integration_id);


--
-- Name: nc_integrations_v2_created_by_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_integrations_v2_created_by_index ON public.nc_integrations_v2 USING btree (created_by);


--
-- Name: nc_integrations_v2_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_integrations_v2_fk_workspace_id_index ON public.nc_integrations_v2 USING btree (fk_workspace_id);


--
-- Name: nc_integrations_v2_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_integrations_v2_type_index ON public.nc_integrations_v2 USING btree (type);


--
-- Name: nc_interface_pages_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_interface_pages_context ON public.nc_interface_pages USING btree (base_id, fk_workspace_id);


--
-- Name: nc_interface_pages_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_interface_pages_id_idx ON public.nc_interface_pages USING btree (id);


--
-- Name: nc_interface_pages_interface_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_interface_pages_interface_idx ON public.nc_interface_pages USING btree (fk_interface_id);


--
-- Name: nc_interface_pages_uuid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_interface_pages_uuid_idx ON public.nc_interface_pages USING btree (uuid);


--
-- Name: nc_interfaces_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_interfaces_context ON public.nc_interfaces USING btree (base_id, fk_workspace_id);


--
-- Name: nc_interfaces_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_interfaces_id_idx ON public.nc_interfaces USING btree (id);


--
-- Name: nc_jobs_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_jobs_context ON public.nc_jobs USING btree (base_id, fk_workspace_id);


--
-- Name: nc_kanban_view_columns_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_kanban_view_columns_v2_base_id_fk_workspace_id_index ON public.nc_kanban_view_columns_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_kanban_view_columns_v2_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_kanban_view_columns_v2_fk_column_id_index ON public.nc_kanban_view_columns_v2 USING btree (fk_column_id);


--
-- Name: nc_kanban_view_columns_v2_fk_view_id_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_kanban_view_columns_v2_fk_view_id_fk_column_id_index ON public.nc_kanban_view_columns_v2 USING btree (fk_view_id, fk_column_id);


--
-- Name: nc_kanban_view_columns_v2_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_kanban_view_columns_v2_fk_view_id_index ON public.nc_kanban_view_columns_v2 USING btree (fk_view_id);


--
-- Name: nc_kanban_view_columns_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_kanban_view_columns_v2_oldpk_idx ON public.nc_kanban_view_columns_v2 USING btree (id);


--
-- Name: nc_kanban_view_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_kanban_view_v2_base_id_fk_workspace_id_index ON public.nc_kanban_view_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_kanban_view_v2_fk_grp_col_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_kanban_view_v2_fk_grp_col_id_index ON public.nc_kanban_view_v2 USING btree (fk_grp_col_id);


--
-- Name: nc_kanban_view_v2_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_kanban_view_v2_fk_view_id_index ON public.nc_kanban_view_v2 USING btree (fk_view_id);


--
-- Name: nc_kanban_view_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_kanban_view_v2_oldpk_idx ON public.nc_kanban_view_v2 USING btree (fk_view_id);


--
-- Name: nc_mail_sends_dedupe_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX nc_mail_sends_dedupe_uq ON public.nc_mail_sends USING btree (event, dedupe_key) WHERE (dedupe_key IS NOT NULL);


--
-- Name: nc_mail_sends_dispatch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_mail_sends_dispatch_idx ON public.nc_mail_sends USING btree (status, scheduled_for);


--
-- Name: nc_mail_sends_message_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_mail_sends_message_idx ON public.nc_mail_sends USING btree (ses_message_id);


--
-- Name: nc_mail_sends_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_mail_sends_user_idx ON public.nc_mail_sends USING btree (fk_user_id, created_at);


--
-- Name: nc_managed_app_deployment_logs_managed_app_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_managed_app_deployment_logs_managed_app_id_idx ON public.nc_managed_app_deployment_logs USING btree (fk_managed_app_id);


--
-- Name: nc_managed_app_versions_managed_app_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_managed_app_versions_managed_app_id_idx ON public.nc_managed_app_versions USING btree (fk_managed_app_id);


--
-- Name: nc_managed_app_versions_ordering_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_managed_app_versions_ordering_idx ON public.nc_managed_app_versions USING btree (fk_managed_app_id, version_number);


--
-- Name: nc_managed_app_versions_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_managed_app_versions_status_idx ON public.nc_managed_app_versions USING btree (fk_managed_app_id, status);


--
-- Name: nc_map_view_columns_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_map_view_columns_v2_base_id_fk_workspace_id_index ON public.nc_map_view_columns_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_map_view_columns_v2_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_map_view_columns_v2_fk_column_id_index ON public.nc_map_view_columns_v2 USING btree (fk_column_id);


--
-- Name: nc_map_view_columns_v2_fk_view_id_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_map_view_columns_v2_fk_view_id_fk_column_id_index ON public.nc_map_view_columns_v2 USING btree (fk_view_id, fk_column_id);


--
-- Name: nc_map_view_columns_v2_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_map_view_columns_v2_fk_view_id_index ON public.nc_map_view_columns_v2 USING btree (fk_view_id);


--
-- Name: nc_map_view_columns_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_map_view_columns_v2_oldpk_idx ON public.nc_map_view_columns_v2 USING btree (id);


--
-- Name: nc_map_view_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_map_view_v2_base_id_fk_workspace_id_index ON public.nc_map_view_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_map_view_v2_fk_geo_data_col_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_map_view_v2_fk_geo_data_col_id_index ON public.nc_map_view_v2 USING btree (fk_geo_data_col_id);


--
-- Name: nc_map_view_v2_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_map_view_v2_fk_view_id_index ON public.nc_map_view_v2 USING btree (fk_view_id);


--
-- Name: nc_map_view_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_map_view_v2_oldpk_idx ON public.nc_map_view_v2 USING btree (fk_view_id);


--
-- Name: nc_mc_tokens_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_mc_tokens_context ON public.nc_mcp_tokens USING btree (base_id, fk_workspace_id);


--
-- Name: nc_mcp_tokens_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_mcp_tokens_oldpk_idx ON public.nc_mcp_tokens USING btree (id);


--
-- Name: nc_model_stats_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_model_stats_v2_base_id_fk_workspace_id_index ON public.nc_model_stats_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_model_stats_v2_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_model_stats_v2_fk_workspace_id_index ON public.nc_model_stats_v2 USING btree (fk_workspace_id);


--
-- Name: nc_model_stats_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_model_stats_v2_oldpk_idx ON public.nc_model_stats_v2 USING btree (fk_workspace_id, fk_model_id);


--
-- Name: nc_models_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_models_v2_base_id_fk_workspace_id_index ON public.nc_models_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_models_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_models_v2_oldpk_idx ON public.nc_models_v2 USING btree (id);


--
-- Name: nc_models_v2_source_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_models_v2_source_id_index ON public.nc_models_v2 USING btree (source_id);


--
-- Name: nc_models_v2_tree_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_models_v2_tree_idx ON public.nc_models_v2 USING btree (base_id, type, parent_id, "order");


--
-- Name: nc_models_v2_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_models_v2_type_index ON public.nc_models_v2 USING btree (type);


--
-- Name: nc_models_v2_uuid_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_models_v2_uuid_index ON public.nc_models_v2 USING btree (uuid);


--
-- Name: nc_oauth_authorization_codes_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_authorization_codes_code_index ON public.nc_oauth_authorization_codes USING btree (code);


--
-- Name: nc_oauth_authorization_codes_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_authorization_codes_expires_at_index ON public.nc_oauth_authorization_codes USING btree (expires_at);


--
-- Name: nc_oauth_authorization_codes_fk_client_id_fk_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_authorization_codes_fk_client_id_fk_user_id_index ON public.nc_oauth_authorization_codes USING btree (fk_client_id, fk_user_id);


--
-- Name: nc_oauth_authorization_codes_fk_client_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_authorization_codes_fk_client_id_index ON public.nc_oauth_authorization_codes USING btree (fk_client_id);


--
-- Name: nc_oauth_authorization_codes_fk_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_authorization_codes_fk_user_id_index ON public.nc_oauth_authorization_codes USING btree (fk_user_id);


--
-- Name: nc_oauth_authorization_codes_is_used_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_authorization_codes_is_used_index ON public.nc_oauth_authorization_codes USING btree (is_used);


--
-- Name: nc_oauth_clients_fk_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_clients_fk_user_id_index ON public.nc_oauth_clients USING btree (fk_user_id);


--
-- Name: nc_oauth_tokens_access_token_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_tokens_access_token_expires_at_index ON public.nc_oauth_tokens USING btree (access_token_expires_at);


--
-- Name: nc_oauth_tokens_access_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_tokens_access_token_index ON public.nc_oauth_tokens USING btree (access_token);


--
-- Name: nc_oauth_tokens_fk_client_id_fk_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_tokens_fk_client_id_fk_user_id_index ON public.nc_oauth_tokens USING btree (fk_client_id, fk_user_id);


--
-- Name: nc_oauth_tokens_fk_client_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_tokens_fk_client_id_index ON public.nc_oauth_tokens USING btree (fk_client_id);


--
-- Name: nc_oauth_tokens_fk_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_tokens_fk_user_id_index ON public.nc_oauth_tokens USING btree (fk_user_id);


--
-- Name: nc_oauth_tokens_is_revoked_access_token_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_tokens_is_revoked_access_token_expires_at_index ON public.nc_oauth_tokens USING btree (is_revoked, access_token_expires_at);


--
-- Name: nc_oauth_tokens_is_revoked_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_tokens_is_revoked_index ON public.nc_oauth_tokens USING btree (is_revoked);


--
-- Name: nc_oauth_tokens_last_used_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_tokens_last_used_at_index ON public.nc_oauth_tokens USING btree (last_used_at);


--
-- Name: nc_oauth_tokens_refresh_token_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_tokens_refresh_token_expires_at_index ON public.nc_oauth_tokens USING btree (refresh_token_expires_at);


--
-- Name: nc_oauth_tokens_refresh_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_oauth_tokens_refresh_token_index ON public.nc_oauth_tokens USING btree (refresh_token);


--
-- Name: nc_op_logs_cleanup_due_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_op_logs_cleanup_due_at_idx ON public.nc_operation_logs USING btree (cleanup_due_at);


--
-- Name: nc_op_logs_user_tab_scope_status_seq_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_op_logs_user_tab_scope_status_seq_idx ON public.nc_operation_logs USING btree (fk_user_id, tab_id, scope_type, scope_id, status, seq);


--
-- Name: nc_org_domain_domain_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_org_domain_domain_index ON public.nc_org_domain USING btree (domain);


--
-- Name: nc_org_domain_fk_org_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_org_domain_fk_org_id_index ON public.nc_org_domain USING btree (fk_org_id);


--
-- Name: nc_org_domain_fk_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_org_domain_fk_user_id_index ON public.nc_org_domain USING btree (fk_user_id);


--
-- Name: nc_org_fk_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_org_fk_user_id_index ON public.nc_org USING btree (fk_user_id);


--
-- Name: nc_org_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_org_slug_index ON public.nc_org USING btree (slug);


--
-- Name: nc_org_users_fk_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_org_users_fk_user_id_index ON public.nc_org_users USING btree (fk_user_id);


--
-- Name: nc_org_users_scim_external_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_org_users_scim_external_id_idx ON public.nc_org_users USING btree (scim_external_id);


--
-- Name: nc_org_users_scim_managed_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_org_users_scim_managed_idx ON public.nc_org_users USING btree (scim_managed);


--
-- Name: nc_outline_view_columns_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_outline_view_columns_v2_base_id_fk_workspace_id_index ON public.nc_list_view_columns_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_outline_view_columns_v2_fk_view_id_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_outline_view_columns_v2_fk_view_id_fk_column_id_index ON public.nc_list_view_columns_v2 USING btree (fk_view_id, fk_column_id);


--
-- Name: nc_outline_view_columns_v2_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_outline_view_columns_v2_fk_view_id_index ON public.nc_list_view_columns_v2 USING btree (fk_view_id);


--
-- Name: nc_outline_view_levels_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_outline_view_levels_v2_base_id_fk_workspace_id_index ON public.nc_list_view_levels_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_outline_view_levels_v2_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_outline_view_levels_v2_fk_view_id_index ON public.nc_list_view_levels_v2 USING btree (fk_view_id);


--
-- Name: nc_outline_view_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_outline_view_v2_base_id_fk_workspace_id_index ON public.nc_list_view_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_outline_view_v2_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_outline_view_v2_fk_view_id_index ON public.nc_list_view_v2 USING btree (fk_view_id);


--
-- Name: nc_permission_subjects_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_permission_subjects_context ON public.nc_permission_subjects USING btree (fk_workspace_id, base_id);


--
-- Name: nc_permission_subjects_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_permission_subjects_oldpk_idx ON public.nc_permission_subjects USING btree (fk_permission_id, subject_type, subject_id);


--
-- Name: nc_permissions_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_permissions_context ON public.nc_permissions USING btree (base_id, fk_workspace_id);


--
-- Name: nc_permissions_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_permissions_entity ON public.nc_permissions USING btree (entity, entity_id, permission);


--
-- Name: nc_permissions_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_permissions_oldpk_idx ON public.nc_permissions USING btree (id);


--
-- Name: nc_plans_license_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_plans_license_type_idx ON public.nc_plans USING btree (license_type);


--
-- Name: nc_plans_stripe_product_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_plans_stripe_product_idx ON public.nc_plans USING btree (stripe_product_id);


--
-- Name: nc_principal_assignments_principal_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_principal_assignments_principal_idx ON public.nc_principal_assignments USING btree (principal_type, principal_ref_id);


--
-- Name: nc_principal_assignments_principal_resource_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_principal_assignments_principal_resource_idx ON public.nc_principal_assignments USING btree (principal_type, principal_ref_id, resource_type);


--
-- Name: nc_principal_assignments_resource_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_principal_assignments_resource_idx ON public.nc_principal_assignments USING btree (resource_type, resource_id);


--
-- Name: nc_principal_assignments_resource_principal_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_principal_assignments_resource_principal_type_idx ON public.nc_principal_assignments USING btree (resource_type, resource_id, principal_type);


--
-- Name: nc_project_users_v2_fk_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_project_users_v2_fk_user_id_index ON public.nc_base_users_v2 USING btree (fk_user_id);


--
-- Name: nc_record_audit_v2_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_record_audit_v2_tenant_idx ON public.nc_audit_v2 USING btree (base_id, fk_model_id, row_id, fk_workspace_id);


--
-- Name: nc_record_templates_base_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_record_templates_base_id_index ON public.nc_record_templates USING btree (base_id);


--
-- Name: nc_record_templates_fk_model_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_record_templates_fk_model_id_index ON public.nc_record_templates USING btree (fk_model_id);


--
-- Name: nc_record_templates_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_record_templates_fk_workspace_id_index ON public.nc_record_templates USING btree (fk_workspace_id);


--
-- Name: nc_rls_policies_model_default_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_rls_policies_model_default_idx ON public.nc_rls_policies USING btree (fk_model_id, is_default);


--
-- Name: nc_rls_policies_model_enabled_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_rls_policies_model_enabled_idx ON public.nc_rls_policies USING btree (fk_model_id, enabled);


--
-- Name: nc_rls_policy_subjects_context_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_rls_policy_subjects_context_idx ON public.nc_rls_policy_subjects USING btree (fk_workspace_id, base_id);


--
-- Name: nc_rls_policy_subjects_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_rls_policy_subjects_oldpk_idx ON public.nc_rls_policy_subjects USING btree (fk_rls_policy_id, subject_type, subject_id);


--
-- Name: nc_row_color_conditions_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_row_color_conditions_fk_view_id_index ON public.nc_row_color_conditions USING btree (fk_view_id);


--
-- Name: nc_row_color_conditions_fk_workspace_id_base_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_row_color_conditions_fk_workspace_id_base_id_index ON public.nc_row_color_conditions USING btree (fk_workspace_id, base_id);


--
-- Name: nc_row_color_conditions_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_row_color_conditions_oldpk_idx ON public.nc_row_color_conditions USING btree (id);


--
-- Name: nc_sandbox_deployment_logs_base_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandbox_deployment_logs_base_created_idx ON public.nc_managed_app_deployment_logs USING btree (base_id, created_at);


--
-- Name: nc_sandbox_deployment_logs_base_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandbox_deployment_logs_base_id_idx ON public.nc_managed_app_deployment_logs USING btree (base_id);


--
-- Name: nc_sandbox_deployment_logs_from_version_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandbox_deployment_logs_from_version_idx ON public.nc_managed_app_deployment_logs USING btree (from_version_id);


--
-- Name: nc_sandbox_deployment_logs_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandbox_deployment_logs_status_idx ON public.nc_managed_app_deployment_logs USING btree (status);


--
-- Name: nc_sandbox_deployment_logs_to_version_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandbox_deployment_logs_to_version_idx ON public.nc_managed_app_deployment_logs USING btree (to_version_id);


--
-- Name: nc_sandbox_deployment_logs_workspace_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandbox_deployment_logs_workspace_id_idx ON public.nc_managed_app_deployment_logs USING btree (fk_workspace_id);


--
-- Name: nc_sandbox_versions_workspace_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandbox_versions_workspace_id_idx ON public.nc_managed_app_versions USING btree (fk_workspace_id);


--
-- Name: nc_sandboxes_base_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandboxes_base_id_idx ON public.nc_managed_apps USING btree (base_id);


--
-- Name: nc_sandboxes_category_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandboxes_category_idx ON public.nc_managed_apps USING btree (category);


--
-- Name: nc_sandboxes_created_by_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandboxes_created_by_idx ON public.nc_managed_apps USING btree (created_by);


--
-- Name: nc_sandboxes_deleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandboxes_deleted_idx ON public.nc_managed_apps USING btree (deleted);


--
-- Name: nc_sandboxes_v2_created_by_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandboxes_v2_created_by_idx ON public.nc_sandboxes_v2 USING btree (created_by);


--
-- Name: nc_sandboxes_v2_production_base_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandboxes_v2_production_base_id_idx ON public.nc_sandboxes_v2 USING btree (production_base_id);


--
-- Name: nc_sandboxes_v2_sandbox_base_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandboxes_v2_sandbox_base_id_idx ON public.nc_sandboxes_v2 USING btree (sandbox_base_id);


--
-- Name: nc_sandboxes_v2_workspace_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandboxes_v2_workspace_id_idx ON public.nc_sandboxes_v2 USING btree (fk_workspace_id);


--
-- Name: nc_sandboxes_visibility_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandboxes_visibility_idx ON public.nc_managed_apps USING btree (visibility);


--
-- Name: nc_sandboxes_workspace_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sandboxes_workspace_id_idx ON public.nc_managed_apps USING btree (fk_workspace_id);


--
-- Name: nc_scim_config_org_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_scim_config_org_idx ON public.nc_scim_config USING btree (fk_org_id);


--
-- Name: nc_scl_base_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_scl_base_id_index ON public.nc_sandbox_changelog USING btree (base_id);


--
-- Name: nc_scl_entity_type_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_scl_entity_type_id_index ON public.nc_sandbox_changelog USING btree (entity_type, entity_id);


--
-- Name: nc_scl_sandbox_seq_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_scl_sandbox_seq_index ON public.nc_sandbox_changelog USING btree (fk_sandbox_id, seq);


--
-- Name: nc_scripts_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_scripts_context ON public.nc_scripts USING btree (base_id, fk_workspace_id);


--
-- Name: nc_scripts_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_scripts_oldpk_idx ON public.nc_scripts USING btree (id);


--
-- Name: nc_snapshot_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_snapshot_context ON public.nc_snapshots USING btree (base_id, fk_workspace_id);


--
-- Name: nc_snapshot_schedules_base_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_snapshot_schedules_base_id_index ON public.nc_snapshot_schedules USING btree (base_id);


--
-- Name: nc_snapshot_schedules_next_run_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_snapshot_schedules_next_run_at_index ON public.nc_snapshot_schedules USING btree (next_run_at);


--
-- Name: nc_sort_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sort_v2_base_id_fk_workspace_id_index ON public.nc_sort_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_sort_v2_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sort_v2_fk_column_id_index ON public.nc_sort_v2 USING btree (fk_column_id);


--
-- Name: nc_sort_v2_fk_level_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sort_v2_fk_level_id_index ON public.nc_sort_v2 USING btree (fk_level_id);


--
-- Name: nc_sort_v2_fk_lookup_col_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sort_v2_fk_lookup_col_id_index ON public.nc_sort_v2 USING btree (fk_lookup_col_id);


--
-- Name: nc_sort_v2_fk_view_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sort_v2_fk_view_id_index ON public.nc_sort_v2 USING btree (fk_view_id);


--
-- Name: nc_sort_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sort_v2_oldpk_idx ON public.nc_sort_v2 USING btree (id);


--
-- Name: nc_source_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_source_v2_base_id_fk_workspace_id_index ON public.nc_sources_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_source_v2_fk_integration_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_source_v2_fk_integration_id_index ON public.nc_sources_v2 USING btree (fk_integration_id);


--
-- Name: nc_source_v2_fk_sql_executor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_source_v2_fk_sql_executor_id_index ON public.nc_sources_v2 USING btree (fk_sql_executor_id);


--
-- Name: nc_sources_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sources_v2_oldpk_idx ON public.nc_sources_v2 USING btree (id);


--
-- Name: nc_sso_client_domain_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sso_client_domain_name_index ON public.nc_sso_client USING btree (domain_name);


--
-- Name: nc_sso_client_fk_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sso_client_fk_user_id_index ON public.nc_sso_client USING btree (fk_user_id);


--
-- Name: nc_sso_client_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sso_client_fk_workspace_id_index ON public.nc_sso_client USING btree (fk_org_id);


--
-- Name: nc_store_key_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_store_key_index ON public.nc_store USING btree (key);


--
-- Name: nc_subscription_addons_key_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_subscription_addons_key_idx ON public.nc_subscription_addons USING btree (addon_key);


--
-- Name: nc_subscription_addons_sub_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_subscription_addons_sub_idx ON public.nc_subscription_addons USING btree (fk_subscription_id);


--
-- Name: nc_subscriptions_org_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_subscriptions_org_idx ON public.nc_subscriptions USING btree (fk_org_id);


--
-- Name: nc_subscriptions_stripe_subscription_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_subscriptions_stripe_subscription_idx ON public.nc_subscriptions USING btree (stripe_subscription_id);


--
-- Name: nc_subscriptions_ws_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_subscriptions_ws_idx ON public.nc_subscriptions USING btree (fk_workspace_id);


--
-- Name: nc_sync_configs_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sync_configs_context ON public.nc_sync_configs USING btree (base_id, fk_workspace_id);


--
-- Name: nc_sync_configs_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sync_configs_oldpk_idx ON public.nc_sync_configs USING btree (id);


--
-- Name: nc_sync_configs_parent_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sync_configs_parent_idx ON public.nc_sync_configs USING btree (fk_parent_sync_config_id);


--
-- Name: nc_sync_logs_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sync_logs_v2_base_id_fk_workspace_id_index ON public.nc_sync_logs_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_sync_logs_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sync_logs_v2_oldpk_idx ON public.nc_sync_logs_v2 USING btree (id);


--
-- Name: nc_sync_mappings_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sync_mappings_context ON public.nc_sync_mappings USING btree (base_id, fk_workspace_id);


--
-- Name: nc_sync_mappings_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sync_mappings_oldpk_idx ON public.nc_sync_mappings USING btree (id);


--
-- Name: nc_sync_mappings_sync_config_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sync_mappings_sync_config_idx ON public.nc_sync_mappings USING btree (fk_sync_config_id);


--
-- Name: nc_sync_source_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sync_source_v2_base_id_fk_workspace_id_index ON public.nc_sync_source_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_sync_source_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sync_source_v2_oldpk_idx ON public.nc_sync_source_v2 USING btree (id);


--
-- Name: nc_sync_source_v2_source_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_sync_source_v2_source_id_index ON public.nc_sync_source_v2 USING btree (source_id);


--
-- Name: nc_teams_created_by_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_teams_created_by_idx ON public.nc_teams USING btree (created_by);


--
-- Name: nc_teams_org_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_teams_org_idx ON public.nc_teams USING btree (fk_org_id);


--
-- Name: nc_teams_parent_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_teams_parent_idx ON public.nc_teams USING btree (fk_parent_team_id);


--
-- Name: nc_teams_scim_external_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_teams_scim_external_id_idx ON public.nc_teams USING btree (scim_external_id);


--
-- Name: nc_teams_scim_managed_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_teams_scim_managed_idx ON public.nc_teams USING btree (scim_managed);


--
-- Name: nc_teams_workspace_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_teams_workspace_idx ON public.nc_teams USING btree (fk_workspace_id);


--
-- Name: nc_timeline_view_columns_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_timeline_view_columns_v2_base_id_fk_workspace_id_index ON public.nc_timeline_view_columns_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_timeline_view_columns_v2_fk_view_id_fk_column_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_timeline_view_columns_v2_fk_view_id_fk_column_id_index ON public.nc_timeline_view_columns_v2 USING btree (fk_view_id, fk_column_id);


--
-- Name: nc_timeline_view_columns_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_timeline_view_columns_v2_oldpk_idx ON public.nc_timeline_view_columns_v2 USING btree (id);


--
-- Name: nc_timeline_view_range_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_timeline_view_range_v2_base_id_fk_workspace_id_index ON public.nc_timeline_view_range_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_timeline_view_range_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_timeline_view_range_v2_oldpk_idx ON public.nc_timeline_view_range_v2 USING btree (id);


--
-- Name: nc_timeline_view_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_timeline_view_v2_base_id_fk_workspace_id_index ON public.nc_timeline_view_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_timeline_view_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_timeline_view_v2_oldpk_idx ON public.nc_timeline_view_v2 USING btree (fk_view_id);


--
-- Name: nc_trash_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_trash_base_id_fk_workspace_id_index ON public.nc_trash USING btree (base_id, fk_workspace_id);


--
-- Name: nc_trash_cleanup_due_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_trash_cleanup_due_at_index ON public.nc_trash USING btree (cleanup_due_at);


--
-- Name: nc_ts_ws_base_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_ts_ws_base_idx ON public.nc_table_syncs USING btree (fk_workspace_id, base_id);


--
-- Name: nc_tscm_dest_col_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_tscm_dest_col_idx ON public.nc_table_sync_column_mappings USING btree (dest_column_id);


--
-- Name: nc_tscm_mapping_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_tscm_mapping_idx ON public.nc_table_sync_column_mappings USING btree (fk_table_sync_mapping_id);


--
-- Name: nc_tscm_source_col_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_tscm_source_col_idx ON public.nc_table_sync_column_mappings USING btree (source_workspace_id, source_base_id, source_column_id);


--
-- Name: nc_tscm_sync_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_tscm_sync_idx ON public.nc_table_sync_column_mappings USING btree (fk_table_sync_id);


--
-- Name: nc_tsm_source_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_tsm_source_idx ON public.nc_table_sync_mappings USING btree (source_workspace_id, source_base_id, source_table_id);


--
-- Name: nc_tsm_source_uuid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_tsm_source_uuid_idx ON public.nc_table_sync_mappings USING btree (source_uuid);


--
-- Name: nc_tsm_table_sync_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_tsm_table_sync_idx ON public.nc_table_sync_mappings USING btree (fk_table_sync_id);


--
-- Name: nc_usage_stats_ws_period_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_usage_stats_ws_period_idx ON public.nc_usage_stats USING btree (fk_workspace_id, period_start);


--
-- Name: nc_user_comment_notifications_preference_base_id_fk_workspace_i; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_user_comment_notifications_preference_base_id_fk_workspace_i ON public.nc_user_comment_notifications_preference USING btree (base_id, fk_workspace_id);


--
-- Name: nc_user_refresh_tokens_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_user_refresh_tokens_expires_at_index ON public.nc_user_refresh_tokens USING btree (expires_at);


--
-- Name: nc_user_refresh_tokens_fk_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_user_refresh_tokens_fk_user_id_index ON public.nc_user_refresh_tokens USING btree (fk_user_id);


--
-- Name: nc_user_refresh_tokens_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_user_refresh_tokens_token_index ON public.nc_user_refresh_tokens USING btree (token);


--
-- Name: nc_users_v2_canonical_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_users_v2_canonical_email_index ON public.nc_users_v2 USING btree (canonical_email);


--
-- Name: nc_users_v2_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_users_v2_email_index ON public.nc_users_v2 USING btree (email);


--
-- Name: nc_users_v2_last_active_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_users_v2_last_active_at_idx ON public.nc_users_v2 USING btree (last_active_at);


--
-- Name: nc_view_sections_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_view_sections_context ON public.nc_view_sections USING btree (base_id, fk_workspace_id);


--
-- Name: nc_view_sections_model_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_view_sections_model_idx ON public.nc_view_sections USING btree (fk_model_id);


--
-- Name: nc_view_sections_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_view_sections_oldpk_idx ON public.nc_view_sections USING btree (id);


--
-- Name: nc_views_v2_base_id_fk_workspace_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_views_v2_base_id_fk_workspace_id_index ON public.nc_views_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_views_v2_created_by_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_views_v2_created_by_index ON public.nc_views_v2 USING btree (created_by);


--
-- Name: nc_views_v2_fk_custom_url_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_views_v2_fk_custom_url_id_index ON public.nc_views_v2 USING btree (fk_custom_url_id);


--
-- Name: nc_views_v2_fk_model_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_views_v2_fk_model_id_index ON public.nc_views_v2 USING btree (fk_model_id);


--
-- Name: nc_views_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_views_v2_oldpk_idx ON public.nc_views_v2 USING btree (id);


--
-- Name: nc_views_v2_owned_by_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_views_v2_owned_by_index ON public.nc_views_v2 USING btree (owned_by);


--
-- Name: nc_widgets_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_widgets_context ON public.nc_widgets_v2 USING btree (base_id, fk_workspace_id);


--
-- Name: nc_widgets_dashboard_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_widgets_dashboard_idx ON public.nc_widgets_v2 USING btree (fk_dashboard_id);


--
-- Name: nc_widgets_v2_oldpk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_widgets_v2_oldpk_idx ON public.nc_widgets_v2 USING btree (id);


--
-- Name: nc_workflow_executions_context_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_workflow_executions_context_idx ON public.nc_automation_executions USING btree (base_id, fk_workspace_id);


--
-- Name: nc_workflow_executions_workflow_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_workflow_executions_workflow_idx ON public.nc_automation_executions USING btree (fk_workflow_id);


--
-- Name: nc_workflows_context_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_workflows_context_idx ON public.nc_workflows USING btree (base_id, fk_workspace_id);


--
-- Name: nc_workspace_user_scim_external_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_workspace_user_scim_external_id_idx ON public.workspace_user USING btree (scim_external_id);


--
-- Name: nc_workspace_user_scim_managed_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nc_workspace_user_scim_managed_idx ON public.workspace_user USING btree (scim_managed);


--
-- Name: notification_created_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notification_created_at_index ON public.notification USING btree (created_at);


--
-- Name: notification_fk_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notification_fk_user_id_index ON public.notification USING btree (fk_user_id);


--
-- Name: org_domain_fk_workspace_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX org_domain_fk_workspace_id_idx ON public.nc_org_domain USING btree (fk_workspace_id);


--
-- Name: share_uuid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX share_uuid_idx ON public.nc_dashboards_v2 USING btree (uuid);


--
-- Name: sso_client_fk_workspace_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sso_client_fk_workspace_id_idx ON public.nc_sso_client USING btree (fk_workspace_id);


--
-- Name: sync_configs_integration_model; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sync_configs_integration_model ON public.nc_sync_configs USING btree (fk_model_id, fk_integration_id);


--
-- Name: user_comments_preference_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_comments_preference_index ON public.nc_user_comment_notifications_preference USING btree (user_id, row_id, fk_model_id);


--
-- Name: workspace_fk_org_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX workspace_fk_org_id_index ON public.workspace USING btree (fk_org_id);


--
-- Name: workspace_user_invited_by_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX workspace_user_invited_by_index ON public.workspace_user USING btree (invited_by);


--
-- PostgreSQL database dump complete
--


