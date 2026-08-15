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
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: ApiTokenAlgorithm; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."ApiTokenAlgorithm" AS ENUM (
    'SHA512'
);



--
-- Name: BackgroundJobStatus; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."BackgroundJobStatus" AS ENUM (
    'PENDING',
    'PROCESSING',
    'COMPLETED',
    'FAILED'
);



--
-- Name: BackgroundJobTaskStatus; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."BackgroundJobTaskStatus" AS ENUM (
    'PENDING',
    'COMPLETED',
    'FAILED'
);



--
-- Name: DocumentDataType; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."DocumentDataType" AS ENUM (
    'S3_PATH',
    'BYTES',
    'BYTES_64'
);



--
-- Name: DocumentDistributionMethod; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."DocumentDistributionMethod" AS ENUM (
    'EMAIL',
    'NONE'
);



--
-- Name: DocumentSigningOrder; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."DocumentSigningOrder" AS ENUM (
    'PARALLEL',
    'SEQUENTIAL'
);



--
-- Name: DocumentSource; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."DocumentSource" AS ENUM (
    'DOCUMENT',
    'TEMPLATE',
    'TEMPLATE_DIRECT_LINK'
);



--
-- Name: DocumentStatus; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."DocumentStatus" AS ENUM (
    'DRAFT',
    'PENDING',
    'COMPLETED',
    'REJECTED',
    'CANCELLED'
);



--
-- Name: DocumentVisibility; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."DocumentVisibility" AS ENUM (
    'EVERYONE',
    'MANAGER_AND_ABOVE',
    'ADMIN'
);



--
-- Name: EmailDomainStatus; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."EmailDomainStatus" AS ENUM (
    'PENDING',
    'ACTIVE'
);



--
-- Name: EmailTransportType; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."EmailTransportType" AS ENUM (
    'SMTP_AUTH',
    'SMTP_API',
    'RESEND',
    'MAILCHANNELS'
);



--
-- Name: EnvelopeType; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."EnvelopeType" AS ENUM (
    'DOCUMENT',
    'TEMPLATE'
);



--
-- Name: FieldType; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."FieldType" AS ENUM (
    'SIGNATURE',
    'FREE_SIGNATURE',
    'DATE',
    'TEXT',
    'NAME',
    'EMAIL',
    'NUMBER',
    'RADIO',
    'CHECKBOX',
    'DROPDOWN',
    'INITIALS'
);



--
-- Name: FolderType; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."FolderType" AS ENUM (
    'DOCUMENT',
    'TEMPLATE'
);



--
-- Name: IdentityProvider; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."IdentityProvider" AS ENUM (
    'DOCUMENSO',
    'GOOGLE',
    'OIDC'
);



--
-- Name: OrganisationGroupType; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."OrganisationGroupType" AS ENUM (
    'INTERNAL_ORGANISATION',
    'INTERNAL_TEAM',
    'CUSTOM'
);



--
-- Name: OrganisationMemberInviteStatus; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."OrganisationMemberInviteStatus" AS ENUM (
    'ACCEPTED',
    'PENDING',
    'DECLINED'
);



--
-- Name: OrganisationMemberRole; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."OrganisationMemberRole" AS ENUM (
    'ADMIN',
    'MANAGER',
    'MEMBER'
);



--
-- Name: OrganisationType; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."OrganisationType" AS ENUM (
    'PERSONAL',
    'ORGANISATION'
);



--
-- Name: ReadStatus; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."ReadStatus" AS ENUM (
    'NOT_OPENED',
    'OPENED'
);



--
-- Name: RecipientRole; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."RecipientRole" AS ENUM (
    'CC',
    'SIGNER',
    'VIEWER',
    'APPROVER',
    'ASSISTANT'
);



--
-- Name: Role; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."Role" AS ENUM (
    'ADMIN',
    'USER'
);



--
-- Name: SendStatus; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."SendStatus" AS ENUM (
    'NOT_SENT',
    'SENT'
);



--
-- Name: SigningStatus; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."SigningStatus" AS ENUM (
    'NOT_SIGNED',
    'SIGNED',
    'REJECTED'
);



--
-- Name: SubscriptionStatus; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."SubscriptionStatus" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'PAST_DUE'
);



--
-- Name: TeamMemberRole; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."TeamMemberRole" AS ENUM (
    'ADMIN',
    'MANAGER',
    'MEMBER'
);



--
-- Name: TemplateType; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."TemplateType" AS ENUM (
    'PUBLIC',
    'PRIVATE',
    'ORGANISATION'
);



--
-- Name: UserSecurityAuditLogType; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."UserSecurityAuditLogType" AS ENUM (
    'ACCOUNT_PROFILE_UPDATE',
    'ACCOUNT_SSO_LINK',
    'AUTH_2FA_DISABLE',
    'AUTH_2FA_ENABLE',
    'PASSWORD_RESET',
    'PASSWORD_UPDATE',
    'SIGN_OUT',
    'SIGN_IN',
    'SIGN_IN_FAIL',
    'SIGN_IN_2FA_FAIL',
    'PASSKEY_CREATED',
    'PASSKEY_DELETED',
    'PASSKEY_UPDATED',
    'SIGN_IN_PASSKEY_FAIL',
    'SESSION_REVOKED',
    'ACCOUNT_SSO_UNLINK',
    'ORGANISATION_SSO_LINK',
    'ORGANISATION_SSO_UNLINK'
);



--
-- Name: WebhookCallStatus; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."WebhookCallStatus" AS ENUM (
    'SUCCESS',
    'FAILED'
);



--
-- Name: WebhookTriggerEvents; Type: TYPE; Schema: public; Owner: documenso
--

CREATE TYPE public."WebhookTriggerEvents" AS ENUM (
    'DOCUMENT_CREATED',
    'DOCUMENT_SIGNED',
    'DOCUMENT_SENT',
    'DOCUMENT_OPENED',
    'DOCUMENT_COMPLETED',
    'DOCUMENT_REJECTED',
    'DOCUMENT_CANCELLED',
    'DOCUMENT_RECIPIENT_COMPLETED',
    'DOCUMENT_REMINDER_SENT',
    'TEMPLATE_CREATED',
    'TEMPLATE_UPDATED',
    'TEMPLATE_DELETED',
    'TEMPLATE_USED',
    'RECIPIENT_EXPIRED'
);



--
-- Name: generate_id(); Type: FUNCTION; Schema: public; Owner: documenso
--

CREATE FUNCTION public.generate_id() RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN nanoid(16, 'abcdefhiklmnorstuvwxyz');
END;
$$;



--
-- Name: generate_prefix_id(text); Type: FUNCTION; Schema: public; Owner: documenso
--

