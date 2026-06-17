import 'api.dart';
import '../data/admin-api.dart';

/// admin-api

/// --/api/admin/ping--
///
/// request:
/// response: PingResp
Future ping({
  Function(PingResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/ping",
    ok: (data) {
      if (ok != null) ok(PingResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/logs--
///
/// request: ListSysLogsReq
/// response: ListSysLogsResp
Future listSysLogs({
  Function(ListSysLogsResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/logs",
    ok: (data) {
      if (ok != null) ok(ListSysLogsResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/logs/:id--
///
/// request: GetSysLogReq
/// response: SysLog
Future getSysLog(
  int id, {
  Function(SysLog)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/logs/${id}",
    ok: (data) {
      if (ok != null) ok(SysLog.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/oauth/clients--
///
/// request: CreateOauthClientDetailsReq
/// response: OauthClientDetails
Future createOauthClientDetails(
  CreateOauthClientDetailsReq request, {
  Function(OauthClientDetails)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/oauth/clients",
    request,
    ok: (data) {
      if (ok != null) ok(OauthClientDetails.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/oauth/clients--
///
/// request: ListOauthClientDetailsReq
/// response: ListOauthClientDetailsResp
Future listOauthClientDetails({
  Function(ListOauthClientDetailsResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/oauth/clients",
    ok: (data) {
      if (ok != null) ok(ListOauthClientDetailsResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/oauth/clients/:id--
///
/// request: GetOauthClientDetailsReq
/// response: OauthClientDetails
Future getOauthClientDetails(
  int id, {
  Function(OauthClientDetails)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/oauth/clients/${id}",
    ok: (data) {
      if (ok != null) ok(OauthClientDetails.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/oauth/clients/:id--
///
/// request: UpdateOauthClientDetailsReq
/// response: OauthClientDetails
Future updateOauthClientDetails(
  int id,
  UpdateOauthClientDetailsReq request, {
  Function(OauthClientDetails)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/oauth/clients/${id}",
    request,
    ok: (data) {
      if (ok != null) ok(OauthClientDetails.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/oauth/clients/:id--
///
/// request: DeleteOauthClientDetailsReq
/// response:
Future deleteOauthClientDetails(
  int id,
  DeleteOauthClientDetailsReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/oauth/clients/${id}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/profile--
///
/// request:
/// response: Profile
Future getProfile({
  Function(Profile)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/profile",
    ok: (data) {
      if (ok != null) ok(Profile.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/profile--
///
/// request: UpdateProfileReq
/// response: Profile
Future updateProfile(
  UpdateProfileReq request, {
  Function(Profile)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/profile",
    request,
    ok: (data) {
      if (ok != null) ok(Profile.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/menus--
///
/// request: CreateMenuReq
/// response: Menu
Future createMenu(
  CreateMenuReq request, {
  Function(Menu)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/menus",
    request,
    ok: (data) {
      if (ok != null) ok(Menu.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/menus--
///
/// request: ListMenusReq
/// response: ListMenusResp
Future listMenus({
  Function(ListMenusResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/menus",
    ok: (data) {
      if (ok != null) ok(ListMenusResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/menus/:id--
///
/// request: GetMenuReq
/// response: Menu
Future getMenu(
  int id, {
  Function(Menu)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/menus/${id}",
    ok: (data) {
      if (ok != null) ok(Menu.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/menus/:id--
///
/// request: UpdateMenuReq
/// response: Menu
Future updateMenu(
  int id,
  UpdateMenuReq request, {
  Function(Menu)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/menus/${id}",
    request,
    ok: (data) {
      if (ok != null) ok(Menu.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/menus/:id--
///
/// request: DeleteMenuReq
/// response:
Future deleteMenu(
  int id,
  DeleteMenuReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/menus/${id}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/role-menus--
///
/// request: CreateRoleMenuReq
/// response: RoleMenu
Future createRoleMenu(
  CreateRoleMenuReq request, {
  Function(RoleMenu)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/role-menus",
    request,
    ok: (data) {
      if (ok != null) ok(RoleMenu.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/role-menus--
///
/// request: ListRoleMenusReq
/// response: ListRoleMenusResp
Future listRoleMenus({
  Function(ListRoleMenusResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/role-menus",
    ok: (data) {
      if (ok != null) ok(ListRoleMenusResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/role-menus/:id--
///
/// request: GetRoleMenuReq
/// response: RoleMenu
Future getRoleMenu(
  int id, {
  Function(RoleMenu)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/role-menus/${id}",
    ok: (data) {
      if (ok != null) ok(RoleMenu.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/role-menus/:id--
///
/// request: UpdateRoleMenuReq
/// response: RoleMenu
Future updateRoleMenu(
  int id,
  UpdateRoleMenuReq request, {
  Function(RoleMenu)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/role-menus/${id}",
    request,
    ok: (data) {
      if (ok != null) ok(RoleMenu.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/role-menus/:id--
///
/// request: DeleteRoleMenuReq
/// response:
Future deleteRoleMenu(
  int id,
  DeleteRoleMenuReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/role-menus/${id}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/roles--
///
/// request: CreateRoleReq
/// response: Role
Future createRole(
  CreateRoleReq request, {
  Function(Role)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/roles",
    request,
    ok: (data) {
      if (ok != null) ok(Role.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/roles--
///
/// request: ListRolesReq
/// response: ListRolesResp
Future listRoles({
  Function(ListRolesResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/roles",
    ok: (data) {
      if (ok != null) ok(ListRolesResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/roles/:id--
///
/// request: GetRoleReq
/// response: Role
Future getRole(
  int id, {
  Function(Role)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/roles/${id}",
    ok: (data) {
      if (ok != null) ok(Role.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/roles/:id--
///
/// request: UpdateRoleReq
/// response: Role
Future updateRole(
  int id,
  UpdateRoleReq request, {
  Function(Role)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/roles/${id}",
    request,
    ok: (data) {
      if (ok != null) ok(Role.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/roles/:id--
///
/// request: DeleteRoleReq
/// response:
Future deleteRole(
  int id,
  DeleteRoleReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/roles/${id}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/user-roles--
///
/// request: CreateUserRoleReq
/// response: UserRole
Future createUserRole(
  CreateUserRoleReq request, {
  Function(UserRole)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/user-roles",
    request,
    ok: (data) {
      if (ok != null) ok(UserRole.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/user-roles--
///
/// request: ListUserRolesReq
/// response: ListUserRolesResp
Future listUserRoles({
  Function(ListUserRolesResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/user-roles",
    ok: (data) {
      if (ok != null) ok(ListUserRolesResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/user-roles/:id--
///
/// request: GetUserRoleReq
/// response: UserRole
Future getUserRole(
  int id, {
  Function(UserRole)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/user-roles/${id}",
    ok: (data) {
      if (ok != null) ok(UserRole.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/user-roles/:id--
///
/// request: UpdateUserRoleReq
/// response: UserRole
Future updateUserRole(
  int id,
  UpdateUserRoleReq request, {
  Function(UserRole)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/user-roles/${id}",
    request,
    ok: (data) {
      if (ok != null) ok(UserRole.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/user-roles/:id--
///
/// request: DeleteUserRoleReq
/// response:
Future deleteUserRole(
  int id,
  DeleteUserRoleReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/user-roles/${id}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/social/users/:id/follow--
///
/// request: SocialUserIdReq
/// response:
Future followUser(
  int id,
  SocialUserIdReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/social/users/${id}/follow",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/social/users/:id/follow--
///
/// request: SocialUserIdReq
/// response:
Future unfollowUser(
  int id,
  SocialUserIdReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/social/users/${id}/follow",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/social/users/:id/public--
///
/// request: SocialUserIdReq
/// response: PublicUserProfile
Future getPublicUserProfile(
  int id, {
  Function(PublicUserProfile)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/social/users/${id}/public",
    ok: (data) {
      if (ok != null) ok(PublicUserProfile.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/social/users/:id/screenplays--
///
/// request: ListUserScreenplaysReq
/// response: ListUserScreenplaysResp
Future listUserScreenplays(
  int id, {
  Function(ListUserScreenplaysResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/social/users/${id}/screenplays",
    ok: (data) {
      if (ok != null) ok(ListUserScreenplaysResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/users--
///
/// request: CreateUmsUserReq
/// response: UmsUser
Future createUmsUser(
  CreateUmsUserReq request, {
  Function(UmsUser)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/users",
    request,
    ok: (data) {
      if (ok != null) ok(UmsUser.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/users--
///
/// request: ListUmsUsersReq
/// response: ListUmsUsersResp
Future listUmsUsers({
  Function(ListUmsUsersResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/users",
    ok: (data) {
      if (ok != null) ok(ListUmsUsersResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/users/:id--
///
/// request: GetUmsUserReq
/// response: UmsUser
Future getUmsUser(
  int id, {
  Function(UmsUser)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/admin/users/${id}",
    ok: (data) {
      if (ok != null) ok(UmsUser.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/users/:id--
///
/// request: UpdateUmsUserReq
/// response: UmsUser
Future updateUmsUser(
  int id,
  UpdateUmsUserReq request, {
  Function(UmsUser)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/users/${id}",
    request,
    ok: (data) {
      if (ok != null) ok(UmsUser.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/admin/users/:id--
///
/// request: DeleteUmsUserReq
/// response:
Future deleteUmsUser(
  int id,
  DeleteUmsUserReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/admin/users/${id}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}
