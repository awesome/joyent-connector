=begin #(fold)
++
Copyright 2004-2007 Joyent Inc.

Redistribution and/or modification of this code is 
governed by the GPLv2.

Report issues and contribute at http://dev.joyent.com/

$Id$
--
=end #(end)

require 'ldap' unless Object.const_defined? "LDAP"

class ProductionLdapSystem
  
  attr_accessor :hostname, :admin_dn, :admin_password, :root_dn
  
  def initialize(hostname, admin_dn, admin_password, root_dn)
    @hostname = hostname
    @admin_dn = admin_dn
    @admin_password = admin_password
    @root_dn = root_dn
  end
  
  def ldap_execute
    unless @ldap.nil?
      begin
        # bogus query...but does it work?
        @ldap.search2(@admin_dn, LDAP::LDAP_SCOPE_ONELEVEL, "(&(objectclass=joyentUser))")
      rescue
        @ldap.unbind rescue nil
        @ldap = nil
      end
    end
      
    if @ldap.nil?
      @ldap = LDAP::Conn.new(@hostname)
      @ldap.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, LDAP::LDAP_VERSION3)
      @ldap.bind(@admin_dn, @admin_password)
    end
    yield(@ldap)
  end
  
  def write_person(p)
    return unless exportable_person?(p)
    
    ldap_execute do |ldap|
      ldap.delete(base_dn_for_person(p)) if person_in_ldap?(p)
      ldap.add(base_dn_for_person(p), person_to_ldap(p))
    end
  end
  
  def update_person(p)
    return unless exportable_person?(p)
    
    if person_in_ldap?(p)
      ldap_execute do |ldap|
        ldap.modify(base_dn_for_person(p), person_to_ldap(p))
      end    
    end
  end  
  
  def remove_person(p)
    return unless exportable_person?(p)
    
    ldap_execute do |ldap|
      ldap.delete(base_dn_for_person(p))  if person_in_ldap?(p)
    end
  end
  
  def write_user(u)
    return unless exportable_user?(u)
    
    ldap_execute do |ldap|
      ldap.delete(base_dn_for_user(u)) if user_in_ldap?(u)
      ldap.add(base_dn_for_user(u), user_to_ldap(u))
    end
  end
  
  def update_user(u)
    return unless exportable_user?(u)
    
    if user_in_ldap?(u)
      ldap_execute do |ldap|
        ldap.modify(base_dn_for_user(u), user_to_ldap(u))
      end    
    end
  end
  
  def remove_user(u)
    return unless exportable_user?(u)
    
    ldap_execute do |ldap|
      ldap.delete(base_dn_for_user(u)) if user_in_ldap?(u)
    end
  end
  
  def write_alias(a)
    return unless exportable_alias?(a)
    # Exception handling to prevent "LDAP::ResultError: No such object"
    # Error when trying to add aliases to existing organizations where
    # we still need to add the alias_dn
    begin
      ldap_execute do |ldap|
        ldap.add(base_dn_for_alias(a), alias_to_ldap(a))
      end
    rescue LDAP::ResultError => e
      if @ldap.err == 32
        ldap_execute do |ldap|
          ldap.add(alias_dn(a.organization), aliases_hash(a.organization))
          ldap.add(base_dn_for_alias(a), alias_to_ldap(a))
        end
      end
    end
  end
  # Note we mostly use this method instead of create because when
  # we add new aliases is after adding mail_alias_memberships
  def update_alias(a)
    # If we're updating an alias where we've removed all the mail_alias_memberships what we must do is to delete it.
    # (Note that an alias without mail_alias_memberships will not be exportable so, we cannot use remove_alias)
    unless exportable_alias?(a)              
      ldap_execute { |ldap| ldap.delete(base_dn_for_alias(a)) if alias_in_ldap?(a) }
    end
    
    if alias_in_ldap?(a)
      ldap_execute do |ldap|
        ldap.modify(base_dn_for_alias(a), alias_to_ldap(a))
      end
    else
      write_alias(a)
    end
  end
  
  def remove_alias(a)
    return unless exportable_alias?(a)
    
    ldap_execute do |ldap|
      ldap.delete(base_dn_for_alias(a)) if alias_in_ldap?(a)
    end
  end
  
  # TODO: we need to update existing organizations with mail aliases
  def write_organization(o)
    return unless exportable_organization?(o)
    
    ldap_execute do |ldap|
      ldap.add(base_dn(o),    base_hash(o))
      ldap.add(user_dn(o),    users_hash(o))
      ldap.add(contact_dn(o), contacts_hash(o))
      ldap.add(alias_dn(o),   aliases_hash(o))
    end
    
    save_organization_group(o)
  end
  
  def update_organization(o)
    return unless exportable_organization?(o)
    
    begin    
      ldap_execute do |ldap|
        ldap.modify(base_dn(o), base_hash(o))
      end                                    
    rescue LDAP::Error
      write_organization(o)
    end
    
    save_organization_group(o)
  end
  
  def remove_organization(o)
    return unless exportable_organization?(o)
    
    begin    
      ldap_execute do |ldap|
        ldap.delete(user_dn(o))
        ldap.delete(contact_dn(o))
        ldap.delete(alias_dn(o))
        ldap.delete(base_dn(o))
      end
    rescue LDAP::Error
      # May not exist
    end
    
    remove_organization_group(o)
  end
  
  def save_organization_group(o)
    return unless exportable_organization?(o)
    
    begin    
      ldap_execute do |ldap|
        ldap.modify(group_base_dn(o), group_base_hash(o))
      end                                    
    rescue LDAP::Error
      ldap_execute do |ldap|
        ldap.add(group_base_dn(o), group_base_hash(o))
      end
    end
  end
  
  def remove_organization_group(o)
    return unless exportable_organization?(o)
    
    begin    
      ldap_execute do |ldap|
        ldap.delete(group_base_dn(o))
      end
    rescue LDAP::Error
      # May not exist
    end
  end
    
  def person_to_ldap(p)
    hash = Hash.new {|h,k| h[k] = []}
    
    hash['objectclass'] << 'joyentContact'
    hash['objectclass'] << 'person'
    hash['objectclass'] << 'organizationalPerson'
    hash['objectclass'] << 'inetOrgPerson'
    hash['dbid']        << p.id.to_s
    hash['domain']      << p.organization.system_domain.email_domain
    hash['namePrefix']  << p.name_prefix
    hash['cn']          << p.first_name   # This is required for person LDAP object
    hash['givenName']   << p.first_name
    hash['middleName']  << p.middle_name
    hash['sn']          << p.last_name    # This is required for person LDAP object
    hash['nameSuffix']  << p.name_suffix
    hash['nickname']    << p.nickname
    hash['companyName'] << p.company_name

    a = p.addresses.find(:first)
    if a
      hash['addressType'] << a.address_type
      hash['street']      << a.street
      hash['city']        << a.city
      hash['st']          << a.state
      hash['postalCode']  << a.postal_code
      hash['country']     << a.country_name
    end

    phone_number = p.phone_numbers.find(:first)
    if phone_number
      hash['phoneNumberType'] << phone_number.phone_number_type
      hash['phoneNumber']     << phone_number.phone_number
    end
    
    return hash.reject{|k,v| ( v == [''] || v == [nil] ) && ( k != 'cn' && k != 'sn' )}
  end
  
  # User and Person are different in LDAP.   
  # User does system stuff, contact is for mailbox connections
  # so the merge was wrong.
  def user_to_ldap(u)
    hd = "#{u.organization.system_domain.email_domain}/#{u.username}/"
    hash = {
      'objectclass'           => ['joyentUser', 'posixAccount', 'shadowAccount', 'ldapPublicKey', 'mailRecipient'],
      'uid'                   => [u.system_email],
      'dbid'                  => [u.id.to_s],
      'mail'                  => [u.system_email],
      'cn'                    => [u.full_name],
      'sn'                    => [u.person.last_name],
      'givenName'             => [u.person.first_name],
      'gid'                   => [u.id.to_s],
      'maildir'               => ["#{hd}Maildir/"],
      'homeDirectory'         => [hd],
      'userPassword'          => [u.plaintext_password],
      'unixHomeDir'           => [u.strongspace_root_path],
      'uidNumber'             => [u.uid.to_s],
      'gidNumber'             => [u.organization.gid.to_s],
      'loginShell'            => ['/usr/local/bin/scponly'],
      'sshPublicKey'          => [u.send(:read_authorized_keys).first.to_s],
      'mailAlternateAddress'  => u.mail_alternate_addresses #, 
      # aliases, multiple including primary email
      #'forward'               => [u.forward_address] # forward mail to address
    } 
                     
    if !u.organization.active?
      hash.delete('mail')
    end
    
    hash
  end
  
  # a: MailAlias
  def alias_to_ldap(a)
    hash = {
      'objectclass' => ['joyentMailAlias'],
      'mail'        => [a.system_email_address],
      'maildrop'    => a.users.collect(&:system_email)
    }
  end
  
  def group_base_hash(o)
    hash = { 
      "objectClass"=> ["top", "posixgroup"], 
      "gidnumber"  => [o.gid.to_s],
      "cn"         => [o.gid.to_s],
      "memberUid"  => o.users.collect(&:system_email)
    }
    
    hash.delete("memberUid") if o.users.blank?
    hash
  end
  
  def base_dn_for_person(p)
    "dbid=#{p.id},#{contact_dn(p.organization)}"
  end
  
  def base_dn_for_user(u)
    "uid=#{u.system_email},#{user_dn(u.organization)}"
  end
  
  # a: MailAlias 
  def base_dn_for_alias(a)
    "mail=#{a.system_email_address},#{alias_dn(a.organization)}"
  end

  def user_dn(org)
    "ou=users,#{base_dn(org)}"
  end
  
  def contact_dn(org)
    "ou=contacts,#{base_dn(org)}"
  end
  
  # TODO: Since we're updating existing LDAP directories,
  #       we should include some exception handling for the case
  #       the alias_dn is missing.
  def alias_dn(org)
    "ou=aliases,#{base_dn(org)}"
  end
  
  def base_dn(org)
    "o=#{org.system_domain.email_domain},#{root_dn}"
  end
    
  def group_base_dn(org)
    "gidnumber=#{org.gid},ou=group,#{root_dn}"
  end
  
  def user_in_ldap?(u)
    find_in_ldap(user_dn(u.organization), 'joyentUser', u.id)
  end
  
  def person_in_ldap?(p)
    find_in_ldap(contact_dn(p.organization), 'joyentContact', p.id)
  end
  
  # a: MailAlias
  def alias_in_ldap?(a)
    # We're not using dbid for aliases now so, searches need to be sightly different:
    ldap_execute do |l|
      !l.search2(alias_dn(a.organization), LDAP::LDAP_SCOPE_ONELEVEL, "(&(objectclass=joyentMailAlias)(mail=#{a.system_email_address}))").empty?
    end
  rescue
    false
  end
  
  def find_in_ldap(dn, oc, id)
    ldap_execute do |l|
      !l.search2(dn, LDAP::LDAP_SCOPE_ONELEVEL, "(&(objectclass=#{oc})(dbid=#{id}))").empty?
    end
  rescue
    false
  end
  
  def base_hash(o)
    d = o.system_domain.email_domain
    { 
      "objectClass"=>["top", "dcObject", "organization", "joyentOrganization"], 
      "o"=>[d], 
      "description"=>["Root for #{o.name}"], 
      "aliasDomain"=> o.domains.collect(&:email_domain),
      "dc"=>[d.split('.')[1]]
    }
  end
  
  def users_hash(o)
    {"description"=>["Users for #{o.name}"], "ou"=>["users"], "objectClass"=>["top", "organizationalUnit"]}
  end
  
  def contacts_hash(o)
    {"description"=>["Contacts for #{o.name}"], "ou"=>["contacts"], "objectClass"=>["top", "organizationalUnit"]}
  end
  
  def aliases_hash(o)
    {"description" => ["Mail aliases for #{o.name}"], "ou" => ["aliases"], "objectClass" => ["top", "organizationalUnit"]}
  end
  
  def exportable_person?(person)
    person && person.organization && person.organization.system_domain && person.organization.system_domain.email_domain
  end
  
  def exportable_user?(user)
    exportable_person?(user) && !user.guest?  
  end                     
  
  def exportable_organization?(organization)
    organization && organization.system_domain && organization.system_domain.email_domain
  end
  
  # a: MailAlias
  def exportable_alias?(a)
    a && a.name && a.organization && a.organization.system_domain && (a.mail_alias_memberships.size > 0) && a.organization.system_domain.email_domain
  end
end