CREATE FUNCTION public.generate_prefix_id(prefix text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN prefix || '_' || nanoid(16, 'abcdefhiklmnorstuvwxyz');
END;
$$;



--
-- Name: nanoid(integer, text, double precision); Type: FUNCTION; Schema: public; Owner: documenso
--

CREATE FUNCTION public.nanoid(size integer DEFAULT 21, alphabet text DEFAULT '_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'::text, additionalbytesfactor double precision DEFAULT 1.6) RETURNS text
    LANGUAGE plpgsql PARALLEL SAFE
    AS $$
DECLARE
    alphabetArray  text[];
    alphabetLength int := 64;
    mask           int := 63;
    step           int := 34;
BEGIN
    IF size IS NULL OR size < 1 THEN
        RAISE EXCEPTION 'The size must be defined and greater than 0!';
    END IF;

    IF alphabet IS NULL OR length(alphabet) = 0 OR length(alphabet) > 255 THEN
        RAISE EXCEPTION 'The alphabet can''t be undefined, zero or bigger than 255 symbols!';
    END IF;

    IF additionalBytesFactor IS NULL OR additionalBytesFactor < 1 THEN
        RAISE EXCEPTION 'The additional bytes factor can''t be less than 1!';
    END IF;

    alphabetArray := regexp_split_to_array(alphabet, '');
    alphabetLength := array_length(alphabetArray, 1);
    mask := (2 << cast(floor(log(alphabetLength - 1) / log(2)) as int)) - 1;
    step := cast(ceil(additionalBytesFactor * mask * size / alphabetLength) AS int);

    IF step > 1024 THEN
        step := 1024; -- The step size % can''t be bigger then 1024!
    END IF;

    RETURN nanoid_optimized(size, alphabet, mask, step);
END
$$;



--
-- Name: nanoid_optimized(integer, text, integer, integer); Type: FUNCTION; Schema: public; Owner: documenso
--

CREATE FUNCTION public.nanoid_optimized(size integer, alphabet text, mask integer, step integer) RETURNS text
    LANGUAGE plpgsql PARALLEL SAFE
    AS $$
DECLARE
    idBuilder      text := '';
    counter        int  := 0;
    bytes          bytea;
    alphabetIndex  int;
    alphabetArray  text[];
    alphabetLength int  := 64;
BEGIN
    alphabetArray := regexp_split_to_array(alphabet, '');
    alphabetLength := array_length(alphabetArray, 1);

    LOOP
        bytes := gen_random_bytes(step);
        FOR counter IN 0..step - 1
            LOOP
                alphabetIndex := (get_byte(bytes, counter) & mask) + 1;
                IF alphabetIndex <= alphabetLength THEN
                    idBuilder := idBuilder || alphabetArray[alphabetIndex];
                    IF length(idBuilder) = size THEN
                        RETURN idBuilder;
                    END IF;
                END IF;
            END LOOP;
    END LOOP;
END
$$;



SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Account; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."Account" (
    id text NOT NULL,
    "userId" integer NOT NULL,
    type text NOT NULL,
    provider text NOT NULL,
    "providerAccountId" text NOT NULL,
    refresh_token text,
    access_token text,
    expires_at integer,
    token_type text,
    scope text,
    id_token text,
    session_state text,
    created_at integer,
    ext_expires_in integer,
    password text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);



--
-- Name: AnonymousVerificationToken; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."AnonymousVerificationToken" (
    id text NOT NULL,
    token text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);



--
-- Name: ApiToken; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."ApiToken" (
    id integer NOT NULL,
    name text NOT NULL,
    token text NOT NULL,
    algorithm public."ApiTokenAlgorithm" DEFAULT 'SHA512'::public."ApiTokenAlgorithm" NOT NULL,
    expires timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" integer,
    "teamId" integer NOT NULL
);



--
-- Name: ApiToken_id_seq; Type: SEQUENCE; Schema: public; Owner: documenso
--

CREATE SEQUENCE public."ApiToken_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: ApiToken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documenso
--

ALTER SEQUENCE public."ApiToken_id_seq" OWNED BY public."ApiToken".id;


--
-- Name: AvatarImage; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."AvatarImage" (
    id text NOT NULL,
    bytes text NOT NULL
);



--
-- Name: BackgroundJob; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."BackgroundJob" (
    id text NOT NULL,
    status public."BackgroundJobStatus" DEFAULT 'PENDING'::public."BackgroundJobStatus" NOT NULL,
    retried integer DEFAULT 0 NOT NULL,
    "maxRetries" integer DEFAULT 3 NOT NULL,
    "jobId" text NOT NULL,
    name text NOT NULL,
    version text NOT NULL,
    "submittedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "lastRetriedAt" timestamp(3) without time zone,
    "completedAt" timestamp(3) without time zone,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    payload jsonb
);



--
-- Name: BackgroundJobTask; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."BackgroundJobTask" (
    id text NOT NULL,
    status public."BackgroundJobTaskStatus" DEFAULT 'PENDING'::public."BackgroundJobTaskStatus" NOT NULL,
    result jsonb,
    retried integer DEFAULT 0 NOT NULL,
    "maxRetries" integer DEFAULT 3 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "jobId" text NOT NULL,
    "completedAt" timestamp(3) without time zone,
    name text NOT NULL
);



--
-- Name: Counter; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."Counter" (
    id text NOT NULL,
    value integer NOT NULL
);



--
-- Name: CscCredential; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."CscCredential" (
    id text NOT NULL,
    "providerId" text NOT NULL,
    "credentialId" text NOT NULL,
    "certCache" bytea,
    "signatureAlgorithm" text NOT NULL,
    "keyType" text NOT NULL,
    "digestAlgorithm" text NOT NULL,
    "keyLenBits" integer,
    "signAlgoParams" text,
    "serviceTokenCiphertext" bytea,
    "serviceTokenExpiresAt" timestamp(3) without time zone,
    "recipientId" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);



--
-- Name: CscSession; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."CscSession" (
    id text NOT NULL,
    "envelopeId" text NOT NULL,
    "signingTime" timestamp(3) without time zone NOT NULL,
    "itemsJson" jsonb NOT NULL,
    "encryptedSad" bytea,
    "sadExpiresAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "recipientId" integer NOT NULL
);



--
-- Name: DocumentAuditLog; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."DocumentAuditLog" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    type text NOT NULL,
    data jsonb NOT NULL,
    name text,
    email text,
    "userId" integer,
    "userAgent" text,
    "ipAddress" text,
    "envelopeId" text
);



--
-- Name: DocumentData; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."DocumentData" (
    id text NOT NULL,
    type public."DocumentDataType" NOT NULL,
    data text NOT NULL,
    "initialData" text NOT NULL
);



--
-- Name: DocumentMeta; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."DocumentMeta" (
    id text NOT NULL,
    message text,
    subject text,
    "dateFormat" text DEFAULT 'yyyy-MM-dd hh:mm a'::text,
    timezone text DEFAULT 'Etc/UTC'::text,
    "redirectUrl" text,
    "signingOrder" public."DocumentSigningOrder" DEFAULT 'PARALLEL'::public."DocumentSigningOrder" NOT NULL,
    "typedSignatureEnabled" boolean DEFAULT true NOT NULL,
    language text DEFAULT 'en'::text NOT NULL,
    "distributionMethod" public."DocumentDistributionMethod" DEFAULT 'EMAIL'::public."DocumentDistributionMethod" NOT NULL,
    "emailSettings" jsonb,
    "drawSignatureEnabled" boolean DEFAULT true NOT NULL,
    "uploadSignatureEnabled" boolean DEFAULT true NOT NULL,
    "allowDictateNextSigner" boolean DEFAULT false NOT NULL,
    "emailId" text,
    "emailReplyTo" text,
    "envelopeExpirationPeriod" jsonb,
    "reminderSettings" jsonb
);



--
-- Name: DocumentShareLink; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."DocumentShareLink" (
    id integer NOT NULL,
    email text NOT NULL,
    slug text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "envelopeId" text NOT NULL
);



--
-- Name: DocumentShareLink_id_seq; Type: SEQUENCE; Schema: public; Owner: documenso
--

CREATE SEQUENCE public."DocumentShareLink_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: DocumentShareLink_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documenso
--

ALTER SEQUENCE public."DocumentShareLink_id_seq" OWNED BY public."DocumentShareLink".id;


--
-- Name: EmailDomain; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."EmailDomain" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    status public."EmailDomainStatus" DEFAULT 'PENDING'::public."EmailDomainStatus" NOT NULL,
    selector text NOT NULL,
    domain text NOT NULL,
    "publicKey" text NOT NULL,
    "privateKey" text NOT NULL,
    "organisationId" text NOT NULL,
    "lastVerifiedAt" timestamp(3) without time zone
);



--
-- Name: EmailTransport; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."EmailTransport" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    name text NOT NULL,
    type public."EmailTransportType" NOT NULL,
    "fromName" text NOT NULL,
    "fromAddress" text NOT NULL,
    config text NOT NULL
);



--
-- Name: Envelope; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."Envelope" (
    id text NOT NULL,
    "secondaryId" text NOT NULL,
    "externalId" text,
    type public."EnvelopeType" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "completedAt" timestamp(3) without time zone,
    "deletedAt" timestamp(3) without time zone,
    title text NOT NULL,
    status public."DocumentStatus" DEFAULT 'DRAFT'::public."DocumentStatus" NOT NULL,
    source public."DocumentSource" NOT NULL,
    "qrToken" text,
    "internalVersion" integer NOT NULL,
    "useLegacyFieldInsertion" boolean DEFAULT false NOT NULL,
    "authOptions" jsonb,
    "formValues" jsonb,
    visibility public."DocumentVisibility" DEFAULT 'EVERYONE'::public."DocumentVisibility" NOT NULL,
    "templateType" public."TemplateType" DEFAULT 'PRIVATE'::public."TemplateType" NOT NULL,
    "publicTitle" text DEFAULT ''::text NOT NULL,
    "publicDescription" text DEFAULT ''::text NOT NULL,
    "templateId" integer,
    "userId" integer NOT NULL,
    "teamId" integer NOT NULL,
    "folderId" text,
    "documentMetaId" text NOT NULL,
    "signatureLevel" text NOT NULL
);



--
-- Name: EnvelopeAttachment; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."EnvelopeAttachment" (
    id text NOT NULL,
    type text NOT NULL,
    label text NOT NULL,
    data text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "envelopeId" text NOT NULL
);



