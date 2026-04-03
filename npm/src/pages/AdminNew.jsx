import React from "react";
import { useContent } from "@thoughtbot/superglue";

import { getLayout } from "../layoutRegistry";
import { AdminForm } from "./AdminForm";
import { Button, Card, CardContent } from "terrazzo/ui";

export default function AdminNew() {
  const Layout = getLayout();
  const {
    pageTitle,
    form,
    errors,
    indexPath,
    navigation,
    resourceName
  } = useContent();

  return (
    <Layout
      navigation={navigation}
      title={pageTitle}
      actions={
      <a href={indexPath} data-sg-visit>
          <Button variant="outline" size="sm">Cancel</Button>
        </a>
      }>

      <Card>
        <CardContent className="pt-6">
          <AdminForm form={form} errors={errors} />
        </CardContent>
      </Card>
    </Layout>);

}
