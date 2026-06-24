import React from "react";
import { useContent } from "@thoughtbot/superglue";

import { getLayout } from "terrazzo";
import { AdminForm } from "./_form";
import { CollectionToolbarActions } from "../components";
import { Button, Card, CardContent } from "../components/ui";

export default function AdminNew() {
  const Layout = getLayout();
  const {
    pageTitle,
    form,
    errors,
    layoutActions,
    indexPath,
    navigation,
    resourceName
  } = useContent();

  return (
    <Layout
      navigation={navigation}
      title={pageTitle}
      actions={
      <div className="flex flex-wrap items-center gap-2">
        <CollectionToolbarActions actions={layoutActions} />
        <a href={indexPath} data-sg-visit>
          <Button variant="outline" size="sm">Cancel</Button>
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
