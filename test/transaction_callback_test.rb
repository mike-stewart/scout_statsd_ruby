require_relative 'test_helper'

class TransactionCallbackTest < Minitest::Test
  include StatsD::Instrument::Assertions
  def setup
    @agent_context = ScoutApm::AgentContext.new
    @context = ScoutApm::Context.new(@agent_context)
  end

  def test_call_payload1
    callback = ScoutStatsd::TransactionCallback.new
    metrics = capture_statsd_calls do
      callback.call(payload1)
    end

    assert_equal 2, metrics.length
    assert_equal 'web.duration_ms', metrics[0].name
    assert_equal 'web.total_count', metrics[1].name
    assert_equal :ms, metrics[0].type
    assert_equal :c, metrics[1].type
    assert_equal 1, metrics[1].value
  end

  def test_call_payload2
    callback = ScoutStatsd::TransactionCallback.new
    metrics = capture_statsd_calls do
      callback.call(payload2)
    end

    assert_equal 3, metrics.length
    assert_equal 'web.duration_ms', metrics[0].name
    assert_equal 'web.total_count', metrics[1].name
    assert_equal 'web.error_count', metrics[2].name

    assert_equal :ms, metrics[0].type
    assert_equal :c, metrics[1].type
    assert_equal :c, metrics[2].type

    assert_equal 1, metrics[1].value
    assert_equal 1, metrics[2].value
  end

  private

  def scope_layer
    scope_layer = ScoutApm::Layer.new('Controller', 'users/index', Time.now - 0.1)
    scope_layer.record_stop_time!(Time.now)
    scope_layer
  end

  def converter_results(errors = nil)
    meta = ScoutApm::MetricMeta.new("Controller/uesrs/index")
    stats = ScoutApm::MetricStats.new
    stats.update!(0.1)
    {
     :metrics => {meta => stats},
     :errors=>errors,
     :queue_time=>nil, 
     :job=>nil
    }
  end

  def payload1
    ScoutApm::Extensions::TransactionCallbackPayload.new(@agent_context,converter_results,@context,scope_layer)
  end
  def payload2
    ScoutApm::Extensions::TransactionCallbackPayload.new(@agent_context,converter_results(['Failed Job']),@context,scope_layer)
  end
end
