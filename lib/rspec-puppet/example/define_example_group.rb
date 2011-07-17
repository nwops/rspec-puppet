module RSpec::Puppet
  module DefineExampleGroup
    include RSpec::Puppet::Matchers

    def subject
      @catalogue ||= catalogue
    end

    def catalogue
      Puppet[:modulepath] = module_path
      # TODO pull type name from describe string
      Puppet[:code] = 'sysctl' + " { " + name + ": " + params.keys.map { |r|
        "#{r.to_s} => '#{params[r].to_s}'"
      }.join(', ') + " }"

      unless facts = Puppet::Node::Facts.find(Puppet[:certname])
        raise "Could not find facts for #{Puppet[:certname]}"
      end

      unless node = Puppet::Node.find(Puppet[:certname])
        raise "Could not find node #{Puppet[:certname]}"
      end

      node.merge(facts.values)

      Puppet::Resource::Catalog.find(node.name, :use_node => node)
    end
  end
end
