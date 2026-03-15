import React from "react";
import { useContent } from "@thoughtbot/superglue";

import { Layout } from "../components/Layout";
import { FieldRenderer } from "../fields/FieldRenderer";
import { Button } from "../components/ui/button";
import { Card, CardContent } from "../components/ui/card";

export default function AdminShow() {
  const {
    pageTitle,
    attributes,
    editPath,
    deletePath,
    indexPath,
    resourceName,
    pluralResourceName,
    navigation
  } = useContent();

  return (
    <Layout
      navigation={navigation}
      title={pageTitle}
      actions={
      <div className="flex gap-2">
          <a href={indexPath} data-sg-visit>
            <Button variant="outline" size="sm">Back to {pluralResourceName}</Button>
          </a>
          {editPath &&
        <a href={editPath} data-sg-visit>
              <Button variant="outline" size="sm">Edit</Button>
            </a>
        }
          {deletePath &&
        <form
          action={deletePath}
          method="post"
          data-sg-visit
          style={{ display: "inline" }}
          onSubmit={(e) => {
            if (!window.confirm("Are you sure?")) e.preventDefault();
          }}>

              <input type="hidden" name="_method" value="delete" />
              <input
            type="hidden"
            name="authenticity_token"
            value={document.querySelector('meta[name="csrf-token"]')?.content ?? ""} />

              <Button type="submit" variant="destructive" size="sm">Delete</Button>
            </form>
        }
        </div>
      }>

      <Card>
        <CardContent className="pt-6">
          <dl className="divide-y">
            {attributes.map((attr) =>
            <div key={attr.attribute} className="py-4 grid grid-cols-3 gap-4">
                <dt className="text-sm font-medium text-muted-foreground">
                  {attr.label}
                </dt>
                <dd className="col-span-2 text-sm">
                  <FieldRenderer mode="show" {...attr} />
                </dd>
              </div>
            )}
          </dl>
        </CardContent>
      </Card>
    </Layout>);

}
