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
-- Name: AccessScope; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."AccessScope" AS ENUM (
    'READ_BOOKING',
    'READ_PROFILE'
);


--
-- Name: AppCategories; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."AppCategories" AS ENUM (
    'calendar',
    'messaging',
    'other',
    'payment',
    'video',
    'web3',
    'automation',
    'analytics',
    'conferencing',
    'crm'
);


--
-- Name: AssignmentReasonEnum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."AssignmentReasonEnum" AS ENUM (
    'ROUTING_FORM_ROUTING',
    'ROUTING_FORM_ROUTING_FALLBACK',
    'REASSIGNED',
    'REROUTED',
    'SALESFORCE_ASSIGNMENT',
    'RR_REASSIGNED'
);


--
-- Name: AttributeType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."AttributeType" AS ENUM (
    'TEXT',
    'NUMBER',
    'SINGLE_SELECT',
    'MULTI_SELECT'
);


--
-- Name: AuditActorType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."AuditActorType" AS ENUM (
    'user',
    'guest',
    'attendee',
    'system',
    'app'
);


--
-- Name: BillingMode; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."BillingMode" AS ENUM (
    'SEATS',
    'ACTIVE_USERS'
);


--
-- Name: BillingPeriod; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."BillingPeriod" AS ENUM (
    'MONTHLY',
    'ANNUALLY'
);


--
-- Name: BookingAuditAction; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."BookingAuditAction" AS ENUM (
    'created',
    'cancelled',
    'accepted',
    'rejected',
    'pending',
    'awaiting_host',
    'rescheduled',
    'attendee_added',
    'attendee_removed',
    'reassignment',
    'location_changed',
    'no_show_updated',
    'reschedule_requested',
    'seat_booked',
    'seat_rescheduled'
);


--
-- Name: BookingAuditSource; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."BookingAuditSource" AS ENUM (
    'api_v1',
    'api_v2',
    'webapp',
    'webhook',
    'unknown',
    'magic_link',
    'system'
);


--
-- Name: BookingAuditType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."BookingAuditType" AS ENUM (
    'record_created',
    'record_updated',
    'record_deleted'
);


--
-- Name: BookingReportReason; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."BookingReportReason" AS ENUM (
    'SPAM',
    'dont_know_person',
    'OTHER'
);


--
-- Name: BookingReportStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."BookingReportStatus" AS ENUM (
    'PENDING',
    'DISMISSED',
    'BLOCKED'
);


--
-- Name: BookingStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."BookingStatus" AS ENUM (
    'cancelled',
    'accepted',
    'rejected',
    'pending',
    'awaiting_host'
);


--
-- Name: CalendarCacheEventStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CalendarCacheEventStatus" AS ENUM (
    'confirmed',
    'tentative',
    'cancelled'
);


--
-- Name: CancellationReasonRequirement; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CancellationReasonRequirement" AS ENUM (
    'MANDATORY_BOTH',
    'MANDATORY_HOST_ONLY',
    'MANDATORY_ATTENDEE_ONLY',
    'OPTIONAL_BOTH'
);


--
-- Name: CreationSource; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CreationSource" AS ENUM (
    'api_v1',
    'api_v2',
    'webapp'
);


--
-- Name: CreditType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CreditType" AS ENUM (
    'MONTHLY',
    'ADDITIONAL'
);


--
-- Name: CreditUsageType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CreditUsageType" AS ENUM (
    'SMS',
    'CAL_AI_PHONE_CALL'
);


--
-- Name: EventTypeAutoTranslatedField; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."EventTypeAutoTranslatedField" AS ENUM (
    'DESCRIPTION',
    'TITLE'
);


--
-- Name: EventTypeCustomInputType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."EventTypeCustomInputType" AS ENUM (
    'text',
    'textLong',
    'number',
    'bool',
    'phone',
    'radio'
);


--
-- Name: FeatureType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."FeatureType" AS ENUM (
    'RELEASE',
    'EXPERIMENT',
    'OPERATIONAL',
    'KILL_SWITCH',
    'PERMISSION'
);


--
-- Name: FilterSegmentScope; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."FilterSegmentScope" AS ENUM (
    'USER',
    'TEAM'
);


--
-- Name: IdentityProvider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."IdentityProvider" AS ENUM (
    'CAL',
    'GOOGLE',
    'SAML'
);


--
-- Name: IncompleteBookingActionType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."IncompleteBookingActionType" AS ENUM (
    'SALESFORCE'
);


--
-- Name: MembershipRole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."MembershipRole" AS ENUM (
    'MEMBER',
    'OWNER',
    'ADMIN'
);


--
-- Name: OAuthClientStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."OAuthClientStatus" AS ENUM (
    'pending',
    'approved',
    'rejected'
);


--
-- Name: OAuthClientType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."OAuthClientType" AS ENUM (
    'confidential',
    'public'
);


--
-- Name: PaymentOption; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."PaymentOption" AS ENUM (
    'ON_BOOKING',
    'HOLD'
);


--
-- Name: PeriodType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."PeriodType" AS ENUM (
    'unlimited',
    'rolling',
    'range',
    'rolling_window'
);


--
-- Name: PhoneNumberSubscriptionStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."PhoneNumberSubscriptionStatus" AS ENUM (
    'ACTIVE',
    'PAST_DUE',
    'CANCELLED',
    'INCOMPLETE',
    'INCOMPLETE_EXPIRED',
    'TRIALING',
    'UNPAID'
);


--
-- Name: ProrationStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ProrationStatus" AS ENUM (
    'PENDING',
    'INVOICE_CREATED',
    'CHARGED',
    'FAILED',
    'CANCELLED'
);


--
-- Name: RRResetInterval; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."RRResetInterval" AS ENUM (
    'MONTH',
    'DAY'
);


--
-- Name: RRTimestampBasis; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."RRTimestampBasis" AS ENUM (
    'CREATED_AT',
    'START_TIME'
);


--
-- Name: RedirectType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."RedirectType" AS ENUM (
    'user-event-type',
    'team-event-type',
    'user',
    'team'
);


--
-- Name: ReminderType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ReminderType" AS ENUM (
    'PENDING_BOOKING_CONFIRMATION'
);


--
-- Name: RoleType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."RoleType" AS ENUM (
    'SYSTEM',
    'CUSTOM'
);


--
-- Name: SMSLockState; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."SMSLockState" AS ENUM (
    'LOCKED',
    'UNLOCKED',
    'REVIEW_NEEDED'
);


--
-- Name: SchedulingType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."SchedulingType" AS ENUM (
    'roundRobin',
    'collective',
    'managed'
);


--
-- Name: SeatChangeType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."SeatChangeType" AS ENUM (
    'ADDITION',
    'REMOVAL'
);


--
-- Name: SystemReportStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."SystemReportStatus" AS ENUM (
    'PENDING',
    'BLOCKED',
    'DISMISSED'
);


--
-- Name: TimeUnit; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."TimeUnit" AS ENUM (
    'day',
    'hour',
    'minute'
);


--
-- Name: UserPermissionRole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."UserPermissionRole" AS ENUM (
    'USER',
    'ADMIN'
);


--
-- Name: WatchlistAction; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WatchlistAction" AS ENUM (
    'REPORT',
    'BLOCK',
    'ALERT'
);


--
-- Name: WatchlistSource; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WatchlistSource" AS ENUM (
    'MANUAL',
    'FREE_DOMAIN_POLICY',
    'SIGNUP'
);


--
-- Name: WatchlistType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WatchlistType" AS ENUM (
    'EMAIL',
    'DOMAIN',
    'USERNAME'
);


--
-- Name: WebhookTriggerEvents; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WebhookTriggerEvents" AS ENUM (
    'BOOKING_CREATED',
    'BOOKING_RESCHEDULED',
    'BOOKING_CANCELLED',
    'FORM_SUBMITTED',
    'MEETING_ENDED',
    'RECORDING_READY',
    'BOOKING_PAID',
    'BOOKING_REQUESTED',
    'BOOKING_REJECTED',
    'BOOKING_PAYMENT_INITIATED',
    'MEETING_STARTED',
    'INSTANT_MEETING',
    'OOO_CREATED',
    'BOOKING_NO_SHOW_UPDATED',
    'RECORDING_TRANSCRIPTION_GENERATED',
    'AFTER_HOSTS_CAL_VIDEO_NO_SHOW',
    'AFTER_GUESTS_CAL_VIDEO_NO_SHOW',
    'FORM_SUBMITTED_NO_EVENT',
    'DELEGATION_CREDENTIAL_ERROR',
    'WRONG_ASSIGNMENT_REPORT',
    'ROUTING_FORM_FALLBACK_HIT'
);


--
-- Name: WorkflowActions; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WorkflowActions" AS ENUM (
    'EMAIL_HOST',
    'EMAIL_ATTENDEE',
    'SMS_ATTENDEE',
    'SMS_NUMBER',
    'EMAIL_ADDRESS',
    'WHATSAPP_ATTENDEE',
    'WHATSAPP_NUMBER',
    'CAL_AI_PHONE_CALL'
);


--
-- Name: WorkflowContactType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WorkflowContactType" AS ENUM (
    'PHONE',
    'EMAIL'
);


--
-- Name: WorkflowMethods; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WorkflowMethods" AS ENUM (
    'EMAIL',
    'SMS',
    'WHATSAPP',
    'AI_PHONE_CALL'
);


--
-- Name: WorkflowStepAutoTranslatedField; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WorkflowStepAutoTranslatedField" AS ENUM (
    'REMINDER_BODY',
    'EMAIL_SUBJECT'
);


--
-- Name: WorkflowTemplates; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WorkflowTemplates" AS ENUM (
    'REMINDER',
    'CUSTOM',
    'CANCELLED',
    'RESCHEDULED',
    'COMPLETED',
    'RATING'
);


--
-- Name: WorkflowTriggerEvents; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WorkflowTriggerEvents" AS ENUM (
    'BEFORE_EVENT',
    'EVENT_CANCELLED',
    'NEW_EVENT',
    'RESCHEDULE_EVENT',
    'AFTER_EVENT',
    'AFTER_HOSTS_CAL_VIDEO_NO_SHOW',
    'AFTER_GUESTS_CAL_VIDEO_NO_SHOW',
    'BOOKING_REJECTED',
    'BOOKING_REQUESTED',
    'BOOKING_PAYMENT_INITIATED',
    'BOOKING_PAID',
    'BOOKING_NO_SHOW_UPDATED',
    'FORM_SUBMITTED',
    'FORM_SUBMITTED_NO_EVENT'
);


--
-- Name: WorkflowType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WorkflowType" AS ENUM (
    'EVENT_TYPE',
    'ROUTING_FORM'
);


--
-- Name: WrongAssignmentReportStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WrongAssignmentReportStatus" AS ENUM (
    'PENDING',
    'REVIEWED',
    'RESOLVED',
    'DISMISSED'
);


