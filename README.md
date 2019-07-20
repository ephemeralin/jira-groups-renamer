# SQL script for group renaming in Jira   
#### About
In 2003 someone created ticket **[JRASERVER-1391](https://jira.atlassian.com/browse/JRASERVER-1391)** in the Atlassian issue tracker about a problem of renaming groups in Jira. Since then there is no any convenient way to do it using an administration web-page.
 I've recently come across with the same problem and built this script. 
The script allows you to rename bunch of groups in one transaction. It follows the[official recommendations](https://confluence.atlassian.com/jirakb/how-to-rename-a-group-in-jira-968662365.html) from Atlassian with changing names in all necessary tables.  
**Note:** the script was written specifically for the **Atlassian Server** platform. Due to the [Functional differences in Atlassian Cloud](https://confluence.atlassian.com/display/Cloud/Functional+differences+in+Atlassian+Cloud), the script cannot be applied to Atlassian Cloud applications.
#### How to use the script
 1. Just to remember: create a backup! 
 2. Atlassian do not mention stopping the Jira instance. But I would recommend to stop it right before running the script jira-groups-renamer.sql.
 3. Run the script:
`psql -U user_name -d db_name -a -f ./jira-groups-renamer.sql`
 5. The script is running in one transaction. Therefore if something goes wrong, the changes won't be applied. Do not forget to run `rollback;` command in any worst case.
 6. During the running the script you can see output in the console about renaming results of each group.
 7. Start Jira.
 8. After running the script you should check filters and workflows that might contain group names. For that purpose you can easily use the find_filters_and_workflows.sql with two select statements.
 9. Atlassian notices, that the group names belongs to the Jira platform, which is shared between Jira Core, Jira Software, and Jira Service Desk (the latter two are built on top of the platform). It might happen that group names are also stored in places specific to Jira Software or Jira Service Desk, and these won’t be updated. But I didn't find any mentions of group names in such tables.
 10. This script won’t update the group names in apps. The apps tables might contain mentions of group names. So you should probably check the tables manually. For example, pg_dump the tables and then use `grep` throw them with group names.
 11. If you find any group names in 8 and 9, just extend the script by adding update statements for these particular tables.