--
-- Name: EnvelopeItem; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."EnvelopeItem" (
    id text NOT NULL,
    title text NOT NULL,
    "documentDataId" text NOT NULL,
    "envelopeId" text NOT NULL,
    "order" integer NOT NULL
);



--
-- Name: Field; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."Field" (
    id integer NOT NULL,
    "recipientId" integer NOT NULL,
    type public."FieldType" NOT NULL,
    page integer NOT NULL,
    "positionX" numeric(65,30) DEFAULT 0 NOT NULL,
    "positionY" numeric(65,30) DEFAULT 0 NOT NULL,
    "customText" text NOT NULL,
    inserted boolean NOT NULL,
    height numeric(65,30) DEFAULT '-1'::integer NOT NULL,
    width numeric(65,30) DEFAULT '-1'::integer NOT NULL,
    "secondaryId" text NOT NULL,
    "fieldMeta" jsonb,
    "envelopeId" text NOT NULL,
    "envelopeItemId" text NOT NULL
);



--
-- Name: Field_id_seq; Type: SEQUENCE; Schema: public; Owner: documenso
--

CREATE SEQUENCE public."Field_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: Field_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documenso
--

ALTER SEQUENCE public."Field_id_seq" OWNED BY public."Field".id;


--
-- Name: Folder; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."Folder" (
    id text NOT NULL,
    name text NOT NULL,
    "userId" integer NOT NULL,
    "teamId" integer NOT NULL,
    "parentId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    pinned boolean DEFAULT false NOT NULL,
    visibility public."DocumentVisibility" DEFAULT 'EVERYONE'::public."DocumentVisibility" NOT NULL,
    type public."FolderType" NOT NULL
);



--
-- Name: Organisation; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."Organisation" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    type public."OrganisationType" NOT NULL,
    name text NOT NULL,
    url text NOT NULL,
    "avatarImageId" text,
    "customerId" text,
    "ownerUserId" integer NOT NULL,
    "organisationClaimId" text NOT NULL,
    "organisationGlobalSettingsId" text NOT NULL,
    "organisationAuthenticationPortalId" text NOT NULL
);



--
-- Name: OrganisationAuthenticationPortal; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."OrganisationAuthenticationPortal" (
    id text NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    "clientId" text DEFAULT ''::text NOT NULL,
    "clientSecret" text DEFAULT ''::text NOT NULL,
    "wellKnownUrl" text DEFAULT ''::text NOT NULL,
    "defaultOrganisationRole" public."OrganisationMemberRole" DEFAULT 'MEMBER'::public."OrganisationMemberRole" NOT NULL,
    "autoProvisionUsers" boolean DEFAULT true NOT NULL,
    "allowedDomains" text[] DEFAULT ARRAY[]::text[],
    "allowPersonalOrganisations" boolean DEFAULT false NOT NULL
);



--
-- Name: OrganisationClaim; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."OrganisationClaim" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "originalSubscriptionClaimId" text,
    "teamCount" integer NOT NULL,
    "memberCount" integer NOT NULL,
    flags jsonb NOT NULL,
    "envelopeItemCount" integer NOT NULL,
    "apiQuota" integer,
    "apiRateLimits" jsonb NOT NULL,
    "documentQuota" integer,
    "documentRateLimits" jsonb NOT NULL,
    "emailQuota" integer,
    "emailRateLimits" jsonb NOT NULL,
    "recipientCount" integer NOT NULL,
    "emailTransportId" text
);



--
-- Name: OrganisationEmail; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."OrganisationEmail" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    email text NOT NULL,
    "emailName" text NOT NULL,
    "emailDomainId" text NOT NULL,
    "organisationId" text NOT NULL
);



--
-- Name: OrganisationGlobalSettings; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."OrganisationGlobalSettings" (
    id text NOT NULL,
    "documentVisibility" public."DocumentVisibility" DEFAULT 'EVERYONE'::public."DocumentVisibility" NOT NULL,
    "documentLanguage" text DEFAULT 'en'::text NOT NULL,
    "includeSenderDetails" boolean DEFAULT true NOT NULL,
    "includeSigningCertificate" boolean DEFAULT true NOT NULL,
    "typedSignatureEnabled" boolean DEFAULT true NOT NULL,
    "uploadSignatureEnabled" boolean DEFAULT true NOT NULL,
    "drawSignatureEnabled" boolean DEFAULT true NOT NULL,
    "brandingEnabled" boolean DEFAULT false NOT NULL,
    "brandingLogo" text DEFAULT ''::text NOT NULL,
    "brandingUrl" text DEFAULT ''::text NOT NULL,
    "brandingCompanyDetails" text DEFAULT ''::text NOT NULL,
    "emailDocumentSettings" jsonb NOT NULL,
    "documentDateFormat" text DEFAULT 'yyyy-MM-dd hh:mm a'::text NOT NULL,
    "documentTimezone" text,
    "emailId" text,
    "emailReplyTo" text,
    "includeAuditLog" boolean DEFAULT false NOT NULL,
    "aiFeaturesEnabled" boolean DEFAULT false NOT NULL,
    "defaultRecipients" jsonb,
    "delegateDocumentOwnership" boolean DEFAULT false NOT NULL,
    "envelopeExpirationPeriod" jsonb,
    "reminderSettings" jsonb,
    "brandingColors" jsonb,
    "brandingCss" text DEFAULT ''::text NOT NULL
);



--
-- Name: OrganisationGroup; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."OrganisationGroup" (
    id text NOT NULL,
    name text,
    type public."OrganisationGroupType" NOT NULL,
    "organisationRole" public."OrganisationMemberRole" NOT NULL,
    "organisationId" text NOT NULL
);



--
-- Name: OrganisationGroupMember; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."OrganisationGroupMember" (
    id text NOT NULL,
    "groupId" text NOT NULL,
    "organisationMemberId" text NOT NULL
);



--
-- Name: OrganisationMember; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."OrganisationMember" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "userId" integer NOT NULL,
    "organisationId" text NOT NULL
);



--
-- Name: OrganisationMemberInvite; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."OrganisationMemberInvite" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    email text NOT NULL,
    token text NOT NULL,
    status public."OrganisationMemberInviteStatus" DEFAULT 'PENDING'::public."OrganisationMemberInviteStatus" NOT NULL,
    "organisationId" text NOT NULL,
    "organisationRole" public."OrganisationMemberRole" NOT NULL
);



--
-- Name: OrganisationMonthlyStat; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."OrganisationMonthlyStat" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "organisationId" text NOT NULL,
    period text NOT NULL,
    "documentCount" integer DEFAULT 0 NOT NULL,
    "emailCount" integer DEFAULT 0 NOT NULL,
    "apiCount" integer DEFAULT 0 NOT NULL,
    "emailReports" integer DEFAULT 0 NOT NULL
);



--
-- Name: Passkey; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."Passkey" (
    id text NOT NULL,
    "userId" integer NOT NULL,
    name text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "lastUsedAt" timestamp(3) without time zone,
    "credentialId" bytea NOT NULL,
    "credentialPublicKey" bytea NOT NULL,
    counter bigint NOT NULL,
    "credentialDeviceType" text NOT NULL,
    "credentialBackedUp" boolean NOT NULL,
    transports text[]
);



--
-- Name: PasswordResetToken; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."PasswordResetToken" (
    id integer NOT NULL,
    token text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expiry timestamp(3) without time zone NOT NULL,
    "userId" integer NOT NULL
);



--
-- Name: PasswordResetToken_id_seq; Type: SEQUENCE; Schema: public; Owner: documenso
--

CREATE SEQUENCE public."PasswordResetToken_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: PasswordResetToken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documenso
--

ALTER SEQUENCE public."PasswordResetToken_id_seq" OWNED BY public."PasswordResetToken".id;


--
-- Name: RateLimit; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."RateLimit" (
    key text NOT NULL,
    action text NOT NULL,
    bucket timestamp(3) without time zone NOT NULL,
    count integer DEFAULT 1 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);



