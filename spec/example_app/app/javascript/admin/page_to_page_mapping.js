import AdminIndex from "../../views/admin/application/index"
import AdminShow from "../../views/admin/application/show"
import AdminNew from "../../views/admin/application/new"
import AdminEdit from "../../views/admin/application/edit"

export const pageToPageMapping = {
  'admin/application/index': AdminIndex,
  'admin/application/show': AdminShow,
  'admin/application/new': AdminNew,
  'admin/application/edit': AdminEdit,
}
