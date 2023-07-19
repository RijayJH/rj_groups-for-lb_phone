#Server Side

```

exports['qb-phone']:NotifyGroup(group, msg, type)

exports['qb-phone']:pNotifyGroup(group, header, msg, icon, colour, length)

exports['qb-phone']:CreateBlipForGroup(groupID, name, data)

exports['qb-phone']:RemoveBlipForGroup(groupID, name)

exports['qb-phone']:GetGroupByMembers(src)

exports['qb-phone']:getGroupMembers(groupID)

exports['qb-phone']:getGroupSize(groupID)

exports['qb-phone']:GetGroupLeader(groupID)

exports['qb-phone']:DestroyGroup(groupID)

exports['qb-phone']:isGroupLeader(src, groupID)

--------------------------------------------------

exports['qb-phone']:setJobStatus(groupID, status, stages)

exports['qb-phone']:getJobStatus(groupID)

exports['qb-phone']:resetJobStatus(groupID)

--------------------------------------------------

exports['qb-phone']:isGroupTemp(groupID)

exports['qb-phone']:CreateGroup(src, name, password)

```