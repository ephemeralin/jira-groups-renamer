-- 1. FIND FILTERS THAT CONTAIN GROUP NAMES
select
    filtername, reqcontent
from
    searchrequest
where
    reqcontent = any(array['OLD-NAME-ONE-users','OLD-NAME-TWO-users']);

-- 2. FIND WORKFLOWS THAT CONTAIN GROUP NAMES
select
    workflowname
from
    jiraworkflows
where
    descriptor = any(array['OLD-NAME-ONE-users','OLD-NAME-TWO-users']);