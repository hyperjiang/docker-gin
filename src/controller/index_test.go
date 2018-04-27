package controller

import (
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/suite"
)

type IndexTestSuite struct {
	suite.Suite
	rec     *httptest.ResponseRecorder
	context *gin.Context
	app     *gin.Engine
	ctrl    *IndexController
}

func (suite *IndexTestSuite) SetupTest() {
	gin.SetMode(gin.ReleaseMode)

	suite.rec = httptest.NewRecorder()
	suite.context, suite.app = gin.CreateTestContext(suite.rec)
	suite.ctrl = new(IndexController)
}

func (suite *IndexTestSuite) TestIndex() {
	suite.ctrl.Index(suite.context)
	suite.Equal(200, suite.rec.Code)
	suite.Equal("{\"version\":\"v1.0\"}", suite.rec.Body.String())
}

func TestIndexTestSuite(t *testing.T) {
	suite.Run(t, new(IndexTestSuite))
}
