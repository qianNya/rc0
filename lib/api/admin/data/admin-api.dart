// --C:\Users\qianlNya\GolandProjects\rc0-go\service\admin\api\admin--

class CreateMenuReq {
  final num parentId;

  final String name;

  final String path;

  final String component;

  final String perms;

  final String menuType;

  final String icon;

  final num sort;

  final num visible;

  final num status;
  CreateMenuReq({
    required this.parentId,
    required this.name,
    required this.path,
    required this.component,
    required this.perms,
    required this.menuType,
    required this.icon,
    required this.sort,
    required this.visible,
    required this.status,
  });
  factory CreateMenuReq.fromJson(Map<String, dynamic> m) {
    return CreateMenuReq(
      parentId: m['parent_id'] ?? 0,
      name: m['name'] ?? "",
      path: m['path'] ?? "",
      component: m['component'] ?? "",
      perms: m['perms'] ?? "",
      menuType: m['menu_type'] ?? "",
      icon: m['icon'] ?? "",
      sort: m['sort'] ?? 0,
      visible: m['visible'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'parent_id': parentId,
      'name': name,
      'path': path,
      'component': component,
      'perms': perms,
      'menu_type': menuType,
      'icon': icon,
      'sort': sort,
      'visible': visible,
      'status': status,
    };
  }
}

class CreateOauthClientDetailsReq {
  final String clientId;

  final String clientSecret;

  final String clientName;

  final String resourceIds;

  final String scope;

  final String authorizedGrantTypes;

  final String webServerRedirectUri;

  final String authorities;

  final num accessTokenValidity;

  final num refreshTokenValidity;

  final String additionalInformation;

  final String autoapprove;

  final num status;
  CreateOauthClientDetailsReq({
    required this.clientId,
    required this.clientSecret,
    required this.clientName,
    required this.resourceIds,
    required this.scope,
    required this.authorizedGrantTypes,
    required this.webServerRedirectUri,
    required this.authorities,
    required this.accessTokenValidity,
    required this.refreshTokenValidity,
    required this.additionalInformation,
    required this.autoapprove,
    required this.status,
  });
  factory CreateOauthClientDetailsReq.fromJson(Map<String, dynamic> m) {
    return CreateOauthClientDetailsReq(
      clientId: m['client_id'] ?? "",
      clientSecret: m['client_secret'] ?? "",
      clientName: m['client_name'] ?? "",
      resourceIds: m['resource_ids'] ?? "",
      scope: m['scope'] ?? "",
      authorizedGrantTypes: m['authorized_grant_types'] ?? "",
      webServerRedirectUri: m['web_server_redirect_uri'] ?? "",
      authorities: m['authorities'] ?? "",
      accessTokenValidity: m['access_token_validity'] ?? 0,
      refreshTokenValidity: m['refresh_token_validity'] ?? 0,
      additionalInformation: m['additional_information'] ?? "",
      autoapprove: m['autoapprove'] ?? "",
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'client_secret': clientSecret,
      'client_name': clientName,
      'resource_ids': resourceIds,
      'scope': scope,
      'authorized_grant_types': authorizedGrantTypes,
      'web_server_redirect_uri': webServerRedirectUri,
      'authorities': authorities,
      'access_token_validity': accessTokenValidity,
      'refresh_token_validity': refreshTokenValidity,
      'additional_information': additionalInformation,
      'autoapprove': autoapprove,
      'status': status,
    };
  }
}

class CreateRoleMenuReq {
  final num roleId;

  final num menuId;

  final num status;
  CreateRoleMenuReq({
    required this.roleId,
    required this.menuId,
    required this.status,
  });
  factory CreateRoleMenuReq.fromJson(Map<String, dynamic> m) {
    return CreateRoleMenuReq(
      roleId: m['role_id'] ?? 0,
      menuId: m['menu_id'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'role_id': roleId, 'menu_id': menuId, 'status': status};
  }
}

class CreateRoleReq {
  final String name;

  final String code;

  final num sort;

  final String remark;

