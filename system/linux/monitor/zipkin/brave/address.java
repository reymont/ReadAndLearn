

//C:\workspace\java\zipkin\brave\archive\brave-core\src\main\java\com\github\kristofa\brave\TracerAdapter.java

// 设置ip地址
    @Override void address(Span span, String key, Endpoint endpoint) {
      brave.Span brave4 = brave4(span);
      switch (key) {
        case Constants.SERVER_ADDR:
          brave4.kind(brave.Span.Kind.CLIENT);
          break;
        case Constants.CLIENT_ADDR:
          brave4.kind(brave.Span.Kind.SERVER);
          break;
        default:
          throw new AssertionError(key + " is not yet supported");
      }
      brave4.remoteEndpoint(zipkin.Endpoint.builder()
          .serviceName(endpoint.service_name)
          .ipv4(endpoint.ipv4)
          .ipv6(endpoint.ipv6)
          .port(endpoint.port)
          .build());
    }