--
-- Name: _process_routing_form_response_fields(integer, jsonb, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._process_routing_form_response_fields(response_id integer, response_data jsonb, form_id text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    form_fields jsonb;
    field_record jsonb;
    response_field jsonb;
    field_type text;
BEGIN
    -- Validate response_data exists and is a valid JSON object
    IF response_data IS NULL OR jsonb_typeof(response_data) != 'object' THEN
        RAISE WARNING 'Invalid response data for id %. Type: %', response_id, COALESCE(jsonb_typeof(response_data), 'null');
        RETURN;
    END IF;
    
    -- Get the fields from App_RoutingForms_Form
    SELECT fields::jsonb INTO form_fields
    FROM "App_RoutingForms_Form"
    WHERE id = form_id;
    
    -- Delete existing entries for this response
    DELETE FROM "RoutingFormResponseField"
    WHERE "responseId" = response_id;
    
    -- Exit early if form_fields is NULL or not an array
    IF form_fields IS NULL OR jsonb_typeof(form_fields) != 'array' THEN
        RAISE WARNING 'form_fields is NULL or not an array for formId %, skipping processing', form_id;
        RETURN;
    END IF;
    
    -- Iterate through each field in the response
    FOR field_record IN SELECT * FROM jsonb_array_elements(form_fields)
    LOOP
        BEGIN
            -- Validate field_record has required properties
            IF field_record->>'id' IS NULL THEN
                RAISE WARNING 'Field record is missing id property, skipping field';
                CONTINUE;
            END IF;
            IF field_record->>'type' IS NULL THEN
                RAISE WARNING 'Field record % is missing type property, skipping field', field_record->>'id';
                CONTINUE;
            END IF;
            
            -- Get the response field object for this field
            response_field := response_data->(field_record->>'id');
            
            -- Skip if no response for this field
            IF response_field IS NULL THEN
                CONTINUE;
            END IF;
            
            -- Get field type
            field_type := field_record->>'type';
            
            -- Insert new record based on field type
            IF field_type = 'multiselect' THEN
                -- Handle array values for multiselect
                -- Accept both array values and string values
                IF response_field->>'value' IS NOT NULL THEN
                    BEGIN
                        IF jsonb_typeof(response_field->'value') = 'array' THEN
                            -- If it's already an array, use it directly
                            INSERT INTO "RoutingFormResponseField" ("responseId", "fieldId", "valueStringArray")
                            VALUES (
                                response_id,
                                field_record->>'id',
                                ARRAY(SELECT jsonb_array_elements_text(response_field->'value'))
                            );
                        ELSIF jsonb_typeof(response_field->'value') = 'string' THEN
                            -- If it's a string, convert it to a single-element array
                            INSERT INTO "RoutingFormResponseField" ("responseId", "fieldId", "valueStringArray")
                            VALUES (
                                response_id,
                                field_record->>'id',
                                ARRAY[response_field->>'value']
                            );
                        END IF;
                    EXCEPTION WHEN OTHERS THEN
                        RAISE WARNING 'Failed to insert multiselect values for field %', field_record->>'id';
                    END;
                END IF;
            ELSIF field_type = 'number' THEN
                -- Handle number values
                -- Accept both JSON number values and string values that can be converted to numbers
                IF response_field->>'value' IS NOT NULL THEN
                    BEGIN
                        IF jsonb_typeof(response_field->'value') = 'number' THEN
                            -- If it's already a JSON number, use it directly
                            INSERT INTO "RoutingFormResponseField" ("responseId", "fieldId", "valueNumber")
                            VALUES (
                                response_id,
                                field_record->>'id',
                                (response_field->>'value')::decimal
                            );
                        ELSIF jsonb_typeof(response_field->'value') = 'string' THEN
                            -- If it's a string, try to convert it to a number
                            INSERT INTO "RoutingFormResponseField" ("responseId", "fieldId", "valueNumber")
                            VALUES (
                                response_id,
                                field_record->>'id',
                                (response_field->>'value')::decimal
                            );
                        END IF;
                    EXCEPTION WHEN OTHERS THEN
                        RAISE WARNING 'Failed to insert number value for field % (value: %)', field_record->>'id', response_field->>'value';
                    END;
                END IF;
            ELSIF field_type = 'select' THEN
                -- Handle select values - can be either string or array
                IF response_field->>'value' IS NOT NULL THEN
                    BEGIN
                        IF jsonb_typeof(response_field->'value') = 'array' THEN
                            -- If it's an array, take the first element
                            INSERT INTO "RoutingFormResponseField" ("responseId", "fieldId", "valueString")
                            VALUES (
                                response_id,
                                field_record->>'id',
                                (response_field->'value'->>0)
                            );
                        ELSIF jsonb_typeof(response_field->'value') = 'string' THEN
                            -- If it's a string, use it directly
                            INSERT INTO "RoutingFormResponseField" ("responseId", "fieldId", "valueString")
                            VALUES (
                                response_id,
                                field_record->>'id',
                                response_field->>'value'
                            );
                        END IF;
                    EXCEPTION WHEN OTHERS THEN
                        RAISE WARNING 'Failed to insert select value for field %', field_record->>'id';
                    END;
                END IF;
            ELSE
                -- Handle all other types as strings
                -- Only insert if value is not null and is a valid string
                IF response_field->>'value' IS NOT NULL AND jsonb_typeof(response_field->'value') = 'string' THEN
                    BEGIN
                        INSERT INTO "RoutingFormResponseField" ("responseId", "fieldId", "valueString")
                        VALUES (
                            response_id,
                            field_record->>'id',
                            response_field->>'value'
                        );
                    EXCEPTION WHEN OTHERS THEN
                        RAISE WARNING 'Failed to insert string value for field %', field_record->>'id';
                    END;
                END IF;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            -- Log the error and continue processing other fields
            RAISE WARNING 'Error processing field %', field_record->>'id';
            CONTINUE;
        END;
    END LOOP;
EXCEPTION WHEN OTHERS THEN
    -- Log any unhandled errors and continue
    RAISE WARNING 'Unhandled error in _process_routing_form_response_fields for response %', response_id;
END;
$$;


--
-- Name: calculate_booking_status_order(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_booking_status_order(status text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN CASE status
        WHEN 'accepted' THEN 1
        WHEN 'pending' THEN 2
        WHEN 'awaiting_host' THEN 3
        WHEN 'cancelled' THEN 4
        WHEN 'rejected' THEN 5
        ELSE 999  -- Default to end of sort order for unknown statuses
    END;
END;
$$;


--
-- Name: calculate_is_team_booking(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_is_team_booking(team_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN team_id IS NOT NULL;
END;
$$;


--
-- Name: handle_routing_form_response_fields(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_routing_form_response_fields() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    response_data jsonb;
    form_id text;
BEGIN
    -- For INSERT trigger on RoutingFormResponseDenormalized, we need to get the response data from App_RoutingForms_FormResponse
    -- For UPDATE trigger on App_RoutingForms_FormResponse, we can use NEW.response directly
    IF TG_TABLE_NAME = 'RoutingFormResponseDenormalized' THEN
        SELECT response, "formId" INTO response_data, form_id
        FROM "App_RoutingForms_FormResponse"
        WHERE id = NEW.id;
    ELSE
        response_data := NEW.response::jsonb;
        form_id := NEW."formId";
    END IF;
    
    -- Call the shared core function
    PERFORM _process_routing_form_response_fields(NEW.id, response_data, form_id);
    
    RETURN NEW;
END;
$$;


--
-- Name: refresh_booking_time_status_denormalized(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.refresh_booking_time_status_denormalized(booking_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Delete existing entry if any
    DELETE FROM "BookingDenormalized" WHERE id = booking_id;

    -- Insert a denormalized booking joined with EventType and user
    INSERT INTO "BookingDenormalized" (
        id,
        uid,
        "eventTypeId",
        title,
        description,
        "startTime",
        "endTime",
        "createdAt",
        "updatedAt",
        location,
        paid,
        status,
        rescheduled,
        "userId",
        "teamId",
        "eventLength",
        "eventParentId",
        "userEmail",
        "userName",
        "userUsername",
        "ratingFeedback",
        "rating",
        "noShowHost",
        "isTeamBooking"
    )
    SELECT
        "Booking".id,
        "Booking".uid,
        "Booking"."eventTypeId",
        "Booking".title,
        "Booking".description,
        "Booking"."startTime",
        "Booking"."endTime",
        "Booking"."createdAt",
        "Booking"."updatedAt",
        "Booking".location,
        "Booking".paid,
        "Booking".status,
        "Booking".rescheduled,
        "Booking"."userId",
        et."teamId",
        et.length AS "eventLength",
        et."parentId" AS "eventParentId",
        "u"."email" AS "userEmail",
        "u"."name" AS "userName",
        "u"."username" AS "userUsername",
        "Booking"."ratingFeedback",
        "Booking"."rating",
        "Booking"."noShowHost",
        calculate_is_team_booking(et."teamId") as "isTeamBooking"
    FROM "Booking"
    LEFT JOIN "EventType" et ON "Booking"."eventTypeId" = et.id
    LEFT JOIN users u ON u.id = "Booking"."userId"
    WHERE "Booking".id = booking_id;
END;
$$;


--
-- Name: refresh_booking_time_status_length(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.refresh_booking_time_status_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE "BookingDenormalized" btsd
    SET "eventLength" = NEW.length
    WHERE btsd."eventTypeId" = NEW.id;
    RETURN NEW;
END;
$$;


--
-- Name: refresh_booking_time_status_parent_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.refresh_booking_time_status_parent_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE "BookingDenormalized" btsd
    SET "eventParentId" = NEW."parentId"
    WHERE btsd."eventTypeId" = NEW.id;
    RETURN NEW;
END;
$$;


--
-- Name: refresh_booking_time_status_team_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.refresh_booking_time_status_team_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE "BookingDenormalized" btsd
    SET
        "teamId" = NEW."teamId",
        "isTeamBooking" = calculate_is_team_booking(NEW."teamId")
    WHERE btsd."eventTypeId" = NEW.id;
    RETURN NEW;
END;
$$;


--
-- Name: refresh_routing_form_response_denormalized(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.refresh_routing_form_response_denormalized(response_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Delete existing entry if any
    DELETE FROM "RoutingFormResponseDenormalized" WHERE id = response_id;

    -- Insert form response with all related data
    INSERT INTO "RoutingFormResponseDenormalized" (
        id,
        "formId",
        "formName",
        "formTeamId",
        "formUserId",
        "bookingUid",
        "bookingId",
        "bookingStatus",
        "bookingStatusOrder",
        "bookingCreatedAt",
        "bookingStartTime",
        "bookingEndTime",
        "bookingUserId",
        "bookingUserName",
        "bookingUserEmail",
        "bookingUserAvatarUrl",
        "bookingAssignmentReason",
        "eventTypeId",
        "eventTypeParentId",
        "eventTypeSchedulingType",
        "createdAt",
        "utm_source",
        "utm_medium",
        "utm_campaign",
        "utm_term",
        "utm_content"
    )
    SELECT
        r.id,
        r."formId",
        f.name as "formName",
        f."teamId" as "formTeamId",
        f."userId" as "formUserId",
        b.uid as "bookingUid",
        b.id as "bookingId",
        b.status as "bookingStatus",
        calculate_booking_status_order(b.status::text) as "bookingStatusOrder",
        b."createdAt" as "bookingCreatedAt",
        b."startTime" as "bookingStartTime",
        b."endTime" as "bookingEndTime",
        b."userId" as "bookingUserId",
        u.name as "bookingUserName",
        u.email as "bookingUserEmail",
        u."avatarUrl" as "bookingUserAvatarUrl",
        COALESCE(
            (
                SELECT ar."reasonString"
                FROM "AssignmentReason" ar
                WHERE ar."bookingId" = b.id
                LIMIT 1
            ),
            ''
        ) as "bookingAssignmentReason",
        et.id as "eventTypeId",
        et."parentId" as "eventTypeParentId",
        et."schedulingType" as "eventTypeSchedulingType",
        r."createdAt",
        t.utm_source,
        t.utm_medium,
        t.utm_campaign,
        t.utm_term,
        t.utm_content
    FROM "App_RoutingForms_FormResponse" r
    INNER JOIN "App_RoutingForms_Form" f ON r."formId" = f.id
    LEFT JOIN "Booking" b ON b.uid = r."routedToBookingUid"
    LEFT JOIN "users" u ON b."userId" = u.id
    LEFT JOIN "EventType" et ON b."eventTypeId" = et.id
    LEFT JOIN "Tracking" t ON t."bookingId" = b.id
    WHERE r.id = response_id;
END;
$$;


--
-- Name: reprocess_routing_form_response_fields(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reprocess_routing_form_response_fields(response_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    response_data jsonb;
    form_id text;
BEGIN
    -- Get the response data and form ID from App_RoutingForms_FormResponse
    SELECT response, "formId" INTO response_data, form_id
    FROM "App_RoutingForms_FormResponse"
    WHERE id = response_id;
    
    -- Check if the response exists
    IF response_data IS NULL THEN
        RAISE EXCEPTION 'Response with id % not found', response_id;
    END IF;
    
    -- Call the shared core function
    PERFORM _process_routing_form_response_fields(response_id, response_data, form_id);
END;
$$;


--
-- Name: trigger_cleanup_routing_form_response_denormalized_assignment_r(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_cleanup_routing_form_response_denormalized_assignment_r() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Clear assignment reason for all responses linked to this booking
    UPDATE "RoutingFormResponseDenormalized" rfrd
    SET "bookingAssignmentReason" = NULL
    WHERE rfrd."bookingId" = OLD."bookingId";
    RETURN OLD;
END;
$$;


--
-- Name: trigger_cleanup_routing_form_response_denormalized_booking(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_cleanup_routing_form_response_denormalized_booking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Clear booking-related fields for all responses linked to this booking
    UPDATE "RoutingFormResponseDenormalized" rfrd
    SET
        "bookingUid" = NULL,
        "bookingId" = NULL,
        "bookingStatus" = NULL,
        "bookingStatusOrder" = NULL,
        "bookingCreatedAt" = NULL,
        "bookingStartTime" = NULL,
        "bookingEndTime" = NULL,
        "bookingUserId" = NULL,
        "bookingUserName" = NULL,
        "bookingUserEmail" = NULL,
        "bookingUserAvatarUrl" = NULL,
        "bookingAssignmentReason" = NULL,
        "eventTypeId" = NULL,
        "eventTypeParentId" = NULL,
        "eventTypeSchedulingType" = NULL,
        utm_source = NULL,
        utm_medium = NULL,
        utm_campaign = NULL,
        utm_term = NULL,
        utm_content = NULL
    WHERE rfrd."bookingId" = OLD.id;
    RETURN OLD;
END;
$$;


--
-- Name: trigger_cleanup_routing_form_response_denormalized_form(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_cleanup_routing_form_response_denormalized_form() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Delete all denormalized responses for this form
    DELETE FROM "RoutingFormResponseDenormalized"
    WHERE "formId" = OLD.id;
    RETURN OLD;
END;
$$;


--
-- Name: trigger_cleanup_routing_form_response_denormalized_tracking(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_cleanup_routing_form_response_denormalized_tracking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Clear tracking data for all responses linked to this booking
    UPDATE "RoutingFormResponseDenormalized" rfrd
    SET
        utm_source = NULL,
        utm_medium = NULL,
        utm_campaign = NULL,
        utm_term = NULL,
        utm_content = NULL
    WHERE rfrd."bookingId" = OLD."bookingId";
    RETURN OLD;
END;
$$;


--
-- Name: trigger_cleanup_routing_form_response_denormalized_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_cleanup_routing_form_response_denormalized_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Delete all responses where this user was the booking user
    DELETE FROM "RoutingFormResponseDenormalized"
    WHERE "bookingUserId" = OLD.id;
    RETURN OLD;
END;
$$;


--
-- Name: trigger_delete_booking_time_status_denormalized(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_delete_booking_time_status_denormalized() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    BEGIN
        DELETE FROM "BookingDenormalized" WHERE id = OLD.id;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'DENORM_ERROR: BookingDenormalized - Failed to delete denormalized booking id %', OLD.id;
    END;
    RETURN OLD;
END;
$$;


--
-- Name: trigger_delete_routing_form_response_denormalized(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_delete_routing_form_response_denormalized() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM "RoutingFormResponseDenormalized" WHERE id = OLD.id;
    RETURN OLD;
END;
$$;


--
-- Name: trigger_nullify_routing_form_response_denormalized_event_type(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_nullify_routing_form_response_denormalized_event_type() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE "RoutingFormResponseDenormalized"
  SET
    "eventTypeId" = NULL,
    "eventTypeParentId" = NULL,
    "eventTypeSchedulingType" = NULL
  WHERE "eventTypeId" = OLD.id;
  RETURN OLD;
END;
$$;


--
-- Name: trigger_refresh_booking_time_status_denormalized(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_refresh_booking_time_status_denormalized() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    BEGIN
        PERFORM refresh_booking_time_status_denormalized(NEW.id);
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'DENORM_ERROR: BookingDenormalized - Failed to handle booking change for id %', NEW.id;
    END;
    RETURN NEW;
END;
$$;


--
-- Name: trigger_refresh_booking_time_status_denormalized_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_refresh_booking_time_status_denormalized_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    BEGIN
        UPDATE "BookingDenormalized" btsd
        SET
            "userEmail" = NEW.email,
            "userName" = NEW.name,
            "userUsername" = NEW.username
        WHERE btsd."userId" = NEW.id;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'DENORM_ERROR: BookingDenormalized - Failed to update user changes for id %', NEW.id;
    END;
    RETURN NEW;
END;
$$;


--
-- Name: trigger_refresh_routing_form_response_denormalized(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_refresh_routing_form_response_denormalized() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    BEGIN
        PERFORM refresh_routing_form_response_denormalized(NEW.id);
    EXCEPTION WHEN OTHERS THEN
        -- Log the error but don't fail the original operation
        RAISE WARNING 'DENORM_ERROR: RoutingFormResponseDenormalized - refresh failed for response_id %', NEW.id;
    END;
    RETURN NEW;
END;
$$;


--
-- Name: trigger_refresh_routing_form_response_denormalized_assignment_r(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_refresh_routing_form_response_denormalized_assignment_r() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update all responses linked to this assignment reason through bookings
    UPDATE "RoutingFormResponseDenormalized" rfrd
    SET "bookingAssignmentReason" = NEW."reasonString"
    WHERE rfrd."bookingId" = NEW."bookingId";
    RETURN NEW;
END;
$$;


--
-- Name: trigger_refresh_routing_form_response_denormalized_booking(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_refresh_routing_form_response_denormalized_booking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update all responses linked to this booking
    UPDATE "RoutingFormResponseDenormalized" rfrd
    SET
        "bookingUserId" = NEW."userId",
        "bookingStatus" = NEW.status,
        "bookingStatusOrder" = calculate_booking_status_order(NEW.status::text),
        "bookingCreatedAt" = NEW."createdAt",
        "bookingStartTime" = NEW."startTime",
        "bookingEndTime" = NEW."endTime",
        "eventTypeId" = NEW."eventTypeId",
        "eventTypeParentId" = (
            SELECT et."parentId"
            FROM "EventType" et
            WHERE et.id = NEW."eventTypeId"
        ),
        "eventTypeSchedulingType" = (
            SELECT et."schedulingType"
            FROM "EventType" et
            WHERE et.id = NEW."eventTypeId"
        )
    WHERE rfrd."bookingId" = NEW.id;
    RETURN NEW;
END;
$$;


--
-- Name: trigger_refresh_routing_form_response_denormalized_event_type(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_refresh_routing_form_response_denormalized_event_type() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update all responses linked to this event type through bookings
    UPDATE "RoutingFormResponseDenormalized" rfrd
    SET
        "eventTypeParentId" = NEW."parentId",
        "eventTypeSchedulingType" = NEW."schedulingType"
    FROM "Booking" b
    WHERE b."eventTypeId" = NEW.id
    AND rfrd."bookingId" = b.id;
    RETURN NEW;
END;
$$;


--
-- Name: trigger_refresh_routing_form_response_denormalized_form_name(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_refresh_routing_form_response_denormalized_form_name() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update all responses for this form's name
    UPDATE "RoutingFormResponseDenormalized" rfrd
    SET "formName" = NEW.name
    WHERE rfrd."formId" = NEW.id;
    RETURN NEW;
END;
$$;


--
-- Name: trigger_refresh_routing_form_response_denormalized_form_team(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_refresh_routing_form_response_denormalized_form_team() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update all responses for this form's team
    UPDATE "RoutingFormResponseDenormalized" rfrd
    SET "formTeamId" = NEW."teamId"
    WHERE rfrd."formId" = NEW.id;
    RETURN NEW;
END;
$$;


--
-- Name: trigger_refresh_routing_form_response_denormalized_form_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_refresh_routing_form_response_denormalized_form_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update all responses for this form's user
    UPDATE "RoutingFormResponseDenormalized" rfrd
    SET "formUserId" = NEW."userId"
    WHERE rfrd."formId" = NEW.id;
    RETURN NEW;
END;
$$;


--
-- Name: trigger_refresh_routing_form_response_denormalized_tracking(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_refresh_routing_form_response_denormalized_tracking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update all responses linked to this tracking through bookings
    UPDATE "RoutingFormResponseDenormalized" rfrd
    SET
        utm_source = NEW.utm_source,
        utm_medium = NEW.utm_medium,
        utm_campaign = NEW.utm_campaign,
        utm_term = NEW.utm_term,
        utm_content = NEW.utm_content
    WHERE rfrd."bookingId" = NEW."bookingId";
    RETURN NEW;
END;
$$;


--
-- Name: trigger_refresh_routing_form_response_denormalized_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_refresh_routing_form_response_denormalized_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update all responses where this user is the booking user
    UPDATE "RoutingFormResponseDenormalized" rfrd
    SET
        "bookingUserName" = NEW.name,
        "bookingUserEmail" = NEW.email,
        "bookingUserAvatarUrl" = NEW."avatarUrl"
    WHERE rfrd."bookingUserId" = NEW.id;
    RETURN NEW;
END;
$$;


--
-- Name: update_membership_custom_role(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_membership_custom_role() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update customRoleId based on role
    CASE NEW.role
        WHEN 'OWNER' THEN
            NEW."customRoleId" := 'owner_role';
        WHEN 'ADMIN' THEN
            NEW."customRoleId" = 'admin_role';
        WHEN 'MEMBER' THEN
            NEW."customRoleId" = 'member_role';
        ELSE
            -- For any other role, keep the existing customRoleId
            NEW."customRoleId" = NEW."customRoleId";
    END CASE;

    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: AIPhoneCallConfiguration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AIPhoneCallConfiguration" (
    id integer NOT NULL,
    "eventTypeId" integer NOT NULL,
    "generalPrompt" text,
    "yourPhoneNumber" text NOT NULL,
    "numberToCall" text NOT NULL,
    "guestName" text,
    enabled boolean DEFAULT false NOT NULL,
    "beginMessage" text,
    "llmId" text,
    "guestCompany" text,
    "guestEmail" text,
    "schedulerName" text,
    "templateType" text DEFAULT 'CUSTOM_TEMPLATE'::text NOT NULL
);


--
-- Name: AIPhoneCallConfiguration_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."AIPhoneCallConfiguration_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: AIPhoneCallConfiguration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."AIPhoneCallConfiguration_id_seq" OWNED BY public."AIPhoneCallConfiguration".id;


--
-- Name: AccessCode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AccessCode" (
    id integer NOT NULL,
    code text NOT NULL,
    "clientId" text,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    scopes public."AccessScope"[],
    "userId" integer,
    "teamId" integer,
    "codeChallenge" text,
    "codeChallengeMethod" text DEFAULT 'S256'::text
);


--
-- Name: AccessCode_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."AccessCode_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: AccessCode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."AccessCode_id_seq" OWNED BY public."AccessCode".id;


--
-- Name: AccessToken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AccessToken" (
    id integer NOT NULL,
    secret text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "platformOAuthClientId" text NOT NULL,
    "userId" integer NOT NULL
);


--
-- Name: AccessToken_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."AccessToken_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: AccessToken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."AccessToken_id_seq" OWNED BY public."AccessToken".id;


--
-- Name: Account; Type: TABLE; Schema: public; Owner: -
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
    "providerEmail" text
);


--
-- Name: Agent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Agent" (
    id text NOT NULL,
    name text NOT NULL,
    "userId" integer,
    "teamId" integer,
    "providerAgentId" text NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "inboundEventTypeId" integer,
    "outboundEventTypeId" integer,
    CONSTRAINT "Agent_owner_check" CHECK ((("userId" IS NOT NULL) OR ("teamId" IS NOT NULL)))
);


--
-- Name: ApiKey; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ApiKey" (
    id text NOT NULL,
    "userId" integer NOT NULL,
    note text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "expiresAt" timestamp(3) without time zone,
    "lastUsedAt" timestamp(3) without time zone,
    "hashedKey" text NOT NULL,
    "appId" text,
    "teamId" integer
);


--
-- Name: App; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."App" (
    slug text NOT NULL,
    "dirName" text NOT NULL,
    keys jsonb,
    categories public."AppCategories"[],
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    enabled boolean DEFAULT false NOT NULL
);


--
-- Name: App_RoutingForms_Form; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."App_RoutingForms_Form" (
    id text NOT NULL,
    description text,
    routes jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    name text NOT NULL,
    fields jsonb,
    "userId" integer NOT NULL,
    disabled boolean DEFAULT false NOT NULL,
    settings jsonb,
    "teamId" integer,
    "position" integer DEFAULT 0 NOT NULL,
    "updatedById" integer
);


--
-- Name: App_RoutingForms_FormResponse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."App_RoutingForms_FormResponse" (
    id integer NOT NULL,
    "formFillerId" text NOT NULL,
    "formId" text NOT NULL,
    response jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "routedToBookingUid" text,
    "chosenRouteId" text,
    "updatedAt" timestamp(3) without time zone,
    uuid text
);


--
-- Name: App_RoutingForms_FormResponse_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."App_RoutingForms_FormResponse_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: App_RoutingForms_FormResponse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."App_RoutingForms_FormResponse_id_seq" OWNED BY public."App_RoutingForms_FormResponse".id;


--
-- Name: App_RoutingForms_IncompleteBookingActions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."App_RoutingForms_IncompleteBookingActions" (
    id integer NOT NULL,
    "formId" text NOT NULL,
    "actionType" public."IncompleteBookingActionType" NOT NULL,
    data jsonb NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    "credentialId" integer
);


--
-- Name: App_RoutingForms_IncompleteBookingActions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."App_RoutingForms_IncompleteBookingActions_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: App_RoutingForms_IncompleteBookingActions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."App_RoutingForms_IncompleteBookingActions_id_seq" OWNED BY public."App_RoutingForms_IncompleteBookingActions".id;


--
-- Name: App_RoutingForms_QueuedFormResponse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."App_RoutingForms_QueuedFormResponse" (
    id text NOT NULL,
    "formId" text NOT NULL,
    response jsonb NOT NULL,
    "chosenRouteId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone,
    "actualResponseId" integer,
    "fallbackAction" jsonb
);


--
-- Name: AssignmentReason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AssignmentReason" (
    id integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "bookingId" integer NOT NULL,
    "reasonEnum" public."AssignmentReasonEnum" NOT NULL,
    "reasonString" text NOT NULL
);


--
-- Name: AssignmentReason_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."AssignmentReason_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: AssignmentReason_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."AssignmentReason_id_seq" OWNED BY public."AssignmentReason".id;


--
-- Name: Attendee; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Attendee" (
    id integer NOT NULL,
    email text NOT NULL,
    name text NOT NULL,
    "timeZone" text NOT NULL,
    "bookingId" integer,
    locale text DEFAULT 'en'::text,
    "phoneNumber" text,
    "noShow" boolean DEFAULT false
);


--
-- Name: Attendee_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Attendee_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Attendee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Attendee_id_seq" OWNED BY public."Attendee".id;


--
-- Name: Attribute; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Attribute" (
    id text NOT NULL,
    "teamId" integer NOT NULL,
    type public."AttributeType" NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    "usersCanEditRelation" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "isWeightsEnabled" boolean DEFAULT false NOT NULL,
    "isLocked" boolean DEFAULT false NOT NULL
);


--
-- Name: AttributeOption; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AttributeOption" (
    id text NOT NULL,
    "attributeId" text NOT NULL,
    value text NOT NULL,
    slug text NOT NULL,
    contains text[],
    "isGroup" boolean DEFAULT false NOT NULL
);


--
-- Name: AttributeSyncFieldMapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AttributeSyncFieldMapping" (
    id text NOT NULL,
    "integrationFieldName" text NOT NULL,
    "attributeId" text NOT NULL,
    enabled boolean NOT NULL,
    "integrationAttributeSyncId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: AttributeSyncRule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AttributeSyncRule" (
    id text NOT NULL,
    "integrationAttributeSyncId" text NOT NULL,
    rule jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: AttributeToUser; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AttributeToUser" (
    id text NOT NULL,
    "memberId" integer NOT NULL,
    "attributeOptionId" text NOT NULL,
    weight integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "createdByDSyncId" text,
    "createdById" integer,
    "updatedAt" timestamp(3) without time zone,
    "updatedByDSyncId" text,
    "updatedById" integer
);


--
-- Name: AuditActor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AuditActor" (
    id uuid NOT NULL,
    type public."AuditActorType" NOT NULL,
    "userUuid" uuid,
    "attendeeId" integer,
    email text,
    phone text,
    name text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "credentialId" integer
);


--
-- Name: Availability; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Availability" (
    id integer NOT NULL,
    "userId" integer,
    "eventTypeId" integer,
    days integer[],
    date date,
    "startTime" time without time zone NOT NULL,
    "endTime" time without time zone NOT NULL,
    "scheduleId" integer
);


--
-- Name: Availability_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Availability_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Availability_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Availability_id_seq" OWNED BY public."Availability".id;


--
-- Name: Booking; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Booking" (
    id integer NOT NULL,
    uid text NOT NULL,
    "userId" integer,
    "eventTypeId" integer,
    title text NOT NULL,
    description text,
    "startTime" timestamp(3) without time zone NOT NULL,
    "endTime" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone,
    location text,
    paid boolean DEFAULT false NOT NULL,
    status public."BookingStatus" DEFAULT 'accepted'::public."BookingStatus" NOT NULL,
    "cancellationReason" text,
    "rejectionReason" text,
    "fromReschedule" text,
    rescheduled boolean,
    "dynamicEventSlugRef" text,
    "dynamicGroupSlugRef" text,
    "recurringEventId" text,
    "customInputs" jsonb,
    "smsReminderNumber" text,
    "destinationCalendarId" integer,
    "scheduledJobs" text[],
    metadata jsonb,
    responses jsonb,
    "isRecorded" boolean DEFAULT false NOT NULL,
    "iCalSequence" integer DEFAULT 0 NOT NULL,
    "iCalUID" text DEFAULT ''::text,
    "userPrimaryEmail" text,
    "idempotencyKey" text,
    "noShowHost" boolean DEFAULT false,
    rating integer,
    "ratingFeedback" text,
    "cancelledBy" text,
    "rescheduledBy" text,
    "oneTimePassword" text,
    "reassignReason" text,
    "reassignById" integer,
    "creationSource" public."CreationSource"
);


--
-- Name: BookingAudit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingAudit" (
    id uuid NOT NULL,
    "bookingUid" text NOT NULL,
    "actorId" uuid NOT NULL,
    type public."BookingAuditType" NOT NULL,
    action public."BookingAuditAction" NOT NULL,
    "timestamp" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    data jsonb,
    "operationId" text NOT NULL,
    source public."BookingAuditSource" NOT NULL,
    context jsonb
);


--
-- Name: BookingDenormalized; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingDenormalized" (
    id integer NOT NULL,
    uid text NOT NULL,
    "eventTypeId" integer,
    title text NOT NULL,
    description text,
    "startTime" timestamp(3) without time zone NOT NULL,
    "endTime" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone NOT NULL,
    "updatedAt" timestamp(3) without time zone,
    location text,
    paid boolean NOT NULL,
    status public."BookingStatus" NOT NULL,
    rescheduled boolean,
    "userId" integer,
    "teamId" integer,
    "eventLength" integer,
    "eventParentId" integer,
    "userEmail" text,
    "userName" text,
    "userUsername" text,
    "ratingFeedback" text,
    rating integer,
    "noShowHost" boolean,
    "isTeamBooking" boolean NOT NULL
);


--
-- Name: BookingInternalNote; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingInternalNote" (
    id integer NOT NULL,
    "notePresetId" integer,
    text text,
    "bookingId" integer NOT NULL,
    "createdById" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: BookingInternalNote_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."BookingInternalNote_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BookingInternalNote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."BookingInternalNote_id_seq" OWNED BY public."BookingInternalNote".id;


--
-- Name: BookingReference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingReference" (
    id integer NOT NULL,
    type text NOT NULL,
    uid text NOT NULL,
    "bookingId" integer,
    "meetingId" text,
    "meetingPassword" text,
    "meetingUrl" text,
    deleted boolean,
    "externalCalendarId" text,
    "credentialId" integer,
    "thirdPartyRecurringEventId" text,
    "domainWideDelegationCredentialId" text,
    "delegationCredentialId" text
);


--
-- Name: BookingReference_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."BookingReference_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BookingReference_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."BookingReference_id_seq" OWNED BY public."BookingReference".id;


--
-- Name: BookingReport; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingReport" (
    id uuid NOT NULL,
    "bookingUid" text NOT NULL,
    "bookerEmail" text NOT NULL,
    "reportedById" integer,
    "organizationId" integer,
    reason public."BookingReportReason" NOT NULL,
    description text,
    cancelled boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "watchlistId" uuid,
    status public."BookingReportStatus" DEFAULT 'PENDING'::public."BookingReportStatus" NOT NULL,
    "globalWatchlistId" uuid,
    "systemStatus" public."SystemReportStatus" DEFAULT 'PENDING'::public."SystemReportStatus" NOT NULL
);


--
-- Name: BookingSeat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingSeat" (
    id integer NOT NULL,
    "referenceUid" text NOT NULL,
    "bookingId" integer NOT NULL,
    "attendeeId" integer NOT NULL,
    data jsonb,
    metadata jsonb
);


--
-- Name: BookingSeat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."BookingSeat_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: BookingSeat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."BookingSeat_id_seq" OWNED BY public."BookingSeat".id;


--
-- Name: EventType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."EventType" (
    id integer NOT NULL,
    title text NOT NULL,
    slug text NOT NULL,
    description text,
    locations jsonb,
    length integer NOT NULL,
    hidden boolean DEFAULT false NOT NULL,
    "userId" integer,
    "eventName" text,
    "timeZone" text,
    "periodCountCalendarDays" boolean,
    "periodDays" integer,
    "periodEndDate" timestamp(3) without time zone,
    "periodStartDate" timestamp(3) without time zone,
    "requiresConfirmation" boolean DEFAULT false NOT NULL,
    "minimumBookingNotice" integer DEFAULT 120 NOT NULL,
    currency text DEFAULT 'usd'::text NOT NULL,
    price integer DEFAULT 0 NOT NULL,
    "schedulingType" public."SchedulingType",
    "teamId" integer,
    "disableGuests" boolean DEFAULT false NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    "periodType" public."PeriodType" DEFAULT 'unlimited'::public."PeriodType" NOT NULL,
    "slotInterval" integer,
    metadata jsonb,
    "afterEventBuffer" integer DEFAULT 0 NOT NULL,
    "beforeEventBuffer" integer DEFAULT 0 NOT NULL,
    "hideCalendarNotes" boolean DEFAULT false NOT NULL,
    "successRedirectUrl" text,
    "seatsPerTimeSlot" integer,
    "recurringEvent" jsonb,
    "scheduleId" integer,
    "bookingLimits" jsonb,
    "seatsShowAttendees" boolean DEFAULT false,
    "bookingFields" jsonb,
    "durationLimits" jsonb,
    "parentId" integer,
    "offsetStart" integer DEFAULT 0 NOT NULL,
    "requiresBookerEmailVerification" boolean DEFAULT false NOT NULL,
    "seatsShowAvailabilityCount" boolean DEFAULT true,
    "lockTimeZoneToggleOnBookingPage" boolean DEFAULT false NOT NULL,
    "onlyShowFirstAvailableSlot" boolean DEFAULT false NOT NULL,
    "isInstantEvent" boolean DEFAULT false NOT NULL,
    "assignAllTeamMembers" boolean DEFAULT false NOT NULL,
    "profileId" integer,
    "useEventTypeDestinationCalendarEmail" boolean DEFAULT false NOT NULL,
    "secondaryEmailId" integer,
    "forwardParamsSuccessRedirect" boolean DEFAULT true,
    "instantMeetingExpiryTimeOffsetInSeconds" integer DEFAULT 90 NOT NULL,
    "isRRWeightsEnabled" boolean DEFAULT false NOT NULL,
    "rescheduleWithSameRoundRobinHost" boolean DEFAULT false NOT NULL,
    "eventTypeColor" jsonb,
    "requiresConfirmationWillBlockSlot" boolean DEFAULT false NOT NULL,
    "instantMeetingScheduleId" integer,
    "showOptimizedSlots" boolean DEFAULT false,
    "hideCalendarEventDetails" boolean DEFAULT false NOT NULL,
    "assignRRMembersUsingSegment" boolean DEFAULT false NOT NULL,
    "rrSegmentQueryValue" jsonb,
    "maxLeadThreshold" integer,
    "instantMeetingParameters" text[],
    "autoTranslateDescriptionEnabled" boolean DEFAULT false NOT NULL,
    "requiresConfirmationForFreeEmail" boolean DEFAULT false NOT NULL,
    "useEventLevelSelectedCalendars" boolean DEFAULT false NOT NULL,
    "allowReschedulingPastBookings" boolean DEFAULT false NOT NULL,
    "interfaceLanguage" text,
    "canSendCalVideoTranscriptionEmails" boolean DEFAULT true NOT NULL,
    "disableCancelling" boolean DEFAULT false,
    "disableRescheduling" boolean DEFAULT false,
    "customReplyToEmail" text,
    "hideOrganizerEmail" boolean DEFAULT false NOT NULL,
    "includeNoShowInRRCalculation" boolean DEFAULT false NOT NULL,
    "restrictionScheduleId" integer,
    "useBookerTimezone" boolean DEFAULT false NOT NULL,
    "allowReschedulingCancelledBookings" boolean DEFAULT false,
    "maxActiveBookingsPerBooker" integer,
    "maxActiveBookingPerBookerOfferReschedule" boolean DEFAULT false NOT NULL,
    "lockedTimeZone" text,
    "bookingRequiresAuthentication" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp(3) without time zone,
    "autoTranslateInstantMeetingTitleEnabled" boolean DEFAULT true NOT NULL,
    "minimumRescheduleNotice" integer,
    "rrHostSubsetEnabled" boolean DEFAULT false NOT NULL,
    "requiresCancellationReason" public."CancellationReasonRequirement" DEFAULT 'MANDATORY_HOST_ONLY'::public."CancellationReasonRequirement",
    "enablePerHostLocations" boolean DEFAULT false NOT NULL,
    "redirectUrlOnNoRoutingFormResponse" text
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text,
    name text,
    email text NOT NULL,
    bio text,
    "timeZone" text DEFAULT 'Europe/London'::text NOT NULL,
    "weekStart" text DEFAULT 'Sunday'::text NOT NULL,
    created timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "bufferTime" integer DEFAULT 0 NOT NULL,
    "emailVerified" timestamp(3) without time zone,
    "hideBranding" boolean DEFAULT false NOT NULL,
    theme text,
    "completedOnboarding" boolean DEFAULT false NOT NULL,
    "twoFactorEnabled" boolean DEFAULT false NOT NULL,
    "twoFactorSecret" text,
    locale text,
    "brandColor" text,
    "identityProvider" public."IdentityProvider" DEFAULT 'CAL'::public."IdentityProvider" NOT NULL,
    "identityProviderId" text,
    "invitedTo" integer,
    metadata jsonb,
    verified boolean DEFAULT false,
    "timeFormat" integer DEFAULT 12,
    "darkBrandColor" text,
    "trialEndsAt" timestamp(3) without time zone,
    "defaultScheduleId" integer,
    "allowDynamicBooking" boolean DEFAULT true,
    role public."UserPermissionRole" DEFAULT 'USER'::public."UserPermissionRole" NOT NULL,
    "disableImpersonation" boolean DEFAULT false NOT NULL,
    "organizationId" integer,
    "allowSEOIndexing" boolean DEFAULT true,
    "backupCodes" text,
    "receiveMonthlyDigestEmail" boolean DEFAULT true,
    "avatarUrl" text,
    locked boolean DEFAULT false NOT NULL,
    "appTheme" text,
    "movedToProfileId" integer,
    "isPlatformManaged" boolean DEFAULT false NOT NULL,
    "smsLockState" public."SMSLockState" DEFAULT 'UNLOCKED'::public."SMSLockState" NOT NULL,
    "smsLockReviewedByAdmin" boolean DEFAULT false NOT NULL,
    "referralLinkId" text,
    "lastActiveAt" timestamp(3) without time zone,
    "creationSource" public."CreationSource",
    "whitelistWorkflows" boolean DEFAULT false NOT NULL,
    "requiresBookerEmailVerification" boolean DEFAULT false,
    uuid uuid NOT NULL,
    "autoOptInFeatures" boolean DEFAULT false NOT NULL
);


--
-- Name: BookingTimeStatus; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."BookingTimeStatus" AS
 SELECT "Booking".id,
    "Booking".uid,
    "Booking"."eventTypeId",
    "Booking".title,
    "Booking".description,
    "Booking"."startTime",
    "Booking"."endTime",
    "Booking"."createdAt",
    "Booking".location,
    "Booking".paid,
    "Booking".status,
    "Booking".rescheduled,
    "Booking"."userId",
    et."teamId",
    et.length AS "eventLength",
        CASE
            WHEN ("Booking".rescheduled IS TRUE) THEN 'rescheduled'::text
            WHEN (("Booking".status = 'cancelled'::public."BookingStatus") AND ("Booking".rescheduled IS NULL)) THEN 'cancelled'::text
            WHEN ("Booking"."endTime" < now()) THEN 'completed'::text
            WHEN ("Booking"."endTime" > now()) THEN 'uncompleted'::text
            ELSE NULL::text
        END AS "timeStatus",
    et."parentId" AS "eventParentId",
    u.email AS "userEmail",
    u.username,
    "Booking"."ratingFeedback",
    "Booking".rating,
    "Booking"."noShowHost",
    false AS "isTeamBooking"
   FROM ((public."Booking"
     LEFT JOIN public."EventType" et ON (("Booking"."eventTypeId" = et.id)))
     LEFT JOIN public.users u ON ((u.id = "Booking"."userId")))
  WHERE (et."teamId" IS NULL)
UNION
 SELECT "Booking".id,
    "Booking".uid,
    "Booking"."eventTypeId",
    "Booking".title,
    "Booking".description,
    "Booking"."startTime",
    "Booking"."endTime",
    "Booking"."createdAt",
    "Booking".location,
    "Booking".paid,
    "Booking".status,
    "Booking".rescheduled,
    "Booking"."userId",
    et."teamId",
    et.length AS "eventLength",
        CASE
            WHEN ("Booking".rescheduled IS TRUE) THEN 'rescheduled'::text
            WHEN (("Booking".status = 'cancelled'::public."BookingStatus") AND ("Booking".rescheduled IS NULL)) THEN 'cancelled'::text
            WHEN ("Booking"."endTime" < now()) THEN 'completed'::text
            WHEN ("Booking"."endTime" > now()) THEN 'uncompleted'::text
            ELSE NULL::text
        END AS "timeStatus",
    et."parentId" AS "eventParentId",
    u.email AS "userEmail",
    u.username,
    "Booking"."ratingFeedback",
    "Booking".rating,
    "Booking"."noShowHost",
    true AS "isTeamBooking"
   FROM ((public."Booking"
     LEFT JOIN public."EventType" et ON (("Booking"."eventTypeId" = et.id)))
     LEFT JOIN public.users u ON ((u.id = "Booking"."userId")))
  WHERE (et."teamId" IS NOT NULL);


--
-- Name: BookingTimeStatusDenormalized; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."BookingTimeStatusDenormalized" AS
 SELECT id,
    uid,
    "eventTypeId",
    title,
    description,
    "startTime",
    "endTime",
    "createdAt",
    "updatedAt",
    location,
    paid,
    status,
    rescheduled,
    "userId",
    "teamId",
    "eventLength",
    "eventParentId",
    "userEmail",
    "userName",
    "userUsername",
    "ratingFeedback",
    rating,
    "noShowHost",
    "isTeamBooking",
        CASE
            WHEN (rescheduled IS TRUE) THEN 'rescheduled'::text
            WHEN ((status = 'cancelled'::public."BookingStatus") AND (rescheduled IS NULL)) THEN 'cancelled'::text
            WHEN ("endTime" < now()) THEN 'completed'::text
            WHEN ("endTime" > now()) THEN 'uncompleted'::text
            ELSE NULL::text
        END AS "timeStatus"
   FROM public."BookingDenormalized";


--
-- Name: Booking_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Booking_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Booking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Booking_id_seq" OWNED BY public."Booking".id;


--
-- Name: CalAiPhoneNumber; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CalAiPhoneNumber" (
    id integer NOT NULL,
    "userId" integer,
    "teamId" integer,
    "phoneNumber" text NOT NULL,
    provider text NOT NULL,
    "providerPhoneNumberId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "stripeCustomerId" text,
    "stripeSubscriptionId" text,
    "subscriptionStatus" public."PhoneNumberSubscriptionStatus",
    "inboundAgentId" text,
    "outboundAgentId" text,
    CONSTRAINT "CalAiPhoneNumber_owner_check" CHECK ((("userId" IS NOT NULL) OR ("teamId" IS NOT NULL)))
);


--
-- Name: CalAiPhoneNumber_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."CalAiPhoneNumber_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: CalAiPhoneNumber_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."CalAiPhoneNumber_id_seq" OWNED BY public."CalAiPhoneNumber".id;


--
-- Name: CalVideoSettings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CalVideoSettings" (
    "eventTypeId" integer NOT NULL,
    "disableRecordingForOrganizer" boolean DEFAULT false NOT NULL,
    "disableRecordingForGuests" boolean DEFAULT false NOT NULL,
    "redirectUrlOnExit" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "enableAutomaticTranscription" boolean DEFAULT false NOT NULL,
    "disableTranscriptionForGuests" boolean DEFAULT false NOT NULL,
    "disableTranscriptionForOrganizer" boolean DEFAULT false NOT NULL,
    "enableAutomaticRecordingForOrganizer" boolean DEFAULT false NOT NULL,
    "requireEmailForGuests" boolean DEFAULT false NOT NULL
);


--
-- Name: CalendarCache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CalendarCache" (
    key text NOT NULL,
    value jsonb NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "credentialId" integer NOT NULL,
    id text,
    "userId" integer,
    "updatedAt" timestamp(3) without time zone DEFAULT now() NOT NULL
);


--
-- Name: CalendarCacheEvent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CalendarCacheEvent" (
    id text NOT NULL,
    "selectedCalendarId" text NOT NULL,
    "externalId" text NOT NULL,
    "externalEtag" text NOT NULL,
    "iCalUID" text,
    "iCalSequence" integer DEFAULT 0 NOT NULL,
    summary text,
    description text,
    location text,
    start timestamp(3) without time zone NOT NULL,
    "end" timestamp(3) without time zone NOT NULL,
    "isAllDay" boolean DEFAULT false NOT NULL,
    "timeZone" text,
    status public."CalendarCacheEventStatus" DEFAULT 'confirmed'::public."CalendarCacheEventStatus" NOT NULL,
    "recurringEventId" text,
    "originalStartTime" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "externalCreatedAt" timestamp(3) without time zone,
    "externalUpdatedAt" timestamp(3) without time zone
);


--
-- Name: Credential; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Credential" (
    id integer NOT NULL,
    type text NOT NULL,
    key jsonb NOT NULL,
    "userId" integer,
    "appId" text,
    invalid boolean DEFAULT false,
    "teamId" integer,
    "billingCycleStart" integer,
    "paymentStatus" text,
    "subscriptionId" text,
    "delegationCredentialId" text,
    "encryptedKey" text
);


--
-- Name: Credential_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Credential_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Credential_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Credential_id_seq" OWNED BY public."Credential".id;


--
-- Name: CreditBalance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CreditBalance" (
    id text NOT NULL,
    "teamId" integer,
    "userId" integer,
    "additionalCredits" integer DEFAULT 0 NOT NULL,
    "limitReachedAt" timestamp(3) without time zone,
    "warningSentAt" timestamp(3) without time zone
);


--
-- Name: CreditExpenseLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CreditExpenseLog" (
    id text NOT NULL,
    "creditBalanceId" text NOT NULL,
    "bookingUid" text,
    credits integer,
    "creditType" public."CreditType" NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    "smsSid" text,
    "smsSegments" integer,
    email text,
    "phoneNumber" text,
    "callDuration" integer,
    "externalRef" text,
    "creditFor" public."CreditUsageType",
    CONSTRAINT "CreditExpenseLog_cal_ai_phone_call_duration_required" CHECK ((("creditFor" <> 'CAL_AI_PHONE_CALL'::public."CreditUsageType") OR ("callDuration" IS NOT NULL)))
);


--
-- Name: CreditPurchaseLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CreditPurchaseLog" (
    id text NOT NULL,
    "creditBalanceId" text NOT NULL,
    credits integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: DSyncData; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DSyncData" (
    id integer NOT NULL,
    "directoryId" text NOT NULL,
    tenant text NOT NULL,
    "organizationId" integer
);


--
-- Name: DSyncData_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."DSyncData_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: DSyncData_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."DSyncData_id_seq" OWNED BY public."DSyncData".id;


--
-- Name: DSyncTeamGroupMapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DSyncTeamGroupMapping" (
    id integer NOT NULL,
    "teamId" integer NOT NULL,
    "directoryId" text NOT NULL,
    "groupName" text NOT NULL,
    "organizationId" integer NOT NULL
);


--
-- Name: DSyncTeamGroupMapping_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."DSyncTeamGroupMapping_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: DSyncTeamGroupMapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."DSyncTeamGroupMapping_id_seq" OWNED BY public."DSyncTeamGroupMapping".id;


--
-- Name: DelegationCredential; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DelegationCredential" (
    id text NOT NULL,
    "workspacePlatformId" integer NOT NULL,
    "serviceAccountKey" jsonb NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    "organizationId" integer NOT NULL,
    domain text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "lastDisabledAt" timestamp(3) without time zone,
    "lastEnabledAt" timestamp(3) without time zone
);


--
-- Name: Deployment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Deployment" (
    id integer DEFAULT 1 NOT NULL,
    logo text,
    theme jsonb,
    "licenseKey" text,
    "agreedLicenseAt" timestamp(3) without time zone,
    "signatureTokenEncrypted" text
);


--
-- Name: DestinationCalendar; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DestinationCalendar" (
    id integer NOT NULL,
    integration text NOT NULL,
    "externalId" text NOT NULL,
    "userId" integer,
    "eventTypeId" integer,
    "credentialId" integer,
    "primaryEmail" text,
    "domainWideDelegationCredentialId" text,
    "delegationCredentialId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp(3) without time zone,
    "customCalendarReminder" integer
);


