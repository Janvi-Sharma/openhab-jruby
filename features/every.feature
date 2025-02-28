Feature:  every
  Rule languages supports cron features

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Using cron shortcuts ':minute'
    Given a rule
      """
      rule 'Log the rule name every minute' do | rule |
        every :minute
        run { logger.info "Rule '#{rule.name}' executed" }
      end
      """
    When I deploy the rule
    Then It should log "Rule 'Log the rule name every minute' executed" within 62 seconds

  Scenario Outline: Cron support days of the week and time of day
    Given a rule template:
      """
            def five_seconds_from_now_string
              (Time.now + 5).strftime('%H:%M:%S')
            end

            def five_seconds_from_now_tod
              TimeOfDay.parse(five_seconds_from_now_string)
            end

            rule 'Simple' do | rule |
              every  <%= ":#{Date.today.strftime('%A').downcase.to_sym}" %>, at: <five_seconds_from_now>
              run { logger.info "Rule #{rule.name} executed" }
            end
      """
    When I deploy the rule
    Then It should log 'Rule Simple executed' within 15 seconds

    Examples:
      | five_seconds_from_now        |
      | five_seconds_from_now_string |
      | five_seconds_from_now_tod    |

  Scenario: Using durations
    Given a rule
      """
      rule 'Every 5 seconds' do | rule |
        every 5.seconds
        run { logger.info "Rule #{rule.name} executed" }
      end
      """
    When I deploy the rule
    Then It should log 'Rule Every 5 seconds executed' within 10 seconds