--
-- Name: Recipient; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."Recipient" (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    token text NOT NULL,
    expired timestamp(3) without time zone,
    "readStatus" public."ReadStatus" DEFAULT 'NOT_OPENED'::public."ReadStatus" NOT NULL,
    "signingStatus" public."SigningStatus" DEFAULT 'NOT_SIGNED'::public."SigningStatus" NOT NULL,
    "sendStatus" public."SendStatus" DEFAULT 'NOT_SENT'::public."SendStatus" NOT NULL,
    "signedAt" timestamp(3) without time zone,
    role public."RecipientRole" DEFAULT 'SIGNER'::public."RecipientRole" NOT NULL,
    "authOptions" jsonb,
    "documentDeletedAt" timestamp(3) without time zone,
    "signingOrder" integer,
    "rejectionReason" text,
    "envelopeId" text NOT NULL,
    "expirationNotifiedAt" timestamp(3) without time zone,
    "expiresAt" timestamp(3) without time zone,
    "sentAt" timestamp(3) without time zone,
    "lastReminderSentAt" timestamp(3) without time zone,
    "nextReminderAt" timestamp(3) without time zone,
    "reminderCount" integer DEFAULT 0 NOT NULL
);



--
-- Name: Recipient_id_seq; Type: SEQUENCE; Schema: public; Owner: documenso
--

CREATE SEQUENCE public."Recipient_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: Recipient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documenso
--

ALTER SEQUENCE public."Recipient_id_seq" OWNED BY public."Recipient".id;


--
-- Name: Session; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."Session" (
    id text NOT NULL,
    "sessionToken" text NOT NULL,
    "userId" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "ipAddress" text,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "userAgent" text
);



--
-- Name: Signature; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."Signature" (
    id integer NOT NULL,
    created timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "recipientId" integer NOT NULL,
    "fieldId" integer NOT NULL,
    "signatureImageAsBase64" text,
    "typedSignature" text
);



--
-- Name: Signature_id_seq; Type: SEQUENCE; Schema: public; Owner: documenso
--

CREATE SEQUENCE public."Signature_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: Signature_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documenso
--

ALTER SEQUENCE public."Signature_id_seq" OWNED BY public."Signature".id;


--
-- Name: SiteSettings; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."SiteSettings" (
    id text NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    data jsonb NOT NULL,
    "lastModifiedByUserId" integer,
    "lastModifiedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);



--
-- Name: Subscription; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."Subscription" (
    id integer NOT NULL,
    status public."SubscriptionStatus" DEFAULT 'INACTIVE'::public."SubscriptionStatus" NOT NULL,
    "planId" text NOT NULL,
    "priceId" text NOT NULL,
    "periodEnd" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "cancelAtPeriodEnd" boolean DEFAULT false NOT NULL,
    "customerId" text NOT NULL,
    "organisationId" text NOT NULL
);



--
-- Name: SubscriptionClaim; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."SubscriptionClaim" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    name text NOT NULL,
    locked boolean DEFAULT false NOT NULL,
    "teamCount" integer NOT NULL,
    "memberCount" integer NOT NULL,
    flags jsonb NOT NULL,
    "envelopeItemCount" integer NOT NULL,
    "apiQuota" integer,
    "apiRateLimits" jsonb NOT NULL,
    "documentQuota" integer,
    "documentRateLimits" jsonb NOT NULL,
    "emailQuota" integer,
    "emailRateLimits" jsonb NOT NULL,
    "recipientCount" integer NOT NULL,
    "emailTransportId" text
);



--
-- Name: Subscription_id_seq; Type: SEQUENCE; Schema: public; Owner: documenso
--

CREATE SEQUENCE public."Subscription_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: Subscription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documenso
--

ALTER SEQUENCE public."Subscription_id_seq" OWNED BY public."Subscription".id;


--
-- Name: Team; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."Team" (
    id integer NOT NULL,
    name text NOT NULL,
    url text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "avatarImageId" text,
    "organisationId" text NOT NULL,
    "teamGlobalSettingsId" text NOT NULL
);



--
-- Name: TeamEmail; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."TeamEmail" (
    "teamId" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text NOT NULL,
    email text NOT NULL
);



--
-- Name: TeamEmailVerification; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."TeamEmailVerification" (
    "teamId" integer NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    token text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    completed boolean DEFAULT false NOT NULL
);



--
-- Name: TeamGlobalSettings; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."TeamGlobalSettings" (
    "documentVisibility" public."DocumentVisibility",
    "includeSenderDetails" boolean,
    "brandingCompanyDetails" text,
    "brandingEnabled" boolean,
    "brandingLogo" text,
    "brandingUrl" text,
    "documentLanguage" text,
    "typedSignatureEnabled" boolean,
    "includeSigningCertificate" boolean,
    "drawSignatureEnabled" boolean,
    "uploadSignatureEnabled" boolean,
    id text NOT NULL,
    "documentDateFormat" text,
    "documentTimezone" text,
    "emailDocumentSettings" jsonb,
    "emailId" text,
    "emailReplyTo" text,
    "includeAuditLog" boolean,
    "aiFeaturesEnabled" boolean,
    "defaultRecipients" jsonb,
    "delegateDocumentOwnership" boolean,
    "envelopeExpirationPeriod" jsonb,
    "reminderSettings" jsonb,
    "brandingColors" jsonb,
    "brandingCss" text
);



--
-- Name: TeamGroup; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."TeamGroup" (
    id text NOT NULL,
    "organisationGroupId" text NOT NULL,
    "teamRole" public."TeamMemberRole" NOT NULL,
    "teamId" integer NOT NULL
);



--
-- Name: TeamProfile; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."TeamProfile" (
    id text NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    "teamId" integer NOT NULL,
    bio text
);



--
-- Name: Team_id_seq; Type: SEQUENCE; Schema: public; Owner: documenso
--

CREATE SEQUENCE public."Team_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: Team_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documenso
--

ALTER SEQUENCE public."Team_id_seq" OWNED BY public."Team".id;


--
-- Name: TemplateDirectLink; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."TemplateDirectLink" (
    id text NOT NULL,
    token text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    enabled boolean NOT NULL,
    "directTemplateRecipientId" integer NOT NULL,
    "envelopeId" text NOT NULL
);



--
-- Name: User; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."User" (
    id integer NOT NULL,
    name text,
    email text NOT NULL,
    "emailVerified" timestamp(3) without time zone,
    password text,
    source text,
    "identityProvider" public."IdentityProvider" DEFAULT 'DOCUMENSO'::public."IdentityProvider" NOT NULL,
    signature text,
    roles public."Role"[] DEFAULT ARRAY['USER'::public."Role"],
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "lastSignedIn" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "twoFactorBackupCodes" text,
    "twoFactorEnabled" boolean DEFAULT false NOT NULL,
    "twoFactorSecret" text,
    "avatarImageId" text,
    disabled boolean DEFAULT false NOT NULL
);



--
-- Name: UserSecurityAuditLog; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."UserSecurityAuditLog" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    type public."UserSecurityAuditLogType" NOT NULL,
    "userAgent" text,
    "ipAddress" text
);



--
-- Name: UserSecurityAuditLog_id_seq; Type: SEQUENCE; Schema: public; Owner: documenso
--

CREATE SEQUENCE public."UserSecurityAuditLog_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: UserSecurityAuditLog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documenso
--

ALTER SEQUENCE public."UserSecurityAuditLog_id_seq" OWNED BY public."UserSecurityAuditLog".id;


--
-- Name: User_id_seq; Type: SEQUENCE; Schema: public; Owner: documenso
--

CREATE SEQUENCE public."User_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: User_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documenso
--

ALTER SEQUENCE public."User_id_seq" OWNED BY public."User".id;


--
-- Name: VerificationToken; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."VerificationToken" (
    id integer NOT NULL,
    identifier text NOT NULL,
    token text NOT NULL,
    expires timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" integer NOT NULL,
    "secondaryId" text NOT NULL,
    completed boolean DEFAULT false NOT NULL,
    metadata jsonb
);



--
-- Name: VerificationToken_id_seq; Type: SEQUENCE; Schema: public; Owner: documenso
--

CREATE SEQUENCE public."VerificationToken_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: VerificationToken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documenso
--

ALTER SEQUENCE public."VerificationToken_id_seq" OWNED BY public."VerificationToken".id;


--
-- Name: Webhook; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."Webhook" (
    id text NOT NULL,
    "webhookUrl" text NOT NULL,
    "eventTriggers" public."WebhookTriggerEvents"[],
    secret text,
    enabled boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" integer NOT NULL,
    "teamId" integer NOT NULL
);



--
-- Name: WebhookCall; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public."WebhookCall" (
    id text NOT NULL,
    status public."WebhookCallStatus" NOT NULL,
    url text NOT NULL,
    "requestBody" jsonb NOT NULL,
    "responseCode" integer NOT NULL,
    "responseHeaders" jsonb,
    "responseBody" jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "webhookId" text NOT NULL,
    event public."WebhookTriggerEvents" NOT NULL
);



