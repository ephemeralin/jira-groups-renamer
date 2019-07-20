-- Official Atlassian recommendations are here:
-- https://confluence.atlassian.com/jirakb/how-to-rename-a-group-in-jira-968662365.html
-- Original ticket about problem is here:
-- https://jira.atlassian.com/browse/JRASERVER-1391

-- rollback;
begin transaction;

do $$

    declare
        -- sample data. You should fill these arrays by real data
        -- the length of both arrays should be the same
        -- each position in first array should contain element
        -- to rename to the name on the same position in the second array
        old_names text[] := array['OLD-NAME-ONE-users','OLD-NAME-TWO-users'];
        new_names text[] := array['NEW-NAME-ONE-users','NEW-NAME-TWO-users'];

        i integer = 1;
        new_name text;
        old_name text;
    begin
        raise info 'start %', current_timestamp;
        foreach old_name in array old_names loop
            new_name = new_names[i];
            raise info '***************************';
            raise info '*** % ---> %', old_name, new_name;
            -- 1. RENAME THE GROUP
            update cwd_group
            set
                group_name = coalesce(new_name, cwd_group.group_name),
                lower_group_name = lower(coalesce(new_name, cwd_group.lower_group_name))
            where
                    cwd_group.group_name = old_name and cwd_group.group_type = 'GROUP';
            if found then raise info '  + renaimed';
            else raise info '  - not renaimed: % not found!', old_name;
            end if;

            -- 2. UPDATE USER MEMBERSHIP
            update
                cwd_membership
            set
                parent_name = coalesce(new_name, cwd_membership.parent_name),
                lower_parent_name = lower(coalesce(new_name, cwd_membership.lower_parent_name))
            where
                    parent_name = old_name
              and membership_type = 'GROUP_USER';

            -- 3. UPDATE NOTIFICATION SCHEMES
            update
                notification
            set
                notif_parameter = coalesce(new_name, notification.notif_parameter)
            where
                    notif_parameter = old_name
              and notif_type = 'Group_Dropdown';

            -- 4. UPDATE ISSUE SECURITY SCHEMES
            update
                schemeissuesecurities
            set
                sec_parameter = coalesce(new_name, schemeissuesecurities.sec_parameter)
            where
                    sec_parameter = old_name
              and sec_type = 'group';

            -- 5. UPDATE PERMISSION SCHEMES
            update
                schemepermissions
            set
                perm_parameter = coalesce(new_name, schemepermissions.perm_parameter)
            where
                    perm_parameter = old_name
              and perm_type = 'group';

            -- 6. UPDATE SHARED EDIT RIGHTS
            -- Note: Updating shared edit rights is required only for Jira 7.12, or later.
            --       Earlier versions don't allow to share edit rights for filters and dashboards.
            update
                sharepermissions
            set
                param1 = coalesce(new_name, sharepermissions.param1)
            where
                    param1 = old_name
              and sharetype = 'group';

            -- 7. UPDATE FILTER SUBSCRIPTIONS
            update
                filtersubscription
            set
                groupname = coalesce(new_name, filtersubscription.groupname)
            where
                    groupname = old_name;

            -- 8. UPDATE COMMENT RESTRICTIONS
            update
                jiraaction
            set
                actionlevel = coalesce(new_name, jiraaction.actionlevel)
            where
                    actionlevel = old_name;

            -- 9. UPDATE WORK LOGS
            update
                worklog
            set
                grouplevel = coalesce(new_name, worklog.grouplevel)
            where
                    grouplevel = old_name;

            -- 10. UPDATE FILTERS
            update
                searchrequest
            set
                groupname = coalesce(new_name, searchrequest.groupname)
            where
                    groupname = old_name;

            -- 11. UPDATE PROJECT ROLES
            update
                projectroleactor
            set
                roletypeparameter = coalesce(new_name, projectroleactor.roletypeparameter)
            where
                    roletypeparameter = old_name
              and roletype = 'atlassian-group-role-actor';

            -- 12. UPDATE GLOBAL PERMISSIONS
            update
                globalpermissionentry
            set
                group_id = coalesce(new_name, globalpermissionentry.group_id)
            where
                    group_id = old_name;

            -- 13. UPDATE LICENSE ROLE GROUPS
            update
                licenserolesgroup
            set
                group_id = coalesce(new_name, licenserolesgroup.group_id)
            where
                    group_id = old_name;

            -- 14. UPDATE CUSTOM FIELD VALUES
            update
                customfieldvalue
            set
                stringvalue = coalesce(new_name, customfieldvalue.stringvalue)
            where
                    stringvalue = old_name
              and customfield in
                  (
                      select
                          id
                      from
                          customfield
                      where
                              customfieldtypekey in (
                                                     'com.atlassian.jira.plugin.system.customfieldtypes:multigrouppicker'
                              , 'com.atlassian.jira.plugin.system.customfieldtypes:grouppicker'
                              )
                  );

            -- 15. Find filters and workflows that contain group names and rename them via admin page
            -- See find_filters_and_workflows_script.sql

            -- end
            i = i + 1;
            raise info '+ done';
        end loop;

    end
    $$ language plpgsql;

commit transaction;
