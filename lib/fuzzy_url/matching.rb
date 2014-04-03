class FuzzyURL

  ## FuzzyURL::Matching provides the logic for 
  module Matching

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods

      ## Compares a URL mask hash with a URL hash.
      ## Returns nil on negative match, and an integer match score otherwise.
      ## This match score is higher for more specific matches.
      def match_hash(mask, url)
        score = 0
        tally = Proc.new {|x| return nil unless x; score += x}

        tally.call match_hostnames(mask[:hostname], url[:hostname])
        tally.call match_protocols_and_ports(mask, url)
        tally.call match_paths(mask[:path], url[:path])
        tally.call fuzzy_match(mask[:port], url[:port])
        tally.call fuzzy_match(mask[:query], url[:query])
        tally.call fuzzy_match(mask[:username], url[:username])
        tally.call fuzzy_match(mask[:password], url[:password])
        tally.call fuzzy_match(mask[:fragment], url[:fragment])
      end

    private

      ## Matches a URL mask hash against a URL hash.
      ## Returns true on positive match, false otherwise.
      def matches_hash?(mask, url)
        match_hash(mask, url) ? true : false
      end

      ## Matches protocol and port information.
      ## Returns nil for no match, 0 if two wildcard matches were made, 1 if
      ## one wildcard match was made, and 2 for an exact match.
      def match_protocols_and_ports(mask_hash, url_hash)
        wildcard_matches = 0
        mask_protocol = mask_hash[:protocol] || 'http'
        url_protocol = url_hash[:protocol] || 'http'
        if mask_hash[:protocol] && mask_protocol != '*'
          return nil if mask_protocol != url_protocol
        else
          wildcard_matches += 1
        end

        mask_port = mask_hash[:port]
        url_port = url_hash[:port]
        if mask_hash[:port] && mask_port != '*'
          if mask_port == PORT_BY_PROTOCOL[url_protocol]
            wildcard_matches += 1
          else
            return nil if mask_port != url_port
          end
        else
          wildcard_matches += 1
        end

        (2 - wildcard_matches)
      end

      PORT_BY_PROTOCOL = {
        'http'  => 80,
        'https' => 443,
        'file'  => nil,
      }

      ## Matches a picee of a mask against a piece of a URL.  Handles wildcards.
      ## Returns nil for no match, 0 for a wildcard match, or 1 for an
      ## exact match.
      def fuzzy_match(mask, piece)
        return 0 if !mask || mask == '*'    # || !piece
        return 1 if mask == piece
        nil
      end

      ## Matches a hostname mask against a hostname.
      ## Returns nil for no match, 0 for a wildcard match, or 1 for an
      ## exact match.
      def match_hostnames(mask, host)
        mask_pieces = (mask || '').split('.').reverse
        host_pieces = (host || '').split('.').reverse
        return 1 if mask && host && mask_pieces==host_pieces
        return 0 if match_pieces(mask_pieces, host_pieces, :ignore_depth => false)
        nil
      end

      ## Matches a path mask against a path.
      ## Returns nil for no match, 0 for a wildcard match, or 1 for an
      ## exact match.
      def match_paths(mask, path)
        mask_pieces = (mask || '*').split(%r{/})
        path_pieces = (path || '/').split(%r{/})
        return 1 if mask && path && mask_pieces==path_pieces
        return 0 if match_pieces(mask_pieces, path_pieces, :ignore_depth => true)
        nil
      end

      ## Matches arrays of URL or hostname pieces.
      ## Returns nil for no match, 0 for a wildcard match, or 1 for an
      ## exact match.
      def match_pieces(mask, pieces, args)
        ignore_depth = args[:ignore_depth]
        return nil if !ignore_depth && mask.count > pieces.count
        pieces.each_with_index do |piece, i|
          return 0 if piece && mask[i] == '*'
          return nil if mask[i] != piece
        end
        1
      end

    end

  end
end
