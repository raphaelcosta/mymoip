module MyMoip
  class PaymentRequest < Request

    HTTP_METHOD       = :get
    PATH              = "/rest/pagamento?callback=?"
    REQUIRES_AUTH     = false
    FORMAT            = :json
    PAYMENT_SLIP_PATH = "/Instrucao.do?token="

    attr_reader :token

    def api_call(data, opts)
      @token = opts[:token]

      opts[:referer_url] ||= MyMoip.default_referer_url
      opts[:parser]      ||= MyMoip::JsonParser

      json = JSON.generate({
        pagamentoWidget: {
          referer:        opts[:referer_url],
          token:          @token,
          dadosPagamento: data.to_json
        }
      })

      params = {
        query:         { pagamentoWidget: json },
        http_method:   HTTP_METHOD,
        requires_auth: REQUIRES_AUTH,
        path:          PATH,
        format:        FORMAT
      }
      params[:parser] = opts.delete(:parser) unless opts[:parser].nil?

      super(params, opts)
    end

    def success?
      @response && @response["StatusPagamento"] == "Sucesso"
    end

    def url
      MyMoip.api_url + PAYMENT_SLIP_PATH + @token if success?
    end

    def code
      @response["CodigoMoIP"]
    rescue NoMethodError => e
      nil
    end

  end
end
