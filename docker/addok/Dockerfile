FROM python:3.11
ENTRYPOINT []
CMD ["/bin/sh"]

ARG ADDOK_VERSION
ENV ADDOK_VERSION ${ADDOK_VERSION:-v1.1.1}
ENV ADDOK_ES_VERSION master
ENV ADDOK_FR_VERSION v1.0.1
ENV ADDOK_SPAIN_VERSION master
ENV ADDOK_FRANCE_VERSION v1.1.3
ENV ADDOK_LUXEMBURG_VERSION v1.2.0

# Addok-csv v1.1.0 Does not works with Addok v1.1.1
ENV ADDOK_CSV_VERSION v1.0.1

ENV ADDOK_MULTIPLE_RESULT_NAME v1.1.0
ENV ADDOK_FRANCE_CLEAN_VERSION v1.0.0
ENV ADDOK_LUXEMBURG_CLEAN_VERSION v1.2.0
ENV ADDOK_SEARCH_2_STEPS_VERSION v1.1.0
ENV ADDOK_USAGE_NAME_BAN_FR_VERSION v1.1.0
ENV ADDOK_USAGE_NAME_LU_VERSION v1.1.0
ENV ADDOK_SCORE_PREPROCESSSED_QUERY_VERSION v1.0.0

RUN apt-get -q update && \
    apt-get -qy install redis-tools jq

RUN pip install gunicorn addok==${ADDOK_VERSION} addok-csv==${ADDOK_CSV_VERSION} && \
    pip install git+https://github.com/cartoway/addok_multiple_result_name.git@${ADDOK_MULTIPLE_RESULT_NAME} && \
    pip install git+https://github.com/cartoway/addok_score_preprocessed_query@${ADDOK_SCORE_PREPROCESSSED_QUERY_VERSION} && \
    pip install git+https://github.com/cartoway/addok_search2steps@${ADDOK_SEARCH_2_STEPS_VERSION} && \
    \
    pip install git+https://github.com/cartoway/addok-es@${ADDOK_ES_VERSION} && \
    pip install git+https://github.com/cartoway/addok-spain@${ADDOK_SPAIN_VERSION} && \
    \
    pip install addok-fr==${ADDOK_FR_VERSION} && \
    pip install addok-france==${ADDOK_FRANCE_VERSION} && \
    pip install git+https://github.com/cartoway/addok_france_clean@${ADDOK_FRANCE_CLEAN_VERSION} && \
    pip install git+https://github.com/cartoway/addok_usage_name_BAN_FR@${ADDOK_USAGE_NAME_BAN_FR_VERSION} && \
    \
    pip install git+https://github.com/cartoway/addok_luxemburg@${ADDOK_LUXEMBURG_VERSION} && \
    pip install git+https://github.com/cartoway/addok_luxemburg_clean@${ADDOK_LUXEMBURG_CLEAN_VERSION} && \
    pip install git+https://github.com/cartoway/addok_usage_name_LU@${ADDOK_USAGE_NAME_LU_VERSION}

EXPOSE 7878

VOLUME /etc/addok/addok.conf
