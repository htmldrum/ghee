class Ghee

  # API module encapsulates all of API endpoints
  # implemented thus far
  #
  module API

    # The Orgs module handles all of the Github Organization
    # API endpoints
    #
    module Orgs

      module Memberships
        class MembershipsProxy < ::Ghee::ResourceProxy
          accept_header "application/vnd.github.moondragon+json"
        end
      end

      # Orgs::Teams module handles all of the Github Organization Teams
      # API endpoints
      #
      module Teams

        # Orgs::Teams::Members module handles all of the Github Organization Teams members
        # API endpoints
        #
        module Members

          # Members::Proxy inherits from Ghee::Proxy and 
          # enables defining methods on the proxy object
          #
          class Proxy < ::Ghee::ResourceProxy

              def add(member)
                connection.put("#{path_prefix}/#{member}").status == 204
              end

              def remove(member)
                connection.delete("#{path_prefix}/#{member}").status == 204
              end
          end
        end

        # Teams::Proxy inherits from Ghee::Proxy and 
        # enables defining methods on the proxy object
        #
        class Proxy < ::Ghee::ResourceProxy
          include Ghee::CUD

          def members(name=nil, &block)
            prefix = name ? "#{path_prefix}/members/#{name}" : "#{path_prefix}/members"
            Ghee::API::Orgs::Teams::Members::Proxy.new(connection, prefix, name, &block)
          end

        end
      end

      # Orgs::Proxy inherits from Ghee::Proxy and
      # enables defining methods on the proxy object
      #
      class Proxy < ::Ghee::ResourceProxy
        include Ghee::CUD

        # Teams for an org
        #
        # Returns json
        #
        def teams(number=nil, &block)
          prefix = (!number.is_a?(Hash) and number) ? "./teams/#{number}" : "#{path_prefix}/teams"
          Ghee::API::Orgs::Teams::Proxy.new(connection, prefix, number, &block)
        end

        # Repos for a orgs
        #
        # Returns json
        #
        def repos(name=nil, &block)
          params = name if name.is_a?Hash
          prefix = (!name.is_a?(Hash) and name) ? "./repos/#{self["login"]}/#{name}" : "#{path_prefix}/repos"
          Ghee::API::Repos::Proxy.new(connection,prefix,name, &block)
        end

        # User Membership for an org
        #
        # Returns json
        #

        def memberships(user, &block)
          prefix = "#{path_prefix}/memberships/#{user}"
          Ghee::API::Orgs::Memberships::MembershipsProxy.new(connection, prefix, nil, &block)
        end
      end

      # Team by id
      #
      # Returns json
      #
      def team(number, params={})
        prefix = "./teams/#{number}" 
        Ghee::API::Orgs::Teams::Proxy.new(connection, prefix, params)
      end

      # Returns list of the authenticated users organizations or 
      # an organization by name
      #
      # org - String name of the organization (optional)
      #
      # Returns json
      #
      def orgs(name=nil, &block)
        prefix = (!name.is_a?(Hash) and name) ? "./orgs/#{name}" : "user/orgs"
        Proxy.new(connection, prefix, name, &block)
      end
    end
  end
end

