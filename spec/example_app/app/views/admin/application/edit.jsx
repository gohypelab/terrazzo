import React from "react";
import { useContent } from "@thoughtbot/superglue";

import { Layout } from "../components/Layout";
import { AdminForm } from "./_form";
import { Button } from "../components/ui/button";
import { Card, CardContent } from "../components/ui/card";

export default function AdminEdit() {
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
