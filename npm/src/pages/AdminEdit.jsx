import React from "react";
import { useContent } from "@thoughtbot/superglue";

import { getComponent } from "../componentRegistry";
import { getLayout } from "../layoutRegistry";
import { AdminForm } from "./AdminForm";
import { CollectionToolbarActions as DefaultCollectionToolbarActions } from "../components/CollectionToolbarActions";
import { Button, Card, CardContent } from "terrazzo/ui";

export default function AdminEdit() {
  const Layout = getLayout();
  const CollectionToolbarActions = getComponent("CollectionToolbarActions") || DefaultCollectionToolbarActions;
  const {
    pageTitle,
    form,
    errors,
    layoutActions,
    indexPath,
    showPath,
    navigation
  } = useContent();

  return (
    <Layout
      navigation={navigation}
      title={pageTitle}
      actions={
      <div className="flex flex-wrap items-center gap-2">
          <CollectionToolbarActions actions={layoutActions} />
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
