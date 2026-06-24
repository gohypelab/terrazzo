import React from "react";
import { useContent } from "@thoughtbot/superglue";

import { getLayout } from "terrazzo";
import { FieldRenderer } from "../fields";
import { Badge, Button, Card, CardContent, CardHeader, CardTitle } from "../components/ui";

export default function OrderShow() {
  const Layout = getLayout();
  const {
    pageTitle,
    attributes,
    attributeGroups,
    editPath,
    deletePath,
    indexPath,
    pluralResourceName,
    navigation,
    totalPrice
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
          {editPath && (
            <a href={editPath} data-sg-visit>
              <Button variant="outline" size="sm">Edit</Button>
            </a>
          )}
          {deletePath && (
            <form
              action={deletePath}
              method="post"
              data-sg-visit
              style={{ display: "inline" }}
              onSubmit={(event) => {
                if (!window.confirm("Are you sure?")) event.preventDefault();
              }}
            >
              <input type="hidden" name="_method" value="delete" />
              <input
                type="hidden"
                name="authenticity_token"
                value={document.querySelector('meta[name="csrf-token"]')?.content ?? ""}
              />
              <Button type="submit" variant="destructive" size="sm">Delete</Button>
            </form>
          )}
        </div>
      }
    >
      <div>
        <Badge data-testid="total-price" variant="secondary">
          Total {totalPrice}
        </Badge>
      </div>

      {attributeGroups.map((group, groupIndex) => (
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
                  <div key={key} className="grid grid-cols-3 gap-4 py-4">
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
      ))}
    </Layout>
  );
}
