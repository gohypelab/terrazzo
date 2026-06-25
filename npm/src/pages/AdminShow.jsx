import React from "react";
import { useContent } from "@thoughtbot/superglue";

import { getComponent } from "../componentRegistry";
import { getLayout } from "../layoutRegistry";
import { CollectionToolbarActions as DefaultCollectionToolbarActions } from "../components/CollectionToolbarActions";
import { FieldRenderer } from "terrazzo/fields";
import { Card, CardContent, CardHeader, CardTitle } from "terrazzo/ui";

export default function AdminShow() {
  const Layout = getLayout();
  const CollectionToolbarActions = getComponent("CollectionToolbarActions") || DefaultCollectionToolbarActions;
  const {
    pageTitle,
    attributes,
    attributeGroups,
    layoutActions,
    editPath,
    deletePath,
    indexPath,
    pluralResourceName,
    navigation
  } = useContent();
  const resourceActions = [
    indexPath && {
      label: `Back to ${pluralResourceName}`,
      url: indexPath,
      variant: "outline",
    },
    editPath && {
      label: "Edit",
      url: editPath,
      variant: "outline",
    },
    deletePath && {
      label: "Delete",
      url: deletePath,
      method: "delete",
      confirm: "Are you sure?",
      variant: "destructive",
    },
  ].filter(Boolean);

  return (
    <Layout
      navigation={navigation}
      title={pageTitle}
      actions={
      <div className="flex flex-wrap items-center gap-2">
          <CollectionToolbarActions actions={layoutActions} />
          <CollectionToolbarActions actions={resourceActions} />
        </div>
      }>

      {attributeGroups.map((group, groupIndex) =>
        <Card key={groupIndex}>
          {group.name && (
            <CardHeader>
              <CardTitle>{group.name}</CardTitle>
            </CardHeader>
          )}
          <CardContent className={group.name ? "" : "pt-6"}>
            <dl className="divide-y">
              {group.attributeKeys.map((key) => {
                const attr = attributes[key];
                return (
                  <div key={key} className="py-4 grid grid-cols-3 gap-4">
                    <dt className="text-sm font-medium text-muted-foreground">
                      <span>{attr.label}</span>
                      {attr.hint && (
                        <p className="mt-1 font-normal">{attr.hint}</p>
                      )}
                    </dt>
                    <dd className="col-span-2 text-sm">
                      {attr.showPath ? (
                        <a href={attr.showPath} data-sg-visit className="hover:underline">
                          <FieldRenderer mode="show" {...attr} />
                        </a>
                      ) : (
                        <FieldRenderer mode="show" {...attr} />
                      )}
                    </dd>
                  </div>
                );
              })}
            </dl>
          </CardContent>
        </Card>
      )}
    </Layout>);

}
