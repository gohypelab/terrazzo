import AdminIndex from "../../views/admin/application/index"
import AdminShow from "../../views/admin/application/show"
import AdminNew from "../../views/admin/application/new"
import AdminEdit from "../../views/admin/application/edit"

export const pageToPageMapping = {
  'terrazzo/application/index': AdminIndex,
  'terrazzo/application/show': AdminShow,
  'terrazzo/application/new': AdminNew,
  'terrazzo/application/edit': AdminEdit,
}
