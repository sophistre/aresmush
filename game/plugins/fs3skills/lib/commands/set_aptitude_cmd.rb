module AresMUSH

  module FS3Skills
    class SetAptitudeCmd
      include CommandHandler
      include CommandRequiresLogin
      include CommandRequiresArgs
      include CommandWithoutSwitches
      
      attr_accessor :great, :good, :poor

      def crack!
        cmd.crack_args!(/(?<great>.+)\/(?<good>.+)\/(?<poor>.+)/)
        self.great = titleize_input(cmd.args.great)
        self.good = titleize_input(cmd.args.good)
        self.poor = titleize_input(cmd.args.poor)
      end

      def required_args
        {
          args: [ self.great, self.good, self.poor ],
          help: 'abilities'
        }
      end
      
      def check_aptitudes
        [self.great, self.good, self.poor].each do |a|
          return t('fs3skills.invalid_aptitude', :name => a) if !FS3Skills.aptitude_names.include?(a)
        end
        return nil
      end
      
      def check_chargen_locked
        return nil if FS3Skills.can_manage_abilities?(enactor)
        Chargen::Api.check_chargen_locked(enactor)
      end
      
      def handle
        FS3Skills.aptitude_names.each do |a|
          # Nil for client to avoid spam.
          FS3Skills.set_ability(nil, enactor, a, 2)
        end
        FS3Skills.set_ability(nil, enactor, self.great, 4)
        FS3Skills.set_ability(nil, enactor, self.good, 3)
        FS3Skills.set_ability(nil, enactor, self.poor, 1)
        enactor.save
        
        client.emit_success t('fs3skills.aptitude_set', :great => self.great, :good => self.good, :poor => self.poor)
      end
    end
  end
end