--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: documenso
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);



--
-- Name: ApiToken id; Type: DEFAULT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."ApiToken" ALTER COLUMN id SET DEFAULT nextval('public."ApiToken_id_seq"'::regclass);


--
-- Name: DocumentShareLink id; Type: DEFAULT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."DocumentShareLink" ALTER COLUMN id SET DEFAULT nextval('public."DocumentShareLink_id_seq"'::regclass);


--
-- Name: Field id; Type: DEFAULT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Field" ALTER COLUMN id SET DEFAULT nextval('public."Field_id_seq"'::regclass);


--
-- Name: PasswordResetToken id; Type: DEFAULT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."PasswordResetToken" ALTER COLUMN id SET DEFAULT nextval('public."PasswordResetToken_id_seq"'::regclass);


--
-- Name: Recipient id; Type: DEFAULT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Recipient" ALTER COLUMN id SET DEFAULT nextval('public."Recipient_id_seq"'::regclass);


--
-- Name: Signature id; Type: DEFAULT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Signature" ALTER COLUMN id SET DEFAULT nextval('public."Signature_id_seq"'::regclass);


--
-- Name: Subscription id; Type: DEFAULT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Subscription" ALTER COLUMN id SET DEFAULT nextval('public."Subscription_id_seq"'::regclass);


--
-- Name: Team id; Type: DEFAULT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Team" ALTER COLUMN id SET DEFAULT nextval('public."Team_id_seq"'::regclass);


--
-- Name: User id; Type: DEFAULT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."User" ALTER COLUMN id SET DEFAULT nextval('public."User_id_seq"'::regclass);


--
-- Name: UserSecurityAuditLog id; Type: DEFAULT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."UserSecurityAuditLog" ALTER COLUMN id SET DEFAULT nextval('public."UserSecurityAuditLog_id_seq"'::regclass);


--
-- Name: VerificationToken id; Type: DEFAULT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."VerificationToken" ALTER COLUMN id SET DEFAULT nextval('public."VerificationToken_id_seq"'::regclass);


--
-- Name: Account Account_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Account"
    ADD CONSTRAINT "Account_pkey" PRIMARY KEY (id);


--
-- Name: AnonymousVerificationToken AnonymousVerificationToken_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."AnonymousVerificationToken"
    ADD CONSTRAINT "AnonymousVerificationToken_pkey" PRIMARY KEY (id);


--
-- Name: ApiToken ApiToken_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."ApiToken"
    ADD CONSTRAINT "ApiToken_pkey" PRIMARY KEY (id);


--
-- Name: AvatarImage AvatarImage_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."AvatarImage"
    ADD CONSTRAINT "AvatarImage_pkey" PRIMARY KEY (id);


--
-- Name: BackgroundJobTask BackgroundJobTask_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."BackgroundJobTask"
    ADD CONSTRAINT "BackgroundJobTask_pkey" PRIMARY KEY (id);


--
-- Name: BackgroundJob BackgroundJob_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."BackgroundJob"
    ADD CONSTRAINT "BackgroundJob_pkey" PRIMARY KEY (id);


--
-- Name: Counter Counter_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Counter"
    ADD CONSTRAINT "Counter_pkey" PRIMARY KEY (id);


--
-- Name: CscCredential CscCredential_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."CscCredential"
    ADD CONSTRAINT "CscCredential_pkey" PRIMARY KEY (id);


--
-- Name: CscSession CscSession_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."CscSession"
    ADD CONSTRAINT "CscSession_pkey" PRIMARY KEY (id);


--
-- Name: DocumentAuditLog DocumentAuditLog_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."DocumentAuditLog"
    ADD CONSTRAINT "DocumentAuditLog_pkey" PRIMARY KEY (id);


--
-- Name: DocumentData DocumentData_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."DocumentData"
    ADD CONSTRAINT "DocumentData_pkey" PRIMARY KEY (id);


--
-- Name: DocumentMeta DocumentMeta_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."DocumentMeta"
    ADD CONSTRAINT "DocumentMeta_pkey" PRIMARY KEY (id);


--
-- Name: DocumentShareLink DocumentShareLink_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."DocumentShareLink"
    ADD CONSTRAINT "DocumentShareLink_pkey" PRIMARY KEY (id);


--
-- Name: EmailDomain EmailDomain_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."EmailDomain"
    ADD CONSTRAINT "EmailDomain_pkey" PRIMARY KEY (id);


--
-- Name: EmailTransport EmailTransport_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."EmailTransport"
    ADD CONSTRAINT "EmailTransport_pkey" PRIMARY KEY (id);


--
-- Name: EnvelopeAttachment EnvelopeAttachment_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."EnvelopeAttachment"
    ADD CONSTRAINT "EnvelopeAttachment_pkey" PRIMARY KEY (id);


--
-- Name: EnvelopeItem EnvelopeItem_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."EnvelopeItem"
    ADD CONSTRAINT "EnvelopeItem_pkey" PRIMARY KEY (id);


--
-- Name: Envelope Envelope_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Envelope"
    ADD CONSTRAINT "Envelope_pkey" PRIMARY KEY (id);


--
-- Name: Field Field_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Field"
    ADD CONSTRAINT "Field_pkey" PRIMARY KEY (id);


--
-- Name: Folder Folder_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Folder"
    ADD CONSTRAINT "Folder_pkey" PRIMARY KEY (id);


--
-- Name: OrganisationAuthenticationPortal OrganisationAuthenticationPortal_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationAuthenticationPortal"
    ADD CONSTRAINT "OrganisationAuthenticationPortal_pkey" PRIMARY KEY (id);


--
-- Name: OrganisationClaim OrganisationClaim_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationClaim"
    ADD CONSTRAINT "OrganisationClaim_pkey" PRIMARY KEY (id);


--
-- Name: OrganisationEmail OrganisationEmail_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationEmail"
    ADD CONSTRAINT "OrganisationEmail_pkey" PRIMARY KEY (id);


--
-- Name: OrganisationGlobalSettings OrganisationGlobalSettings_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationGlobalSettings"
    ADD CONSTRAINT "OrganisationGlobalSettings_pkey" PRIMARY KEY (id);


--
-- Name: OrganisationGroupMember OrganisationGroupMember_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationGroupMember"
    ADD CONSTRAINT "OrganisationGroupMember_pkey" PRIMARY KEY (id);


--
-- Name: OrganisationGroup OrganisationGroup_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationGroup"
    ADD CONSTRAINT "OrganisationGroup_pkey" PRIMARY KEY (id);


--
-- Name: OrganisationMemberInvite OrganisationMemberInvite_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationMemberInvite"
    ADD CONSTRAINT "OrganisationMemberInvite_pkey" PRIMARY KEY (id);


--
-- Name: OrganisationMember OrganisationMember_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationMember"
    ADD CONSTRAINT "OrganisationMember_pkey" PRIMARY KEY (id);


--
-- Name: OrganisationMonthlyStat OrganisationMonthlyStat_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationMonthlyStat"
    ADD CONSTRAINT "OrganisationMonthlyStat_pkey" PRIMARY KEY (id);


--
-- Name: Organisation Organisation_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Organisation"
    ADD CONSTRAINT "Organisation_pkey" PRIMARY KEY (id);


--
-- Name: Passkey Passkey_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Passkey"
    ADD CONSTRAINT "Passkey_pkey" PRIMARY KEY (id);


--
-- Name: PasswordResetToken PasswordResetToken_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."PasswordResetToken"
    ADD CONSTRAINT "PasswordResetToken_pkey" PRIMARY KEY (id);


--
-- Name: RateLimit RateLimit_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."RateLimit"
    ADD CONSTRAINT "RateLimit_pkey" PRIMARY KEY (key, action, bucket);


--
-- Name: Recipient Recipient_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Recipient"
    ADD CONSTRAINT "Recipient_pkey" PRIMARY KEY (id);


--
-- Name: Session Session_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Session"
    ADD CONSTRAINT "Session_pkey" PRIMARY KEY (id);


--
-- Name: Signature Signature_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Signature"
    ADD CONSTRAINT "Signature_pkey" PRIMARY KEY (id);


--
-- Name: SiteSettings SiteSettings_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."SiteSettings"
    ADD CONSTRAINT "SiteSettings_pkey" PRIMARY KEY (id);


--
-- Name: SubscriptionClaim SubscriptionClaim_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."SubscriptionClaim"
    ADD CONSTRAINT "SubscriptionClaim_pkey" PRIMARY KEY (id);


