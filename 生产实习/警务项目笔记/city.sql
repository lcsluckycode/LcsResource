
-- ----------------------------
-- Table structure for city
-- ----------------------------
DROP TABLE IF EXISTS `city`;
CREATE TABLE `city` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provincename` varchar(255) DEFAULT NULL,
  `cityname` varchar(255) DEFAULT NULL,
  `usernumber` int(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of city
-- ----------------------------
INSERT INTO `city` VALUES ('1', '内蒙古自治区', '呼和浩特', '1903');
INSERT INTO `city` VALUES ('2', '辽宁省', '沈阳市', '1864');
INSERT INTO `city` VALUES ('3', '黑龙江省', '哈尔滨市', '1863');
INSERT INTO `city` VALUES ('4', '广西壮族自治区', '南宁', '1841');
INSERT INTO `city` VALUES ('5', '江西省', '南昌市', '1898');
INSERT INTO `city` VALUES ('6', '山西省', '太原市', '1886');
INSERT INTO `city` VALUES ('7', '陕西省', '西安市', '1816');
INSERT INTO `city` VALUES ('8', '海南省', '海口市', '1919');
INSERT INTO `city` VALUES ('9', '西藏自治区', '拉萨', '1830');
INSERT INTO `city` VALUES ('10', '安徽省', '合肥市', '1848');
INSERT INTO `city` VALUES ('11', '北京市', '北京市', '1826');
INSERT INTO `city` VALUES ('12', '天津市', '天津市', '1816');
INSERT INTO `city` VALUES ('13', '香港', '九龙', '1877');
INSERT INTO `city` VALUES ('14', '甘肃省', '兰州市', '1883');
INSERT INTO `city` VALUES ('15', '宁夏回族自治区', '银川', '1886');
INSERT INTO `city` VALUES ('16', '山东省', '济南市', '1864');
INSERT INTO `city` VALUES ('17', '江苏省', '南京市', '1884');
INSERT INTO `city` VALUES ('18', '重庆市', '重庆市', '1821');
INSERT INTO `city` VALUES ('19', '上海市', '上海市', '1955');
INSERT INTO `city` VALUES ('20', '贵州省', '贵阳市', '1814');
INSERT INTO `city` VALUES ('21', '河南省', '郑州市', '1787');
INSERT INTO `city` VALUES ('22', '云南省', '昆明市', '1850');
INSERT INTO `city` VALUES ('23', '湖南省', '株洲市', '1924');
INSERT INTO `city` VALUES ('24', '四川省', '成都市', '1861');
INSERT INTO `city` VALUES ('25', '吉林省', '长春市', '1867');
INSERT INTO `city` VALUES ('26', '河北省', '石家庄市', '1841');
INSERT INTO `city` VALUES ('27', '福建省', '福州市', '1874');
INSERT INTO `city` VALUES ('28', '台湾省', '台北市', '1820');
INSERT INTO `city` VALUES ('29', '浙江省', '杭州市', '1905');
INSERT INTO `city` VALUES ('30', '广东省', '广州市', '1911');
INSERT INTO `city` VALUES ('31', '湖北省', '武汉市', '1851');
INSERT INTO `city` VALUES ('32', '青海省', '西宁市', '1890');
INSERT INTO `city` VALUES ('33', '新疆维吾尔自治区', '乌鲁木齐', '1808');
INSERT INTO `city` VALUES ('34', '澳门', '澳门', '1894');
INSERT INTO `city` VALUES ('36', '湖南省', '株洲市', '123');
INSERT INTO `city` VALUES ('38', '湖南省', '长沙市', '1999');
