(newDoc, oldDoc, userCtx, secObj) ->
  v = require 'node_modules/validator'

  if newDoc.where == 'here'
    # outsiders posting here
    if oldDoc
      throw forbidden: 'Can\'t change scraps already posted.'

    for key, val of newDoc
      switch key
        when '_id' then throw forbidden: '_id is too small.' if val.length < 20
        when 'content' then throw forbidden: 'content is not a string.' if v.isNull val
        when 'src' then throw forbidden: 'src is not a URL.' unless v.isURL val
        when 'from' then throw forbidden: 'from is not a URL.' unless v.isURL val
        when 'verified' then throw forbidden: 'verified is not boolean.' unless typeof val is 'boolean'
        when 'timestamp' then throw forbidden: 'timestamp is not a number.' unless typeof val is 'number'
        when 'email' then throw forbidden: 'email is not a real email.' unless v.isEmail val
        when 'name' then throw forbidden: 'name is not a string.' if name and typeof name is 'object'
        when 'where' then null
        else
          if key[0] isnt '_'
            throw forbidden: "#{key} is not an allowed key."

    # checks only made at the original database, not replication
    if secObj and secObj.admins and 'original' in secObj.admins.roles

      now = (new Date).getTime()
      if newDoc.timestamp > now + 60000 or newDoc.timestamp < now - 60000
        throw forbidden: 'timestamp is not now.'

      if newDoc.verified is not false
        throw forbidden: 'verified is not false.'

  else if newDoc.where == 'elsewhere'
    # myself posting elsewhere
    
    ## normalize cloudant secObj
    if secObj.cloudant
      if '_writer' in secObj.cloudant.nobody
        return

      names = []
      for name, roles in secObj.cloudant
        names.push name if '_writer' in roles

      roles = []
    
    else
      if not secObj.members and not secObj.admins
        return

      admins = secObj.admins or {}
      members = secObj.members or {}
      names = (admins.names or []).concat(members.names or [])
      roles = (admins.roles or []).concat(members.roles or [])
    ## now we have a standard "names" and a standard "roles"

    if userCtx.name in names
      return

    for role in userCtx.roles
      if role in roles
        return

    throw unauthorized: 'you are not an authorized user.'

  else
    throw forbidden: 'where is invalid.'