--
-- Name: Subscription Subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Subscription"
    ADD CONSTRAINT "Subscription_pkey" PRIMARY KEY (id);


--
-- Name: TeamEmailVerification TeamEmailVerification_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."TeamEmailVerification"
    ADD CONSTRAINT "TeamEmailVerification_pkey" PRIMARY KEY ("teamId");


--
-- Name: TeamEmail TeamEmail_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."TeamEmail"
    ADD CONSTRAINT "TeamEmail_pkey" PRIMARY KEY ("teamId");


--
-- Name: TeamGlobalSettings TeamGlobalSettings_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."TeamGlobalSettings"
    ADD CONSTRAINT "TeamGlobalSettings_pkey" PRIMARY KEY (id);


--
-- Name: TeamGroup TeamGroup_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."TeamGroup"
    ADD CONSTRAINT "TeamGroup_pkey" PRIMARY KEY (id);


--
-- Name: TeamProfile TeamProfile_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."TeamProfile"
    ADD CONSTRAINT "TeamProfile_pkey" PRIMARY KEY (id);


--
-- Name: Team Team_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Team"
    ADD CONSTRAINT "Team_pkey" PRIMARY KEY (id);


--
-- Name: TemplateDirectLink TemplateDirectLink_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."TemplateDirectLink"
    ADD CONSTRAINT "TemplateDirectLink_pkey" PRIMARY KEY (id);


--
-- Name: UserSecurityAuditLog UserSecurityAuditLog_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."UserSecurityAuditLog"
    ADD CONSTRAINT "UserSecurityAuditLog_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: VerificationToken VerificationToken_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."VerificationToken"
    ADD CONSTRAINT "VerificationToken_pkey" PRIMARY KEY (id);


--
-- Name: WebhookCall WebhookCall_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."WebhookCall"
    ADD CONSTRAINT "WebhookCall_pkey" PRIMARY KEY (id);


--
-- Name: Webhook Webhook_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Webhook"
    ADD CONSTRAINT "Webhook_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: Account_provider_providerAccountId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "Account_provider_providerAccountId_key" ON public."Account" USING btree (provider, "providerAccountId");


--
-- Name: AnonymousVerificationToken_id_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "AnonymousVerificationToken_id_key" ON public."AnonymousVerificationToken" USING btree (id);


--
-- Name: AnonymousVerificationToken_token_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "AnonymousVerificationToken_token_key" ON public."AnonymousVerificationToken" USING btree (token);


--
-- Name: ApiToken_token_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "ApiToken_token_key" ON public."ApiToken" USING btree (token);


--
-- Name: CscCredential_recipientId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "CscCredential_recipientId_key" ON public."CscCredential" USING btree ("recipientId");


--
-- Name: CscSession_recipientId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "CscSession_recipientId_key" ON public."CscSession" USING btree ("recipientId");


--
-- Name: DocumentAuditLog_envelopeId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "DocumentAuditLog_envelopeId_idx" ON public."DocumentAuditLog" USING btree ("envelopeId");


--
-- Name: DocumentShareLink_envelopeId_email_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "DocumentShareLink_envelopeId_email_key" ON public."DocumentShareLink" USING btree ("envelopeId", email);


--
-- Name: DocumentShareLink_slug_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "DocumentShareLink_slug_key" ON public."DocumentShareLink" USING btree (slug);


--
-- Name: EmailDomain_domain_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "EmailDomain_domain_key" ON public."EmailDomain" USING btree (domain);


--
-- Name: EmailDomain_selector_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "EmailDomain_selector_key" ON public."EmailDomain" USING btree (selector);


--
-- Name: EnvelopeAttachment_envelopeId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "EnvelopeAttachment_envelopeId_idx" ON public."EnvelopeAttachment" USING btree ("envelopeId");


--
-- Name: EnvelopeItem_documentDataId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "EnvelopeItem_documentDataId_key" ON public."EnvelopeItem" USING btree ("documentDataId");


--
-- Name: EnvelopeItem_envelopeId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "EnvelopeItem_envelopeId_idx" ON public."EnvelopeItem" USING btree ("envelopeId");


--
-- Name: Envelope_createdAt_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Envelope_createdAt_idx" ON public."Envelope" USING btree ("createdAt");


--
-- Name: Envelope_documentMetaId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "Envelope_documentMetaId_key" ON public."Envelope" USING btree ("documentMetaId");


--
-- Name: Envelope_folderId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Envelope_folderId_idx" ON public."Envelope" USING btree ("folderId");


--
-- Name: Envelope_secondaryId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "Envelope_secondaryId_key" ON public."Envelope" USING btree ("secondaryId");


--
-- Name: Envelope_status_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Envelope_status_idx" ON public."Envelope" USING btree (status);


--
-- Name: Envelope_teamId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Envelope_teamId_idx" ON public."Envelope" USING btree ("teamId");


--
-- Name: Envelope_type_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Envelope_type_idx" ON public."Envelope" USING btree (type);


--
-- Name: Envelope_userId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Envelope_userId_idx" ON public."Envelope" USING btree ("userId");


--
-- Name: Field_envelopeId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Field_envelopeId_idx" ON public."Field" USING btree ("envelopeId");


--
-- Name: Field_envelopeItemId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Field_envelopeItemId_idx" ON public."Field" USING btree ("envelopeItemId");


--
-- Name: Field_recipientId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Field_recipientId_idx" ON public."Field" USING btree ("recipientId");


--
-- Name: Field_secondaryId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "Field_secondaryId_key" ON public."Field" USING btree ("secondaryId");


--
-- Name: Folder_parentId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Folder_parentId_idx" ON public."Folder" USING btree ("parentId");


--
-- Name: Folder_teamId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Folder_teamId_idx" ON public."Folder" USING btree ("teamId");


--
-- Name: Folder_type_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Folder_type_idx" ON public."Folder" USING btree (type);


--
-- Name: Folder_userId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Folder_userId_idx" ON public."Folder" USING btree ("userId");


--
-- Name: OrganisationEmail_email_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "OrganisationEmail_email_key" ON public."OrganisationEmail" USING btree (email);


--
-- Name: OrganisationGroupMember_groupId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "OrganisationGroupMember_groupId_idx" ON public."OrganisationGroupMember" USING btree ("groupId");


--
-- Name: OrganisationGroupMember_organisationMemberId_groupId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "OrganisationGroupMember_organisationMemberId_groupId_key" ON public."OrganisationGroupMember" USING btree ("organisationMemberId", "groupId");


--
-- Name: OrganisationGroupMember_organisationMemberId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "OrganisationGroupMember_organisationMemberId_idx" ON public."OrganisationGroupMember" USING btree ("organisationMemberId");


--
-- Name: OrganisationGroup_organisationId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "OrganisationGroup_organisationId_idx" ON public."OrganisationGroup" USING btree ("organisationId");


--
-- Name: OrganisationMemberInvite_token_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "OrganisationMemberInvite_token_key" ON public."OrganisationMemberInvite" USING btree (token);


--
-- Name: OrganisationMember_organisationId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "OrganisationMember_organisationId_idx" ON public."OrganisationMember" USING btree ("organisationId");


--
-- Name: OrganisationMember_userId_organisationId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "OrganisationMember_userId_organisationId_key" ON public."OrganisationMember" USING btree ("userId", "organisationId");


--
-- Name: OrganisationMonthlyStat_organisationId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "OrganisationMonthlyStat_organisationId_idx" ON public."OrganisationMonthlyStat" USING btree ("organisationId");


--
-- Name: OrganisationMonthlyStat_organisationId_period_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "OrganisationMonthlyStat_organisationId_period_key" ON public."OrganisationMonthlyStat" USING btree ("organisationId", period);


--
-- Name: Organisation_customerId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "Organisation_customerId_key" ON public."Organisation" USING btree ("customerId");


--
-- Name: Organisation_name_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Organisation_name_idx" ON public."Organisation" USING btree (name);


--
-- Name: Organisation_organisationAuthenticationPortalId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "Organisation_organisationAuthenticationPortalId_key" ON public."Organisation" USING btree ("organisationAuthenticationPortalId");


--
-- Name: Organisation_organisationClaimId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "Organisation_organisationClaimId_key" ON public."Organisation" USING btree ("organisationClaimId");


--
-- Name: Organisation_organisationGlobalSettingsId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "Organisation_organisationGlobalSettingsId_key" ON public."Organisation" USING btree ("organisationGlobalSettingsId");


