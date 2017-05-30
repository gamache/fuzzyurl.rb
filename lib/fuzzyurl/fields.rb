class Fuzzyurl
  FIELDS = %i[
    protocol
    username
    password
    hostname
    port
    path
    query
    fragment
  ].freeze
end