--
-- Name: DestinationCalendar_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."DestinationCalendar_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: DestinationCalendar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."DestinationCalendar_id_seq" OWNED BY public."DestinationCalendar".id;


--
-- Name: DomainWideDelegation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DomainWideDelegation" (
    id text NOT NULL,
    "workspacePlatformId" integer NOT NULL,
    "serviceAccountKey" jsonb NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    "organizationId" integer NOT NULL,
    domain text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: EventTypeCustomInput; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."EventTypeCustomInput" (
    id integer NOT NULL,
    "eventTypeId" integer NOT NULL,
    label text NOT NULL,
    required boolean NOT NULL,
    type public."EventTypeCustomInputType" NOT NULL,
    placeholder text DEFAULT ''::text NOT NULL,
    options jsonb
);


--
-- Name: EventTypeCustomInput_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."EventTypeCustomInput_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: EventTypeCustomInput_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."EventTypeCustomInput_id_seq" OWNED BY public."EventTypeCustomInput".id;


--
-- Name: EventTypeTranslation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."EventTypeTranslation" (
    "eventTypeId" integer NOT NULL,
    field public."EventTypeAutoTranslatedField" NOT NULL,
    "translatedText" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "createdBy" integer NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "updatedBy" integer,
    "sourceLocale" text NOT NULL,
    "targetLocale" text NOT NULL,
    uid text NOT NULL
);


--
-- Name: EventType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."EventType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: EventType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."EventType_id_seq" OWNED BY public."EventType".id;


--
-- Name: Feature; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Feature" (
    slug text NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    description text,
    type public."FeatureType" DEFAULT 'RELEASE'::public."FeatureType",
    stale boolean DEFAULT false,
    "lastUsedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedBy" integer
);


--
-- Name: Feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Feedback" (
    id integer NOT NULL,
    date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" integer NOT NULL,
    rating text NOT NULL,
    comment text
);


--
-- Name: Feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Feedback_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Feedback_id_seq" OWNED BY public."Feedback".id;


--
-- Name: FilterSegment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."FilterSegment" (
    id integer NOT NULL,
    name text NOT NULL,
    "tableIdentifier" text NOT NULL,
    scope public."FilterSegmentScope" NOT NULL,
    "activeFilters" jsonb,
    sorting jsonb,
    "columnVisibility" jsonb,
    "columnSizing" jsonb,
    "perPage" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "userId" integer NOT NULL,
    "teamId" integer,
    "searchTerm" text
);


--
-- Name: FilterSegment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."FilterSegment_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: FilterSegment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."FilterSegment_id_seq" OWNED BY public."FilterSegment".id;


--
-- Name: HashedLink; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."HashedLink" (
    id integer NOT NULL,
    link text NOT NULL,
    "eventTypeId" integer NOT NULL,
    "expiresAt" timestamp(3) without time zone,
    "maxUsageCount" integer DEFAULT 1 NOT NULL,
    "usageCount" integer DEFAULT 0 NOT NULL
);


--
-- Name: HashedLink_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."HashedLink_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: HashedLink_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."HashedLink_id_seq" OWNED BY public."HashedLink".id;


--
-- Name: HolidayCache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."HolidayCache" (
    id text NOT NULL,
    "countryCode" text NOT NULL,
    "calendarId" text NOT NULL,
    "eventId" text NOT NULL,
    name text NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    year integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Host; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Host" (
    "userId" integer NOT NULL,
    "eventTypeId" integer NOT NULL,
    "isFixed" boolean DEFAULT false NOT NULL,
    priority integer,
    weight integer,
    "weightAdjustment" integer,
    "scheduleId" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "groupId" text,
    "memberId" integer
);


--
-- Name: HostGroup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."HostGroup" (
    id text NOT NULL,
    name text NOT NULL,
    "eventTypeId" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: HostLocation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."HostLocation" (
    id text NOT NULL,
    "userId" integer NOT NULL,
    "eventTypeId" integer NOT NULL,
    type text NOT NULL,
    "credentialId" integer,
    link text,
    address text,
    "phoneNumber" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Impersonations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Impersonations" (
    id integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "impersonatedUserId" integer NOT NULL,
    "impersonatedById" integer NOT NULL
);


--
-- Name: Impersonations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Impersonations_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Impersonations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Impersonations_id_seq" OWNED BY public."Impersonations".id;


--
-- Name: InstantMeetingToken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."InstantMeetingToken" (
    id integer NOT NULL,
    token text NOT NULL,
    expires timestamp(3) without time zone NOT NULL,
    "teamId" integer NOT NULL,
    "bookingId" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: InstantMeetingToken_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."InstantMeetingToken_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: InstantMeetingToken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."InstantMeetingToken_id_seq" OWNED BY public."InstantMeetingToken".id;


--
-- Name: IntegrationAttributeSync; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."IntegrationAttributeSync" (
    id text NOT NULL,
    "organizationId" integer NOT NULL,
    name text NOT NULL,
    integration text NOT NULL,
    "credentialId" integer,
    enabled boolean NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: InternalNotePreset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."InternalNotePreset" (
    id integer NOT NULL,
    name text NOT NULL,
    "cancellationReason" text,
    "teamId" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: InternalNotePreset_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."InternalNotePreset_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: InternalNotePreset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."InternalNotePreset_id_seq" OWNED BY public."InternalNotePreset".id;


--
-- Name: ManagedOrganization; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ManagedOrganization" (
    "managedOrganizationId" integer NOT NULL,
    "managerOrganizationId" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Membership; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Membership" (
    "teamId" integer NOT NULL,
    "userId" integer NOT NULL,
    accepted boolean DEFAULT false NOT NULL,
    role public."MembershipRole" NOT NULL,
    "disableImpersonation" boolean DEFAULT false NOT NULL,
    id integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp(3) without time zone,
    "customRoleId" text
);


--
-- Name: Membership_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Membership_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Membership_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Membership_id_seq" OWNED BY public."Membership".id;


--
-- Name: MonthlyProration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."MonthlyProration" (
    id text NOT NULL,
    "teamId" integer NOT NULL,
    "monthKey" text NOT NULL,
    "periodStart" timestamp(3) without time zone NOT NULL,
    "periodEnd" timestamp(3) without time zone NOT NULL,
    "seatsAtStart" integer NOT NULL,
    "seatsAdded" integer NOT NULL,
    "seatsRemoved" integer NOT NULL,
    "netSeatIncrease" integer NOT NULL,
    "seatsAtEnd" integer NOT NULL,
    "subscriptionId" text NOT NULL,
    "subscriptionItemId" text NOT NULL,
    "customerId" text NOT NULL,
    "subscriptionStart" timestamp(3) without time zone NOT NULL,
    "subscriptionEnd" timestamp(3) without time zone NOT NULL,
    "remainingDays" integer NOT NULL,
    "pricePerSeat" integer NOT NULL,
    "proratedAmount" integer NOT NULL,
    "invoiceItemId" text,
    "invoiceId" text,
    status public."ProrationStatus" DEFAULT 'PENDING'::public."ProrationStatus" NOT NULL,
    "chargedAt" timestamp(3) without time zone,
    "failedAt" timestamp(3) without time zone,
    "failureReason" text,
    "retryCount" integer DEFAULT 0 NOT NULL,
    metadata jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "teamBillingId" text,
    "organizationBillingId" text,
    "invoiceUrl" text
);


--
-- Name: NotificationsSubscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."NotificationsSubscriptions" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    subscription text NOT NULL
);


--
-- Name: NotificationsSubscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."NotificationsSubscriptions_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: NotificationsSubscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."NotificationsSubscriptions_id_seq" OWNED BY public."NotificationsSubscriptions".id;


--
-- Name: OAuthClient; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OAuthClient" (
    "clientId" text NOT NULL,
    "redirectUri" text NOT NULL,
    "clientSecret" text,
    name text NOT NULL,
    logo text,
    "clientType" public."OAuthClientType" DEFAULT 'confidential'::public."OAuthClientType" NOT NULL,
    "isTrusted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    purpose text,
    "rejectionReason" text,
    status public."OAuthClientStatus" DEFAULT 'approved'::public."OAuthClientStatus" NOT NULL,
    "userId" integer,
    "websiteUrl" text
);


--
-- Name: OrganizationBilling; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OrganizationBilling" (
    id text NOT NULL,
    "teamId" integer NOT NULL,
    "subscriptionId" text NOT NULL,
    "subscriptionItemId" text NOT NULL,
    "customerId" text NOT NULL,
    status text NOT NULL,
    "planName" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "subscriptionEnd" timestamp(3) without time zone,
    "subscriptionStart" timestamp(3) without time zone,
    "subscriptionTrialEnd" timestamp(3) without time zone,
    "billingPeriod" public."BillingPeriod",
    "pricePerSeat" integer,
    "paidSeats" integer,
    "highWaterMark" integer,
    "highWaterMarkPeriodStart" timestamp(3) without time zone,
    "billingMode" public."BillingMode" DEFAULT 'SEATS'::public."BillingMode" NOT NULL
);


--
-- Name: OrganizationOnboarding; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OrganizationOnboarding" (
    id text NOT NULL,
    "createdById" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "orgOwnerEmail" text NOT NULL,
    error text,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "organizationId" integer,
    "billingPeriod" public."BillingPeriod" NOT NULL,
    "pricePerSeat" double precision NOT NULL,
    seats integer NOT NULL,
    "isPlatform" boolean DEFAULT false NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    logo text,
    bio text,
    "isDomainConfigured" boolean DEFAULT false NOT NULL,
    "stripeCustomerId" text,
    "stripeSubscriptionId" text,
    "stripeSubscriptionItemId" text,
    "invitedMembers" jsonb DEFAULT '[]'::jsonb NOT NULL,
    teams jsonb DEFAULT '[]'::jsonb NOT NULL,
    "isComplete" boolean DEFAULT false NOT NULL,
    "bannerUrl" text,
    "brandColor" text
);


--
-- Name: OrganizationSettings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OrganizationSettings" (
    id integer NOT NULL,
    "organizationId" integer NOT NULL,
    "isOrganizationConfigured" boolean DEFAULT false NOT NULL,
    "isOrganizationVerified" boolean DEFAULT false NOT NULL,
    "orgAutoAcceptEmail" text NOT NULL,
    "lockEventTypeCreationForUsers" boolean DEFAULT false NOT NULL,
    "isAdminReviewed" boolean DEFAULT false NOT NULL,
    "adminGetsNoSlotsNotification" boolean DEFAULT false NOT NULL,
    "isAdminAPIEnabled" boolean DEFAULT false NOT NULL,
    "allowSEOIndexing" boolean DEFAULT false NOT NULL,
    "orgProfileRedirectsToVerifiedDomain" boolean DEFAULT false NOT NULL,
    "disablePhoneOnlySMSNotifications" boolean DEFAULT false NOT NULL,
    "disableAutofillOnBookingPage" boolean DEFAULT false NOT NULL,
    "orgAutoJoinOnSignup" boolean DEFAULT true NOT NULL,
    "disableAttendeeAwaitingPaymentEmail" boolean DEFAULT false NOT NULL,
    "disableAttendeeCancellationEmail" boolean DEFAULT false NOT NULL,
    "disableAttendeeConfirmationEmail" boolean DEFAULT false NOT NULL,
    "disableAttendeeLocationChangeEmail" boolean DEFAULT false NOT NULL,
    "disableAttendeeNewEventEmail" boolean DEFAULT false NOT NULL,
    "disableAttendeeReassignedEmail" boolean DEFAULT false NOT NULL,
    "disableAttendeeRequestEmail" boolean DEFAULT false NOT NULL,
    "disableAttendeeRescheduleRequestEmail" boolean DEFAULT false NOT NULL,
    "disableAttendeeRescheduledEmail" boolean DEFAULT false NOT NULL
);


--
-- Name: OrganizationSettings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."OrganizationSettings_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: OrganizationSettings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."OrganizationSettings_id_seq" OWNED BY public."OrganizationSettings".id;


--
-- Name: OutOfOfficeEntry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OutOfOfficeEntry" (
    id integer NOT NULL,
    uuid text NOT NULL,
    start timestamp(3) without time zone NOT NULL,
    "end" timestamp(3) without time zone NOT NULL,
    "userId" integer NOT NULL,
    "toUserId" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "reasonId" integer,
    notes text,
    "showNotePublicly" boolean DEFAULT false NOT NULL
);


--
-- Name: OutOfOfficeEntry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."OutOfOfficeEntry_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: OutOfOfficeEntry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."OutOfOfficeEntry_id_seq" OWNED BY public."OutOfOfficeEntry".id;


--
-- Name: OutOfOfficeReason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OutOfOfficeReason" (
    id integer NOT NULL,
    emoji text NOT NULL,
    reason text NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    "userId" integer
);


--
-- Name: OutOfOfficeReason_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."OutOfOfficeReason_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: OutOfOfficeReason_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."OutOfOfficeReason_id_seq" OWNED BY public."OutOfOfficeReason".id;


--
-- Name: Payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Payment" (
    id integer NOT NULL,
    uid text NOT NULL,
    "bookingId" integer NOT NULL,
    amount integer NOT NULL,
    fee integer NOT NULL,
    currency text NOT NULL,
    success boolean NOT NULL,
    refunded boolean NOT NULL,
    data jsonb NOT NULL,
    "externalId" text NOT NULL,
    "appId" text,
    "paymentOption" public."PaymentOption" DEFAULT 'ON_BOOKING'::public."PaymentOption"
);


--
-- Name: Payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Payment_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Payment_id_seq" OWNED BY public."Payment".id;


--
-- Name: PendingRoutingTrace; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PendingRoutingTrace" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trace jsonb NOT NULL,
    "formResponseId" integer,
    "queuedFormResponseId" text,
    CONSTRAINT "PendingRoutingTrace_at_least_one_response_id" CHECK ((("formResponseId" IS NOT NULL) OR ("queuedFormResponseId" IS NOT NULL)))
);


--
-- Name: PlatformAuthorizationToken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PlatformAuthorizationToken" (
    id text NOT NULL,
    "platformOAuthClientId" text NOT NULL,
    "userId" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: PlatformBilling; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PlatformBilling" (
    id integer NOT NULL,
    "customerId" text NOT NULL,
    plan text DEFAULT 'none'::text NOT NULL,
    "subscriptionId" text,
    "billingCycleStart" integer,
    "billingCycleEnd" integer,
    overdue boolean DEFAULT false,
    "managerBillingId" integer,
    "priceId" text
);


--
-- Name: PlatformOAuthClient; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PlatformOAuthClient" (
    id text NOT NULL,
    name text NOT NULL,
    secret text NOT NULL,
    permissions integer NOT NULL,
    logo text,
    "redirectUris" text[],
    "organizationId" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "areEmailsEnabled" boolean DEFAULT false NOT NULL,
    "bookingCancelRedirectUri" text,
    "bookingRedirectUri" text,
    "bookingRescheduleRedirectUri" text,
    "areDefaultEventTypesEnabled" boolean DEFAULT true NOT NULL,
    "areCalendarEventsEnabled" boolean DEFAULT true NOT NULL
);


--
-- Name: Profile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Profile" (
    id integer NOT NULL,
    uid text NOT NULL,
    "userId" integer NOT NULL,
    "organizationId" integer NOT NULL,
    username text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Profile_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Profile_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Profile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Profile_id_seq" OWNED BY public."Profile".id;


--
-- Name: RateLimit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RateLimit" (
    id text NOT NULL,
    name text NOT NULL,
    "apiKeyId" text NOT NULL,
    ttl integer NOT NULL,
    "limit" integer NOT NULL,
    "blockDuration" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: RefreshToken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RefreshToken" (
    id integer NOT NULL,
    secret text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "platformOAuthClientId" text NOT NULL,
    "userId" integer NOT NULL
);


--
-- Name: RefreshToken_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."RefreshToken_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: RefreshToken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."RefreshToken_id_seq" OWNED BY public."RefreshToken".id;


--
-- Name: ReminderMail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ReminderMail" (
    id integer NOT NULL,
    "referenceId" integer NOT NULL,
    "reminderType" public."ReminderType" NOT NULL,
    "elapsedMinutes" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: ReminderMail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ReminderMail_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ReminderMail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ReminderMail_id_seq" OWNED BY public."ReminderMail".id;


--
-- Name: ResetPasswordRequest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ResetPasswordRequest" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    email text NOT NULL,
    expires timestamp(3) without time zone NOT NULL
);


--
-- Name: Role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Role" (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    "teamId" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    type public."RoleType" DEFAULT 'CUSTOM'::public."RoleType" NOT NULL,
    color text
);


--
-- Name: RolePermission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RolePermission" (
    id text NOT NULL,
    "roleId" text NOT NULL,
    resource text NOT NULL,
    action text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Tracking; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Tracking" (
    id integer NOT NULL,
    "bookingId" integer NOT NULL,
    utm_source text,
    utm_medium text,
    utm_campaign text,
    utm_term text,
    utm_content text
);


--
-- Name: RoutingFormResponse; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."RoutingFormResponse" AS
 SELECT r.id,
    r.response,
    ( SELECT jsonb_object_agg(jsonb_each.key,
                CASE
                    WHEN (jsonb_typeof((jsonb_each.value -> 'value'::text)) = 'string'::text) THEN jsonb_build_object('label', (jsonb_each.value -> 'label'::text), 'value', lower((jsonb_each.value ->> 'value'::text)))
                    ELSE jsonb_each.value
                END) AS jsonb_object_agg
           FROM jsonb_each(r.response) jsonb_each(key, value)) AS "responseLowercase",
    f.id AS "formId",
    f.name AS "formName",
    f."teamId" AS "formTeamId",
    f."userId" AS "formUserId",
    b.uid AS "bookingUid",
    b.status AS "bookingStatus",
        CASE b.status
            WHEN 'accepted'::public."BookingStatus" THEN 1
            WHEN 'pending'::public."BookingStatus" THEN 2
            WHEN 'awaiting_host'::public."BookingStatus" THEN 3
            WHEN 'cancelled'::public."BookingStatus" THEN 4
            WHEN 'rejected'::public."BookingStatus" THEN 5
            ELSE NULL::integer
        END AS "bookingStatusOrder",
    b."createdAt" AS "bookingCreatedAt",
    b."startTime" AS "bookingStartTime",
    b."endTime" AS "bookingEndTime",
    ( SELECT json_agg(json_build_object('name', a.name, 'timeZone', a."timeZone", 'email', a.email)) AS json_agg
           FROM public."Attendee" a
          WHERE (a."bookingId" = b.id)) AS "bookingAttendees",
    u.id AS "bookingUserId",
    u.name AS "bookingUserName",
    u.email AS "bookingUserEmail",
    u."avatarUrl" AS "bookingUserAvatarUrl",
    COALESCE(( SELECT ar."reasonString"
           FROM public."AssignmentReason" ar
          WHERE (ar."bookingId" = b.id)
         LIMIT 1), ''::text) AS "bookingAssignmentReason",
    COALESCE(( SELECT lower(ar."reasonString") AS lower
           FROM public."AssignmentReason" ar
          WHERE (ar."bookingId" = b.id)
         LIMIT 1), ''::text) AS "bookingAssignmentReasonLowercase",
    r."createdAt",
    t.utm_source,
    t.utm_medium,
    t.utm_campaign,
    t.utm_term,
    t.utm_content
   FROM ((((public."App_RoutingForms_FormResponse" r
     LEFT JOIN public."App_RoutingForms_Form" f ON ((r."formId" = f.id)))
     LEFT JOIN public."Booking" b ON ((r."routedToBookingUid" = b.uid)))
     LEFT JOIN public.users u ON ((b."userId" = u.id)))
     LEFT JOIN public."Tracking" t ON ((t."bookingId" = b.id)));


--
-- Name: RoutingFormResponseDenormalized; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RoutingFormResponseDenormalized" (
    id integer NOT NULL,
    "formId" text NOT NULL,
    "formName" text NOT NULL,
    "formTeamId" integer,
    "formUserId" integer NOT NULL,
    "bookingUid" text,
    "bookingId" integer,
    "bookingStatus" public."BookingStatus",
    "bookingStatusOrder" integer,
    "bookingCreatedAt" timestamp(3) without time zone,
    "bookingStartTime" timestamp(3) without time zone,
    "bookingEndTime" timestamp(3) without time zone,
    "bookingUserId" integer,
    "bookingUserName" text,
    "bookingUserEmail" text,
    "bookingUserAvatarUrl" text,
    "bookingAssignmentReason" text,
    "eventTypeId" integer,
    "eventTypeParentId" integer,
    "eventTypeSchedulingType" text,
    "createdAt" timestamp(3) without time zone NOT NULL,
    utm_source text,
    utm_medium text,
    utm_campaign text,
    utm_term text,
    utm_content text,
    uuid text
);


--
-- Name: RoutingFormResponseField; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RoutingFormResponseField" (
    id integer NOT NULL,
    "responseId" integer NOT NULL,
    "fieldId" text NOT NULL,
    "valueString" text,
    "valueNumber" numeric(65,30),
    "valueStringArray" text[]
);


--
-- Name: RoutingFormResponseField_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."RoutingFormResponseField_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: RoutingFormResponseField_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."RoutingFormResponseField_id_seq" OWNED BY public."RoutingFormResponseField".id;


--
-- Name: RoutingTrace; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RoutingTrace" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trace jsonb NOT NULL,
    "formResponseId" integer,
    "queuedFormResponseId" text,
    "bookingUid" text,
    "assignmentReasonId" integer,
    CONSTRAINT "RoutingTrace_at_least_one_response_id" CHECK ((("formResponseId" IS NOT NULL) OR ("queuedFormResponseId" IS NOT NULL)))
);


--
-- Name: Schedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Schedule" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    name text NOT NULL,
    "timeZone" text
);


--
-- Name: Schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Schedule_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Schedule_id_seq" OWNED BY public."Schedule".id;


--
-- Name: SeatChangeLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SeatChangeLog" (
    id text NOT NULL,
    "teamId" integer NOT NULL,
    "changeType" public."SeatChangeType" NOT NULL,
    "seatCount" integer NOT NULL,
    "userId" integer,
    "triggeredBy" integer,
    "changeDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "monthKey" text NOT NULL,
    "processedInProrationId" text,
    metadata jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "teamBillingId" text,
    "organizationBillingId" text,
    "operationId" text
);


--
-- Name: SecondaryEmail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SecondaryEmail" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    email text NOT NULL,
    "emailVerified" timestamp(3) without time zone
);


--
-- Name: SecondaryEmail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."SecondaryEmail_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: SecondaryEmail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."SecondaryEmail_id_seq" OWNED BY public."SecondaryEmail".id;


--
-- Name: SelectedCalendar; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SelectedCalendar" (
    "userId" integer NOT NULL,
    integration text NOT NULL,
    "externalId" text NOT NULL,
    "credentialId" integer,
    "googleChannelExpiration" text,
    "googleChannelId" text,
    "googleChannelKind" text,
    "googleChannelResourceId" text,
    "googleChannelResourceUri" text,
    "domainWideDelegationCredentialId" text,
    id text NOT NULL,
    "eventTypeId" integer,
    error text,
    "channelId" text,
    "channelKind" text,
    "channelResourceId" text,
    "channelResourceUri" text,
    "channelExpiration" timestamp(3) without time zone,
    "syncSubscribedAt" timestamp(3) without time zone,
    "syncToken" text,
    "syncedAt" timestamp(3) without time zone,
    "syncErrorAt" timestamp(3) without time zone,
    "syncErrorCount" integer DEFAULT 0,
    "delegationCredentialId" text,
    "lastErrorAt" timestamp(3) without time zone,
    "maxAttempts" integer DEFAULT 3 NOT NULL,
    "unwatchAttempts" integer DEFAULT 0 NOT NULL,
    "watchAttempts" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp(3) without time zone,
    "syncSubscribedErrorAt" timestamp(3) without time zone,
    "syncSubscribedErrorCount" integer DEFAULT 0 NOT NULL
);


--
-- Name: SelectedSlots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SelectedSlots" (
    id integer NOT NULL,
    "eventTypeId" integer NOT NULL,
    "userId" integer NOT NULL,
    "slotUtcStartDate" timestamp(3) without time zone NOT NULL,
    "slotUtcEndDate" timestamp(3) without time zone NOT NULL,
    uid text NOT NULL,
    "releaseAt" timestamp(3) without time zone NOT NULL,
    "isSeat" boolean DEFAULT false NOT NULL
);


--
-- Name: SelectedSlots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."SelectedSlots_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: SelectedSlots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."SelectedSlots_id_seq" OWNED BY public."SelectedSlots".id;


--
-- Name: Session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Session" (
    id text NOT NULL,
    "sessionToken" text NOT NULL,
    "userId" integer NOT NULL,
    expires timestamp(3) without time zone NOT NULL
);


