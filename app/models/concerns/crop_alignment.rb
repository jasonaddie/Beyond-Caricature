module CropAlignment
  extend ActiveSupport::Concern

  included do

    #################
    ## ENUMS ##
    #################
    enum crop_alignment: { center: 'c', north: 'n', northeast: 'ne', east: 'e', southeast: 'se', south: 's', southwest: 'sw', west: 'w', northwest: 'nw'}

    #################
    ## SCOPES ##
    #################
    def self.crop_alignment_for_select
      options = {}
      crop_alignments.each do |key, value|
        options[I18n.t("crop_alignments.#{key}")] = value
      end
      return options
    end

    #################
    ## METHODS ##
    #################

    # show the translated name of the enum value
    def crop_alignment_formatted
      self.crop_alignment? ? I18n.t("crop_alignments.#{crop_alignment}") : nil
    end

    def crop_alignment_value
      self.class.crop_alignments[self.crop_alignment]
    end

    # combine the image size and crop alignment into one string
    def generate_image_size_syntax(image_size, with_crop=true)
      image_sizes = {
        square: '400x400#',
        wide: '400x204#',
        news: '438x326#',
        highlight: '726x483#',
        landscape: 'x576',
        portrait: '550x',
        annotation: '550x',
        square_small: '150x150#',
        wide_small: '150x76#',
        news_small: '150x112#',
        highlight_small: '150x100#',
        share: '1200x630#'
      }

      syntax = ''
      if !image_sizes.keys.include?(image_size)
        image_size = :square
      end
      syntax << image_sizes[image_size]

      # if there is an alignment and the value is not 'c' (center),
      # add the alignment
      # - do not do it for center for it is centered by default
      crop = crop_alignment_value
      if with_crop && crop.present? && crop != 'c'
        syntax << crop
      end

      puts "-----------------"
      puts syntax

      return syntax
    end

  end
end