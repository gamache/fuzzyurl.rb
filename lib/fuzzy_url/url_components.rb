class FuzzyURL

  ## FuzzyURL::URLComponents provides getting/setting of URL components
  ## on FuzzyURL objects in hash style (e.g. `foo[:hostname]`) and
  ## method style (e.g. `foo.hostname`).  Acceptable URL components are
  ## :protocol, :username, :password, :hostname, :port, :path, :query,
  ## and :fragment.
  module URLComponents

    COMPONENTS = [:protocol, :username, :password, :hostname,
                  :port, :path, :query, :fragment]

    ## Gets a URL component.
    def [](component)
      component_sym = component.to_sym
      if !COMPONENTS.include?(component_sym)
        raise ArgumentError, "#{component.inspect} is not a URL component. "+
                             COMPONENTS.inspect
      end
      @components[component_sym]
    end

    ## Sets a URL component.
    def []=(component, value)
      component_sym = component.to_sym
      if !COMPONENTS.include?(component_sym)
        raise ArgumentError, "#{component.inspect} is not a URL component. "+
                             COMPONENTS.inspect
      end
      @components[component_sym] = value
    end


    ## Get the protocol for this FuzzyURL.
    def protocol; self[:protocol] end

    ## Set the protocol for this FuzzyURL.
    def protocol=(v); self[:protocol]=v end


    ## Get the username for this FuzzyURL.
    def username; self[:username] end

    ## Set the username for this FuzzyURL.
    def username=(v); self[:username]=v end


    ## Get the password for this FuzzyURL.
    def password; self[:password] end

    ## Set the password for this FuzzyURL.
    def password=(v); self[:password]=v end


    ## Get the hostname for this FuzzyURL.
    def hostname; self[:hostname] end

    ## Set the hostname for this FuzzyURL.
    def hostname=(v); self[:hostname]=v end


    ## Get the port for this FuzzyURL.
    def port; self[:port] end

    ## Set the port for this FuzzyURL.
    def port=(v); self[:port]=v end


    ## Get the path for this FuzzyURL.
    def path; self[:path] end

    ## Set the path for this FuzzyURL.
    def path=(v); self[:path]=v end


    ## Get the query for this FuzzyURL.
    def query; self[:query] end

    ## Set the query for this FuzzyURL.
    def query=(v); self[:query]=v end


    ## Get the fragment for this FuzzyURL.
    def fragment; self[:fragment] end

    ## Set the fragment for this FuzzyURL.
    def fragment=(v); self[:fragment]=v end

  end
end