  final num status;
  CreateRoleReq({
    required this.name,
    required this.code,
    required this.sort,
    required this.remark,
    required this.status,
  });
  factory CreateRoleReq.fromJson(Map<String, dynamic> m) {
    return CreateRoleReq(
      name: m['name'] ?? "",
      code: m['code'] ?? "",
      sort: m['sort'] ?? 0,
      remark: m['remark'] ?? "",
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'sort': sort,
      'remark': remark,
      'status': status,
    };
  }
}

class CreateUmsUserReq {
  final String username;

  final String password;

  final String nickname;

  final String email;

  final String phone;

  final String avatar;

  final num status;
  CreateUmsUserReq({
    required this.username,
    required this.password,
    required this.nickname,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.status,
  });
  factory CreateUmsUserReq.fromJson(Map<String, dynamic> m) {
    return CreateUmsUserReq(
      username: m['username'] ?? "",
      password: m['password'] ?? "",
      nickname: m['nickname'] ?? "",
      email: m['email'] ?? "",
      phone: m['phone'] ?? "",
      avatar: m['avatar'] ?? "",
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'status': status,
    };
  }
}

class CreateUserRoleReq {
  final num userId;

  final num roleId;

  final num status;
  CreateUserRoleReq({
    required this.userId,
    required this.roleId,
    required this.status,
  });
  factory CreateUserRoleReq.fromJson(Map<String, dynamic> m) {
    return CreateUserRoleReq(
      userId: m['user_id'] ?? 0,
      roleId: m['role_id'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'role_id': roleId, 'status': status};
  }
}

class DeleteMenuReq {
  final num id;
  DeleteMenuReq({required this.id});
  factory DeleteMenuReq.fromJson(Map<String, dynamic> m) {
    return DeleteMenuReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class DeleteOauthClientDetailsReq {
  final num id;
  DeleteOauthClientDetailsReq({required this.id});
  factory DeleteOauthClientDetailsReq.fromJson(Map<String, dynamic> m) {
    return DeleteOauthClientDetailsReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class DeleteRoleMenuReq {
  final num id;
  DeleteRoleMenuReq({required this.id});
  factory DeleteRoleMenuReq.fromJson(Map<String, dynamic> m) {
    return DeleteRoleMenuReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class DeleteRoleReq {
  final num id;
  DeleteRoleReq({required this.id});
  factory DeleteRoleReq.fromJson(Map<String, dynamic> m) {
    return DeleteRoleReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class DeleteUmsUserReq {
  final num id;
  DeleteUmsUserReq({required this.id});
  factory DeleteUmsUserReq.fromJson(Map<String, dynamic> m) {
    return DeleteUmsUserReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class DeleteUserRoleReq {
  final num id;
  DeleteUserRoleReq({required this.id});
  factory DeleteUserRoleReq.fromJson(Map<String, dynamic> m) {
    return DeleteUserRoleReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetMenuReq {
  final num id;
  GetMenuReq({required this.id});
  factory GetMenuReq.fromJson(Map<String, dynamic> m) {
    return GetMenuReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetOauthClientDetailsReq {
  final num id;
  GetOauthClientDetailsReq({required this.id});
  factory GetOauthClientDetailsReq.fromJson(Map<String, dynamic> m) {
    return GetOauthClientDetailsReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetRoleMenuReq {
  final num id;
  GetRoleMenuReq({required this.id});
  factory GetRoleMenuReq.fromJson(Map<String, dynamic> m) {
    return GetRoleMenuReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetRoleReq {
  final num id;
  GetRoleReq({required this.id});
  factory GetRoleReq.fromJson(Map<String, dynamic> m) {
    return GetRoleReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetSysLogReq {
  final num id;
  GetSysLogReq({required this.id});
  factory GetSysLogReq.fromJson(Map<String, dynamic> m) {
    return GetSysLogReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetUmsUserReq {
  final num id;
  GetUmsUserReq({required this.id});
  factory GetUmsUserReq.fromJson(Map<String, dynamic> m) {
    return GetUmsUserReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetUserRoleReq {
  final num id;
  GetUserRoleReq({required this.id});
  factory GetUserRoleReq.fromJson(Map<String, dynamic> m) {
    return GetUserRoleReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class ListMenusReq {
  final num page;

  final num pageSize;

  final num parentId;

  final String name;

  final String perms;

  final num status;

  final num deleted;
  ListMenusReq({
    required this.page,
    required this.pageSize,
    required this.parentId,
    required this.name,
    required this.perms,
    required this.status,
    required this.deleted,
  });
  factory ListMenusReq.fromJson(Map<String, dynamic> m) {
    return ListMenusReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      parentId: m['parent_id'] ?? 0,
      name: m['name'] ?? "",
      perms: m['perms'] ?? "",
      status: m['status'] ?? 0,
      deleted: m['deleted'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'parent_id': parentId,
      'name': name,
      'perms': perms,
      'status': status,
      'deleted': deleted,
    };
  }
}

class ListMenusResp {
  final List<Menu> list;

  final num total;
  ListMenusResp({required this.list, required this.total});
  factory ListMenusResp.fromJson(Map<String, dynamic> m) {
    return ListMenusResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => Menu.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListOauthClientDetailsReq {
  final num page;

  final num pageSize;

  final String clientId;

  final String clientName;

  final num status;

  final num deleted;
  ListOauthClientDetailsReq({
    required this.page,
    required this.pageSize,
    required this.clientId,
    required this.clientName,
    required this.status,
    required this.deleted,
  });
  factory ListOauthClientDetailsReq.fromJson(Map<String, dynamic> m) {
    return ListOauthClientDetailsReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      clientId: m['client_id'] ?? "",
      clientName: m['client_name'] ?? "",
      status: m['status'] ?? 0,
      deleted: m['deleted'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'client_id': clientId,
      'client_name': clientName,
      'status': status,
      'deleted': deleted,
    };
  }
}

class ListOauthClientDetailsResp {
  final List<OauthClientDetails> list;

  final num total;
  ListOauthClientDetailsResp({required this.list, required this.total});
  factory ListOauthClientDetailsResp.fromJson(Map<String, dynamic> m) {
    return ListOauthClientDetailsResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => OauthClientDetails.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListRoleMenusReq {
  final num page;

  final num pageSize;

  final num roleId;

  final num menuId;

  final num status;

  final num deleted;
  ListRoleMenusReq({
    required this.page,
    required this.pageSize,
    required this.roleId,
    required this.menuId,
    required this.status,
    required this.deleted,
  });
  factory ListRoleMenusReq.fromJson(Map<String, dynamic> m) {
    return ListRoleMenusReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      roleId: m['role_id'] ?? 0,
      menuId: m['menu_id'] ?? 0,
      status: m['status'] ?? 0,
      deleted: m['deleted'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'role_id': roleId,
      'menu_id': menuId,
      'status': status,
      'deleted': deleted,
    };
  }
}

class ListRoleMenusResp {
  final List<RoleMenu> list;

  final num total;
  ListRoleMenusResp({required this.list, required this.total});
  factory ListRoleMenusResp.fromJson(Map<String, dynamic> m) {
    return ListRoleMenusResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => RoleMenu.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListRolesReq {
  final num page;

  final num pageSize;

  final String code;

  final String name;

  final num status;

  final num deleted;
  ListRolesReq({
    required this.page,
    required this.pageSize,
    required this.code,
    required this.name,
    required this.status,
    required this.deleted,
  });
  factory ListRolesReq.fromJson(Map<String, dynamic> m) {
    return ListRolesReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      code: m['code'] ?? "",
      name: m['name'] ?? "",
      status: m['status'] ?? 0,
      deleted: m['deleted'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'code': code,
      'name': name,
      'status': status,
      'deleted': deleted,
    };
  }
}

class ListRolesResp {
  final List<Role> list;

  final num total;
  ListRolesResp({required this.list, required this.total});
  factory ListRolesResp.fromJson(Map<String, dynamic> m) {
    return ListRolesResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => Role.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListSysLogsReq {
  final num page;

  final num pageSize;

  final num userId;

  final String username;

  final String module;

  final String operation;

  final num deleted;
  ListSysLogsReq({
    required this.page,
    required this.pageSize,
    required this.userId,
    required this.username,
    required this.module,
    required this.operation,
    required this.deleted,
  });
  factory ListSysLogsReq.fromJson(Map<String, dynamic> m) {
    return ListSysLogsReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      userId: m['user_id'] ?? 0,
      username: m['username'] ?? "",
      module: m['module'] ?? "",
      operation: m['operation'] ?? "",
      deleted: m['deleted'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'user_id': userId,
      'username': username,
      'module': module,
      'operation': operation,
      'deleted': deleted,
    };
  }
}

class ListSysLogsResp {
  final List<SysLog> list;

  final num total;
  ListSysLogsResp({required this.list, required this.total});
  factory ListSysLogsResp.fromJson(Map<String, dynamic> m) {
    return ListSysLogsResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => SysLog.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListUmsUsersReq {
  final num page;

  final num pageSize;

  final String username;

  final String nickname;

  final String email;

  final String phone;

  final num status;

  final num deleted;
  ListUmsUsersReq({
    required this.page,
    required this.pageSize,
    required this.username,
    required this.nickname,
    required this.email,
    required this.phone,
    required this.status,
    required this.deleted,
  });
  factory ListUmsUsersReq.fromJson(Map<String, dynamic> m) {
    return ListUmsUsersReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      username: m['username'] ?? "",
      nickname: m['nickname'] ?? "",
      email: m['email'] ?? "",
      phone: m['phone'] ?? "",
      status: m['status'] ?? 0,
      deleted: m['deleted'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'username': username,
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'status': status,
      'deleted': deleted,
    };
  }
}

class ListUmsUsersResp {
  final List<UmsUser> list;

  final num total;
  ListUmsUsersResp({required this.list, required this.total});
  factory ListUmsUsersResp.fromJson(Map<String, dynamic> m) {
    return ListUmsUsersResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => UmsUser.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListUserRolesReq {
  final num page;

  final num pageSize;

  final num userId;

  final num roleId;

  final num status;

  final num deleted;
  ListUserRolesReq({
    required this.page,
    required this.pageSize,
    required this.userId,
    required this.roleId,
    required this.status,
    required this.deleted,
  });
  factory ListUserRolesReq.fromJson(Map<String, dynamic> m) {
    return ListUserRolesReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      userId: m['user_id'] ?? 0,
      roleId: m['role_id'] ?? 0,
      status: m['status'] ?? 0,
      deleted: m['deleted'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'user_id': userId,
      'role_id': roleId,
      'status': status,
      'deleted': deleted,
    };
  }
}

class ListUserRolesResp {
  final List<UserRole> list;

  final num total;
  ListUserRolesResp({required this.list, required this.total});
  factory ListUserRolesResp.fromJson(Map<String, dynamic> m) {
    return ListUserRolesResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => UserRole.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListUserScreenplaysReq {
  final num id;

  final num page;

  final num pageSize;
  ListUserScreenplaysReq({
    required this.id,
    required this.page,
    required this.pageSize,
  });
  factory ListUserScreenplaysReq.fromJson(Map<String, dynamic> m) {
    return ListUserScreenplaysReq(
      id: m['id'] ?? 0,
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'page': page, 'page_size': pageSize};
  }
}

class ListUserScreenplaysResp {
  final List<ScreenplayBrief> list;

  final num total;
  ListUserScreenplaysResp({required this.list, required this.total});
  factory ListUserScreenplaysResp.fromJson(Map<String, dynamic> m) {
    return ListUserScreenplaysResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => ScreenplayBrief.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class Menu {
  final num id;

  final num parentId;

  final String name;

  final String path;

  final String component;

  final String perms;

  final String menuType;

  final String icon;

  final num sort;

  final num visible;

  final num status;

  final String createAt;

  final String updateAt;
  Menu({
    required this.id,
    required this.parentId,
    required this.name,
    required this.path,
    required this.component,
    required this.perms,
    required this.menuType,
    required this.icon,
    required this.sort,
    required this.visible,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });
  factory Menu.fromJson(Map<String, dynamic> m) {
    return Menu(
      id: m['id'] ?? 0,
      parentId: m['parent_id'] ?? 0,
      name: m['name'] ?? "",
      path: m['path'] ?? "",
      component: m['component'] ?? "",
      perms: m['perms'] ?? "",
      menuType: m['menu_type'] ?? "",
      icon: m['icon'] ?? "",
      sort: m['sort'] ?? 0,
      visible: m['visible'] ?? 0,
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'name': name,
      'path': path,
      'component': component,
      'perms': perms,
      'menu_type': menuType,
      'icon': icon,
      'sort': sort,
      'visible': visible,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class OauthClientDetails {
  final num id;

  final String clientId;

  final bool hasClientSecret;

  final String clientName;

  final String resourceIds;

  final String scope;

  final String authorizedGrantTypes;

  final String webServerRedirectUri;

  final String authorities;

  final num accessTokenValidity;

  final num refreshTokenValidity;

  final String additionalInformation;

  final String autoapprove;

  final num status;

  final String createAt;

  final String updateAt;
  OauthClientDetails({
    required this.id,
    required this.clientId,
    required this.hasClientSecret,
    required this.clientName,
    required this.resourceIds,
    required this.scope,
    required this.authorizedGrantTypes,
    required this.webServerRedirectUri,
    required this.authorities,
    required this.accessTokenValidity,
    required this.refreshTokenValidity,
    required this.additionalInformation,
    required this.autoapprove,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });
  factory OauthClientDetails.fromJson(Map<String, dynamic> m) {
    return OauthClientDetails(
      id: m['id'] ?? 0,
      clientId: m['client_id'] ?? "",
      hasClientSecret: m['has_client_secret'] ?? false,
      clientName: m['client_name'] ?? "",
      resourceIds: m['resource_ids'] ?? "",
      scope: m['scope'] ?? "",
      authorizedGrantTypes: m['authorized_grant_types'] ?? "",
      webServerRedirectUri: m['web_server_redirect_uri'] ?? "",
      authorities: m['authorities'] ?? "",
      accessTokenValidity: m['access_token_validity'] ?? 0,
      refreshTokenValidity: m['refresh_token_validity'] ?? 0,
      additionalInformation: m['additional_information'] ?? "",
      autoapprove: m['autoapprove'] ?? "",
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'has_client_secret': hasClientSecret,
      'client_name': clientName,
      'resource_ids': resourceIds,
      'scope': scope,
      'authorized_grant_types': authorizedGrantTypes,
      'web_server_redirect_uri': webServerRedirectUri,
      'authorities': authorities,
      'access_token_validity': accessTokenValidity,
      'refresh_token_validity': refreshTokenValidity,
      'additional_information': additionalInformation,
      'autoapprove': autoapprove,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class PingResp {
  final String pong;
  PingResp({required this.pong});
  factory PingResp.fromJson(Map<String, dynamic> m) {
    return PingResp(pong: m['pong'] ?? "");
  }
  Map<String, dynamic> toJson() {
    return {'pong': pong};
  }
}

class Profile {
  final num id;

  final String username;

  final String nickname;

  final String email;

  final String phone;

  final String avatar;

  final String bio;

  final num level;

  final num followerCount;

  final num followingCount;

  final num totalLikes;

  final num screenplayCount;
  Profile({
    required this.id,
    required this.username,
    required this.nickname,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.bio,
    required this.level,
    required this.followerCount,
    required this.followingCount,
    required this.totalLikes,
    required this.screenplayCount,
  });
  factory Profile.fromJson(Map<String, dynamic> m) {
    return Profile(
      id: m['id'] ?? 0,
      username: m['username'] ?? "",
      nickname: m['nickname'] ?? "",
      email: m['email'] ?? "",
      phone: m['phone'] ?? "",
      avatar: m['avatar'] ?? "",
      bio: m['bio'] ?? "",
      level: m['level'] ?? 0,
      followerCount: m['follower_count'] ?? 0,
      followingCount: m['following_count'] ?? 0,
      totalLikes: m['total_likes'] ?? 0,
      screenplayCount: m['screenplay_count'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'level': level,
      'follower_count': followerCount,
      'following_count': followingCount,
      'total_likes': totalLikes,
      'screenplay_count': screenplayCount,
    };
  }
}

class PublicUserProfile {
  final num id;

  final String username;

  final String nickname;

  final String avatar;

  final String bio;

  final num level;

  final num followerCount;

  final num followingCount;

  final num totalLikes;

  final num screenplayCount;

  final bool isFollowing;
  PublicUserProfile({
    required this.id,
    required this.username,
    required this.nickname,
    required this.avatar,
    required this.bio,
    required this.level,
    required this.followerCount,
    required this.followingCount,
    required this.totalLikes,
    required this.screenplayCount,
    required this.isFollowing,
  });
  factory PublicUserProfile.fromJson(Map<String, dynamic> m) {
    return PublicUserProfile(
      id: m['id'] ?? 0,
      username: m['username'] ?? "",
      nickname: m['nickname'] ?? "",
      avatar: m['avatar'] ?? "",
      bio: m['bio'] ?? "",
      level: m['level'] ?? 0,
      followerCount: m['follower_count'] ?? 0,
      followingCount: m['following_count'] ?? 0,
      totalLikes: m['total_likes'] ?? 0,
      screenplayCount: m['screenplay_count'] ?? 0,
      isFollowing: m['is_following'] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatar': avatar,
      'bio': bio,
      'level': level,
      'follower_count': followerCount,
      'following_count': followingCount,
      'total_likes': totalLikes,
      'screenplay_count': screenplayCount,
      'is_following': isFollowing,
    };
  }
}

class Role {
  final num id;

  final String name;

  final String code;

  final num sort;

  final String remark;

  final num status;

  final String createAt;

  final String updateAt;
  Role({
    required this.id,
    required this.name,
    required this.code,
    required this.sort,
    required this.remark,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });
  factory Role.fromJson(Map<String, dynamic> m) {
    return Role(
      id: m['id'] ?? 0,
      name: m['name'] ?? "",
      code: m['code'] ?? "",
      sort: m['sort'] ?? 0,
      remark: m['remark'] ?? "",
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'sort': sort,
      'remark': remark,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class RoleMenu {
  final num id;

  final num roleId;

  final num menuId;

  final num status;

  final String createAt;

  final String updateAt;
  RoleMenu({
    required this.id,
    required this.roleId,
    required this.menuId,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });
  factory RoleMenu.fromJson(Map<String, dynamic> m) {
    return RoleMenu(
      id: m['id'] ?? 0,
      roleId: m['role_id'] ?? 0,
      menuId: m['menu_id'] ?? 0,
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_id': roleId,
      'menu_id': menuId,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class ScreenplayBrief {
  final num id;

  final String title;

  final String coverUrl;

  final num likeCount;

  final num viewCount;

  final num creatorId;

  final String creatorNickname;
  ScreenplayBrief({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.likeCount,
    required this.viewCount,
    required this.creatorId,
    required this.creatorNickname,
  });
  factory ScreenplayBrief.fromJson(Map<String, dynamic> m) {
    return ScreenplayBrief(
      id: m['id'] ?? 0,
      title: m['title'] ?? "",
      coverUrl: m['cover_url'] ?? "",
      likeCount: m['like_count'] ?? 0,
      viewCount: m['view_count'] ?? 0,
      creatorId: m['creator_id'] ?? 0,
      creatorNickname: m['creator_nickname'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cover_url': coverUrl,
      'like_count': likeCount,
      'view_count': viewCount,
      'creator_id': creatorId,
      'creator_nickname': creatorNickname,
    };
  }
}

class SocialUserIdReq {
  final num id;
  SocialUserIdReq({required this.id});
  factory SocialUserIdReq.fromJson(Map<String, dynamic> m) {
    return SocialUserIdReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class SysLog {
  final num id;

  final num userId;

  final String username;

  final String module;

  final String operation;

  final String method;

  final String path;

  final String ip;

  final String userAgent;

  final String reqBody;

  final num respCode;

  final String respMsg;

  final String respBody;

  final String traceId;

  final String spanId;

  final String serviceName;

  final String env;

  final num httpStatus;

  final num durationMs;

  final String createAt;

  final String updateAt;
  SysLog({
    required this.id,
    required this.userId,
    required this.username,
    required this.module,
    required this.operation,
    required this.method,
    required this.path,
    required this.ip,
    required this.userAgent,
    required this.reqBody,
    required this.respCode,
    required this.respMsg,
    required this.respBody,
    required this.traceId,
    required this.spanId,
    required this.serviceName,
    required this.env,
    required this.httpStatus,
    required this.durationMs,
    required this.createAt,
    required this.updateAt,
  });
  factory SysLog.fromJson(Map<String, dynamic> m) {
    return SysLog(
      id: m['id'] ?? 0,
      userId: m['user_id'] ?? 0,
      username: m['username'] ?? "",
      module: m['module'] ?? "",
      operation: m['operation'] ?? "",
      method: m['method'] ?? "",
      path: m['path'] ?? "",
      ip: m['ip'] ?? "",
      userAgent: m['user_agent'] ?? "",
      reqBody: m['req_body'] ?? "",
      respCode: m['resp_code'] ?? 0,
      respMsg: m['resp_msg'] ?? "",
      respBody: m['resp_body'] ?? "",
      traceId: m['trace_id'] ?? "",
      spanId: m['span_id'] ?? "",
      serviceName: m['service_name'] ?? "",
      env: m['env'] ?? "",
      httpStatus: m['http_status'] ?? 0,
      durationMs: m['duration_ms'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'module': module,
      'operation': operation,
      'method': method,
      'path': path,
      'ip': ip,
      'user_agent': userAgent,
      'req_body': reqBody,
      'resp_code': respCode,
      'resp_msg': respMsg,
      'resp_body': respBody,
      'trace_id': traceId,
      'span_id': spanId,
      'service_name': serviceName,
      'env': env,
      'http_status': httpStatus,
      'duration_ms': durationMs,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class UmsUser {
  final num id;

  final String username;

  final bool hasPassword;

  final String nickname;

  final String email;

  final String phone;

  final String avatar;

  final num status;

  final String createAt;

  final String updateAt;
  UmsUser({
    required this.id,
    required this.username,
    required this.hasPassword,
    required this.nickname,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });
  factory UmsUser.fromJson(Map<String, dynamic> m) {
    return UmsUser(
      id: m['id'] ?? 0,
      username: m['username'] ?? "",
      hasPassword: m['has_password'] ?? false,
      nickname: m['nickname'] ?? "",
      email: m['email'] ?? "",
      phone: m['phone'] ?? "",
      avatar: m['avatar'] ?? "",
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'has_password': hasPassword,
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class UpdateMenuReq {
  final num id;

  final num parentId;

  final String name;

  final String path;

  final String component;

  final String perms;

  final String menuType;

  final String icon;

  final num sort;

  final num visible;

  final num status;
  UpdateMenuReq({
    required this.id,
    required this.parentId,
    required this.name,
    required this.path,
    required this.component,
    required this.perms,
    required this.menuType,
    required this.icon,
    required this.sort,
    required this.visible,
    required this.status,
  });
  factory UpdateMenuReq.fromJson(Map<String, dynamic> m) {
    return UpdateMenuReq(
      id: m['id'] ?? 0,
      parentId: m['parent_id'] ?? 0,
      name: m['name'] ?? "",
      path: m['path'] ?? "",
      component: m['component'] ?? "",
      perms: m['perms'] ?? "",
      menuType: m['menu_type'] ?? "",
      icon: m['icon'] ?? "",
      sort: m['sort'] ?? 0,
      visible: m['visible'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'name': name,
      'path': path,
      'component': component,
      'perms': perms,
      'menu_type': menuType,
      'icon': icon,
      'sort': sort,
      'visible': visible,
      'status': status,
    };
  }
}

class UpdateOauthClientDetailsReq {
  final num id;

  final String clientId;

  final String clientSecret;

  final String clientName;

  final String resourceIds;

  final String scope;

  final String authorizedGrantTypes;

  final String webServerRedirectUri;

  final String authorities;

  final num accessTokenValidity;

  final num refreshTokenValidity;

  final String additionalInformation;

  final String autoapprove;

  final num status;
  UpdateOauthClientDetailsReq({
    required this.id,
    required this.clientId,
    required this.clientSecret,
    required this.clientName,
    required this.resourceIds,
    required this.scope,
    required this.authorizedGrantTypes,
    required this.webServerRedirectUri,
    required this.authorities,
    required this.accessTokenValidity,
    required this.refreshTokenValidity,
    required this.additionalInformation,
    required this.autoapprove,
    required this.status,
  });
  factory UpdateOauthClientDetailsReq.fromJson(Map<String, dynamic> m) {
    return UpdateOauthClientDetailsReq(
      id: m['id'] ?? 0,
      clientId: m['client_id'] ?? "",
      clientSecret: m['client_secret'] ?? "",
      clientName: m['client_name'] ?? "",
      resourceIds: m['resource_ids'] ?? "",
      scope: m['scope'] ?? "",
      authorizedGrantTypes: m['authorized_grant_types'] ?? "",
      webServerRedirectUri: m['web_server_redirect_uri'] ?? "",
      authorities: m['authorities'] ?? "",
      accessTokenValidity: m['access_token_validity'] ?? 0,
      refreshTokenValidity: m['refresh_token_validity'] ?? 0,
      additionalInformation: m['additional_information'] ?? "",
      autoapprove: m['autoapprove'] ?? "",
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'client_secret': clientSecret,
      'client_name': clientName,
      'resource_ids': resourceIds,
      'scope': scope,
      'authorized_grant_types': authorizedGrantTypes,
      'web_server_redirect_uri': webServerRedirectUri,
      'authorities': authorities,
      'access_token_validity': accessTokenValidity,
      'refresh_token_validity': refreshTokenValidity,
      'additional_information': additionalInformation,
      'autoapprove': autoapprove,
      'status': status,
    };
  }
}

class UpdateProfileReq {
  final String nickname;

  final String email;

  final String phone;

  final String avatar;

  final String password;
  UpdateProfileReq({
    required this.nickname,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.password,
  });
  factory UpdateProfileReq.fromJson(Map<String, dynamic> m) {
    return UpdateProfileReq(
      nickname: m['nickname'] ?? "",
      email: m['email'] ?? "",
      phone: m['phone'] ?? "",
      avatar: m['avatar'] ?? "",
      password: m['password'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'password': password,
    };
  }
}

class UpdateRoleMenuReq {
  final num id;

  final num status;
  UpdateRoleMenuReq({required this.id, required this.status});
  factory UpdateRoleMenuReq.fromJson(Map<String, dynamic> m) {
    return UpdateRoleMenuReq(id: m['id'] ?? 0, status: m['status'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'status': status};
  }
}

class UpdateRoleReq {
  final num id;

  final String name;

  final String code;

  final num sort;

  final String remark;

  final num status;
  UpdateRoleReq({
    required this.id,
    required this.name,
    required this.code,
    required this.sort,
    required this.remark,
    required this.status,
  });
  factory UpdateRoleReq.fromJson(Map<String, dynamic> m) {
    return UpdateRoleReq(
      id: m['id'] ?? 0,
      name: m['name'] ?? "",
      code: m['code'] ?? "",
      sort: m['sort'] ?? 0,
      remark: m['remark'] ?? "",
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'sort': sort,
      'remark': remark,
      'status': status,
    };
  }
}

class UpdateUmsUserReq {
  final num id;

  final String username;

  final String password;

  final String nickname;

  final String email;

  final String phone;

  final String avatar;

  final num status;
  UpdateUmsUserReq({
    required this.id,
    required this.username,
    required this.password,
    required this.nickname,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.status,
  });
  factory UpdateUmsUserReq.fromJson(Map<String, dynamic> m) {
    return UpdateUmsUserReq(
      id: m['id'] ?? 0,
      username: m['username'] ?? "",
      password: m['password'] ?? "",
      nickname: m['nickname'] ?? "",
      email: m['email'] ?? "",
      phone: m['phone'] ?? "",
      avatar: m['avatar'] ?? "",
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'status': status,
    };
  }
}

class UpdateUserRoleReq {
  final num id;

  final num status;
  UpdateUserRoleReq({required this.id, required this.status});
  factory UpdateUserRoleReq.fromJson(Map<String, dynamic> m) {
    return UpdateUserRoleReq(id: m['id'] ?? 0, status: m['status'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'status': status};
  }
}

class UserRole {
  final num id;

  final num userId;

  final num roleId;

  final num status;

  final String createAt;

  final String updateAt;
  UserRole({
    required this.id,
    required this.userId,
    required this.roleId,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });
  factory UserRole.fromJson(Map<String, dynamic> m) {
    return UserRole(
      id: m['id'] ?? 0,
      userId: m['user_id'] ?? 0,
      roleId: m['role_id'] ?? 0,
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'role_id': roleId,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}