--
-- Name: Organisation_ownerUserId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Organisation_ownerUserId_idx" ON public."Organisation" USING btree ("ownerUserId");


--
-- Name: Organisation_url_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "Organisation_url_key" ON public."Organisation" USING btree (url);


--
-- Name: PasswordResetToken_token_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "PasswordResetToken_token_key" ON public."PasswordResetToken" USING btree (token);


--
-- Name: RateLimit_createdAt_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "RateLimit_createdAt_idx" ON public."RateLimit" USING btree ("createdAt");


--
-- Name: Recipient_email_documentDeletedAt_envelopeId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Recipient_email_documentDeletedAt_envelopeId_idx" ON public."Recipient" USING btree (email, "documentDeletedAt", "envelopeId");


--
-- Name: Recipient_email_envelopeId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Recipient_email_envelopeId_idx" ON public."Recipient" USING btree (email, "envelopeId");


--
-- Name: Recipient_email_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Recipient_email_idx" ON public."Recipient" USING btree (email);


--
-- Name: Recipient_email_signingStatus_envelopeId_role_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Recipient_email_signingStatus_envelopeId_role_idx" ON public."Recipient" USING btree (email, "signingStatus", "envelopeId", role);


--
-- Name: Recipient_email_trgm_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Recipient_email_trgm_idx" ON public."Recipient" USING gin (email public.gin_trgm_ops);


--
-- Name: Recipient_envelopeId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Recipient_envelopeId_idx" ON public."Recipient" USING btree ("envelopeId");


--
-- Name: Recipient_expiresAt_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Recipient_expiresAt_idx" ON public."Recipient" USING btree ("expiresAt");


--
-- Name: Recipient_name_trgm_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Recipient_name_trgm_idx" ON public."Recipient" USING gin (name public.gin_trgm_ops);


--
-- Name: Recipient_nextReminderAt_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Recipient_nextReminderAt_idx" ON public."Recipient" USING btree ("nextReminderAt");


--
-- Name: Recipient_signedAt_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Recipient_signedAt_idx" ON public."Recipient" USING btree ("signedAt");


--
-- Name: Recipient_token_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Recipient_token_idx" ON public."Recipient" USING btree (token);


--
-- Name: Session_sessionToken_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Session_sessionToken_idx" ON public."Session" USING btree ("sessionToken");


--
-- Name: Session_sessionToken_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "Session_sessionToken_key" ON public."Session" USING btree ("sessionToken");


--
-- Name: Session_userId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Session_userId_idx" ON public."Session" USING btree ("userId");


--
-- Name: Signature_fieldId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "Signature_fieldId_key" ON public."Signature" USING btree ("fieldId");


--
-- Name: Signature_recipientId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Signature_recipientId_idx" ON public."Signature" USING btree ("recipientId");


--
-- Name: Subscription_organisationId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Subscription_organisationId_idx" ON public."Subscription" USING btree ("organisationId");


--
-- Name: Subscription_organisationId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "Subscription_organisationId_key" ON public."Subscription" USING btree ("organisationId");


--
-- Name: Subscription_planId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "Subscription_planId_key" ON public."Subscription" USING btree ("planId");


--
-- Name: TeamEmailVerification_teamId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "TeamEmailVerification_teamId_key" ON public."TeamEmailVerification" USING btree ("teamId");


--
-- Name: TeamEmailVerification_token_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "TeamEmailVerification_token_key" ON public."TeamEmailVerification" USING btree (token);


--
-- Name: TeamEmail_email_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "TeamEmail_email_key" ON public."TeamEmail" USING btree (email);


--
-- Name: TeamEmail_teamId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "TeamEmail_teamId_key" ON public."TeamEmail" USING btree ("teamId");


--
-- Name: TeamGroup_organisationGroupId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "TeamGroup_organisationGroupId_idx" ON public."TeamGroup" USING btree ("organisationGroupId");


--
-- Name: TeamGroup_teamId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "TeamGroup_teamId_idx" ON public."TeamGroup" USING btree ("teamId");


--
-- Name: TeamGroup_teamId_organisationGroupId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "TeamGroup_teamId_organisationGroupId_key" ON public."TeamGroup" USING btree ("teamId", "organisationGroupId");


--
-- Name: TeamProfile_teamId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "TeamProfile_teamId_key" ON public."TeamProfile" USING btree ("teamId");


--
-- Name: Team_name_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Team_name_idx" ON public."Team" USING btree (name);


--
-- Name: Team_organisationId_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "Team_organisationId_idx" ON public."Team" USING btree ("organisationId");


--
-- Name: Team_teamGlobalSettingsId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "Team_teamGlobalSettingsId_key" ON public."Team" USING btree ("teamGlobalSettingsId");


--
-- Name: Team_url_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "Team_url_key" ON public."Team" USING btree (url);


--
-- Name: TemplateDirectLink_envelopeId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "TemplateDirectLink_envelopeId_key" ON public."TemplateDirectLink" USING btree ("envelopeId");


--
-- Name: TemplateDirectLink_id_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "TemplateDirectLink_id_key" ON public."TemplateDirectLink" USING btree (id);


--
-- Name: TemplateDirectLink_token_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "TemplateDirectLink_token_key" ON public."TemplateDirectLink" USING btree (token);


--
-- Name: User_email_idx; Type: INDEX; Schema: public; Owner: documenso
--

CREATE INDEX "User_email_idx" ON public."User" USING btree (email);


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: VerificationToken_secondaryId_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "VerificationToken_secondaryId_key" ON public."VerificationToken" USING btree ("secondaryId");


--
-- Name: VerificationToken_token_key; Type: INDEX; Schema: public; Owner: documenso
--

CREATE UNIQUE INDEX "VerificationToken_token_key" ON public."VerificationToken" USING btree (token);


