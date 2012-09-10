-- Icinga User Credentials

SET @USERNAME = "%USERNAME%";
SET @PASSWORD = (SELECT MD5("%PASSWORD%"));

SET @STATUS = 2;
SET @CMDBSTATUS = 6;
SET @ADMINTITLE = (SELECT isys_obj__title FROM isys_obj WHERE isys_obj__const = "C__OBJ__PERSON_ADMIN");
SET @ADMINGROUP = (SELECT isys_obj__id FROM isys_obj WHERE isys_obj__const = "C__OBJ__PERSON_GROUP_ADMIN");
SET @ADMINGROUPTITLE = (SELECT isys_obj__title FROM isys_obj WHERE isys_obj__const = "C__OBJ__PERSON_GROUP_ADMIN");
SET @PERSON = (SELECT isys_obj_type__id FROM isys_obj_type WHERE isys_obj_type__const = "C__OBJTYPE__PERSON");
SET @RELATION = (SELECT isys_obj_type__id FROM isys_obj_type WHERE isys_obj_type__const = "C__OBJTYPE__RELATION");
SET @RELATIONTYPE = (SELECT isys_relation_type__id FROM isys_relation_type WHERE isys_relation_type__const = "C__RELATION_TYPE__PERSON_ASSIGNED_GROUPS");

-- Sleep for one second to create an unique SYSID:
SELECT SLEEP(1);

INSERT INTO isys_obj (
    isys_obj__title,
    isys_obj__isys_obj_type__id,
    isys_obj__isys_cmdb_status__id,
    isys_obj__status,
    isys_obj__sysid,
    isys_obj__created,
    isys_obj__created_by,
    isys_obj__updated,
    isys_obj__updated_by,
    isys_obj__hostname,
    isys_obj__scantime,
    isys_obj__imported,
    isys_obj__description
) VALUES (
    @USERNAME, @PERSON, @CMDBSTATUS, @STATUS, CONCAT('SYSID_', NOW()), NOW(), @ADMINTITLE, NOW(), @ADMINTITLE, '', NULL, NULL, ''
);

SET @USERID = (SELECT LAST_INSERT_ID());

INSERT INTO isys_catg_global_list (
    isys_catg_global_list__isys_catg_global_category__id,
    isys_catg_global_list__isys_purpose__id,
    isys_catg_global_list__isys_obj__id,
    isys_catg_global_list__description,
    isys_catg_global_list__status
) VALUES (
    NULL, NULL, @USERID, '', @STATUS
);

INSERT INTO isys_connection SET isys_connection__isys_obj__id = @USERID;
SET @CONNECTIONID = (SELECT LAST_INSERT_ID());

INSERT INTO isys_cats_person_list SET
    isys_cats_person_list__isys_obj__id = @USERID,
    isys_cats_person_list__first_name = @USERNAME,
    isys_cats_person_list__last_name = '',
    isys_cats_person_list__title = @USERNAME,
    isys_cats_person_list__user_pass = @PASSWORD,
    isys_cats_person_list__phone_company = '',
    isys_cats_person_list__phone_mobile = '',
    isys_cats_person_list__phone_home = '',
    isys_cats_person_list__fax = '',
    isys_cats_person_list__personnel_number = '',
    isys_cats_person_list__department = '',
    isys_cats_person_list__isys_connection__id = @CONNECTIONID,
    isys_cats_person_list__description = '',
    isys_cats_person_list__status = @STATUS;
    
INSERT INTO isys_person_2_group SET
    isys_person_2_group__isys_obj__id__person = @USERID,
    isys_person_2_group__isys_obj__id__group = @ADMINGROUP;

SET @PERSON2GROUP = (SELECT LAST_INSERT_ID());

-- Sleep for one second to create an unique SYSID:
SELECT SLEEP(1);

INSERT INTO isys_obj (
    isys_obj__title,
    isys_obj__isys_obj_type__id,
    isys_obj__isys_cmdb_status__id,
    isys_obj__status,
    isys_obj__sysid,
    isys_obj__created,
    isys_obj__created_by,
    isys_obj__updated,
    isys_obj__updated_by,
    isys_obj__hostname,
    isys_obj__scantime,
    isys_obj__imported,
    isys_obj__description
) VALUES (
    CONCAT(@ADMINGROUPTITLE, ' has member ', @USERNAME), @RELATION, @CMDBSTATUS, @STATUS, CONCAT('SYSID_', NOW()), NOW(), @ADMINTITLE, NOW(), @ADMINTITLE, '', NULL, NULL, ''
);

SET @MEMBERSHIP = (SELECT LAST_INSERT_ID());

INSERT INTO isys_catg_global_list (
    isys_catg_global_list__isys_catg_global_category__id,
    isys_catg_global_list__isys_purpose__id,
    isys_catg_global_list__isys_obj__id,
    isys_catg_global_list__description,
    isys_catg_global_list__status
) VALUES (
    NULL, NULL, @MEMBERSHIP, '', @STATUS
);

INSERT INTO isys_catg_relation_list SET
    isys_catg_relation_list__isys_obj__id = @MEMBERSHIP,
    isys_catg_relation_list__isys_obj__id__master = @ADMINGROUP,
    isys_catg_relation_list__isys_obj__id__slave = @USERID,
    isys_catg_relation_list__isys_obj__id__itservice = NULL,
    isys_catg_relation_list__isys_relation_type__id = @RELATIONTYPE,
    isys_catg_relation_list__isys_weighting__id = '5',
    isys_catg_relation_list__status = @STATUS,
    isys_catg_relation_list__description = '';

SET @RELATIONID = (SELECT LAST_INSERT_ID());
    
UPDATE isys_person_2_group SET
    isys_person_2_group__isys_catg_relation_list__id = @RELATIONID
WHERE isys_person_2_group__id = @PERSON2GROUP;
