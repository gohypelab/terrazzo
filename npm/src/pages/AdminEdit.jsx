import React from "react";
import { useContent } from "@thoughtbot/superglue";

import { getLayout } from "../layoutRegistry";
import { AdminForm } from "./AdminForm";
import { Button, Card, CardContent } from "terrazzo/ui";

export default function AdminEdit() {
  const Layout = getLayout();
  const {
    pageTitle,
    form,
    errors,
    indexPath,
    showPath,
    navigation,
    resourceName
  } = useContent();

  return (
    <Layout
      navigation={navigation}
      title={pageTitle}
      actions={
      <div className="flex gap-2">
          {showPath &&
        <a href={showPath} data-sg-visit>
              <Button variant="outline" size="sm">Cancel</Button>
            </a>
        }
          <a href={indexPath} data-sg-visit>
            <Button variant="outline" size="sm">Back to list</Button>
          </a>
        </div>
      }>

      <Card>
        <CardContent className="pt-6">
          <AdminForm form={form} errors={errors} />
        </CardContent>
      </Card>
    </Layout>);

}
