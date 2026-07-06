export interface CategoryProduct {
  name: string;
  detail: string;
  image: ResourceStr;
}

export interface SecondaryCategory {
  label: string;
  title: string;
  products: CategoryProduct[];
}

export interface PrimaryCategory {
  label: string;
  sections: SecondaryCategory[];
}