--
-- Name: Task; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Task" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "scheduledAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "succeededAt" timestamp(3) without time zone,
    type text NOT NULL,
    payload text NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    "maxAttempts" integer DEFAULT 3 NOT NULL,
    "lastError" text,
    "lastFailedAttemptAt" timestamp(3) without time zone,
    "referenceUid" text
);


--
-- Name: Team; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Team" (
    id integer NOT NULL,
    name text NOT NULL,
    slug text,
    bio text,
    "hideBranding" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    metadata jsonb,
    "hideBookATeamMember" boolean DEFAULT false NOT NULL,
    "brandColor" text,
    "darkBrandColor" text,
    theme text,
    "appLogo" text,
    "appIconLogo" text,
    "parentId" integer,
    "timeFormat" integer,
    "timeZone" text DEFAULT 'Europe/London'::text NOT NULL,
    "weekStart" text DEFAULT 'Sunday'::text NOT NULL,
    "isPrivate" boolean DEFAULT false NOT NULL,
    "logoUrl" text,
    "calVideoLogo" text,
    "pendingPayment" boolean DEFAULT false NOT NULL,
    "isOrganization" boolean DEFAULT false NOT NULL,
    "bannerUrl" text,
    "isPlatform" boolean DEFAULT false NOT NULL,
    "smsLockState" public."SMSLockState" DEFAULT 'UNLOCKED'::public."SMSLockState" NOT NULL,
    "createdByOAuthClientId" text,
    "smsLockReviewedByAdmin" boolean DEFAULT false NOT NULL,
    "bookingLimits" jsonb,
    "includeManagedEventsInLimits" boolean DEFAULT false NOT NULL,
    "rrResetInterval" public."RRResetInterval" DEFAULT 'MONTH'::public."RRResetInterval",
    "hideTeamProfileLink" boolean DEFAULT false NOT NULL,
    "rrTimestampBasis" public."RRTimestampBasis" DEFAULT 'CREATED_AT'::public."RRTimestampBasis" NOT NULL,
    "autoOptInFeatures" boolean DEFAULT false NOT NULL
);


--
-- Name: TeamBilling; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TeamBilling" (
    id text NOT NULL,
    "teamId" integer NOT NULL,
    "subscriptionId" text NOT NULL,
    "subscriptionItemId" text NOT NULL,
    "customerId" text NOT NULL,
    status text NOT NULL,
    "planName" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "subscriptionEnd" timestamp(3) without time zone,
    "subscriptionStart" timestamp(3) without time zone,
    "subscriptionTrialEnd" timestamp(3) without time zone,
    "billingPeriod" public."BillingPeriod",
    "pricePerSeat" integer,
    "paidSeats" integer,
    "highWaterMark" integer,
    "highWaterMarkPeriodStart" timestamp(3) without time zone,
    "billingMode" public."BillingMode" DEFAULT 'SEATS'::public."BillingMode" NOT NULL
);


--
-- Name: TeamFeatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TeamFeatures" (
    "teamId" integer NOT NULL,
    "featureId" text NOT NULL,
    "assignedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "assignedBy" text NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    enabled boolean NOT NULL
);


--
-- Name: Team_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Team_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Team_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Team_id_seq" OWNED BY public."Team".id;


--
-- Name: TempOrgRedirect; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TempOrgRedirect" (
    id integer NOT NULL,
    "from" text NOT NULL,
    "fromOrgId" integer NOT NULL,
    type public."RedirectType" NOT NULL,
    "toUrl" text NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: TempOrgRedirect_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TempOrgRedirect_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TempOrgRedirect_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TempOrgRedirect_id_seq" OWNED BY public."TempOrgRedirect".id;


--
-- Name: Tracking_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Tracking_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Tracking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Tracking_id_seq" OWNED BY public."Tracking".id;


--
-- Name: TravelSchedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TravelSchedule" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "timeZone" text NOT NULL,
    "startDate" timestamp(3) without time zone NOT NULL,
    "endDate" timestamp(3) without time zone,
    "prevTimeZone" text
);


--
-- Name: TravelSchedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TravelSchedule_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: TravelSchedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TravelSchedule_id_seq" OWNED BY public."TravelSchedule".id;


--
-- Name: UserFeatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserFeatures" (
    "userId" integer NOT NULL,
    "featureId" text NOT NULL,
    "assignedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "assignedBy" text NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    enabled boolean NOT NULL
);


--
-- Name: UserFilterSegmentPreference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserFilterSegmentPreference" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "tableIdentifier" text NOT NULL,
    "segmentId" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "systemSegmentId" text,
    CONSTRAINT "UserFilterSegmentPreference_segment_xor_system_chk" CHECK (((("segmentId" IS NOT NULL) AND ("systemSegmentId" IS NULL)) OR (("segmentId" IS NULL) AND ("systemSegmentId" IS NOT NULL)))),
    CONSTRAINT "UserFilterSegmentPreference_systemSegmentId_nonempty_chk" CHECK ((("systemSegmentId" IS NULL) OR (length("systemSegmentId") > 0)))
);


--
-- Name: UserFilterSegmentPreference_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserFilterSegmentPreference_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserFilterSegmentPreference_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserFilterSegmentPreference_id_seq" OWNED BY public."UserFilterSegmentPreference".id;


--
-- Name: UserHolidaySettings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserHolidaySettings" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "countryCode" text,
    "disabledIds" text[],
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: UserHolidaySettings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserHolidaySettings_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: UserHolidaySettings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserHolidaySettings_id_seq" OWNED BY public."UserHolidaySettings".id;


--
-- Name: UserPassword; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserPassword" (
    hash text NOT NULL,
    "userId" integer NOT NULL
);


--
-- Name: VerificationToken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."VerificationToken" (
    id integer NOT NULL,
    identifier text NOT NULL,
    token text NOT NULL,
    expires timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "expiresInDays" integer,
    "teamId" integer,
    "secondaryEmailId" integer
);


--
-- Name: VerificationRequest_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."VerificationRequest_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: VerificationRequest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."VerificationRequest_id_seq" OWNED BY public."VerificationToken".id;


--
-- Name: VerifiedEmail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."VerifiedEmail" (
    id integer NOT NULL,
    "userId" integer,
    "teamId" integer,
    email text NOT NULL
);


--
-- Name: VerifiedEmail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."VerifiedEmail_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: VerifiedEmail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."VerifiedEmail_id_seq" OWNED BY public."VerifiedEmail".id;


--
-- Name: VerifiedNumber; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."VerifiedNumber" (
    id integer NOT NULL,
    "userId" integer,
    "phoneNumber" text NOT NULL,
    "teamId" integer
);


--
-- Name: VerifiedNumber_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."VerifiedNumber_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: VerifiedNumber_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."VerifiedNumber_id_seq" OWNED BY public."VerifiedNumber".id;


--
-- Name: VideoCallGuest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."VideoCallGuest" (
    id text NOT NULL,
    "bookingUid" text NOT NULL,
    email text NOT NULL,
    name text NOT NULL,
    "joinedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Watchlist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Watchlist" (
    type public."WatchlistType" NOT NULL,
    value text NOT NULL,
    description text,
    action public."WatchlistAction" DEFAULT 'REPORT'::public."WatchlistAction" NOT NULL,
    "organizationId" integer,
    id uuid NOT NULL,
    "isGlobal" boolean DEFAULT false NOT NULL,
    "lastUpdatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    source public."WatchlistSource" DEFAULT 'MANUAL'::public."WatchlistSource" NOT NULL
);


--
-- Name: WatchlistAudit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WatchlistAudit" (
    id uuid NOT NULL,
    type public."WatchlistType" NOT NULL,
    value text NOT NULL,
    description text,
    action public."WatchlistAction" DEFAULT 'REPORT'::public."WatchlistAction" NOT NULL,
    "changedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "changedByUserId" integer,
    "watchlistId" uuid
);


--
-- Name: WatchlistEventAudit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WatchlistEventAudit" (
    id uuid NOT NULL,
    "watchlistId" uuid NOT NULL,
    "eventTypeId" integer NOT NULL,
    "actionTaken" public."WatchlistAction" NOT NULL,
    "timestamp" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Webhook; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Webhook" (
    id text NOT NULL,
    "userId" integer,
    "subscriberUrl" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    active boolean DEFAULT true NOT NULL,
    "eventTriggers" public."WebhookTriggerEvents"[],
    "payloadTemplate" text,
    "eventTypeId" integer,
    "appId" text,
    secret text,
    "teamId" integer,
    platform boolean DEFAULT false NOT NULL,
    "platformOAuthClientId" text,
    "time" integer,
    "timeUnit" public."TimeUnit",
    version text DEFAULT '2021-10-20'::text NOT NULL
);


--
-- Name: WebhookScheduledTriggers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WebhookScheduledTriggers" (
    id integer NOT NULL,
    "jobName" text,
    "subscriberUrl" text NOT NULL,
    payload text NOT NULL,
    "startAfter" timestamp(3) without time zone NOT NULL,
    "retryCount" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP,
    "webhookId" text,
    "appId" text,
    "bookingId" integer
);


--
-- Name: WebhookScheduledTriggers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."WebhookScheduledTriggers_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: WebhookScheduledTriggers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."WebhookScheduledTriggers_id_seq" OWNED BY public."WebhookScheduledTriggers".id;


--
-- Name: Workflow; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Workflow" (
    id integer NOT NULL,
    name text NOT NULL,
    "userId" integer,
    trigger public."WorkflowTriggerEvents" NOT NULL,
    "time" integer,
    "timeUnit" public."TimeUnit",
    "teamId" integer,
    "position" integer DEFAULT 0 NOT NULL,
    "isActiveOnAll" boolean DEFAULT false NOT NULL,
    type public."WorkflowType" DEFAULT 'EVENT_TYPE'::public."WorkflowType" NOT NULL
);


--
-- Name: WorkflowOptOutContact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WorkflowOptOutContact" (
    id integer NOT NULL,
    type public."WorkflowContactType" NOT NULL,
    value text NOT NULL,
    "optedOut" boolean NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: WorkflowOptOutContact_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."WorkflowOptOutContact_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: WorkflowOptOutContact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."WorkflowOptOutContact_id_seq" OWNED BY public."WorkflowOptOutContact".id;


--
-- Name: WorkflowReminder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WorkflowReminder" (
    id integer NOT NULL,
    "bookingUid" text,
    method public."WorkflowMethods" NOT NULL,
    "scheduledDate" timestamp(3) without time zone NOT NULL,
    "referenceId" text,
    scheduled boolean NOT NULL,
    "workflowStepId" integer,
    cancelled boolean,
    "seatReferenceId" text,
    "isMandatoryReminder" boolean DEFAULT false,
    "retryCount" integer DEFAULT 0 NOT NULL,
    uuid text
);


--
-- Name: WorkflowReminder_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."WorkflowReminder_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: WorkflowReminder_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."WorkflowReminder_id_seq" OWNED BY public."WorkflowReminder".id;


--
-- Name: WorkflowStep; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WorkflowStep" (
    id integer NOT NULL,
    "stepNumber" integer NOT NULL,
    action public."WorkflowActions" NOT NULL,
    "workflowId" integer NOT NULL,
    "sendTo" text,
    "reminderBody" text,
    "emailSubject" text,
    template public."WorkflowTemplates" DEFAULT 'REMINDER'::public."WorkflowTemplates" NOT NULL,
    "numberRequired" boolean,
    sender text,
    "numberVerificationPending" boolean DEFAULT true NOT NULL,
    "includeCalendarEvent" boolean DEFAULT false NOT NULL,
    "verifiedAt" timestamp(3) without time zone,
    "agentId" text,
    "inboundAgentId" text,
    "autoTranslateEnabled" boolean DEFAULT false NOT NULL,
    "sourceLocale" text
);


--
-- Name: WorkflowStepTranslation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WorkflowStepTranslation" (
    uid text NOT NULL,
    "workflowStepId" integer NOT NULL,
    field public."WorkflowStepAutoTranslatedField" NOT NULL,
    "sourceLocale" text NOT NULL,
    "targetLocale" text NOT NULL,
    "translatedText" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: WorkflowStep_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."WorkflowStep_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: WorkflowStep_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."WorkflowStep_id_seq" OWNED BY public."WorkflowStep".id;


--
-- Name: Workflow_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Workflow_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: Workflow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Workflow_id_seq" OWNED BY public."Workflow".id;


--
-- Name: WorkflowsOnEventTypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WorkflowsOnEventTypes" (
    id integer NOT NULL,
    "workflowId" integer NOT NULL,
    "eventTypeId" integer NOT NULL
);


--
-- Name: WorkflowsOnEventTypes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."WorkflowsOnEventTypes_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: WorkflowsOnEventTypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."WorkflowsOnEventTypes_id_seq" OWNED BY public."WorkflowsOnEventTypes".id;


--
-- Name: WorkflowsOnRoutingForms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WorkflowsOnRoutingForms" (
    id integer NOT NULL,
    "workflowId" integer NOT NULL,
    "routingFormId" text NOT NULL
);


--
-- Name: WorkflowsOnRoutingForms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."WorkflowsOnRoutingForms_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: WorkflowsOnRoutingForms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."WorkflowsOnRoutingForms_id_seq" OWNED BY public."WorkflowsOnRoutingForms".id;


--
-- Name: WorkflowsOnTeams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WorkflowsOnTeams" (
    id integer NOT NULL,
    "workflowId" integer NOT NULL,
    "teamId" integer NOT NULL
);


--
-- Name: WorkflowsOnTeams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."WorkflowsOnTeams_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: WorkflowsOnTeams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."WorkflowsOnTeams_id_seq" OWNED BY public."WorkflowsOnTeams".id;


--
-- Name: WorkspacePlatform; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WorkspacePlatform" (
    id integer NOT NULL,
    slug text NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    "defaultServiceAccountKey" jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    enabled boolean DEFAULT false NOT NULL
);


--
-- Name: WorkspacePlatform_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."WorkspacePlatform_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: WorkspacePlatform_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."WorkspacePlatform_id_seq" OWNED BY public."WorkspacePlatform".id;


--
-- Name: WrongAssignmentReport; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WrongAssignmentReport" (
    id uuid NOT NULL,
    "bookingUid" text NOT NULL,
    "reportedById" integer,
    "correctAssignee" text,
    "additionalNotes" text NOT NULL,
    "teamId" integer,
    "routingFormId" text,
    status public."WrongAssignmentReportStatus" DEFAULT 'PENDING'::public."WrongAssignmentReportStatus" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "reviewedAt" timestamp(3) without time zone,
    "reviewedById" integer
);


--
-- Name: _PlatformOAuthClientToUser; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."_PlatformOAuthClientToUser" (
    "A" text NOT NULL,
    "B" integer NOT NULL
);


--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
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
-- Name: _user_eventtype; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._user_eventtype (
    "A" integer NOT NULL,
    "B" integer NOT NULL
);


