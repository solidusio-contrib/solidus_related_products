# Related Products

[![Build Status](https://travis-ci.org/solidusio-contrib/solidus_related_products.svg?branch=master)](https://travis-ci.org/solidusio-contrib/solidus_related_products)
[![Gem](https://img.shields.io/gem/v/solidus_related_products.svg)](https://rubygems.org/gems/solidus_related_products)
[![License](http://img.shields.io/badge/license-BSD-yellowgreen.svg)](LICENSE.md)

This extension provides a generic way for you to define different types of relationships between your products, by defining a RelationType for each type of relationship you'd like to maintain.

You can manage RelationTypes via the admin configuration menu, and you can maintain product relationships via __Related Products__ tab on the edit product UI.

## Installation

Add to `Gemfile`:
```ruby
gem 'solidus_related_products'
```

Run:
```sh
$ bundle install
$ bundle exec rake railties:install:migrations
$ bundle exec rake db:migrate
$ bundle exec rails g solidus_related_products:install
```

## Possible uses

* Accessories
* Cross Sells
* Up Sells
* Compatible Products
* Replacement Products
* Warranty & Support Products

## Relation Types

When you create a RelationType you can access that set of related products by referencing the relation_type name, see below for an example:
```ruby
rt = Spree::RelationType.create(name: 'Accessories', applies_to: 'Spree::Product')
 => #<Spree::RelationType id: 4, name: "Accessories" ...>
product = Spree::Product.last
 => #<Spree::Product id: 1060500592 ...>
product.accessories
 => []
```

Since respond_to? will not work in this case, you can test whether a relation_type method exists with has_related_products?(method):

```ruby
product.has_related_products?('accessories')
# => true

if product.has_related_products?('accessories')
  # Display an accessories box..
end
```

You can access all related products regardless of RelationType by:
```ruby
product.relations
 => []
```

**Discounts**
You can optionally specify a discount amount to be applied if a customer purchases both products.

Note: In order for the coupon to be automatically applied, you must create a promotion leaving the __code__ value empty, and adding an Action of type : __RelatedProductDiscount__  (blank codes are required for coupons to be automatically applied).

## Contributing

See corresponding [guidelines][4]

---

Copyright (c) 2010-2015 [Brian Quinn][5] and [contributors][6], released under the [New BSD License][3]

[1]: http://www.fsf.org/licensing/essays/free-sw.html
[2]: https://github.com/solidusio-contrib/solidus_related_products/issues
[3]: https://github.com/solidusio-contrib/solidus_related_products/blob/master/LICENSE.md
[4]: https://github.com/solidusio-contrib/solidus_related_products/blob/master/CONTRIBUTING.md
[5]: https://github.com/BDQ
[6]: https://github.com/solidusio-contrib/solidus_related_products/graphs/contributors
