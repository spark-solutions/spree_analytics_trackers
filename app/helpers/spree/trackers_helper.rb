module Spree
  module TrackersHelper
    def product_for_segment(product, optional = {})
      cache_key = [
        'spree-segment-product',
        I18n.locale,
        current_currency,
        product.cache_key_with_version
      ].compact.join('/')

      product_hash = Rails.cache.fetch(cache_key) do
        {
          product_id: product.id,
          sku: product.sku,
          category: product.category&.name,
          name: product.name,
          brand: product.brand&.name,
          price: product.price_in(current_currency).to_f,
          currency: current_currency,
          url: product_url(product)
        }
      end

      product_hash.tap do |hash|
        hash[:image_url] = product_for_segment_image_url(hash, optional)
      end.merge(optional).to_json.html_safe
    end

    def ga_line_item(line_item)
      variant = line_item.variant

      cache_key = [
        'spree-ga-line-item',
        I18n.locale,
        current_currency,
        line_item.cache_key_with_version,
        variant.cache_key_with_version
      ].compact.join('/')

      Rails.cache.fetch(cache_key) do
        product = line_item.product
        {
          id: variant.sku,
          name: variant.name,
          category: product.category&.name,
          variant: variant.options_text,
          brand: product.brand&.name,
          quantity: line_item.quantity,
          price: variant.price_in(current_currency)
        }.to_json.html_safe
      end
    end
  end
end