--
-- Name: avatars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.avatars (
    "teamId" integer DEFAULT 0 NOT NULL,
    "userId" integer DEFAULT 0 NOT NULL,
    data text NOT NULL,
    "objectKey" text NOT NULL,
    "isBanner" boolean DEFAULT false NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
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
-- Name: AIPhoneCallConfiguration id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AIPhoneCallConfiguration" ALTER COLUMN id SET DEFAULT nextval('public."AIPhoneCallConfiguration_id_seq"'::regclass);


--
-- Name: AccessCode id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AccessCode" ALTER COLUMN id SET DEFAULT nextval('public."AccessCode_id_seq"'::regclass);


--
-- Name: AccessToken id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AccessToken" ALTER COLUMN id SET DEFAULT nextval('public."AccessToken_id_seq"'::regclass);


--
-- Name: App_RoutingForms_FormResponse id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."App_RoutingForms_FormResponse" ALTER COLUMN id SET DEFAULT nextval('public."App_RoutingForms_FormResponse_id_seq"'::regclass);


--
-- Name: App_RoutingForms_IncompleteBookingActions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."App_RoutingForms_IncompleteBookingActions" ALTER COLUMN id SET DEFAULT nextval('public."App_RoutingForms_IncompleteBookingActions_id_seq"'::regclass);


--
-- Name: AssignmentReason id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AssignmentReason" ALTER COLUMN id SET DEFAULT nextval('public."AssignmentReason_id_seq"'::regclass);


--
-- Name: Attendee id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Attendee" ALTER COLUMN id SET DEFAULT nextval('public."Attendee_id_seq"'::regclass);


--
-- Name: Availability id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Availability" ALTER COLUMN id SET DEFAULT nextval('public."Availability_id_seq"'::regclass);


--
-- Name: Booking id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Booking" ALTER COLUMN id SET DEFAULT nextval('public."Booking_id_seq"'::regclass);


--
-- Name: BookingInternalNote id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingInternalNote" ALTER COLUMN id SET DEFAULT nextval('public."BookingInternalNote_id_seq"'::regclass);


--
-- Name: BookingReference id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingReference" ALTER COLUMN id SET DEFAULT nextval('public."BookingReference_id_seq"'::regclass);


--
-- Name: BookingSeat id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingSeat" ALTER COLUMN id SET DEFAULT nextval('public."BookingSeat_id_seq"'::regclass);


--
-- Name: CalAiPhoneNumber id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CalAiPhoneNumber" ALTER COLUMN id SET DEFAULT nextval('public."CalAiPhoneNumber_id_seq"'::regclass);


--
-- Name: Credential id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Credential" ALTER COLUMN id SET DEFAULT nextval('public."Credential_id_seq"'::regclass);


--
-- Name: DSyncData id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DSyncData" ALTER COLUMN id SET DEFAULT nextval('public."DSyncData_id_seq"'::regclass);


--
-- Name: DSyncTeamGroupMapping id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DSyncTeamGroupMapping" ALTER COLUMN id SET DEFAULT nextval('public."DSyncTeamGroupMapping_id_seq"'::regclass);


--
-- Name: DestinationCalendar id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DestinationCalendar" ALTER COLUMN id SET DEFAULT nextval('public."DestinationCalendar_id_seq"'::regclass);


--
-- Name: EventType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventType" ALTER COLUMN id SET DEFAULT nextval('public."EventType_id_seq"'::regclass);


--
-- Name: EventTypeCustomInput id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventTypeCustomInput" ALTER COLUMN id SET DEFAULT nextval('public."EventTypeCustomInput_id_seq"'::regclass);


--
-- Name: Feedback id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Feedback" ALTER COLUMN id SET DEFAULT nextval('public."Feedback_id_seq"'::regclass);


--
-- Name: FilterSegment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FilterSegment" ALTER COLUMN id SET DEFAULT nextval('public."FilterSegment_id_seq"'::regclass);


--
-- Name: HashedLink id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."HashedLink" ALTER COLUMN id SET DEFAULT nextval('public."HashedLink_id_seq"'::regclass);


--
-- Name: Impersonations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Impersonations" ALTER COLUMN id SET DEFAULT nextval('public."Impersonations_id_seq"'::regclass);


--
-- Name: InstantMeetingToken id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InstantMeetingToken" ALTER COLUMN id SET DEFAULT nextval('public."InstantMeetingToken_id_seq"'::regclass);


--
-- Name: InternalNotePreset id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InternalNotePreset" ALTER COLUMN id SET DEFAULT nextval('public."InternalNotePreset_id_seq"'::regclass);


--
-- Name: Membership id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Membership" ALTER COLUMN id SET DEFAULT nextval('public."Membership_id_seq"'::regclass);


--
-- Name: NotificationsSubscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NotificationsSubscriptions" ALTER COLUMN id SET DEFAULT nextval('public."NotificationsSubscriptions_id_seq"'::regclass);


--
-- Name: OrganizationSettings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OrganizationSettings" ALTER COLUMN id SET DEFAULT nextval('public."OrganizationSettings_id_seq"'::regclass);


--
-- Name: OutOfOfficeEntry id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OutOfOfficeEntry" ALTER COLUMN id SET DEFAULT nextval('public."OutOfOfficeEntry_id_seq"'::regclass);


--
-- Name: OutOfOfficeReason id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OutOfOfficeReason" ALTER COLUMN id SET DEFAULT nextval('public."OutOfOfficeReason_id_seq"'::regclass);


--
-- Name: Payment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payment" ALTER COLUMN id SET DEFAULT nextval('public."Payment_id_seq"'::regclass);


--
-- Name: Profile id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Profile" ALTER COLUMN id SET DEFAULT nextval('public."Profile_id_seq"'::regclass);


--
-- Name: RefreshToken id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RefreshToken" ALTER COLUMN id SET DEFAULT nextval('public."RefreshToken_id_seq"'::regclass);


--
-- Name: ReminderMail id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReminderMail" ALTER COLUMN id SET DEFAULT nextval('public."ReminderMail_id_seq"'::regclass);


--
-- Name: RoutingFormResponseField id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RoutingFormResponseField" ALTER COLUMN id SET DEFAULT nextval('public."RoutingFormResponseField_id_seq"'::regclass);


--
-- Name: Schedule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Schedule" ALTER COLUMN id SET DEFAULT nextval('public."Schedule_id_seq"'::regclass);


--
-- Name: SecondaryEmail id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SecondaryEmail" ALTER COLUMN id SET DEFAULT nextval('public."SecondaryEmail_id_seq"'::regclass);


--
-- Name: SelectedSlots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SelectedSlots" ALTER COLUMN id SET DEFAULT nextval('public."SelectedSlots_id_seq"'::regclass);


--
-- Name: Team id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Team" ALTER COLUMN id SET DEFAULT nextval('public."Team_id_seq"'::regclass);


--
-- Name: TempOrgRedirect id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TempOrgRedirect" ALTER COLUMN id SET DEFAULT nextval('public."TempOrgRedirect_id_seq"'::regclass);


--
-- Name: Tracking id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Tracking" ALTER COLUMN id SET DEFAULT nextval('public."Tracking_id_seq"'::regclass);


--
-- Name: TravelSchedule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TravelSchedule" ALTER COLUMN id SET DEFAULT nextval('public."TravelSchedule_id_seq"'::regclass);


--
-- Name: UserFilterSegmentPreference id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserFilterSegmentPreference" ALTER COLUMN id SET DEFAULT nextval('public."UserFilterSegmentPreference_id_seq"'::regclass);


--
-- Name: UserHolidaySettings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserHolidaySettings" ALTER COLUMN id SET DEFAULT nextval('public."UserHolidaySettings_id_seq"'::regclass);


--
-- Name: VerificationToken id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VerificationToken" ALTER COLUMN id SET DEFAULT nextval('public."VerificationRequest_id_seq"'::regclass);


--
-- Name: VerifiedEmail id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VerifiedEmail" ALTER COLUMN id SET DEFAULT nextval('public."VerifiedEmail_id_seq"'::regclass);


--
-- Name: VerifiedNumber id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VerifiedNumber" ALTER COLUMN id SET DEFAULT nextval('public."VerifiedNumber_id_seq"'::regclass);


--
-- Name: WebhookScheduledTriggers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WebhookScheduledTriggers" ALTER COLUMN id SET DEFAULT nextval('public."WebhookScheduledTriggers_id_seq"'::regclass);


--
-- Name: Workflow id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Workflow" ALTER COLUMN id SET DEFAULT nextval('public."Workflow_id_seq"'::regclass);


--
-- Name: WorkflowOptOutContact id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowOptOutContact" ALTER COLUMN id SET DEFAULT nextval('public."WorkflowOptOutContact_id_seq"'::regclass);


--
-- Name: WorkflowReminder id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowReminder" ALTER COLUMN id SET DEFAULT nextval('public."WorkflowReminder_id_seq"'::regclass);


--
-- Name: WorkflowStep id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowStep" ALTER COLUMN id SET DEFAULT nextval('public."WorkflowStep_id_seq"'::regclass);


--
-- Name: WorkflowsOnEventTypes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowsOnEventTypes" ALTER COLUMN id SET DEFAULT nextval('public."WorkflowsOnEventTypes_id_seq"'::regclass);


--
-- Name: WorkflowsOnRoutingForms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowsOnRoutingForms" ALTER COLUMN id SET DEFAULT nextval('public."WorkflowsOnRoutingForms_id_seq"'::regclass);


--
-- Name: WorkflowsOnTeams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowsOnTeams" ALTER COLUMN id SET DEFAULT nextval('public."WorkflowsOnTeams_id_seq"'::regclass);


--
-- Name: WorkspacePlatform id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkspacePlatform" ALTER COLUMN id SET DEFAULT nextval('public."WorkspacePlatform_id_seq"'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: AIPhoneCallConfiguration AIPhoneCallConfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AIPhoneCallConfiguration"
    ADD CONSTRAINT "AIPhoneCallConfiguration_pkey" PRIMARY KEY (id);


--
-- Name: AccessCode AccessCode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AccessCode"
    ADD CONSTRAINT "AccessCode_pkey" PRIMARY KEY (id);


--
-- Name: AccessToken AccessToken_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AccessToken"
    ADD CONSTRAINT "AccessToken_pkey" PRIMARY KEY (id);


--
-- Name: Account Account_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Account"
    ADD CONSTRAINT "Account_pkey" PRIMARY KEY (id);


--
-- Name: Agent Agent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Agent"
    ADD CONSTRAINT "Agent_pkey" PRIMARY KEY (id);


--
-- Name: ApiKey ApiKey_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ApiKey"
    ADD CONSTRAINT "ApiKey_pkey" PRIMARY KEY (id);


--
-- Name: App_RoutingForms_FormResponse App_RoutingForms_FormResponse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."App_RoutingForms_FormResponse"
    ADD CONSTRAINT "App_RoutingForms_FormResponse_pkey" PRIMARY KEY (id);


--
-- Name: App_RoutingForms_Form App_RoutingForms_Form_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."App_RoutingForms_Form"
    ADD CONSTRAINT "App_RoutingForms_Form_pkey" PRIMARY KEY (id);


--
-- Name: App_RoutingForms_IncompleteBookingActions App_RoutingForms_IncompleteBookingActions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."App_RoutingForms_IncompleteBookingActions"
    ADD CONSTRAINT "App_RoutingForms_IncompleteBookingActions_pkey" PRIMARY KEY (id);


--
-- Name: App_RoutingForms_QueuedFormResponse App_RoutingForms_QueuedFormResponse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."App_RoutingForms_QueuedFormResponse"
    ADD CONSTRAINT "App_RoutingForms_QueuedFormResponse_pkey" PRIMARY KEY (id);


--
-- Name: App App_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."App"
    ADD CONSTRAINT "App_pkey" PRIMARY KEY (slug);


--
-- Name: AssignmentReason AssignmentReason_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AssignmentReason"
    ADD CONSTRAINT "AssignmentReason_pkey" PRIMARY KEY (id);


--
-- Name: Attendee Attendee_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Attendee"
    ADD CONSTRAINT "Attendee_pkey" PRIMARY KEY (id);


--
-- Name: AttributeOption AttributeOption_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AttributeOption"
    ADD CONSTRAINT "AttributeOption_pkey" PRIMARY KEY (id);


--
-- Name: AttributeSyncFieldMapping AttributeSyncFieldMapping_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AttributeSyncFieldMapping"
    ADD CONSTRAINT "AttributeSyncFieldMapping_pkey" PRIMARY KEY (id);


--
-- Name: AttributeSyncRule AttributeSyncRule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AttributeSyncRule"
    ADD CONSTRAINT "AttributeSyncRule_pkey" PRIMARY KEY (id);


--
-- Name: AttributeToUser AttributeToUser_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AttributeToUser"
    ADD CONSTRAINT "AttributeToUser_pkey" PRIMARY KEY (id);


--
-- Name: Attribute Attribute_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Attribute"
    ADD CONSTRAINT "Attribute_pkey" PRIMARY KEY (id);


--
-- Name: AuditActor AuditActor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AuditActor"
    ADD CONSTRAINT "AuditActor_pkey" PRIMARY KEY (id);


--
-- Name: Availability Availability_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Availability"
    ADD CONSTRAINT "Availability_pkey" PRIMARY KEY (id);


--
-- Name: BookingAudit BookingAudit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingAudit"
    ADD CONSTRAINT "BookingAudit_pkey" PRIMARY KEY (id);


--
-- Name: BookingDenormalized BookingDenormalized_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingDenormalized"
    ADD CONSTRAINT "BookingDenormalized_pkey" PRIMARY KEY (id);


--
-- Name: BookingInternalNote BookingInternalNote_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingInternalNote"
    ADD CONSTRAINT "BookingInternalNote_pkey" PRIMARY KEY (id);


--
-- Name: BookingReference BookingReference_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingReference"
    ADD CONSTRAINT "BookingReference_pkey" PRIMARY KEY (id);


--
-- Name: BookingReport BookingReport_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingReport"
    ADD CONSTRAINT "BookingReport_pkey" PRIMARY KEY (id);


--
-- Name: BookingSeat BookingSeat_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingSeat"
    ADD CONSTRAINT "BookingSeat_pkey" PRIMARY KEY (id);


--
-- Name: Booking Booking_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Booking"
    ADD CONSTRAINT "Booking_pkey" PRIMARY KEY (id);


--
-- Name: CalAiPhoneNumber CalAiPhoneNumber_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CalAiPhoneNumber"
    ADD CONSTRAINT "CalAiPhoneNumber_pkey" PRIMARY KEY (id);


--
-- Name: CalVideoSettings CalVideoSettings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CalVideoSettings"
    ADD CONSTRAINT "CalVideoSettings_pkey" PRIMARY KEY ("eventTypeId");


--
-- Name: CalendarCacheEvent CalendarCacheEvent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CalendarCacheEvent"
    ADD CONSTRAINT "CalendarCacheEvent_pkey" PRIMARY KEY (id);


--
-- Name: CalendarCache CalendarCache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CalendarCache"
    ADD CONSTRAINT "CalendarCache_pkey" PRIMARY KEY ("credentialId", key);


--
-- Name: Credential Credential_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Credential"
    ADD CONSTRAINT "Credential_pkey" PRIMARY KEY (id);


--
-- Name: CreditBalance CreditBalance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditBalance"
    ADD CONSTRAINT "CreditBalance_pkey" PRIMARY KEY (id);


--
-- Name: CreditExpenseLog CreditExpenseLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditExpenseLog"
    ADD CONSTRAINT "CreditExpenseLog_pkey" PRIMARY KEY (id);


--
-- Name: CreditPurchaseLog CreditPurchaseLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditPurchaseLog"
    ADD CONSTRAINT "CreditPurchaseLog_pkey" PRIMARY KEY (id);


--
-- Name: DSyncData DSyncData_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DSyncData"
    ADD CONSTRAINT "DSyncData_pkey" PRIMARY KEY (id);


--
-- Name: DSyncTeamGroupMapping DSyncTeamGroupMapping_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DSyncTeamGroupMapping"
    ADD CONSTRAINT "DSyncTeamGroupMapping_pkey" PRIMARY KEY (id);


--
-- Name: DelegationCredential DelegationCredential_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DelegationCredential"
    ADD CONSTRAINT "DelegationCredential_pkey" PRIMARY KEY (id);


--
-- Name: Deployment Deployment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Deployment"
    ADD CONSTRAINT "Deployment_pkey" PRIMARY KEY (id);


--
-- Name: DestinationCalendar DestinationCalendar_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DestinationCalendar"
    ADD CONSTRAINT "DestinationCalendar_pkey" PRIMARY KEY (id);


--
-- Name: DomainWideDelegation DomainWideDelegation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DomainWideDelegation"
    ADD CONSTRAINT "DomainWideDelegation_pkey" PRIMARY KEY (id);


--
-- Name: EventTypeCustomInput EventTypeCustomInput_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventTypeCustomInput"
    ADD CONSTRAINT "EventTypeCustomInput_pkey" PRIMARY KEY (id);


--
-- Name: EventTypeTranslation EventTypeTranslation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventTypeTranslation"
    ADD CONSTRAINT "EventTypeTranslation_pkey" PRIMARY KEY (uid);


--
-- Name: EventType EventType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventType"
    ADD CONSTRAINT "EventType_pkey" PRIMARY KEY (id);


--
-- Name: Feature Feature_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Feature"
    ADD CONSTRAINT "Feature_pkey" PRIMARY KEY (slug);


--
-- Name: Feedback Feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Feedback"
    ADD CONSTRAINT "Feedback_pkey" PRIMARY KEY (id);


--
-- Name: FilterSegment FilterSegment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FilterSegment"
    ADD CONSTRAINT "FilterSegment_pkey" PRIMARY KEY (id);


--
-- Name: HashedLink HashedLink_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."HashedLink"
    ADD CONSTRAINT "HashedLink_pkey" PRIMARY KEY (id);


--
-- Name: HolidayCache HolidayCache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."HolidayCache"
    ADD CONSTRAINT "HolidayCache_pkey" PRIMARY KEY (id);


--
-- Name: HostGroup HostGroup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."HostGroup"
    ADD CONSTRAINT "HostGroup_pkey" PRIMARY KEY (id);


--
-- Name: HostLocation HostLocation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."HostLocation"
    ADD CONSTRAINT "HostLocation_pkey" PRIMARY KEY (id);


--
-- Name: Host Host_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Host"
    ADD CONSTRAINT "Host_pkey" PRIMARY KEY ("userId", "eventTypeId");


--
-- Name: Impersonations Impersonations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Impersonations"
    ADD CONSTRAINT "Impersonations_pkey" PRIMARY KEY (id);


--
-- Name: InstantMeetingToken InstantMeetingToken_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InstantMeetingToken"
    ADD CONSTRAINT "InstantMeetingToken_pkey" PRIMARY KEY (id);


--
-- Name: IntegrationAttributeSync IntegrationAttributeSync_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."IntegrationAttributeSync"
    ADD CONSTRAINT "IntegrationAttributeSync_pkey" PRIMARY KEY (id);


--
-- Name: InternalNotePreset InternalNotePreset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InternalNotePreset"
    ADD CONSTRAINT "InternalNotePreset_pkey" PRIMARY KEY (id);


--
-- Name: Membership Membership_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Membership"
    ADD CONSTRAINT "Membership_pkey" PRIMARY KEY (id);


--
-- Name: MonthlyProration MonthlyProration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MonthlyProration"
    ADD CONSTRAINT "MonthlyProration_pkey" PRIMARY KEY (id);


--
-- Name: NotificationsSubscriptions NotificationsSubscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NotificationsSubscriptions"
    ADD CONSTRAINT "NotificationsSubscriptions_pkey" PRIMARY KEY (id);


--
-- Name: OAuthClient OAuthClient_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OAuthClient"
    ADD CONSTRAINT "OAuthClient_pkey" PRIMARY KEY ("clientId");


--
-- Name: OrganizationBilling OrganizationBilling_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OrganizationBilling"
    ADD CONSTRAINT "OrganizationBilling_pkey" PRIMARY KEY (id);


--
-- Name: OrganizationOnboarding OrganizationOnboarding_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OrganizationOnboarding"
    ADD CONSTRAINT "OrganizationOnboarding_pkey" PRIMARY KEY (id);


--
-- Name: OrganizationSettings OrganizationSettings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OrganizationSettings"
    ADD CONSTRAINT "OrganizationSettings_pkey" PRIMARY KEY (id);


--
-- Name: OutOfOfficeEntry OutOfOfficeEntry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OutOfOfficeEntry"
    ADD CONSTRAINT "OutOfOfficeEntry_pkey" PRIMARY KEY (id);


--
-- Name: OutOfOfficeReason OutOfOfficeReason_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OutOfOfficeReason"
    ADD CONSTRAINT "OutOfOfficeReason_pkey" PRIMARY KEY (id);


--
-- Name: Payment Payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_pkey" PRIMARY KEY (id);


--
-- Name: PendingRoutingTrace PendingRoutingTrace_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PendingRoutingTrace"
    ADD CONSTRAINT "PendingRoutingTrace_pkey" PRIMARY KEY (id);


--
-- Name: PlatformAuthorizationToken PlatformAuthorizationToken_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PlatformAuthorizationToken"
    ADD CONSTRAINT "PlatformAuthorizationToken_pkey" PRIMARY KEY (id);


--
-- Name: PlatformBilling PlatformBilling_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PlatformBilling"
    ADD CONSTRAINT "PlatformBilling_pkey" PRIMARY KEY (id);


--
-- Name: PlatformOAuthClient PlatformOAuthClient_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PlatformOAuthClient"
    ADD CONSTRAINT "PlatformOAuthClient_pkey" PRIMARY KEY (id);


--
-- Name: Profile Profile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Profile"
    ADD CONSTRAINT "Profile_pkey" PRIMARY KEY (id);


--
-- Name: RateLimit RateLimit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RateLimit"
    ADD CONSTRAINT "RateLimit_pkey" PRIMARY KEY (id);


--
-- Name: RefreshToken RefreshToken_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RefreshToken"
    ADD CONSTRAINT "RefreshToken_pkey" PRIMARY KEY (id);


--
-- Name: ReminderMail ReminderMail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReminderMail"
    ADD CONSTRAINT "ReminderMail_pkey" PRIMARY KEY (id);


--
-- Name: ResetPasswordRequest ResetPasswordRequest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ResetPasswordRequest"
    ADD CONSTRAINT "ResetPasswordRequest_pkey" PRIMARY KEY (id);


--
-- Name: RolePermission RolePermission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RolePermission"
    ADD CONSTRAINT "RolePermission_pkey" PRIMARY KEY (id);


--
-- Name: Role Role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Role"
    ADD CONSTRAINT "Role_pkey" PRIMARY KEY (id);


--
-- Name: RoutingFormResponseDenormalized RoutingFormResponseDenormalized_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RoutingFormResponseDenormalized"
    ADD CONSTRAINT "RoutingFormResponseDenormalized_pkey" PRIMARY KEY (id);


--
-- Name: RoutingFormResponseField RoutingFormResponseField_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RoutingFormResponseField"
    ADD CONSTRAINT "RoutingFormResponseField_pkey" PRIMARY KEY (id);


--
-- Name: RoutingTrace RoutingTrace_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RoutingTrace"
    ADD CONSTRAINT "RoutingTrace_pkey" PRIMARY KEY (id);


--
-- Name: Schedule Schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Schedule"
    ADD CONSTRAINT "Schedule_pkey" PRIMARY KEY (id);


--
-- Name: SeatChangeLog SeatChangeLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SeatChangeLog"
    ADD CONSTRAINT "SeatChangeLog_pkey" PRIMARY KEY (id);


--
-- Name: SecondaryEmail SecondaryEmail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SecondaryEmail"
    ADD CONSTRAINT "SecondaryEmail_pkey" PRIMARY KEY (id);


--
-- Name: SelectedCalendar SelectedCalendar_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SelectedCalendar"
    ADD CONSTRAINT "SelectedCalendar_pkey" PRIMARY KEY (id);


--
-- Name: SelectedSlots SelectedSlots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SelectedSlots"
    ADD CONSTRAINT "SelectedSlots_pkey" PRIMARY KEY (id);


--
-- Name: Session Session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Session"
    ADD CONSTRAINT "Session_pkey" PRIMARY KEY (id);


--
-- Name: Task Task_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Task"
    ADD CONSTRAINT "Task_pkey" PRIMARY KEY (id);


--
-- Name: TeamBilling TeamBilling_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TeamBilling"
    ADD CONSTRAINT "TeamBilling_pkey" PRIMARY KEY (id);


--
-- Name: TeamFeatures TeamFeatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TeamFeatures"
    ADD CONSTRAINT "TeamFeatures_pkey" PRIMARY KEY ("teamId", "featureId");


--
-- Name: Team Team_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Team"
    ADD CONSTRAINT "Team_pkey" PRIMARY KEY (id);


--
-- Name: TempOrgRedirect TempOrgRedirect_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TempOrgRedirect"
    ADD CONSTRAINT "TempOrgRedirect_pkey" PRIMARY KEY (id);


--
-- Name: Tracking Tracking_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Tracking"
    ADD CONSTRAINT "Tracking_pkey" PRIMARY KEY (id);


--
-- Name: TravelSchedule TravelSchedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TravelSchedule"
    ADD CONSTRAINT "TravelSchedule_pkey" PRIMARY KEY (id);


--
-- Name: UserFeatures UserFeatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserFeatures"
    ADD CONSTRAINT "UserFeatures_pkey" PRIMARY KEY ("userId", "featureId");


--
-- Name: UserFilterSegmentPreference UserFilterSegmentPreference_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserFilterSegmentPreference"
    ADD CONSTRAINT "UserFilterSegmentPreference_pkey" PRIMARY KEY (id);


--
-- Name: UserHolidaySettings UserHolidaySettings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserHolidaySettings"
    ADD CONSTRAINT "UserHolidaySettings_pkey" PRIMARY KEY (id);


--
-- Name: VerificationToken VerificationToken_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VerificationToken"
    ADD CONSTRAINT "VerificationToken_pkey" PRIMARY KEY (id);


--
-- Name: VerifiedEmail VerifiedEmail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VerifiedEmail"
    ADD CONSTRAINT "VerifiedEmail_pkey" PRIMARY KEY (id);


--
-- Name: VerifiedNumber VerifiedNumber_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VerifiedNumber"
    ADD CONSTRAINT "VerifiedNumber_pkey" PRIMARY KEY (id);


--
-- Name: VideoCallGuest VideoCallGuest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VideoCallGuest"
    ADD CONSTRAINT "VideoCallGuest_pkey" PRIMARY KEY (id);


--
-- Name: WatchlistAudit WatchlistAudit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WatchlistAudit"
    ADD CONSTRAINT "WatchlistAudit_pkey" PRIMARY KEY (id);


--
-- Name: WatchlistEventAudit WatchlistEventAudit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WatchlistEventAudit"
    ADD CONSTRAINT "WatchlistEventAudit_pkey" PRIMARY KEY (id);


--
-- Name: Watchlist Watchlist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Watchlist"
    ADD CONSTRAINT "Watchlist_pkey" PRIMARY KEY (id);


--
-- Name: WebhookScheduledTriggers WebhookScheduledTriggers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WebhookScheduledTriggers"
    ADD CONSTRAINT "WebhookScheduledTriggers_pkey" PRIMARY KEY (id);


--
-- Name: Webhook Webhook_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Webhook"
    ADD CONSTRAINT "Webhook_pkey" PRIMARY KEY (id);


--
-- Name: WorkflowOptOutContact WorkflowOptOutContact_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowOptOutContact"
    ADD CONSTRAINT "WorkflowOptOutContact_pkey" PRIMARY KEY (id);


--
-- Name: WorkflowReminder WorkflowReminder_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowReminder"
    ADD CONSTRAINT "WorkflowReminder_pkey" PRIMARY KEY (id);


--
-- Name: WorkflowStepTranslation WorkflowStepTranslation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowStepTranslation"
    ADD CONSTRAINT "WorkflowStepTranslation_pkey" PRIMARY KEY (uid);


--
-- Name: WorkflowStep WorkflowStep_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowStep"
    ADD CONSTRAINT "WorkflowStep_pkey" PRIMARY KEY (id);


--
-- Name: Workflow Workflow_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Workflow"
    ADD CONSTRAINT "Workflow_pkey" PRIMARY KEY (id);


--
-- Name: WorkflowsOnEventTypes WorkflowsOnEventTypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowsOnEventTypes"
    ADD CONSTRAINT "WorkflowsOnEventTypes_pkey" PRIMARY KEY (id);


--
-- Name: WorkflowsOnRoutingForms WorkflowsOnRoutingForms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowsOnRoutingForms"
    ADD CONSTRAINT "WorkflowsOnRoutingForms_pkey" PRIMARY KEY (id);


--
-- Name: WorkflowsOnTeams WorkflowsOnTeams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowsOnTeams"
    ADD CONSTRAINT "WorkflowsOnTeams_pkey" PRIMARY KEY (id);


--
-- Name: WorkspacePlatform WorkspacePlatform_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkspacePlatform"
    ADD CONSTRAINT "WorkspacePlatform_pkey" PRIMARY KEY (id);


--
-- Name: WrongAssignmentReport WrongAssignmentReport_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WrongAssignmentReport"
    ADD CONSTRAINT "WrongAssignmentReport_pkey" PRIMARY KEY (id);


--
-- Name: _PlatformOAuthClientToUser _PlatformOAuthClientToUser_AB_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_PlatformOAuthClientToUser"
    ADD CONSTRAINT "_PlatformOAuthClientToUser_AB_pkey" PRIMARY KEY ("A", "B");


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: _user_eventtype _user_eventtype_AB_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._user_eventtype
    ADD CONSTRAINT "_user_eventtype_AB_pkey" PRIMARY KEY ("A", "B");


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: AIPhoneCallConfiguration_eventTypeId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AIPhoneCallConfiguration_eventTypeId_idx" ON public."AIPhoneCallConfiguration" USING btree ("eventTypeId");


--
-- Name: AIPhoneCallConfiguration_eventTypeId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AIPhoneCallConfiguration_eventTypeId_key" ON public."AIPhoneCallConfiguration" USING btree ("eventTypeId");


--
-- Name: AccessToken_secret_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AccessToken_secret_key" ON public."AccessToken" USING btree (secret);


--
-- Name: Account_provider_providerAccountId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Account_provider_providerAccountId_key" ON public."Account" USING btree (provider, "providerAccountId");


--
-- Name: Account_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Account_type_idx" ON public."Account" USING btree (type);


--
-- Name: Account_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Account_userId_idx" ON public."Account" USING btree ("userId");


--
-- Name: Agent_inboundEventTypeId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Agent_inboundEventTypeId_idx" ON public."Agent" USING btree ("inboundEventTypeId");


--
-- Name: Agent_outboundEventTypeId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Agent_outboundEventTypeId_idx" ON public."Agent" USING btree ("outboundEventTypeId");


--
-- Name: Agent_providerAgentId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Agent_providerAgentId_key" ON public."Agent" USING btree ("providerAgentId");


--
-- Name: Agent_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Agent_teamId_idx" ON public."Agent" USING btree ("teamId");


--
-- Name: Agent_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Agent_userId_idx" ON public."Agent" USING btree ("userId");


--
-- Name: ApiKey_hashedKey_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ApiKey_hashedKey_key" ON public."ApiKey" USING btree ("hashedKey");


--
-- Name: ApiKey_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ApiKey_id_key" ON public."ApiKey" USING btree (id);


--
-- Name: ApiKey_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ApiKey_userId_idx" ON public."ApiKey" USING btree ("userId");


--
-- Name: App_RoutingForms_FormResponse_formFillerId_formId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "App_RoutingForms_FormResponse_formFillerId_formId_key" ON public."App_RoutingForms_FormResponse" USING btree ("formFillerId", "formId");


--
-- Name: App_RoutingForms_FormResponse_formFillerId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "App_RoutingForms_FormResponse_formFillerId_idx" ON public."App_RoutingForms_FormResponse" USING btree ("formFillerId");


--
-- Name: App_RoutingForms_FormResponse_formId_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "App_RoutingForms_FormResponse_formId_createdAt_idx" ON public."App_RoutingForms_FormResponse" USING btree ("formId", "createdAt");


--
-- Name: App_RoutingForms_FormResponse_formId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "App_RoutingForms_FormResponse_formId_idx" ON public."App_RoutingForms_FormResponse" USING btree ("formId");


--
-- Name: App_RoutingForms_FormResponse_routedToBookingUid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "App_RoutingForms_FormResponse_routedToBookingUid_idx" ON public."App_RoutingForms_FormResponse" USING btree ("routedToBookingUid");


--
-- Name: App_RoutingForms_FormResponse_routedToBookingUid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "App_RoutingForms_FormResponse_routedToBookingUid_key" ON public."App_RoutingForms_FormResponse" USING btree ("routedToBookingUid");


--
-- Name: App_RoutingForms_Form_disabled_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "App_RoutingForms_Form_disabled_idx" ON public."App_RoutingForms_Form" USING btree (disabled);


--
-- Name: App_RoutingForms_Form_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "App_RoutingForms_Form_userId_idx" ON public."App_RoutingForms_Form" USING btree ("userId");


--
-- Name: App_RoutingForms_QueuedFormResponse_actualResponseId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "App_RoutingForms_QueuedFormResponse_actualResponseId_key" ON public."App_RoutingForms_QueuedFormResponse" USING btree ("actualResponseId");


--
-- Name: App_dirName_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "App_dirName_key" ON public."App" USING btree ("dirName");


--
-- Name: App_enabled_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "App_enabled_idx" ON public."App" USING btree (enabled);


--
-- Name: App_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "App_slug_key" ON public."App" USING btree (slug);


--
-- Name: AssignmentReason_bookingId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AssignmentReason_bookingId_idx" ON public."AssignmentReason" USING btree ("bookingId");


--
-- Name: AssignmentReason_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AssignmentReason_id_key" ON public."AssignmentReason" USING btree (id);


--
-- Name: Attendee_bookingId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Attendee_bookingId_idx" ON public."Attendee" USING btree ("bookingId");


--
-- Name: Attendee_email_bookingId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Attendee_email_bookingId_idx" ON public."Attendee" USING btree (email, "bookingId");


--
-- Name: Attendee_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Attendee_email_idx" ON public."Attendee" USING btree (email);


--
-- Name: AttributeSyncFieldMapping_integrationAttributeSyncId_attrib_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AttributeSyncFieldMapping_integrationAttributeSyncId_attrib_key" ON public."AttributeSyncFieldMapping" USING btree ("integrationAttributeSyncId", "attributeId");


--
-- Name: AttributeSyncFieldMapping_integrationAttributeSyncId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AttributeSyncFieldMapping_integrationAttributeSyncId_idx" ON public."AttributeSyncFieldMapping" USING btree ("integrationAttributeSyncId");


--
-- Name: AttributeSyncRule_integrationAttributeSyncId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AttributeSyncRule_integrationAttributeSyncId_key" ON public."AttributeSyncRule" USING btree ("integrationAttributeSyncId");


--
-- Name: AttributeToUser_memberId_attributeOptionId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AttributeToUser_memberId_attributeOptionId_key" ON public."AttributeToUser" USING btree ("memberId", "attributeOptionId");


--
-- Name: Attribute_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Attribute_teamId_idx" ON public."Attribute" USING btree ("teamId");


--
-- Name: Attribute_teamId_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Attribute_teamId_slug_key" ON public."Attribute" USING btree ("teamId", slug);


--
-- Name: AuditActor_attendeeId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AuditActor_attendeeId_idx" ON public."AuditActor" USING btree ("attendeeId");


--
-- Name: AuditActor_attendeeId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AuditActor_attendeeId_key" ON public."AuditActor" USING btree ("attendeeId");


--
-- Name: AuditActor_credentialId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AuditActor_credentialId_idx" ON public."AuditActor" USING btree ("credentialId");


--
-- Name: AuditActor_credentialId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AuditActor_credentialId_key" ON public."AuditActor" USING btree ("credentialId");


--
-- Name: AuditActor_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AuditActor_email_idx" ON public."AuditActor" USING btree (email);


--
-- Name: AuditActor_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AuditActor_email_key" ON public."AuditActor" USING btree (email);


--
-- Name: AuditActor_phone_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AuditActor_phone_key" ON public."AuditActor" USING btree (phone);


--
-- Name: AuditActor_userUuid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AuditActor_userUuid_idx" ON public."AuditActor" USING btree ("userUuid");


--
-- Name: AuditActor_userUuid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AuditActor_userUuid_key" ON public."AuditActor" USING btree ("userUuid");


--
-- Name: Availability_eventTypeId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Availability_eventTypeId_idx" ON public."Availability" USING btree ("eventTypeId");


--
-- Name: Availability_scheduleId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Availability_scheduleId_idx" ON public."Availability" USING btree ("scheduleId");


--
-- Name: Availability_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Availability_userId_idx" ON public."Availability" USING btree ("userId");


--
-- Name: BookingAudit_actorId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingAudit_actorId_idx" ON public."BookingAudit" USING btree ("actorId");


--
-- Name: BookingAudit_bookingUid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingAudit_bookingUid_idx" ON public."BookingAudit" USING btree ("bookingUid");


--
-- Name: BookingAudit_operationId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingAudit_operationId_idx" ON public."BookingAudit" USING btree ("operationId");


--
-- Name: BookingAudit_timestamp_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingAudit_timestamp_idx" ON public."BookingAudit" USING btree ("timestamp");


--
-- Name: BookingDenormalized_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingDenormalized_createdAt_idx" ON public."BookingDenormalized" USING btree ("createdAt");


--
-- Name: BookingDenormalized_endTime_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingDenormalized_endTime_idx" ON public."BookingDenormalized" USING btree ("endTime");


--
-- Name: BookingDenormalized_eventParentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingDenormalized_eventParentId_idx" ON public."BookingDenormalized" USING btree ("eventParentId");


--
-- Name: BookingDenormalized_eventTypeId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingDenormalized_eventTypeId_idx" ON public."BookingDenormalized" USING btree ("eventTypeId");


--
-- Name: BookingDenormalized_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "BookingDenormalized_id_key" ON public."BookingDenormalized" USING btree (id);


--
-- Name: BookingDenormalized_startTime_endTime_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingDenormalized_startTime_endTime_idx" ON public."BookingDenormalized" USING btree ("startTime", "endTime");


--
-- Name: BookingDenormalized_startTime_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingDenormalized_startTime_idx" ON public."BookingDenormalized" USING btree ("startTime");


--
-- Name: BookingDenormalized_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingDenormalized_status_idx" ON public."BookingDenormalized" USING btree (status);


--
-- Name: BookingDenormalized_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingDenormalized_teamId_idx" ON public."BookingDenormalized" USING btree ("teamId");


--
-- Name: BookingDenormalized_teamId_isTeamBooking_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingDenormalized_teamId_isTeamBooking_idx" ON public."BookingDenormalized" USING btree ("teamId", "isTeamBooking");


--
-- Name: BookingDenormalized_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingDenormalized_userId_idx" ON public."BookingDenormalized" USING btree ("userId");


--
-- Name: BookingDenormalized_userId_isTeamBooking_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingDenormalized_userId_isTeamBooking_idx" ON public."BookingDenormalized" USING btree ("userId", "isTeamBooking");


--
-- Name: BookingInternalNote_bookingId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingInternalNote_bookingId_idx" ON public."BookingInternalNote" USING btree ("bookingId");


--
-- Name: BookingInternalNote_bookingId_notePresetId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "BookingInternalNote_bookingId_notePresetId_key" ON public."BookingInternalNote" USING btree ("bookingId", "notePresetId");


--
-- Name: BookingReference_bookingId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingReference_bookingId_idx" ON public."BookingReference" USING btree ("bookingId");


--
-- Name: BookingReference_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingReference_type_idx" ON public."BookingReference" USING btree (type);


--
-- Name: BookingReference_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingReference_uid_idx" ON public."BookingReference" USING btree (uid);


--
-- Name: BookingReport_bookerEmail_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingReport_bookerEmail_idx" ON public."BookingReport" USING btree ("bookerEmail");


--
-- Name: BookingReport_bookingUid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "BookingReport_bookingUid_key" ON public."BookingReport" USING btree ("bookingUid");


--
-- Name: BookingReport_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingReport_createdAt_idx" ON public."BookingReport" USING btree ("createdAt");


--
-- Name: BookingReport_globalWatchlistId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingReport_globalWatchlistId_idx" ON public."BookingReport" USING btree ("globalWatchlistId");


--
-- Name: BookingReport_organizationId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingReport_organizationId_idx" ON public."BookingReport" USING btree ("organizationId");


--
-- Name: BookingReport_reportedById_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingReport_reportedById_idx" ON public."BookingReport" USING btree ("reportedById");


--
-- Name: BookingReport_systemStatus_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingReport_systemStatus_idx" ON public."BookingReport" USING btree ("systemStatus");


--
-- Name: BookingReport_watchlistId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingReport_watchlistId_idx" ON public."BookingReport" USING btree ("watchlistId");


--
-- Name: BookingSeat_attendeeId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingSeat_attendeeId_idx" ON public."BookingSeat" USING btree ("attendeeId");


--
-- Name: BookingSeat_attendeeId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "BookingSeat_attendeeId_key" ON public."BookingSeat" USING btree ("attendeeId");


--
-- Name: BookingSeat_bookingId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingSeat_bookingId_idx" ON public."BookingSeat" USING btree ("bookingId");


--
-- Name: BookingSeat_referenceUid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "BookingSeat_referenceUid_key" ON public."BookingSeat" USING btree ("referenceUid");


--
-- Name: Booking_destinationCalendarId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_destinationCalendarId_idx" ON public."Booking" USING btree ("destinationCalendarId");


--
-- Name: Booking_eventTypeId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_eventTypeId_idx" ON public."Booking" USING btree ("eventTypeId");


--
-- Name: Booking_eventTypeId_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_eventTypeId_status_idx" ON public."Booking" USING btree ("eventTypeId", status);


--
-- Name: Booking_fromReschedule_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_fromReschedule_idx" ON public."Booking" USING btree ("fromReschedule");


--
-- Name: Booking_idempotencyKey_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Booking_idempotencyKey_key" ON public."Booking" USING btree ("idempotencyKey");


--
-- Name: Booking_oneTimePassword_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Booking_oneTimePassword_key" ON public."Booking" USING btree ("oneTimePassword");


--
-- Name: Booking_reassignById_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_reassignById_idx" ON public."Booking" USING btree ("reassignById") WHERE ("reassignById" IS NOT NULL);


--
-- Name: Booking_recurringEventId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_recurringEventId_idx" ON public."Booking" USING btree ("recurringEventId");


--
-- Name: Booking_startTime_endTime_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_startTime_endTime_status_idx" ON public."Booking" USING btree ("startTime", "endTime", status);


--
-- Name: Booking_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_status_idx" ON public."Booking" USING btree (status);


--
-- Name: Booking_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_uid_idx" ON public."Booking" USING btree (uid);


--
-- Name: Booking_uid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Booking_uid_key" ON public."Booking" USING btree (uid);


--
-- Name: Booking_userId_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_userId_createdAt_idx" ON public."Booking" USING btree ("userId", "createdAt");


--
-- Name: Booking_userId_endTime_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_userId_endTime_idx" ON public."Booking" USING btree ("userId", "endTime");


--
-- Name: Booking_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_userId_idx" ON public."Booking" USING btree ("userId");


--
-- Name: Booking_userId_status_startTime_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_userId_status_startTime_idx" ON public."Booking" USING btree ("userId", status, "startTime");


--
-- Name: CalAiPhoneNumber_inboundAgentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CalAiPhoneNumber_inboundAgentId_idx" ON public."CalAiPhoneNumber" USING btree ("inboundAgentId");


--
-- Name: CalAiPhoneNumber_outboundAgentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CalAiPhoneNumber_outboundAgentId_idx" ON public."CalAiPhoneNumber" USING btree ("outboundAgentId");


--
-- Name: CalAiPhoneNumber_phoneNumber_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CalAiPhoneNumber_phoneNumber_key" ON public."CalAiPhoneNumber" USING btree ("phoneNumber");


--
-- Name: CalAiPhoneNumber_providerPhoneNumberId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CalAiPhoneNumber_providerPhoneNumberId_key" ON public."CalAiPhoneNumber" USING btree ("providerPhoneNumberId");


--
-- Name: CalAiPhoneNumber_stripeSubscriptionId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CalAiPhoneNumber_stripeSubscriptionId_key" ON public."CalAiPhoneNumber" USING btree ("stripeSubscriptionId");


--
-- Name: CalAiPhoneNumber_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CalAiPhoneNumber_teamId_idx" ON public."CalAiPhoneNumber" USING btree ("teamId");


--
-- Name: CalAiPhoneNumber_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CalAiPhoneNumber_userId_idx" ON public."CalAiPhoneNumber" USING btree ("userId");


--
-- Name: CalendarCacheEvent_selectedCalendarId_externalId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CalendarCacheEvent_selectedCalendarId_externalId_key" ON public."CalendarCacheEvent" USING btree ("selectedCalendarId", "externalId");


--
-- Name: CalendarCacheEvent_selectedCalendarId_iCalUID_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CalendarCacheEvent_selectedCalendarId_iCalUID_idx" ON public."CalendarCacheEvent" USING btree ("selectedCalendarId", "iCalUID");


--
-- Name: CalendarCacheEvent_start_end_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CalendarCacheEvent_start_end_status_idx" ON public."CalendarCacheEvent" USING btree (start, "end", status);


--
-- Name: CalendarCache_credentialId_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CalendarCache_credentialId_key_key" ON public."CalendarCache" USING btree ("credentialId", key);


--
-- Name: CalendarCache_userId_key_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CalendarCache_userId_key_idx" ON public."CalendarCache" USING btree ("userId", key);


--
-- Name: Credential_appId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Credential_appId_idx" ON public."Credential" USING btree ("appId");


--
-- Name: Credential_invalid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Credential_invalid_idx" ON public."Credential" USING btree (invalid);


--
-- Name: Credential_subscriptionId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Credential_subscriptionId_idx" ON public."Credential" USING btree ("subscriptionId");


--
-- Name: Credential_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Credential_teamId_idx" ON public."Credential" USING btree ("teamId");


--
-- Name: Credential_userId_delegationCredentialId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Credential_userId_delegationCredentialId_idx" ON public."Credential" USING btree ("userId", "delegationCredentialId");


--
-- Name: CreditBalance_teamId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CreditBalance_teamId_key" ON public."CreditBalance" USING btree ("teamId");


--
-- Name: CreditBalance_userId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CreditBalance_userId_key" ON public."CreditBalance" USING btree ("userId");


--
-- Name: CreditExpenseLog_bookingUid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CreditExpenseLog_bookingUid_idx" ON public."CreditExpenseLog" USING btree ("bookingUid") WHERE ("bookingUid" IS NOT NULL);


--
-- Name: CreditExpenseLog_externalRef_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CreditExpenseLog_externalRef_key" ON public."CreditExpenseLog" USING btree ("externalRef");


--
-- Name: DSyncData_directoryId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DSyncData_directoryId_key" ON public."DSyncData" USING btree ("directoryId");


--
-- Name: DSyncData_organizationId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DSyncData_organizationId_key" ON public."DSyncData" USING btree ("organizationId");


--
-- Name: DSyncTeamGroupMapping_teamId_groupName_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DSyncTeamGroupMapping_teamId_groupName_key" ON public."DSyncTeamGroupMapping" USING btree ("teamId", "groupName");


--
-- Name: DelegationCredential_enabled_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DelegationCredential_enabled_idx" ON public."DelegationCredential" USING btree (enabled);


--
-- Name: DelegationCredential_organizationId_domain_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DelegationCredential_organizationId_domain_key" ON public."DelegationCredential" USING btree ("organizationId", domain);


--
-- Name: DestinationCalendar_credentialId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DestinationCalendar_credentialId_idx" ON public."DestinationCalendar" USING btree ("credentialId");


--
-- Name: DestinationCalendar_eventTypeId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DestinationCalendar_eventTypeId_idx" ON public."DestinationCalendar" USING btree ("eventTypeId");


--
-- Name: DestinationCalendar_eventTypeId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DestinationCalendar_eventTypeId_key" ON public."DestinationCalendar" USING btree ("eventTypeId");


--
-- Name: DestinationCalendar_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DestinationCalendar_userId_idx" ON public."DestinationCalendar" USING btree ("userId");


--
-- Name: DestinationCalendar_userId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DestinationCalendar_userId_key" ON public."DestinationCalendar" USING btree ("userId");


--
-- Name: DomainWideDelegation_organizationId_domain_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DomainWideDelegation_organizationId_domain_key" ON public."DomainWideDelegation" USING btree ("organizationId", domain);


--
-- Name: EventTypeCustomInput_eventTypeId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "EventTypeCustomInput_eventTypeId_idx" ON public."EventTypeCustomInput" USING btree ("eventTypeId");


--
-- Name: EventTypeTranslation_eventTypeId_field_targetLocale_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "EventTypeTranslation_eventTypeId_field_targetLocale_idx" ON public."EventTypeTranslation" USING btree ("eventTypeId", field, "targetLocale");


--
-- Name: EventTypeTranslation_eventTypeId_field_targetLocale_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "EventTypeTranslation_eventTypeId_field_targetLocale_key" ON public."EventTypeTranslation" USING btree ("eventTypeId", field, "targetLocale");


--
-- Name: EventType_instantMeetingScheduleId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "EventType_instantMeetingScheduleId_idx" ON public."EventType" USING btree ("instantMeetingScheduleId") WHERE ("instantMeetingScheduleId" IS NOT NULL);


--
-- Name: EventType_parentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "EventType_parentId_idx" ON public."EventType" USING btree ("parentId");


--
-- Name: EventType_parentId_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "EventType_parentId_teamId_idx" ON public."EventType" USING btree ("parentId", "teamId");


--
-- Name: EventType_profileId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "EventType_profileId_idx" ON public."EventType" USING btree ("profileId");


--
-- Name: EventType_restrictionScheduleId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "EventType_restrictionScheduleId_idx" ON public."EventType" USING btree ("restrictionScheduleId");


--
-- Name: EventType_scheduleId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "EventType_scheduleId_idx" ON public."EventType" USING btree ("scheduleId");


--
-- Name: EventType_secondaryEmailId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "EventType_secondaryEmailId_idx" ON public."EventType" USING btree ("secondaryEmailId");


--
-- Name: EventType_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "EventType_teamId_idx" ON public."EventType" USING btree ("teamId");


--
-- Name: EventType_teamId_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "EventType_teamId_slug_key" ON public."EventType" USING btree ("teamId", slug);


--
-- Name: EventType_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "EventType_userId_idx" ON public."EventType" USING btree ("userId");


--
-- Name: EventType_userId_parentId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "EventType_userId_parentId_key" ON public."EventType" USING btree ("userId", "parentId");


--
-- Name: EventType_userId_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "EventType_userId_slug_key" ON public."EventType" USING btree ("userId", slug);


--
-- Name: Feature_enabled_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Feature_enabled_idx" ON public."Feature" USING btree (enabled);


--
-- Name: Feature_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Feature_slug_key" ON public."Feature" USING btree (slug);


--
-- Name: Feature_stale_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Feature_stale_idx" ON public."Feature" USING btree (stale);


--
-- Name: Feedback_rating_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Feedback_rating_idx" ON public."Feedback" USING btree (rating);


--
-- Name: Feedback_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Feedback_userId_idx" ON public."Feedback" USING btree ("userId");


--
-- Name: FilterSegment_scope_teamId_tableIdentifier_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "FilterSegment_scope_teamId_tableIdentifier_idx" ON public."FilterSegment" USING btree (scope, "teamId", "tableIdentifier");


--
-- Name: FilterSegment_scope_userId_tableIdentifier_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "FilterSegment_scope_userId_tableIdentifier_idx" ON public."FilterSegment" USING btree (scope, "userId", "tableIdentifier");


--
-- Name: HashedLink_eventTypeId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "HashedLink_eventTypeId_idx" ON public."HashedLink" USING btree ("eventTypeId");


--
-- Name: HashedLink_link_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "HashedLink_link_key" ON public."HashedLink" USING btree (link);


--
-- Name: HolidayCache_countryCode_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "HolidayCache_countryCode_date_idx" ON public."HolidayCache" USING btree ("countryCode", date);


--
-- Name: HolidayCache_countryCode_eventId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "HolidayCache_countryCode_eventId_key" ON public."HolidayCache" USING btree ("countryCode", "eventId");


--
-- Name: HolidayCache_countryCode_year_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "HolidayCache_countryCode_year_idx" ON public."HolidayCache" USING btree ("countryCode", year);


--
-- Name: HostGroup_eventTypeId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "HostGroup_eventTypeId_idx" ON public."HostGroup" USING btree ("eventTypeId");


--
-- Name: HostGroup_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "HostGroup_name_idx" ON public."HostGroup" USING btree (name);


--
-- Name: HostLocation_credentialId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "HostLocation_credentialId_idx" ON public."HostLocation" USING btree ("credentialId");


--
-- Name: HostLocation_eventTypeId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "HostLocation_eventTypeId_idx" ON public."HostLocation" USING btree ("eventTypeId");


--
-- Name: HostLocation_userId_eventTypeId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "HostLocation_userId_eventTypeId_key" ON public."HostLocation" USING btree ("userId", "eventTypeId");


--
-- Name: Host_eventTypeId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Host_eventTypeId_idx" ON public."Host" USING btree ("eventTypeId");


--
-- Name: Host_memberId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Host_memberId_idx" ON public."Host" USING btree ("memberId");


--
-- Name: Host_scheduleId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Host_scheduleId_idx" ON public."Host" USING btree ("scheduleId");


--
-- Name: Host_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Host_userId_idx" ON public."Host" USING btree ("userId");


--
-- Name: Impersonations_impersonatedById_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Impersonations_impersonatedById_idx" ON public."Impersonations" USING btree ("impersonatedById");


--
-- Name: Impersonations_impersonatedUserId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Impersonations_impersonatedUserId_idx" ON public."Impersonations" USING btree ("impersonatedUserId");


--
-- Name: InstantMeetingToken_bookingId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "InstantMeetingToken_bookingId_key" ON public."InstantMeetingToken" USING btree ("bookingId");


--
-- Name: InstantMeetingToken_token_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "InstantMeetingToken_token_idx" ON public."InstantMeetingToken" USING btree (token);


--
-- Name: InstantMeetingToken_token_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "InstantMeetingToken_token_key" ON public."InstantMeetingToken" USING btree (token);


--
-- Name: IntegrationAttributeSync_credentialId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IntegrationAttributeSync_credentialId_idx" ON public."IntegrationAttributeSync" USING btree ("credentialId");


--
-- Name: IntegrationAttributeSync_organizationId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IntegrationAttributeSync_organizationId_idx" ON public."IntegrationAttributeSync" USING btree ("organizationId");


--
-- Name: InternalNotePreset_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "InternalNotePreset_teamId_idx" ON public."InternalNotePreset" USING btree ("teamId");


--
-- Name: InternalNotePreset_teamId_name_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "InternalNotePreset_teamId_name_key" ON public."InternalNotePreset" USING btree ("teamId", name);


--
-- Name: ManagedOrganization_managedOrganizationId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ManagedOrganization_managedOrganizationId_key" ON public."ManagedOrganization" USING btree ("managedOrganizationId");


--
-- Name: ManagedOrganization_managerOrganizationId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ManagedOrganization_managerOrganizationId_idx" ON public."ManagedOrganization" USING btree ("managerOrganizationId");


--
-- Name: ManagedOrganization_managerOrganizationId_managedOrganizati_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ManagedOrganization_managerOrganizationId_managedOrganizati_key" ON public."ManagedOrganization" USING btree ("managerOrganizationId", "managedOrganizationId");


--
-- Name: Membership_accepted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Membership_accepted_idx" ON public."Membership" USING btree (accepted);


--
-- Name: Membership_customRoleId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Membership_customRoleId_idx" ON public."Membership" USING btree ("customRoleId");


--
-- Name: Membership_role_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Membership_role_idx" ON public."Membership" USING btree (role);


--
-- Name: Membership_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Membership_teamId_idx" ON public."Membership" USING btree ("teamId");


--
-- Name: Membership_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Membership_userId_idx" ON public."Membership" USING btree ("userId");


--
-- Name: Membership_userId_teamId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Membership_userId_teamId_key" ON public."Membership" USING btree ("userId", "teamId");


--
-- Name: MonthlyProration_monthKey_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MonthlyProration_monthKey_status_idx" ON public."MonthlyProration" USING btree ("monthKey", status);


--
-- Name: MonthlyProration_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MonthlyProration_status_idx" ON public."MonthlyProration" USING btree (status);


--
-- Name: MonthlyProration_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MonthlyProration_teamId_idx" ON public."MonthlyProration" USING btree ("teamId");


--
-- Name: MonthlyProration_teamId_monthKey_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "MonthlyProration_teamId_monthKey_key" ON public."MonthlyProration" USING btree ("teamId", "monthKey");


--
-- Name: NotificationsSubscriptions_userId_subscription_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "NotificationsSubscriptions_userId_subscription_idx" ON public."NotificationsSubscriptions" USING btree ("userId", subscription);


--
-- Name: OAuthClient_clientId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "OAuthClient_clientId_key" ON public."OAuthClient" USING btree ("clientId");


--
-- Name: OAuthClient_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "OAuthClient_userId_idx" ON public."OAuthClient" USING btree ("userId");


--
-- Name: OrganizationBilling_subscriptionId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "OrganizationBilling_subscriptionId_key" ON public."OrganizationBilling" USING btree ("subscriptionId");


--
-- Name: OrganizationBilling_teamId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "OrganizationBilling_teamId_key" ON public."OrganizationBilling" USING btree ("teamId");


--
-- Name: OrganizationOnboarding_orgOwnerEmail_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "OrganizationOnboarding_orgOwnerEmail_idx" ON public."OrganizationOnboarding" USING btree ("orgOwnerEmail");


--
-- Name: OrganizationOnboarding_orgOwnerEmail_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "OrganizationOnboarding_orgOwnerEmail_key" ON public."OrganizationOnboarding" USING btree ("orgOwnerEmail");


--
-- Name: OrganizationOnboarding_organizationId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "OrganizationOnboarding_organizationId_key" ON public."OrganizationOnboarding" USING btree ("organizationId");


--
-- Name: OrganizationOnboarding_stripeCustomerId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "OrganizationOnboarding_stripeCustomerId_idx" ON public."OrganizationOnboarding" USING btree ("stripeCustomerId");


--
-- Name: OrganizationOnboarding_stripeCustomerId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "OrganizationOnboarding_stripeCustomerId_key" ON public."OrganizationOnboarding" USING btree ("stripeCustomerId");


--
-- Name: OrganizationSettings_organizationId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "OrganizationSettings_organizationId_key" ON public."OrganizationSettings" USING btree ("organizationId");


--
-- Name: OutOfOfficeEntry_start_end_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "OutOfOfficeEntry_start_end_idx" ON public."OutOfOfficeEntry" USING btree (start, "end");


--
-- Name: OutOfOfficeEntry_toUserId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "OutOfOfficeEntry_toUserId_idx" ON public."OutOfOfficeEntry" USING btree ("toUserId");


--
-- Name: OutOfOfficeEntry_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "OutOfOfficeEntry_userId_idx" ON public."OutOfOfficeEntry" USING btree ("userId");


--
-- Name: OutOfOfficeEntry_uuid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "OutOfOfficeEntry_uuid_idx" ON public."OutOfOfficeEntry" USING btree (uuid);


--
-- Name: OutOfOfficeEntry_uuid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "OutOfOfficeEntry_uuid_key" ON public."OutOfOfficeEntry" USING btree (uuid);


--
-- Name: OutOfOfficeReason_reason_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "OutOfOfficeReason_reason_key" ON public."OutOfOfficeReason" USING btree (reason);


--
-- Name: Payment_bookingId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Payment_bookingId_idx" ON public."Payment" USING btree ("bookingId");


--
-- Name: Payment_externalId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Payment_externalId_idx" ON public."Payment" USING btree ("externalId");


--
-- Name: Payment_externalId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Payment_externalId_key" ON public."Payment" USING btree ("externalId");


--
-- Name: Payment_uid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Payment_uid_key" ON public."Payment" USING btree (uid);


--
-- Name: PendingRoutingTrace_formResponseId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PendingRoutingTrace_formResponseId_key" ON public."PendingRoutingTrace" USING btree ("formResponseId");


--
-- Name: PendingRoutingTrace_queuedFormResponseId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PendingRoutingTrace_queuedFormResponseId_key" ON public."PendingRoutingTrace" USING btree ("queuedFormResponseId");


--
-- Name: PlatformAuthorizationToken_userId_platformOAuthClientId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PlatformAuthorizationToken_userId_platformOAuthClientId_key" ON public."PlatformAuthorizationToken" USING btree ("userId", "platformOAuthClientId");


--
-- Name: PlatformBilling_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PlatformBilling_id_key" ON public."PlatformBilling" USING btree (id);


--
-- Name: Profile_organizationId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Profile_organizationId_idx" ON public."Profile" USING btree ("organizationId");


--
-- Name: Profile_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Profile_uid_idx" ON public."Profile" USING btree (uid);


--
-- Name: Profile_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Profile_userId_idx" ON public."Profile" USING btree ("userId");


--
-- Name: Profile_userId_organizationId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Profile_userId_organizationId_key" ON public."Profile" USING btree ("userId", "organizationId");


--
-- Name: Profile_username_organizationId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Profile_username_organizationId_key" ON public."Profile" USING btree (username, "organizationId");


--
-- Name: RateLimit_apiKeyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RateLimit_apiKeyId_idx" ON public."RateLimit" USING btree ("apiKeyId");


--
-- Name: RefreshToken_secret_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "RefreshToken_secret_key" ON public."RefreshToken" USING btree (secret);


--
-- Name: ReminderMail_referenceId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ReminderMail_referenceId_idx" ON public."ReminderMail" USING btree ("referenceId");


--
-- Name: ReminderMail_reminderType_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ReminderMail_reminderType_idx" ON public."ReminderMail" USING btree ("reminderType");


--
-- Name: RolePermission_action_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RolePermission_action_idx" ON public."RolePermission" USING btree (action);


--
-- Name: RolePermission_roleId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RolePermission_roleId_idx" ON public."RolePermission" USING btree ("roleId");


--
-- Name: RolePermission_roleId_resource_action_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "RolePermission_roleId_resource_action_key" ON public."RolePermission" USING btree ("roleId", resource, action);


--
-- Name: Role_name_teamId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Role_name_teamId_key" ON public."Role" USING btree (name, "teamId");


--
-- Name: Role_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Role_teamId_idx" ON public."Role" USING btree ("teamId");


--
-- Name: RoutingFormResponseDenormalized_bookingAssignmentReason_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RoutingFormResponseDenormalized_bookingAssignmentReason_idx" ON public."RoutingFormResponseDenormalized" USING btree (lower("bookingAssignmentReason"));


--
-- Name: RoutingFormResponseDenormalized_bookingId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RoutingFormResponseDenormalized_bookingId_idx" ON public."RoutingFormResponseDenormalized" USING btree ("bookingId");


--
-- Name: RoutingFormResponseDenormalized_bookingUserId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RoutingFormResponseDenormalized_bookingUserId_idx" ON public."RoutingFormResponseDenormalized" USING btree ("bookingUserId");


--
-- Name: RoutingFormResponseDenormalized_eventTypeId_eventTypeParent_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RoutingFormResponseDenormalized_eventTypeId_eventTypeParent_idx" ON public."RoutingFormResponseDenormalized" USING btree ("eventTypeId", "eventTypeParentId");


--
-- Name: RoutingFormResponseDenormalized_formId_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RoutingFormResponseDenormalized_formId_createdAt_idx" ON public."RoutingFormResponseDenormalized" USING btree ("formId", "createdAt");


--
-- Name: RoutingFormResponseDenormalized_formId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RoutingFormResponseDenormalized_formId_idx" ON public."RoutingFormResponseDenormalized" USING btree ("formId");


--
-- Name: RoutingFormResponseDenormalized_formTeamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RoutingFormResponseDenormalized_formTeamId_idx" ON public."RoutingFormResponseDenormalized" USING btree ("formTeamId");


--
-- Name: RoutingFormResponseDenormalized_formUserId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RoutingFormResponseDenormalized_formUserId_idx" ON public."RoutingFormResponseDenormalized" USING btree ("formUserId");


--
-- Name: RoutingFormResponseField_fieldId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RoutingFormResponseField_fieldId_idx" ON public."RoutingFormResponseField" USING btree ("fieldId");


--
-- Name: RoutingFormResponseField_responseId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RoutingFormResponseField_responseId_idx" ON public."RoutingFormResponseField" USING btree ("responseId");


--
-- Name: RoutingFormResponseField_valueNumber_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RoutingFormResponseField_valueNumber_idx" ON public."RoutingFormResponseField" USING btree ("valueNumber");


--
-- Name: RoutingFormResponseField_valueStringArray_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RoutingFormResponseField_valueStringArray_idx" ON public."RoutingFormResponseField" USING gin ("valueStringArray");


--
-- Name: RoutingFormResponseField_valueString_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RoutingFormResponseField_valueString_idx" ON public."RoutingFormResponseField" USING btree (lower("valueString"));


--
-- Name: RoutingTrace_assignmentReasonId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "RoutingTrace_assignmentReasonId_key" ON public."RoutingTrace" USING btree ("assignmentReasonId");


--
-- Name: RoutingTrace_bookingUid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "RoutingTrace_bookingUid_key" ON public."RoutingTrace" USING btree ("bookingUid");


--
-- Name: RoutingTrace_formResponseId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "RoutingTrace_formResponseId_key" ON public."RoutingTrace" USING btree ("formResponseId");


--
-- Name: RoutingTrace_queuedFormResponseId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "RoutingTrace_queuedFormResponseId_key" ON public."RoutingTrace" USING btree ("queuedFormResponseId");


--
-- Name: Schedule_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Schedule_userId_idx" ON public."Schedule" USING btree ("userId");


--
-- Name: SeatChangeLog_monthKey_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SeatChangeLog_monthKey_idx" ON public."SeatChangeLog" USING btree ("monthKey");


--
-- Name: SeatChangeLog_teamId_monthKey_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SeatChangeLog_teamId_monthKey_idx" ON public."SeatChangeLog" USING btree ("teamId", "monthKey");


--
-- Name: SeatChangeLog_teamId_operationId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SeatChangeLog_teamId_operationId_key" ON public."SeatChangeLog" USING btree ("teamId", "operationId");


--
-- Name: SeatChangeLog_teamId_processedInProrationId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SeatChangeLog_teamId_processedInProrationId_idx" ON public."SeatChangeLog" USING btree ("teamId", "processedInProrationId");


--
-- Name: SecondaryEmail_email_emailVerified_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SecondaryEmail_email_emailVerified_idx" ON public."SecondaryEmail" USING btree (email, "emailVerified");


--
-- Name: SecondaryEmail_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SecondaryEmail_email_key" ON public."SecondaryEmail" USING btree (email);


--
-- Name: SecondaryEmail_userId_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SecondaryEmail_userId_email_key" ON public."SecondaryEmail" USING btree ("userId", email);


--
-- Name: SecondaryEmail_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SecondaryEmail_userId_idx" ON public."SecondaryEmail" USING btree ("userId");


--
-- Name: SelectedCalendar_channelId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SelectedCalendar_channelId_idx" ON public."SelectedCalendar" USING btree ("channelId");


--
-- Name: SelectedCalendar_credentialId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SelectedCalendar_credentialId_idx" ON public."SelectedCalendar" USING btree ("credentialId");


--
-- Name: SelectedCalendar_eventTypeId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SelectedCalendar_eventTypeId_idx" ON public."SelectedCalendar" USING btree ("eventTypeId");


--
-- Name: SelectedCalendar_externalId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SelectedCalendar_externalId_idx" ON public."SelectedCalendar" USING btree ("externalId");


--
-- Name: SelectedCalendar_googleChannelId_eventTypeId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SelectedCalendar_googleChannelId_eventTypeId_key" ON public."SelectedCalendar" USING btree ("googleChannelId", "eventTypeId");


--
-- Name: SelectedCalendar_unwatch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SelectedCalendar_unwatch_idx" ON public."SelectedCalendar" USING btree (integration, "googleChannelExpiration", error, "unwatchAttempts", "maxAttempts");


--
-- Name: SelectedCalendar_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SelectedCalendar_userId_idx" ON public."SelectedCalendar" USING btree ("userId");


--
-- Name: SelectedCalendar_userId_integration_externalId_eventTypeId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SelectedCalendar_userId_integration_externalId_eventTypeId_key" ON public."SelectedCalendar" USING btree ("userId", integration, "externalId", "eventTypeId");


--
-- Name: SelectedCalendar_watch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SelectedCalendar_watch_idx" ON public."SelectedCalendar" USING btree (integration, "googleChannelExpiration", error, "watchAttempts", "maxAttempts");


--
-- Name: SelectedSlots_userId_slotUtcStartDate_slotUtcEndDate_uid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SelectedSlots_userId_slotUtcStartDate_slotUtcEndDate_uid_key" ON public."SelectedSlots" USING btree ("userId", "slotUtcStartDate", "slotUtcEndDate", uid);


--
-- Name: Session_sessionToken_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Session_sessionToken_key" ON public."Session" USING btree ("sessionToken");


--
-- Name: Session_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Session_userId_idx" ON public."Session" USING btree ("userId");


--
-- Name: Task_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Task_id_key" ON public."Task" USING btree (id);


--
-- Name: Task_referenceUid_type_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Task_referenceUid_type_key" ON public."Task" USING btree ("referenceUid", type);


--
-- Name: Task_scheduledAt_succeededAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Task_scheduledAt_succeededAt_idx" ON public."Task" USING btree ("scheduledAt", "succeededAt");


--
-- Name: Task_succeededAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Task_succeededAt_idx" ON public."Task" USING btree ("succeededAt");


--
-- Name: TeamBilling_subscriptionId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "TeamBilling_subscriptionId_key" ON public."TeamBilling" USING btree ("subscriptionId");


--
-- Name: TeamBilling_teamId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "TeamBilling_teamId_key" ON public."TeamBilling" USING btree ("teamId");


--
-- Name: TeamFeatures_teamId_featureId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TeamFeatures_teamId_featureId_idx" ON public."TeamFeatures" USING btree ("teamId", "featureId");


--
-- Name: Team_parentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Team_parentId_idx" ON public."Team" USING btree ("parentId");


--
-- Name: Team_slug_parentId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Team_slug_parentId_key" ON public."Team" USING btree (slug, "parentId");


--
-- Name: Team_slug_parentId_key_null; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Team_slug_parentId_key_null" ON public."Team" USING btree (slug, (("parentId" IS NULL))) WHERE ("parentId" IS NULL);


--
-- Name: TempOrgRedirect_from_type_fromOrgId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "TempOrgRedirect_from_type_fromOrgId_key" ON public."TempOrgRedirect" USING btree ("from", type, "fromOrgId");


--
-- Name: Tracking_bookingId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Tracking_bookingId_key" ON public."Tracking" USING btree ("bookingId");


--
-- Name: TravelSchedule_endDate_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TravelSchedule_endDate_idx" ON public."TravelSchedule" USING btree ("endDate");


--
-- Name: TravelSchedule_startDate_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TravelSchedule_startDate_idx" ON public."TravelSchedule" USING btree ("startDate");


--
-- Name: UserFeatures_userId_featureId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserFeatures_userId_featureId_idx" ON public."UserFeatures" USING btree ("userId", "featureId");


--
-- Name: UserFilterSegmentPreference_segmentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserFilterSegmentPreference_segmentId_idx" ON public."UserFilterSegmentPreference" USING btree ("segmentId");


--
-- Name: UserFilterSegmentPreference_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserFilterSegmentPreference_userId_idx" ON public."UserFilterSegmentPreference" USING btree ("userId");


--
-- Name: UserFilterSegmentPreference_userId_tableIdentifier_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UserFilterSegmentPreference_userId_tableIdentifier_key" ON public."UserFilterSegmentPreference" USING btree ("userId", "tableIdentifier");


--
-- Name: UserHolidaySettings_userId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UserHolidaySettings_userId_key" ON public."UserHolidaySettings" USING btree ("userId");


--
-- Name: UserPassword_userId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UserPassword_userId_key" ON public."UserPassword" USING btree ("userId");


--
-- Name: VerificationToken_identifier_token_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "VerificationToken_identifier_token_key" ON public."VerificationToken" USING btree (identifier, token);


--
-- Name: VerificationToken_secondaryEmailId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "VerificationToken_secondaryEmailId_idx" ON public."VerificationToken" USING btree ("secondaryEmailId");


--
-- Name: VerificationToken_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "VerificationToken_teamId_idx" ON public."VerificationToken" USING btree ("teamId");


--
-- Name: VerificationToken_token_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "VerificationToken_token_idx" ON public."VerificationToken" USING btree (token);


--
-- Name: VerificationToken_token_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "VerificationToken_token_key" ON public."VerificationToken" USING btree (token);


--
-- Name: VerifiedEmail_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "VerifiedEmail_teamId_idx" ON public."VerifiedEmail" USING btree ("teamId");


--
-- Name: VerifiedEmail_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "VerifiedEmail_userId_idx" ON public."VerifiedEmail" USING btree ("userId");


--
-- Name: VerifiedNumber_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "VerifiedNumber_teamId_idx" ON public."VerifiedNumber" USING btree ("teamId");


--
-- Name: VerifiedNumber_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "VerifiedNumber_userId_idx" ON public."VerifiedNumber" USING btree ("userId");


--
-- Name: VideoCallGuest_bookingUid_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "VideoCallGuest_bookingUid_email_key" ON public."VideoCallGuest" USING btree ("bookingUid", email);


--
-- Name: VideoCallGuest_bookingUid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "VideoCallGuest_bookingUid_idx" ON public."VideoCallGuest" USING btree ("bookingUid");


--
-- Name: VideoCallGuest_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "VideoCallGuest_email_idx" ON public."VideoCallGuest" USING btree (email);


--
-- Name: WatchlistAudit_watchlistId_changedAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WatchlistAudit_watchlistId_changedAt_idx" ON public."WatchlistAudit" USING btree ("watchlistId", "changedAt");


--
-- Name: Watchlist_isGlobal_action_organizationId_type_value_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Watchlist_isGlobal_action_organizationId_type_value_idx" ON public."Watchlist" USING btree ("isGlobal", action, "organizationId", type, value);


--
-- Name: Watchlist_type_value_global_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Watchlist_type_value_global_key" ON public."Watchlist" USING btree (type, value) WHERE ("organizationId" IS NULL);


--
-- Name: Watchlist_type_value_organizationId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Watchlist_type_value_organizationId_key" ON public."Watchlist" USING btree (type, value, "organizationId");


--
-- Name: WebhookScheduledTriggers_bookingId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WebhookScheduledTriggers_bookingId_idx" ON public."WebhookScheduledTriggers" USING btree ("bookingId") WHERE ("bookingId" IS NOT NULL);


--
-- Name: Webhook_active_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Webhook_active_idx" ON public."Webhook" USING btree (active);


--
-- Name: Webhook_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Webhook_id_key" ON public."Webhook" USING btree (id);


--
-- Name: Webhook_platformOAuthClientId_subscriberUrl_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Webhook_platformOAuthClientId_subscriberUrl_key" ON public."Webhook" USING btree ("platformOAuthClientId", "subscriberUrl");


--
-- Name: Webhook_userId_subscriberUrl_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Webhook_userId_subscriberUrl_key" ON public."Webhook" USING btree ("userId", "subscriberUrl");


--
-- Name: WorkflowOptOutContact_type_value_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WorkflowOptOutContact_type_value_key" ON public."WorkflowOptOutContact" USING btree (type, value);


--
-- Name: WorkflowReminder_bookingUid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkflowReminder_bookingUid_idx" ON public."WorkflowReminder" USING btree ("bookingUid");


--
-- Name: WorkflowReminder_cancelled_scheduledDate_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkflowReminder_cancelled_scheduledDate_idx" ON public."WorkflowReminder" USING btree (cancelled, "scheduledDate");


--
-- Name: WorkflowReminder_method_scheduled_scheduledDate_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkflowReminder_method_scheduled_scheduledDate_idx" ON public."WorkflowReminder" USING btree (method, scheduled, "scheduledDate");


--
-- Name: WorkflowReminder_referenceId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WorkflowReminder_referenceId_key" ON public."WorkflowReminder" USING btree ("referenceId");


--
-- Name: WorkflowReminder_seatReferenceId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkflowReminder_seatReferenceId_idx" ON public."WorkflowReminder" USING btree ("seatReferenceId");


--
-- Name: WorkflowReminder_uuid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WorkflowReminder_uuid_key" ON public."WorkflowReminder" USING btree (uuid);


--
-- Name: WorkflowReminder_workflowStepId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkflowReminder_workflowStepId_idx" ON public."WorkflowReminder" USING btree ("workflowStepId");


--
-- Name: WorkflowStepTranslation_workflowStepId_field_targetLocale_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WorkflowStepTranslation_workflowStepId_field_targetLocale_key" ON public."WorkflowStepTranslation" USING btree ("workflowStepId", field, "targetLocale");


--
-- Name: WorkflowStep_agentId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WorkflowStep_agentId_key" ON public."WorkflowStep" USING btree ("agentId");


--
-- Name: WorkflowStep_inboundAgentId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WorkflowStep_inboundAgentId_key" ON public."WorkflowStep" USING btree ("inboundAgentId");


--
-- Name: WorkflowStep_workflowId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkflowStep_workflowId_idx" ON public."WorkflowStep" USING btree ("workflowId");


--
-- Name: Workflow_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Workflow_teamId_idx" ON public."Workflow" USING btree ("teamId");


--
-- Name: Workflow_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Workflow_userId_idx" ON public."Workflow" USING btree ("userId");


--
-- Name: WorkflowsOnEventTypes_eventTypeId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkflowsOnEventTypes_eventTypeId_idx" ON public."WorkflowsOnEventTypes" USING btree ("eventTypeId");


--
-- Name: WorkflowsOnEventTypes_workflowId_eventTypeId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WorkflowsOnEventTypes_workflowId_eventTypeId_key" ON public."WorkflowsOnEventTypes" USING btree ("workflowId", "eventTypeId");


--
-- Name: WorkflowsOnEventTypes_workflowId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkflowsOnEventTypes_workflowId_idx" ON public."WorkflowsOnEventTypes" USING btree ("workflowId");


--
-- Name: WorkflowsOnRoutingForms_routingFormId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkflowsOnRoutingForms_routingFormId_idx" ON public."WorkflowsOnRoutingForms" USING btree ("routingFormId");


--
-- Name: WorkflowsOnRoutingForms_workflowId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkflowsOnRoutingForms_workflowId_idx" ON public."WorkflowsOnRoutingForms" USING btree ("workflowId");


--
-- Name: WorkflowsOnRoutingForms_workflowId_routingFormId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WorkflowsOnRoutingForms_workflowId_routingFormId_key" ON public."WorkflowsOnRoutingForms" USING btree ("workflowId", "routingFormId");


--
-- Name: WorkflowsOnTeams_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkflowsOnTeams_teamId_idx" ON public."WorkflowsOnTeams" USING btree ("teamId");


--
-- Name: WorkflowsOnTeams_workflowId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkflowsOnTeams_workflowId_idx" ON public."WorkflowsOnTeams" USING btree ("workflowId");


--
-- Name: WorkflowsOnTeams_workflowId_teamId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WorkflowsOnTeams_workflowId_teamId_key" ON public."WorkflowsOnTeams" USING btree ("workflowId", "teamId");


--
-- Name: WorkspacePlatform_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WorkspacePlatform_slug_key" ON public."WorkspacePlatform" USING btree (slug);


--
-- Name: WrongAssignmentReport_bookingUid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WrongAssignmentReport_bookingUid_key" ON public."WrongAssignmentReport" USING btree ("bookingUid");


--
-- Name: WrongAssignmentReport_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WrongAssignmentReport_createdAt_idx" ON public."WrongAssignmentReport" USING btree ("createdAt");


--
-- Name: WrongAssignmentReport_reportedById_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WrongAssignmentReport_reportedById_idx" ON public."WrongAssignmentReport" USING btree ("reportedById");


--
-- Name: WrongAssignmentReport_reviewedById_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WrongAssignmentReport_reviewedById_idx" ON public."WrongAssignmentReport" USING btree ("reviewedById");


--
-- Name: WrongAssignmentReport_routingFormId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WrongAssignmentReport_routingFormId_idx" ON public."WrongAssignmentReport" USING btree ("routingFormId");


--
-- Name: WrongAssignmentReport_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WrongAssignmentReport_status_idx" ON public."WrongAssignmentReport" USING btree (status);


--
-- Name: WrongAssignmentReport_teamId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WrongAssignmentReport_teamId_idx" ON public."WrongAssignmentReport" USING btree ("teamId");


--
-- Name: WrongAssignmentReport_teamId_status_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WrongAssignmentReport_teamId_status_createdAt_idx" ON public."WrongAssignmentReport" USING btree ("teamId", status, "createdAt");


--
-- Name: _PlatformOAuthClientToUser_B_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "_PlatformOAuthClientToUser_B_index" ON public."_PlatformOAuthClientToUser" USING btree ("B");


--
-- Name: _user_eventtype_B_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "_user_eventtype_B_index" ON public._user_eventtype USING btree ("B");


--
-- Name: avatars_objectKey_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "avatars_objectKey_key" ON public.avatars USING btree ("objectKey");


--
-- Name: avatars_teamId_userId_isBanner_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "avatars_teamId_userId_isBanner_key" ON public.avatars USING btree ("teamId", "userId", "isBanner");


--
-- Name: users_emailVerified_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "users_emailVerified_idx" ON public.users USING btree ("emailVerified");


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: users_email_username_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_username_key ON public.users USING btree (email, username);


--
-- Name: users_identityProviderId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "users_identityProviderId_idx" ON public.users USING btree ("identityProviderId");


--
-- Name: users_identityProvider_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "users_identityProvider_idx" ON public.users USING btree ("identityProvider");


--
-- Name: users_movedToProfileId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "users_movedToProfileId_key" ON public.users USING btree ("movedToProfileId");


--
-- Name: users_username_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_username_idx ON public.users USING btree (username);


--
-- Name: users_username_organizationId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "users_username_organizationId_key" ON public.users USING btree (username, "organizationId");


--
-- Name: users_username_organizationId_key_null; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "users_username_organizationId_key_null" ON public.users USING btree (username, (("organizationId" IS NULL))) WHERE ("organizationId" IS NULL);


--
-- Name: users_uuid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_uuid_key ON public.users USING btree (uuid);


--
-- Name: AssignmentReason assignment_reason_delete_trigger_for_routing_form; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER assignment_reason_delete_trigger_for_routing_form AFTER DELETE ON public."AssignmentReason" FOR EACH ROW EXECUTE FUNCTION public.trigger_cleanup_routing_form_response_denormalized_assignment_r();


--
-- Name: AssignmentReason assignment_reason_insert_trigger_for_routing_form; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER assignment_reason_insert_trigger_for_routing_form AFTER INSERT ON public."AssignmentReason" FOR EACH ROW EXECUTE FUNCTION public.trigger_refresh_routing_form_response_denormalized_assignment_r();


--
-- Name: AssignmentReason assignment_reason_update_trigger_for_routing_form; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER assignment_reason_update_trigger_for_routing_form AFTER UPDATE OF "reasonString" ON public."AssignmentReason" FOR EACH ROW EXECUTE FUNCTION public.trigger_refresh_routing_form_response_denormalized_assignment_r();


--
-- Name: Booking booking_delete_trigger_for_routing_form; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER booking_delete_trigger_for_routing_form AFTER DELETE ON public."Booking" FOR EACH ROW EXECUTE FUNCTION public.trigger_cleanup_routing_form_response_denormalized_booking();


--
-- Name: Booking booking_denorm_booking_delete_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER booking_denorm_booking_delete_trigger AFTER DELETE ON public."Booking" FOR EACH ROW EXECUTE FUNCTION public.trigger_delete_booking_time_status_denormalized();


--
-- Name: Booking booking_denorm_booking_insert_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER booking_denorm_booking_insert_update_trigger AFTER INSERT OR UPDATE ON public."Booking" FOR EACH ROW EXECUTE FUNCTION public.trigger_refresh_booking_time_status_denormalized();


--
-- Name: EventType booking_denorm_event_type_length_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER booking_denorm_event_type_length_update_trigger AFTER UPDATE OF length ON public."EventType" FOR EACH ROW EXECUTE FUNCTION public.refresh_booking_time_status_length();


--
-- Name: EventType booking_denorm_event_type_parent_id_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER booking_denorm_event_type_parent_id_update_trigger AFTER UPDATE OF "parentId" ON public."EventType" FOR EACH ROW EXECUTE FUNCTION public.refresh_booking_time_status_parent_id();


--
-- Name: EventType booking_denorm_event_type_team_id_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER booking_denorm_event_type_team_id_update_trigger AFTER UPDATE OF "teamId" ON public."EventType" FOR EACH ROW EXECUTE FUNCTION public.refresh_booking_time_status_team_id();


--
-- Name: users booking_denorm_user_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER booking_denorm_user_update_trigger AFTER UPDATE OF email, name, username ON public.users FOR EACH ROW EXECUTE FUNCTION public.trigger_refresh_booking_time_status_denormalized_user();


--
-- Name: Booking booking_insert_trigger_for_routing_form; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER booking_insert_trigger_for_routing_form AFTER INSERT ON public."Booking" FOR EACH ROW EXECUTE FUNCTION public.trigger_refresh_routing_form_response_denormalized_booking();


--
-- Name: Booking booking_update_trigger_for_routing_form; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER booking_update_trigger_for_routing_form AFTER UPDATE OF status, "createdAt", "startTime", "endTime", "userId", "eventTypeId" ON public."Booking" FOR EACH ROW EXECUTE FUNCTION public.trigger_refresh_routing_form_response_denormalized_booking();


--
-- Name: EventType event_type_update_trigger_for_routing_form; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER event_type_update_trigger_for_routing_form AFTER UPDATE OF "parentId", "schedulingType" ON public."EventType" FOR EACH ROW EXECUTE FUNCTION public.trigger_refresh_routing_form_response_denormalized_event_type();


--
-- Name: Membership membership_role_change_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER membership_role_change_trigger BEFORE INSERT OR UPDATE OF role ON public."Membership" FOR EACH ROW EXECUTE FUNCTION public.update_membership_custom_role();


--
-- Name: App_RoutingForms_Form routing_form_delete_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER routing_form_delete_trigger AFTER DELETE ON public."App_RoutingForms_Form" FOR EACH ROW EXECUTE FUNCTION public.trigger_cleanup_routing_form_response_denormalized_form();


--
-- Name: App_RoutingForms_Form routing_form_name_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER routing_form_name_update_trigger AFTER UPDATE OF name ON public."App_RoutingForms_Form" FOR EACH ROW EXECUTE FUNCTION public.trigger_refresh_routing_form_response_denormalized_form_name();


--
-- Name: App_RoutingForms_FormResponse routing_form_response_delete_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER routing_form_response_delete_trigger AFTER DELETE ON public."App_RoutingForms_FormResponse" FOR EACH ROW EXECUTE FUNCTION public.trigger_delete_routing_form_response_denormalized();


--
-- Name: RoutingFormResponseDenormalized routing_form_response_denormalized_insert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER routing_form_response_denormalized_insert_trigger AFTER INSERT ON public."RoutingFormResponseDenormalized" FOR EACH ROW EXECUTE FUNCTION public.handle_routing_form_response_fields();


--
-- Name: App_RoutingForms_FormResponse routing_form_response_insert_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER routing_form_response_insert_update_trigger AFTER INSERT OR UPDATE ON public."App_RoutingForms_FormResponse" FOR EACH ROW EXECUTE FUNCTION public.trigger_refresh_routing_form_response_denormalized();


--
-- Name: App_RoutingForms_FormResponse routing_form_response_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER routing_form_response_update_trigger AFTER UPDATE OF response ON public."App_RoutingForms_FormResponse" FOR EACH ROW EXECUTE FUNCTION public.handle_routing_form_response_fields();


--
-- Name: App_RoutingForms_Form routing_form_team_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER routing_form_team_update_trigger AFTER UPDATE OF "teamId" ON public."App_RoutingForms_Form" FOR EACH ROW EXECUTE FUNCTION public.trigger_refresh_routing_form_response_denormalized_form_team();


--
-- Name: App_RoutingForms_Form routing_form_user_update_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER routing_form_user_update_trigger AFTER UPDATE OF "userId" ON public."App_RoutingForms_Form" FOR EACH ROW EXECUTE FUNCTION public.trigger_refresh_routing_form_response_denormalized_form_user();


--
-- Name: Tracking tracking_delete_trigger_for_routing_form; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tracking_delete_trigger_for_routing_form AFTER DELETE ON public."Tracking" FOR EACH ROW EXECUTE FUNCTION public.trigger_cleanup_routing_form_response_denormalized_tracking();


--
-- Name: Tracking tracking_insert_trigger_for_routing_form; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tracking_insert_trigger_for_routing_form AFTER INSERT ON public."Tracking" FOR EACH ROW EXECUTE FUNCTION public.trigger_refresh_routing_form_response_denormalized_tracking();


--
-- Name: Tracking tracking_update_trigger_for_routing_form; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tracking_update_trigger_for_routing_form AFTER UPDATE OF utm_source, utm_medium, utm_campaign, utm_term, utm_content ON public."Tracking" FOR EACH ROW EXECUTE FUNCTION public.trigger_refresh_routing_form_response_denormalized_tracking();


--
-- Name: EventType trigger_nullify_routing_form_response_denormalized_event_type; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_nullify_routing_form_response_denormalized_event_type BEFORE DELETE ON public."EventType" FOR EACH ROW EXECUTE FUNCTION public.trigger_nullify_routing_form_response_denormalized_event_type();


--
-- Name: users user_delete_trigger_for_routing_form; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER user_delete_trigger_for_routing_form AFTER DELETE ON public.users FOR EACH ROW EXECUTE FUNCTION public.trigger_cleanup_routing_form_response_denormalized_user();


--
-- Name: users user_update_trigger_for_routing_form; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER user_update_trigger_for_routing_form AFTER UPDATE OF name, email, "avatarUrl" ON public.users FOR EACH ROW EXECUTE FUNCTION public.trigger_refresh_routing_form_response_denormalized_user();


--
-- Name: AIPhoneCallConfiguration AIPhoneCallConfiguration_eventTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AIPhoneCallConfiguration"
    ADD CONSTRAINT "AIPhoneCallConfiguration_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES public."EventType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AccessCode AccessCode_clientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AccessCode"
    ADD CONSTRAINT "AccessCode_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES public."OAuthClient"("clientId") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AccessCode AccessCode_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AccessCode"
    ADD CONSTRAINT "AccessCode_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AccessCode AccessCode_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AccessCode"
    ADD CONSTRAINT "AccessCode_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AccessToken AccessToken_platformOAuthClientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AccessToken"
    ADD CONSTRAINT "AccessToken_platformOAuthClientId_fkey" FOREIGN KEY ("platformOAuthClientId") REFERENCES public."PlatformOAuthClient"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AccessToken AccessToken_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AccessToken"
    ADD CONSTRAINT "AccessToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Account Account_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Account"
    ADD CONSTRAINT "Account_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Agent Agent_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Agent"
    ADD CONSTRAINT "Agent_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Agent Agent_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Agent"
    ADD CONSTRAINT "Agent_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ApiKey ApiKey_appId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ApiKey"
    ADD CONSTRAINT "ApiKey_appId_fkey" FOREIGN KEY ("appId") REFERENCES public."App"(slug) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ApiKey ApiKey_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ApiKey"
    ADD CONSTRAINT "ApiKey_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ApiKey ApiKey_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ApiKey"
    ADD CONSTRAINT "ApiKey_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: App_RoutingForms_FormResponse App_RoutingForms_FormResponse_formId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."App_RoutingForms_FormResponse"
    ADD CONSTRAINT "App_RoutingForms_FormResponse_formId_fkey" FOREIGN KEY ("formId") REFERENCES public."App_RoutingForms_Form"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: App_RoutingForms_FormResponse App_RoutingForms_FormResponse_routedToBookingUid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."App_RoutingForms_FormResponse"
    ADD CONSTRAINT "App_RoutingForms_FormResponse_routedToBookingUid_fkey" FOREIGN KEY ("routedToBookingUid") REFERENCES public."Booking"(uid) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: App_RoutingForms_Form App_RoutingForms_Form_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."App_RoutingForms_Form"
    ADD CONSTRAINT "App_RoutingForms_Form_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: App_RoutingForms_Form App_RoutingForms_Form_updatedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."App_RoutingForms_Form"
    ADD CONSTRAINT "App_RoutingForms_Form_updatedById_fkey" FOREIGN KEY ("updatedById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: App_RoutingForms_Form App_RoutingForms_Form_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."App_RoutingForms_Form"
    ADD CONSTRAINT "App_RoutingForms_Form_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: App_RoutingForms_IncompleteBookingActions App_RoutingForms_IncompleteBookingActions_formId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."App_RoutingForms_IncompleteBookingActions"
    ADD CONSTRAINT "App_RoutingForms_IncompleteBookingActions_formId_fkey" FOREIGN KEY ("formId") REFERENCES public."App_RoutingForms_Form"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: App_RoutingForms_QueuedFormResponse App_RoutingForms_QueuedFormResponse_actualResponseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."App_RoutingForms_QueuedFormResponse"
    ADD CONSTRAINT "App_RoutingForms_QueuedFormResponse_actualResponseId_fkey" FOREIGN KEY ("actualResponseId") REFERENCES public."App_RoutingForms_FormResponse"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: App_RoutingForms_QueuedFormResponse App_RoutingForms_QueuedFormResponse_formId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."App_RoutingForms_QueuedFormResponse"
    ADD CONSTRAINT "App_RoutingForms_QueuedFormResponse_formId_fkey" FOREIGN KEY ("formId") REFERENCES public."App_RoutingForms_Form"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AssignmentReason AssignmentReason_bookingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AssignmentReason"
    ADD CONSTRAINT "AssignmentReason_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES public."Booking"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Attendee Attendee_bookingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Attendee"
    ADD CONSTRAINT "Attendee_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES public."Booking"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AttributeOption AttributeOption_attributeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AttributeOption"
    ADD CONSTRAINT "AttributeOption_attributeId_fkey" FOREIGN KEY ("attributeId") REFERENCES public."Attribute"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AttributeSyncFieldMapping AttributeSyncFieldMapping_attributeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AttributeSyncFieldMapping"
    ADD CONSTRAINT "AttributeSyncFieldMapping_attributeId_fkey" FOREIGN KEY ("attributeId") REFERENCES public."Attribute"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AttributeSyncFieldMapping AttributeSyncFieldMapping_integrationAttributeSyncId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AttributeSyncFieldMapping"
    ADD CONSTRAINT "AttributeSyncFieldMapping_integrationAttributeSyncId_fkey" FOREIGN KEY ("integrationAttributeSyncId") REFERENCES public."IntegrationAttributeSync"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AttributeSyncRule AttributeSyncRule_integrationAttributeSyncId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AttributeSyncRule"
    ADD CONSTRAINT "AttributeSyncRule_integrationAttributeSyncId_fkey" FOREIGN KEY ("integrationAttributeSyncId") REFERENCES public."IntegrationAttributeSync"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AttributeToUser AttributeToUser_attributeOptionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AttributeToUser"
    ADD CONSTRAINT "AttributeToUser_attributeOptionId_fkey" FOREIGN KEY ("attributeOptionId") REFERENCES public."AttributeOption"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AttributeToUser AttributeToUser_createdByDSyncId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AttributeToUser"
    ADD CONSTRAINT "AttributeToUser_createdByDSyncId_fkey" FOREIGN KEY ("createdByDSyncId") REFERENCES public."DSyncData"("directoryId") ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: AttributeToUser AttributeToUser_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AttributeToUser"
    ADD CONSTRAINT "AttributeToUser_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: AttributeToUser AttributeToUser_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AttributeToUser"
    ADD CONSTRAINT "AttributeToUser_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public."Membership"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AttributeToUser AttributeToUser_updatedByDSyncId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AttributeToUser"
    ADD CONSTRAINT "AttributeToUser_updatedByDSyncId_fkey" FOREIGN KEY ("updatedByDSyncId") REFERENCES public."DSyncData"("directoryId") ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: AttributeToUser AttributeToUser_updatedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AttributeToUser"
    ADD CONSTRAINT "AttributeToUser_updatedById_fkey" FOREIGN KEY ("updatedById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Attribute Attribute_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Attribute"
    ADD CONSTRAINT "Attribute_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Availability Availability_eventTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Availability"
    ADD CONSTRAINT "Availability_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES public."EventType"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Availability Availability_scheduleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Availability"
    ADD CONSTRAINT "Availability_scheduleId_fkey" FOREIGN KEY ("scheduleId") REFERENCES public."Schedule"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Availability Availability_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Availability"
    ADD CONSTRAINT "Availability_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingAudit BookingAudit_actorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingAudit"
    ADD CONSTRAINT "BookingAudit_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES public."AuditActor"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: BookingInternalNote BookingInternalNote_bookingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingInternalNote"
    ADD CONSTRAINT "BookingInternalNote_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES public."Booking"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingInternalNote BookingInternalNote_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingInternalNote"
    ADD CONSTRAINT "BookingInternalNote_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: BookingInternalNote BookingInternalNote_notePresetId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingInternalNote"
    ADD CONSTRAINT "BookingInternalNote_notePresetId_fkey" FOREIGN KEY ("notePresetId") REFERENCES public."InternalNotePreset"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingReference BookingReference_bookingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingReference"
    ADD CONSTRAINT "BookingReference_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES public."Booking"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingReference BookingReference_credentialId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingReference"
    ADD CONSTRAINT "BookingReference_credentialId_fkey" FOREIGN KEY ("credentialId") REFERENCES public."Credential"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: BookingReference BookingReference_delegationCredentialId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingReference"
    ADD CONSTRAINT "BookingReference_delegationCredentialId_fkey" FOREIGN KEY ("delegationCredentialId") REFERENCES public."DelegationCredential"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: BookingReference BookingReference_domainWideDelegationCredentialId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingReference"
    ADD CONSTRAINT "BookingReference_domainWideDelegationCredentialId_fkey" FOREIGN KEY ("domainWideDelegationCredentialId") REFERENCES public."DomainWideDelegation"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: BookingReport BookingReport_bookingUid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingReport"
    ADD CONSTRAINT "BookingReport_bookingUid_fkey" FOREIGN KEY ("bookingUid") REFERENCES public."Booking"(uid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingReport BookingReport_globalWatchlistId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingReport"
    ADD CONSTRAINT "BookingReport_globalWatchlistId_fkey" FOREIGN KEY ("globalWatchlistId") REFERENCES public."Watchlist"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: BookingReport BookingReport_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingReport"
    ADD CONSTRAINT "BookingReport_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingReport BookingReport_reportedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingReport"
    ADD CONSTRAINT "BookingReport_reportedById_fkey" FOREIGN KEY ("reportedById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: BookingReport BookingReport_watchlistId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingReport"
    ADD CONSTRAINT "BookingReport_watchlistId_fkey" FOREIGN KEY ("watchlistId") REFERENCES public."Watchlist"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: BookingSeat BookingSeat_attendeeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingSeat"
    ADD CONSTRAINT "BookingSeat_attendeeId_fkey" FOREIGN KEY ("attendeeId") REFERENCES public."Attendee"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingSeat BookingSeat_bookingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingSeat"
    ADD CONSTRAINT "BookingSeat_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES public."Booking"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Booking Booking_destinationCalendarId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Booking"
    ADD CONSTRAINT "Booking_destinationCalendarId_fkey" FOREIGN KEY ("destinationCalendarId") REFERENCES public."DestinationCalendar"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Booking Booking_eventTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Booking"
    ADD CONSTRAINT "Booking_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES public."EventType"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Booking Booking_reassignById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Booking"
    ADD CONSTRAINT "Booking_reassignById_fkey" FOREIGN KEY ("reassignById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Booking Booking_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Booking"
    ADD CONSTRAINT "Booking_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CalAiPhoneNumber CalAiPhoneNumber_inboundAgentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CalAiPhoneNumber"
    ADD CONSTRAINT "CalAiPhoneNumber_inboundAgentId_fkey" FOREIGN KEY ("inboundAgentId") REFERENCES public."Agent"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CalAiPhoneNumber CalAiPhoneNumber_outboundAgentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CalAiPhoneNumber"
    ADD CONSTRAINT "CalAiPhoneNumber_outboundAgentId_fkey" FOREIGN KEY ("outboundAgentId") REFERENCES public."Agent"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CalAiPhoneNumber CalAiPhoneNumber_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CalAiPhoneNumber"
    ADD CONSTRAINT "CalAiPhoneNumber_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CalAiPhoneNumber CalAiPhoneNumber_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CalAiPhoneNumber"
    ADD CONSTRAINT "CalAiPhoneNumber_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CalVideoSettings CalVideoSettings_eventTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CalVideoSettings"
    ADD CONSTRAINT "CalVideoSettings_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES public."EventType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CalendarCacheEvent CalendarCacheEvent_selectedCalendarId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CalendarCacheEvent"
    ADD CONSTRAINT "CalendarCacheEvent_selectedCalendarId_fkey" FOREIGN KEY ("selectedCalendarId") REFERENCES public."SelectedCalendar"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CalendarCache CalendarCache_credentialId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CalendarCache"
    ADD CONSTRAINT "CalendarCache_credentialId_fkey" FOREIGN KEY ("credentialId") REFERENCES public."Credential"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Credential Credential_appId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Credential"
    ADD CONSTRAINT "Credential_appId_fkey" FOREIGN KEY ("appId") REFERENCES public."App"(slug) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Credential Credential_delegationCredentialId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Credential"
    ADD CONSTRAINT "Credential_delegationCredentialId_fkey" FOREIGN KEY ("delegationCredentialId") REFERENCES public."DelegationCredential"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Credential Credential_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Credential"
    ADD CONSTRAINT "Credential_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Credential Credential_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Credential"
    ADD CONSTRAINT "Credential_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CreditBalance CreditBalance_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditBalance"
    ADD CONSTRAINT "CreditBalance_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CreditBalance CreditBalance_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditBalance"
    ADD CONSTRAINT "CreditBalance_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CreditExpenseLog CreditExpenseLog_bookingUid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditExpenseLog"
    ADD CONSTRAINT "CreditExpenseLog_bookingUid_fkey" FOREIGN KEY ("bookingUid") REFERENCES public."Booking"(uid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CreditExpenseLog CreditExpenseLog_creditBalanceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditExpenseLog"
    ADD CONSTRAINT "CreditExpenseLog_creditBalanceId_fkey" FOREIGN KEY ("creditBalanceId") REFERENCES public."CreditBalance"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CreditPurchaseLog CreditPurchaseLog_creditBalanceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CreditPurchaseLog"
    ADD CONSTRAINT "CreditPurchaseLog_creditBalanceId_fkey" FOREIGN KEY ("creditBalanceId") REFERENCES public."CreditBalance"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DSyncData DSyncData_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DSyncData"
    ADD CONSTRAINT "DSyncData_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."OrganizationSettings"("organizationId") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DSyncTeamGroupMapping DSyncTeamGroupMapping_directoryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DSyncTeamGroupMapping"
    ADD CONSTRAINT "DSyncTeamGroupMapping_directoryId_fkey" FOREIGN KEY ("directoryId") REFERENCES public."DSyncData"("directoryId") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DSyncTeamGroupMapping DSyncTeamGroupMapping_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DSyncTeamGroupMapping"
    ADD CONSTRAINT "DSyncTeamGroupMapping_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DelegationCredential DelegationCredential_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DelegationCredential"
    ADD CONSTRAINT "DelegationCredential_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DelegationCredential DelegationCredential_workspacePlatformId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DelegationCredential"
    ADD CONSTRAINT "DelegationCredential_workspacePlatformId_fkey" FOREIGN KEY ("workspacePlatformId") REFERENCES public."WorkspacePlatform"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DestinationCalendar DestinationCalendar_credentialId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DestinationCalendar"
    ADD CONSTRAINT "DestinationCalendar_credentialId_fkey" FOREIGN KEY ("credentialId") REFERENCES public."Credential"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DestinationCalendar DestinationCalendar_delegationCredentialId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DestinationCalendar"
    ADD CONSTRAINT "DestinationCalendar_delegationCredentialId_fkey" FOREIGN KEY ("delegationCredentialId") REFERENCES public."DelegationCredential"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DestinationCalendar DestinationCalendar_domainWideDelegationCredentialId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DestinationCalendar"
    ADD CONSTRAINT "DestinationCalendar_domainWideDelegationCredentialId_fkey" FOREIGN KEY ("domainWideDelegationCredentialId") REFERENCES public."DomainWideDelegation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DestinationCalendar DestinationCalendar_eventTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DestinationCalendar"
    ADD CONSTRAINT "DestinationCalendar_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES public."EventType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DestinationCalendar DestinationCalendar_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DestinationCalendar"
    ADD CONSTRAINT "DestinationCalendar_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DomainWideDelegation DomainWideDelegation_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DomainWideDelegation"
    ADD CONSTRAINT "DomainWideDelegation_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DomainWideDelegation DomainWideDelegation_workspacePlatformId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DomainWideDelegation"
    ADD CONSTRAINT "DomainWideDelegation_workspacePlatformId_fkey" FOREIGN KEY ("workspacePlatformId") REFERENCES public."WorkspacePlatform"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: EventTypeCustomInput EventTypeCustomInput_eventTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventTypeCustomInput"
    ADD CONSTRAINT "EventTypeCustomInput_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES public."EventType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: EventTypeTranslation EventTypeTranslation_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventTypeTranslation"
    ADD CONSTRAINT "EventTypeTranslation_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: EventTypeTranslation EventTypeTranslation_eventTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventTypeTranslation"
    ADD CONSTRAINT "EventTypeTranslation_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES public."EventType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: EventTypeTranslation EventTypeTranslation_updatedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventTypeTranslation"
    ADD CONSTRAINT "EventTypeTranslation_updatedBy_fkey" FOREIGN KEY ("updatedBy") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: EventType EventType_instantMeetingScheduleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventType"
    ADD CONSTRAINT "EventType_instantMeetingScheduleId_fkey" FOREIGN KEY ("instantMeetingScheduleId") REFERENCES public."Schedule"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: EventType EventType_parentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventType"
    ADD CONSTRAINT "EventType_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES public."EventType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: EventType EventType_profileId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventType"
    ADD CONSTRAINT "EventType_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES public."Profile"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: EventType EventType_restrictionScheduleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventType"
    ADD CONSTRAINT "EventType_restrictionScheduleId_fkey" FOREIGN KEY ("restrictionScheduleId") REFERENCES public."Schedule"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: EventType EventType_scheduleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventType"
    ADD CONSTRAINT "EventType_scheduleId_fkey" FOREIGN KEY ("scheduleId") REFERENCES public."Schedule"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: EventType EventType_secondaryEmailId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventType"
    ADD CONSTRAINT "EventType_secondaryEmailId_fkey" FOREIGN KEY ("secondaryEmailId") REFERENCES public."SecondaryEmail"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: EventType EventType_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventType"
    ADD CONSTRAINT "EventType_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: EventType EventType_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EventType"
    ADD CONSTRAINT "EventType_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Feedback Feedback_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Feedback"
    ADD CONSTRAINT "Feedback_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: FilterSegment FilterSegment_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FilterSegment"
    ADD CONSTRAINT "FilterSegment_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: FilterSegment FilterSegment_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FilterSegment"
    ADD CONSTRAINT "FilterSegment_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HashedLink HashedLink_eventTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."HashedLink"
    ADD CONSTRAINT "HashedLink_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES public."EventType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HostGroup HostGroup_eventTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."HostGroup"
    ADD CONSTRAINT "HostGroup_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES public."EventType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HostLocation HostLocation_credentialId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."HostLocation"
    ADD CONSTRAINT "HostLocation_credentialId_fkey" FOREIGN KEY ("credentialId") REFERENCES public."Credential"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: HostLocation HostLocation_userId_eventTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."HostLocation"
    ADD CONSTRAINT "HostLocation_userId_eventTypeId_fkey" FOREIGN KEY ("userId", "eventTypeId") REFERENCES public."Host"("userId", "eventTypeId") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Host Host_eventTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Host"
    ADD CONSTRAINT "Host_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES public."EventType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Host Host_groupId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Host"
    ADD CONSTRAINT "Host_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES public."HostGroup"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Host Host_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Host"
    ADD CONSTRAINT "Host_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public."Membership"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Host Host_scheduleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Host"
    ADD CONSTRAINT "Host_scheduleId_fkey" FOREIGN KEY ("scheduleId") REFERENCES public."Schedule"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Host Host_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Host"
    ADD CONSTRAINT "Host_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Impersonations Impersonations_impersonatedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Impersonations"
    ADD CONSTRAINT "Impersonations_impersonatedById_fkey" FOREIGN KEY ("impersonatedById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Impersonations Impersonations_impersonatedUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Impersonations"
    ADD CONSTRAINT "Impersonations_impersonatedUserId_fkey" FOREIGN KEY ("impersonatedUserId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: InstantMeetingToken InstantMeetingToken_bookingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InstantMeetingToken"
    ADD CONSTRAINT "InstantMeetingToken_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES public."Booking"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: InstantMeetingToken InstantMeetingToken_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InstantMeetingToken"
    ADD CONSTRAINT "InstantMeetingToken_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: IntegrationAttributeSync IntegrationAttributeSync_credentialId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."IntegrationAttributeSync"
    ADD CONSTRAINT "IntegrationAttributeSync_credentialId_fkey" FOREIGN KEY ("credentialId") REFERENCES public."Credential"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: IntegrationAttributeSync IntegrationAttributeSync_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."IntegrationAttributeSync"
    ADD CONSTRAINT "IntegrationAttributeSync_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: InternalNotePreset InternalNotePreset_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InternalNotePreset"
    ADD CONSTRAINT "InternalNotePreset_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ManagedOrganization ManagedOrganization_managedOrganizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ManagedOrganization"
    ADD CONSTRAINT "ManagedOrganization_managedOrganizationId_fkey" FOREIGN KEY ("managedOrganizationId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ManagedOrganization ManagedOrganization_managerOrganizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ManagedOrganization"
    ADD CONSTRAINT "ManagedOrganization_managerOrganizationId_fkey" FOREIGN KEY ("managerOrganizationId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Membership Membership_customRoleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Membership"
    ADD CONSTRAINT "Membership_customRoleId_fkey" FOREIGN KEY ("customRoleId") REFERENCES public."Role"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Membership Membership_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Membership"
    ADD CONSTRAINT "Membership_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Membership Membership_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Membership"
    ADD CONSTRAINT "Membership_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MonthlyProration MonthlyProration_organizationBillingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MonthlyProration"
    ADD CONSTRAINT "MonthlyProration_organizationBillingId_fkey" FOREIGN KEY ("organizationBillingId") REFERENCES public."OrganizationBilling"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: MonthlyProration MonthlyProration_teamBillingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MonthlyProration"
    ADD CONSTRAINT "MonthlyProration_teamBillingId_fkey" FOREIGN KEY ("teamBillingId") REFERENCES public."TeamBilling"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: MonthlyProration MonthlyProration_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MonthlyProration"
    ADD CONSTRAINT "MonthlyProration_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: NotificationsSubscriptions NotificationsSubscriptions_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NotificationsSubscriptions"
    ADD CONSTRAINT "NotificationsSubscriptions_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OAuthClient OAuthClient_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OAuthClient"
    ADD CONSTRAINT "OAuthClient_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: OrganizationBilling OrganizationBilling_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OrganizationBilling"
    ADD CONSTRAINT "OrganizationBilling_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrganizationOnboarding OrganizationOnboarding_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OrganizationOnboarding"
    ADD CONSTRAINT "OrganizationOnboarding_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrganizationOnboarding OrganizationOnboarding_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OrganizationOnboarding"
    ADD CONSTRAINT "OrganizationOnboarding_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrganizationSettings OrganizationSettings_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OrganizationSettings"
    ADD CONSTRAINT "OrganizationSettings_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OutOfOfficeEntry OutOfOfficeEntry_reasonId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OutOfOfficeEntry"
    ADD CONSTRAINT "OutOfOfficeEntry_reasonId_fkey" FOREIGN KEY ("reasonId") REFERENCES public."OutOfOfficeReason"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: OutOfOfficeEntry OutOfOfficeEntry_toUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OutOfOfficeEntry"
    ADD CONSTRAINT "OutOfOfficeEntry_toUserId_fkey" FOREIGN KEY ("toUserId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OutOfOfficeEntry OutOfOfficeEntry_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OutOfOfficeEntry"
    ADD CONSTRAINT "OutOfOfficeEntry_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OutOfOfficeReason OutOfOfficeReason_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OutOfOfficeReason"
    ADD CONSTRAINT "OutOfOfficeReason_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Payment Payment_appId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_appId_fkey" FOREIGN KEY ("appId") REFERENCES public."App"(slug) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Payment Payment_bookingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES public."Booking"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PendingRoutingTrace PendingRoutingTrace_formResponseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PendingRoutingTrace"
    ADD CONSTRAINT "PendingRoutingTrace_formResponseId_fkey" FOREIGN KEY ("formResponseId") REFERENCES public."App_RoutingForms_FormResponse"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PendingRoutingTrace PendingRoutingTrace_queuedFormResponseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PendingRoutingTrace"
    ADD CONSTRAINT "PendingRoutingTrace_queuedFormResponseId_fkey" FOREIGN KEY ("queuedFormResponseId") REFERENCES public."App_RoutingForms_QueuedFormResponse"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PlatformAuthorizationToken PlatformAuthorizationToken_platformOAuthClientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PlatformAuthorizationToken"
    ADD CONSTRAINT "PlatformAuthorizationToken_platformOAuthClientId_fkey" FOREIGN KEY ("platformOAuthClientId") REFERENCES public."PlatformOAuthClient"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PlatformAuthorizationToken PlatformAuthorizationToken_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PlatformAuthorizationToken"
    ADD CONSTRAINT "PlatformAuthorizationToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PlatformBilling PlatformBilling_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PlatformBilling"
    ADD CONSTRAINT "PlatformBilling_id_fkey" FOREIGN KEY (id) REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PlatformBilling PlatformBilling_managerBillingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PlatformBilling"
    ADD CONSTRAINT "PlatformBilling_managerBillingId_fkey" FOREIGN KEY ("managerBillingId") REFERENCES public."PlatformBilling"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: PlatformOAuthClient PlatformOAuthClient_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PlatformOAuthClient"
    ADD CONSTRAINT "PlatformOAuthClient_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Profile Profile_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Profile"
    ADD CONSTRAINT "Profile_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Profile Profile_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Profile"
    ADD CONSTRAINT "Profile_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RateLimit RateLimit_apiKeyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RateLimit"
    ADD CONSTRAINT "RateLimit_apiKeyId_fkey" FOREIGN KEY ("apiKeyId") REFERENCES public."ApiKey"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RefreshToken RefreshToken_platformOAuthClientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RefreshToken"
    ADD CONSTRAINT "RefreshToken_platformOAuthClientId_fkey" FOREIGN KEY ("platformOAuthClientId") REFERENCES public."PlatformOAuthClient"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RefreshToken RefreshToken_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RefreshToken"
    ADD CONSTRAINT "RefreshToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RolePermission RolePermission_roleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RolePermission"
    ADD CONSTRAINT "RolePermission_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES public."Role"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Role Role_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Role"
    ADD CONSTRAINT "Role_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RoutingFormResponseDenormalized RoutingFormResponseDenormalized_bookingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RoutingFormResponseDenormalized"
    ADD CONSTRAINT "RoutingFormResponseDenormalized_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES public."Booking"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: RoutingFormResponseDenormalized RoutingFormResponseDenormalized_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RoutingFormResponseDenormalized"
    ADD CONSTRAINT "RoutingFormResponseDenormalized_id_fkey" FOREIGN KEY (id) REFERENCES public."App_RoutingForms_FormResponse"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RoutingFormResponseField RoutingFormResponseField_responseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RoutingFormResponseField"
    ADD CONSTRAINT "RoutingFormResponseField_responseId_fkey" FOREIGN KEY ("responseId") REFERENCES public."RoutingFormResponseDenormalized"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RoutingFormResponseField RoutingFormResponseField_response_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RoutingFormResponseField"
    ADD CONSTRAINT "RoutingFormResponseField_response_fkey" FOREIGN KEY ("responseId") REFERENCES public."App_RoutingForms_FormResponse"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RoutingTrace RoutingTrace_assignmentReasonId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RoutingTrace"
    ADD CONSTRAINT "RoutingTrace_assignmentReasonId_fkey" FOREIGN KEY ("assignmentReasonId") REFERENCES public."AssignmentReason"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RoutingTrace RoutingTrace_bookingUid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RoutingTrace"
    ADD CONSTRAINT "RoutingTrace_bookingUid_fkey" FOREIGN KEY ("bookingUid") REFERENCES public."Booking"(uid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RoutingTrace RoutingTrace_formResponseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RoutingTrace"
    ADD CONSTRAINT "RoutingTrace_formResponseId_fkey" FOREIGN KEY ("formResponseId") REFERENCES public."App_RoutingForms_FormResponse"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RoutingTrace RoutingTrace_queuedFormResponseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RoutingTrace"
    ADD CONSTRAINT "RoutingTrace_queuedFormResponseId_fkey" FOREIGN KEY ("queuedFormResponseId") REFERENCES public."App_RoutingForms_QueuedFormResponse"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Schedule Schedule_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Schedule"
    ADD CONSTRAINT "Schedule_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SeatChangeLog SeatChangeLog_organizationBillingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SeatChangeLog"
    ADD CONSTRAINT "SeatChangeLog_organizationBillingId_fkey" FOREIGN KEY ("organizationBillingId") REFERENCES public."OrganizationBilling"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SeatChangeLog SeatChangeLog_processedInProrationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SeatChangeLog"
    ADD CONSTRAINT "SeatChangeLog_processedInProrationId_fkey" FOREIGN KEY ("processedInProrationId") REFERENCES public."MonthlyProration"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SeatChangeLog SeatChangeLog_teamBillingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SeatChangeLog"
    ADD CONSTRAINT "SeatChangeLog_teamBillingId_fkey" FOREIGN KEY ("teamBillingId") REFERENCES public."TeamBilling"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SeatChangeLog SeatChangeLog_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SeatChangeLog"
    ADD CONSTRAINT "SeatChangeLog_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SecondaryEmail SecondaryEmail_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SecondaryEmail"
    ADD CONSTRAINT "SecondaryEmail_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SelectedCalendar SelectedCalendar_credentialId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SelectedCalendar"
    ADD CONSTRAINT "SelectedCalendar_credentialId_fkey" FOREIGN KEY ("credentialId") REFERENCES public."Credential"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SelectedCalendar SelectedCalendar_delegationCredentialId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SelectedCalendar"
    ADD CONSTRAINT "SelectedCalendar_delegationCredentialId_fkey" FOREIGN KEY ("delegationCredentialId") REFERENCES public."DelegationCredential"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SelectedCalendar SelectedCalendar_domainWideDelegationCredentialId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SelectedCalendar"
    ADD CONSTRAINT "SelectedCalendar_domainWideDelegationCredentialId_fkey" FOREIGN KEY ("domainWideDelegationCredentialId") REFERENCES public."DomainWideDelegation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SelectedCalendar SelectedCalendar_eventTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SelectedCalendar"
    ADD CONSTRAINT "SelectedCalendar_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES public."EventType"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SelectedCalendar SelectedCalendar_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SelectedCalendar"
    ADD CONSTRAINT "SelectedCalendar_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Session Session_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Session"
    ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TeamBilling TeamBilling_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TeamBilling"
    ADD CONSTRAINT "TeamBilling_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TeamFeatures TeamFeatures_featureId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TeamFeatures"
    ADD CONSTRAINT "TeamFeatures_featureId_fkey" FOREIGN KEY ("featureId") REFERENCES public."Feature"(slug) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TeamFeatures TeamFeatures_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TeamFeatures"
    ADD CONSTRAINT "TeamFeatures_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Team Team_createdByOAuthClientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Team"
    ADD CONSTRAINT "Team_createdByOAuthClientId_fkey" FOREIGN KEY ("createdByOAuthClientId") REFERENCES public."PlatformOAuthClient"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Team Team_parentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Team"
    ADD CONSTRAINT "Team_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Tracking Tracking_bookingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Tracking"
    ADD CONSTRAINT "Tracking_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES public."Booking"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TravelSchedule TravelSchedule_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TravelSchedule"
    ADD CONSTRAINT "TravelSchedule_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserFeatures UserFeatures_featureId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserFeatures"
    ADD CONSTRAINT "UserFeatures_featureId_fkey" FOREIGN KEY ("featureId") REFERENCES public."Feature"(slug) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserFeatures UserFeatures_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserFeatures"
    ADD CONSTRAINT "UserFeatures_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserFilterSegmentPreference UserFilterSegmentPreference_segmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserFilterSegmentPreference"
    ADD CONSTRAINT "UserFilterSegmentPreference_segmentId_fkey" FOREIGN KEY ("segmentId") REFERENCES public."FilterSegment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserFilterSegmentPreference UserFilterSegmentPreference_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserFilterSegmentPreference"
    ADD CONSTRAINT "UserFilterSegmentPreference_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserHolidaySettings UserHolidaySettings_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserHolidaySettings"
    ADD CONSTRAINT "UserHolidaySettings_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserPassword UserPassword_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserPassword"
    ADD CONSTRAINT "UserPassword_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: VerificationToken VerificationToken_secondaryEmailId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VerificationToken"
    ADD CONSTRAINT "VerificationToken_secondaryEmailId_fkey" FOREIGN KEY ("secondaryEmailId") REFERENCES public."SecondaryEmail"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: VerificationToken VerificationToken_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VerificationToken"
    ADD CONSTRAINT "VerificationToken_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: VerifiedEmail VerifiedEmail_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VerifiedEmail"
    ADD CONSTRAINT "VerifiedEmail_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: VerifiedEmail VerifiedEmail_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VerifiedEmail"
    ADD CONSTRAINT "VerifiedEmail_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: VerifiedNumber VerifiedNumber_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VerifiedNumber"
    ADD CONSTRAINT "VerifiedNumber_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: VerifiedNumber VerifiedNumber_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."VerifiedNumber"
    ADD CONSTRAINT "VerifiedNumber_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WatchlistAudit WatchlistAudit_watchlistId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WatchlistAudit"
    ADD CONSTRAINT "WatchlistAudit_watchlistId_fkey" FOREIGN KEY ("watchlistId") REFERENCES public."Watchlist"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WebhookScheduledTriggers WebhookScheduledTriggers_bookingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WebhookScheduledTriggers"
    ADD CONSTRAINT "WebhookScheduledTriggers_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES public."Booking"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WebhookScheduledTriggers WebhookScheduledTriggers_webhookId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WebhookScheduledTriggers"
    ADD CONSTRAINT "WebhookScheduledTriggers_webhookId_fkey" FOREIGN KEY ("webhookId") REFERENCES public."Webhook"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Webhook Webhook_appId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Webhook"
    ADD CONSTRAINT "Webhook_appId_fkey" FOREIGN KEY ("appId") REFERENCES public."App"(slug) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Webhook Webhook_eventTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Webhook"
    ADD CONSTRAINT "Webhook_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES public."EventType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Webhook Webhook_platformOAuthClientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Webhook"
    ADD CONSTRAINT "Webhook_platformOAuthClientId_fkey" FOREIGN KEY ("platformOAuthClientId") REFERENCES public."PlatformOAuthClient"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Webhook Webhook_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Webhook"
    ADD CONSTRAINT "Webhook_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Webhook Webhook_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Webhook"
    ADD CONSTRAINT "Webhook_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WorkflowReminder WorkflowReminder_bookingUid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowReminder"
    ADD CONSTRAINT "WorkflowReminder_bookingUid_fkey" FOREIGN KEY ("bookingUid") REFERENCES public."Booking"(uid) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WorkflowReminder WorkflowReminder_workflowStepId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowReminder"
    ADD CONSTRAINT "WorkflowReminder_workflowStepId_fkey" FOREIGN KEY ("workflowStepId") REFERENCES public."WorkflowStep"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WorkflowStepTranslation WorkflowStepTranslation_workflowStepId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowStepTranslation"
    ADD CONSTRAINT "WorkflowStepTranslation_workflowStepId_fkey" FOREIGN KEY ("workflowStepId") REFERENCES public."WorkflowStep"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WorkflowStep WorkflowStep_agentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowStep"
    ADD CONSTRAINT "WorkflowStep_agentId_fkey" FOREIGN KEY ("agentId") REFERENCES public."Agent"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WorkflowStep WorkflowStep_inboundAgentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowStep"
    ADD CONSTRAINT "WorkflowStep_inboundAgentId_fkey" FOREIGN KEY ("inboundAgentId") REFERENCES public."Agent"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WorkflowStep WorkflowStep_workflowId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowStep"
    ADD CONSTRAINT "WorkflowStep_workflowId_fkey" FOREIGN KEY ("workflowId") REFERENCES public."Workflow"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Workflow Workflow_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Workflow"
    ADD CONSTRAINT "Workflow_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Workflow Workflow_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Workflow"
    ADD CONSTRAINT "Workflow_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WorkflowsOnEventTypes WorkflowsOnEventTypes_eventTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowsOnEventTypes"
    ADD CONSTRAINT "WorkflowsOnEventTypes_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES public."EventType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WorkflowsOnEventTypes WorkflowsOnEventTypes_workflowId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowsOnEventTypes"
    ADD CONSTRAINT "WorkflowsOnEventTypes_workflowId_fkey" FOREIGN KEY ("workflowId") REFERENCES public."Workflow"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WorkflowsOnRoutingForms WorkflowsOnRoutingForms_routingFormId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowsOnRoutingForms"
    ADD CONSTRAINT "WorkflowsOnRoutingForms_routingFormId_fkey" FOREIGN KEY ("routingFormId") REFERENCES public."App_RoutingForms_Form"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WorkflowsOnRoutingForms WorkflowsOnRoutingForms_workflowId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowsOnRoutingForms"
    ADD CONSTRAINT "WorkflowsOnRoutingForms_workflowId_fkey" FOREIGN KEY ("workflowId") REFERENCES public."Workflow"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WorkflowsOnTeams WorkflowsOnTeams_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowsOnTeams"
    ADD CONSTRAINT "WorkflowsOnTeams_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WorkflowsOnTeams WorkflowsOnTeams_workflowId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkflowsOnTeams"
    ADD CONSTRAINT "WorkflowsOnTeams_workflowId_fkey" FOREIGN KEY ("workflowId") REFERENCES public."Workflow"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WrongAssignmentReport WrongAssignmentReport_bookingUid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WrongAssignmentReport"
    ADD CONSTRAINT "WrongAssignmentReport_bookingUid_fkey" FOREIGN KEY ("bookingUid") REFERENCES public."Booking"(uid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WrongAssignmentReport WrongAssignmentReport_reportedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WrongAssignmentReport"
    ADD CONSTRAINT "WrongAssignmentReport_reportedById_fkey" FOREIGN KEY ("reportedById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WrongAssignmentReport WrongAssignmentReport_reviewedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WrongAssignmentReport"
    ADD CONSTRAINT "WrongAssignmentReport_reviewedById_fkey" FOREIGN KEY ("reviewedById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WrongAssignmentReport WrongAssignmentReport_routingFormId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WrongAssignmentReport"
    ADD CONSTRAINT "WrongAssignmentReport_routingFormId_fkey" FOREIGN KEY ("routingFormId") REFERENCES public."App_RoutingForms_Form"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WrongAssignmentReport WrongAssignmentReport_teamId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WrongAssignmentReport"
    ADD CONSTRAINT "WrongAssignmentReport_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: _PlatformOAuthClientToUser _PlatformOAuthClientToUser_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_PlatformOAuthClientToUser"
    ADD CONSTRAINT "_PlatformOAuthClientToUser_A_fkey" FOREIGN KEY ("A") REFERENCES public."PlatformOAuthClient"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _PlatformOAuthClientToUser _PlatformOAuthClientToUser_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_PlatformOAuthClientToUser"
    ADD CONSTRAINT "_PlatformOAuthClientToUser_B_fkey" FOREIGN KEY ("B") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _user_eventtype _user_eventtype_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._user_eventtype
    ADD CONSTRAINT "_user_eventtype_A_fkey" FOREIGN KEY ("A") REFERENCES public."EventType"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _user_eventtype _user_eventtype_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._user_eventtype
    ADD CONSTRAINT "_user_eventtype_B_fkey" FOREIGN KEY ("B") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users users_movedToProfileId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "users_movedToProfileId_fkey" FOREIGN KEY ("movedToProfileId") REFERENCES public."Profile"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: users users_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "users_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Team"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--