--
-- Name: Account Account_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Account"
    ADD CONSTRAINT "Account_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ApiToken ApiToken_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."ApiToken"
    ADD CONSTRAINT "ApiToken_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ApiToken ApiToken_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."ApiToken"
    ADD CONSTRAINT "ApiToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BackgroundJobTask BackgroundJobTask_jobId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."BackgroundJobTask"
    ADD CONSTRAINT "BackgroundJobTask_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES public."BackgroundJob"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CscCredential CscCredential_recipientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."CscCredential"
    ADD CONSTRAINT "CscCredential_recipientId_fkey" FOREIGN KEY ("recipientId") REFERENCES public."Recipient"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CscSession CscSession_recipientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."CscSession"
    ADD CONSTRAINT "CscSession_recipientId_fkey" FOREIGN KEY ("recipientId") REFERENCES public."Recipient"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DocumentAuditLog DocumentAuditLog_envelopeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."DocumentAuditLog"
    ADD CONSTRAINT "DocumentAuditLog_envelopeId_fkey" FOREIGN KEY ("envelopeId") REFERENCES public."Envelope"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: DocumentShareLink DocumentShareLink_envelopeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."DocumentShareLink"
    ADD CONSTRAINT "DocumentShareLink_envelopeId_fkey" FOREIGN KEY ("envelopeId") REFERENCES public."Envelope"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: EmailDomain EmailDomain_organisationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."EmailDomain"
    ADD CONSTRAINT "EmailDomain_organisationId_fkey" FOREIGN KEY ("organisationId") REFERENCES public."Organisation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: EnvelopeAttachment EnvelopeAttachment_envelopeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."EnvelopeAttachment"
    ADD CONSTRAINT "EnvelopeAttachment_envelopeId_fkey" FOREIGN KEY ("envelopeId") REFERENCES public."Envelope"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: EnvelopeItem EnvelopeItem_documentDataId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."EnvelopeItem"
    ADD CONSTRAINT "EnvelopeItem_documentDataId_fkey" FOREIGN KEY ("documentDataId") REFERENCES public."DocumentData"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: EnvelopeItem EnvelopeItem_envelopeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."EnvelopeItem"
    ADD CONSTRAINT "EnvelopeItem_envelopeId_fkey" FOREIGN KEY ("envelopeId") REFERENCES public."Envelope"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Envelope Envelope_documentMetaId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Envelope"
    ADD CONSTRAINT "Envelope_documentMetaId_fkey" FOREIGN KEY ("documentMetaId") REFERENCES public."DocumentMeta"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Envelope Envelope_folderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Envelope"
    ADD CONSTRAINT "Envelope_folderId_fkey" FOREIGN KEY ("folderId") REFERENCES public."Folder"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Envelope Envelope_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Envelope"
    ADD CONSTRAINT "Envelope_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Envelope Envelope_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Envelope"
    ADD CONSTRAINT "Envelope_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Field Field_envelopeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Field"
    ADD CONSTRAINT "Field_envelopeId_fkey" FOREIGN KEY ("envelopeId") REFERENCES public."Envelope"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Field Field_envelopeItemId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Field"
    ADD CONSTRAINT "Field_envelopeItemId_fkey" FOREIGN KEY ("envelopeItemId") REFERENCES public."EnvelopeItem"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Field Field_recipientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Field"
    ADD CONSTRAINT "Field_recipientId_fkey" FOREIGN KEY ("recipientId") REFERENCES public."Recipient"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Folder Folder_parentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Folder"
    ADD CONSTRAINT "Folder_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES public."Folder"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Folder Folder_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Folder"
    ADD CONSTRAINT "Folder_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Folder Folder_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Folder"
    ADD CONSTRAINT "Folder_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrganisationClaim OrganisationClaim_emailTransportId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationClaim"
    ADD CONSTRAINT "OrganisationClaim_emailTransportId_fkey" FOREIGN KEY ("emailTransportId") REFERENCES public."EmailTransport"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: OrganisationEmail OrganisationEmail_emailDomainId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationEmail"
    ADD CONSTRAINT "OrganisationEmail_emailDomainId_fkey" FOREIGN KEY ("emailDomainId") REFERENCES public."EmailDomain"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrganisationEmail OrganisationEmail_organisationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationEmail"
    ADD CONSTRAINT "OrganisationEmail_organisationId_fkey" FOREIGN KEY ("organisationId") REFERENCES public."Organisation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrganisationGlobalSettings OrganisationGlobalSettings_emailId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationGlobalSettings"
    ADD CONSTRAINT "OrganisationGlobalSettings_emailId_fkey" FOREIGN KEY ("emailId") REFERENCES public."OrganisationEmail"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: OrganisationGroupMember OrganisationGroupMember_groupId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationGroupMember"
    ADD CONSTRAINT "OrganisationGroupMember_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES public."OrganisationGroup"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrganisationGroupMember OrganisationGroupMember_organisationMemberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationGroupMember"
    ADD CONSTRAINT "OrganisationGroupMember_organisationMemberId_fkey" FOREIGN KEY ("organisationMemberId") REFERENCES public."OrganisationMember"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrganisationGroup OrganisationGroup_organisationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationGroup"
    ADD CONSTRAINT "OrganisationGroup_organisationId_fkey" FOREIGN KEY ("organisationId") REFERENCES public."Organisation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrganisationMemberInvite OrganisationMemberInvite_organisationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationMemberInvite"
    ADD CONSTRAINT "OrganisationMemberInvite_organisationId_fkey" FOREIGN KEY ("organisationId") REFERENCES public."Organisation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrganisationMember OrganisationMember_organisationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationMember"
    ADD CONSTRAINT "OrganisationMember_organisationId_fkey" FOREIGN KEY ("organisationId") REFERENCES public."Organisation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrganisationMember OrganisationMember_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationMember"
    ADD CONSTRAINT "OrganisationMember_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrganisationMonthlyStat OrganisationMonthlyStat_organisationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."OrganisationMonthlyStat"
    ADD CONSTRAINT "OrganisationMonthlyStat_organisationId_fkey" FOREIGN KEY ("organisationId") REFERENCES public."Organisation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Organisation Organisation_avatarImageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Organisation"
    ADD CONSTRAINT "Organisation_avatarImageId_fkey" FOREIGN KEY ("avatarImageId") REFERENCES public."AvatarImage"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Organisation Organisation_organisationAuthenticationPortalId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Organisation"
    ADD CONSTRAINT "Organisation_organisationAuthenticationPortalId_fkey" FOREIGN KEY ("organisationAuthenticationPortalId") REFERENCES public."OrganisationAuthenticationPortal"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Organisation Organisation_organisationClaimId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Organisation"
    ADD CONSTRAINT "Organisation_organisationClaimId_fkey" FOREIGN KEY ("organisationClaimId") REFERENCES public."OrganisationClaim"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Organisation Organisation_organisationGlobalSettingsId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Organisation"
    ADD CONSTRAINT "Organisation_organisationGlobalSettingsId_fkey" FOREIGN KEY ("organisationGlobalSettingsId") REFERENCES public."OrganisationGlobalSettings"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Organisation Organisation_ownerUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Organisation"
    ADD CONSTRAINT "Organisation_ownerUserId_fkey" FOREIGN KEY ("ownerUserId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Passkey Passkey_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Passkey"
    ADD CONSTRAINT "Passkey_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PasswordResetToken PasswordResetToken_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."PasswordResetToken"
    ADD CONSTRAINT "PasswordResetToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Recipient Recipient_envelopeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Recipient"
    ADD CONSTRAINT "Recipient_envelopeId_fkey" FOREIGN KEY ("envelopeId") REFERENCES public."Envelope"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Session Session_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Session"
    ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Signature Signature_fieldId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Signature"
    ADD CONSTRAINT "Signature_fieldId_fkey" FOREIGN KEY ("fieldId") REFERENCES public."Field"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Signature Signature_recipientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Signature"
    ADD CONSTRAINT "Signature_recipientId_fkey" FOREIGN KEY ("recipientId") REFERENCES public."Recipient"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SiteSettings SiteSettings_lastModifiedByUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."SiteSettings"
    ADD CONSTRAINT "SiteSettings_lastModifiedByUserId_fkey" FOREIGN KEY ("lastModifiedByUserId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SubscriptionClaim SubscriptionClaim_emailTransportId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."SubscriptionClaim"
    ADD CONSTRAINT "SubscriptionClaim_emailTransportId_fkey" FOREIGN KEY ("emailTransportId") REFERENCES public."EmailTransport"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Subscription Subscription_organisationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Subscription"
    ADD CONSTRAINT "Subscription_organisationId_fkey" FOREIGN KEY ("organisationId") REFERENCES public."Organisation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TeamEmailVerification TeamEmailVerification_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."TeamEmailVerification"
    ADD CONSTRAINT "TeamEmailVerification_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TeamEmail TeamEmail_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."TeamEmail"
    ADD CONSTRAINT "TeamEmail_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TeamGlobalSettings TeamGlobalSettings_emailId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."TeamGlobalSettings"
    ADD CONSTRAINT "TeamGlobalSettings_emailId_fkey" FOREIGN KEY ("emailId") REFERENCES public."OrganisationEmail"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: TeamGroup TeamGroup_organisationGroupId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."TeamGroup"
    ADD CONSTRAINT "TeamGroup_organisationGroupId_fkey" FOREIGN KEY ("organisationGroupId") REFERENCES public."OrganisationGroup"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TeamGroup TeamGroup_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."TeamGroup"
    ADD CONSTRAINT "TeamGroup_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TeamProfile TeamProfile_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."TeamProfile"
    ADD CONSTRAINT "TeamProfile_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Team Team_avatarImageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Team"
    ADD CONSTRAINT "Team_avatarImageId_fkey" FOREIGN KEY ("avatarImageId") REFERENCES public."AvatarImage"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Team Team_organisationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Team"
    ADD CONSTRAINT "Team_organisationId_fkey" FOREIGN KEY ("organisationId") REFERENCES public."Organisation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Team Team_teamGlobalSettingsId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Team"
    ADD CONSTRAINT "Team_teamGlobalSettingsId_fkey" FOREIGN KEY ("teamGlobalSettingsId") REFERENCES public."TeamGlobalSettings"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TemplateDirectLink TemplateDirectLink_envelopeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."TemplateDirectLink"
    ADD CONSTRAINT "TemplateDirectLink_envelopeId_fkey" FOREIGN KEY ("envelopeId") REFERENCES public."Envelope"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserSecurityAuditLog UserSecurityAuditLog_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."UserSecurityAuditLog"
    ADD CONSTRAINT "UserSecurityAuditLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: User User_avatarImageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_avatarImageId_fkey" FOREIGN KEY ("avatarImageId") REFERENCES public."AvatarImage"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: VerificationToken VerificationToken_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."VerificationToken"
    ADD CONSTRAINT "VerificationToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WebhookCall WebhookCall_webhookId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."WebhookCall"
    ADD CONSTRAINT "WebhookCall_webhookId_fkey" FOREIGN KEY ("webhookId") REFERENCES public."Webhook"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Webhook Webhook_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Webhook"
    ADD CONSTRAINT "Webhook_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Webhook Webhook_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: documenso
--

ALTER TABLE ONLY public."Webhook"
    ADD CONSTRAINT "Webhook_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


