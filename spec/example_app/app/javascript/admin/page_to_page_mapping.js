import AdminIndex from "../../views/admin/application/index"
import AdminShow from "../../views/admin/application/show"
import AdminNew from "../../views/admin/application/new"
import AdminEdit from "../../views/admin/application/edit"

export const pageToPageMapping = {
  'super_admin/application/index': AdminIndex,
  'super_admin/application/show': AdminShow,
  'super_admin/application/new': AdminNew,
  'super_admin/application/edit': AdminEdit,
}
