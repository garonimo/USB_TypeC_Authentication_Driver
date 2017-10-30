`ifndef parameters

`define parameters

`define SIZE_OF_STATES_RESP       9
`define SIZE_OF_STATES_DRIVER     9
`define SIZE_OF_STATES_INIT       9
`define	SIZE_OF_HEADER_VARS       8
`define SIZE_OF_HEADER_IN_BYTES   4
`define CERTIFICATE_TIMEOUT       135
`define CHALLENGE_AUTH_TIMEOUT    635
`define GET_DIGESTS_TIMEOUT       135
`define MSG_LEN_IN_BYTES          260
`define MSG_LEN                   `MSG_LEN_IN_BYTES*8
`define GET_CERTIFICATE_TIMEOUT   20000000     //200 ms
`define CERTIFICATE_ANW_TIMEOUT   13500000     //135 ms
`define CHALLENGE_TIMEOUT         120000000    //1200 ms
`define CHALLENGE_TIMEOUT_AUTH    63500000     //635 ms
`define DIGEST_REQ_TIMEOUT        20000000     //200 ms
`define DIGEST_ANW_TIMEOUT        13500000     //135 ms
`define GET_CERTIFICATE_TIMEOUT_USB   1000000      //100 ms
`define CERTIFICATE_ANW_TIMEOUT_USB   50000000     //500 ms
`define CHALLENGE_TIMEOUT_USB         1000000      //100 ms
`define CHALLENGE_TIMEOUT_AUTH_USB    60000000     //600 ms
`define DIGEST_REQ_TIMEOUT_USB        100000000    //1000 ms
`define CERT_CHAINS               3
`define CERT_CHAINS_MASK          8'h07
`define HEADER_DIGESTS            {8'h01,8'h81,8'h00,8'h00}
`define HEADER_CHALLENGE_SLOT0    {8'h01,8'h83,8'h00,8'h00}
`define HEADER_CHALLENGE_SLOT1    {8'h01,8'h83,8'h01,8'h00}
`define HEADER_CHALLENGE_SLOT2    {8'h01,8'h83,8'h02,8'h00}
`define HEADER_CERTIFICATE_SLOT0  {8'h01,8'h82,8'h00,8'h00}
`define HEADER_CERTIFICATE_SLOT1  {8'h01,8'h82,8'h01,8'h00}
`define HEADER_CERTIFICATE_SLOT2  {8'h01,8'h82,8'h02,8'h00}
`define PROTOCOL_VERSION          8'h01
`define CERTIFICATE_ANSWER_CMD    8'h02
`define DIGESTS_ANSWER_CMD        8'h01
`define CHALLENGE_AUTH_CMD        8'h03
`define CAPABILITIES              8'h01
`define ERROR_RESP_CMD            8'h7F
`define SLOT0_CERT1               2072'h35796834356801333467333467337134673372746733676572676465626466626574206c61206672757461206d616472652071756520746520706172696f2068696a6f206465206c61206772616e646973696d6120707574612e20686f6c6120636f6d6f20657374616d6f7320686f792c2065737065726f20717565206d7579206269656e2e2051756572696120636f6d656e7461726c657320717565206e6f7320656e636f6e7472616d6f7320656e207a7a7a7a7a7a7a
`define SLOT0_CERT2               2072'h4573746520657320756e206d656e73616a65207365637265746f2e2e2066656c6963696461646573207369206c6f206861732064656369667261646f2e2e207465206861732067616e61646f20756e6f732062657369746f73203a2a203a2a203a2a203a2a2e2e2061686f7261206269656e20656c206d656e73616a65207365637265746f2074616e20696d706f7274616e7465206f63756c746f2061717569206573202e2e2e
`define SLOT0_CERT3               2072'h016733676572676465626466626574206c612066727574612062061686f7261206269656e20656c206d656e73616a65207365637265746f2074616e20696d706f7274616e7465206f63756cf63756c746f206171756920657320654668491651abe47865488468498498498498446887a484d49849848c98484cc984984984847a7a67686a6b68756c0008
`define SLOT0_CERT4               2072'hff6d652073756269206120756e2074617869207920616c206d697261726c6f206e6f2074652071756520646563696120667265636f20796f206e6f20736520706f72207175652c206e6f206c6520646920696d706f7274616e6369612079206c6f2061626f7264652079206d652064696a652061206d69206d69736d6f206361736920657374617320656e2062656c2d6169722e204861792073692c206c6c65677565206120756e61206d616e73696f6e206465206c6f206d61
`define SLOT0_CERT5               2072'h007320656c6567616e74652079206c6520696a6520616c207461786973746120706f6e7465206465736f646f72616e74656520657320756e206d656e73616a65207365637265746f2e2e2066656c6963696461646573207369206c6f206861732064656369667261646f2e2e207465206861732067616e61646f20756e6f732062657369746f73203a2a203a2a203a2a203a2a2e2e2061686f7261206269656e20656c206d656e73616a6520736563
`define SLOT0_CERT6               2072'h7a7265746f2074616e20696d706f7274616e7465206f63756c746f2061717569206573202e2e2e6f636a6e6f66776620776f656a6e6677656a66206377656a203420636a776565626369776a65206377763534776566206966736668776696a6e656b6a6e6177736a6e7861736a646477656a66206377656a203420636a7
`define SLOT1_CERT1               2072'h6f636a6e6f66776620776f656a6e6677656a66206377656a203420636a776565626369776a652063777635347765662069776a6566756577666f717775756e66717766373861696b6a71656e6669776a65626668776620776b6a6566776a656e66696a776566206b6b696a6e656b6a6e6177736a6e7861736a6464646439343938206b736a666e736f6a666e776f65666e6163206665663636984988498400
`define SLOT1_CERT2               2072'h76616d6f73206120657363726962697220756e6120686973746f72696120736f62726520756e2074696275726f6e206d75792066656c697a207175652073616c7461626120736f627265206c6f7320616c70657320617267656e74696e6f7320756e612074617264652064652073616261646f206a756e746f2061207375732033206573706f7361732c20756e612074696275726f6e612c20756e61206d6f737175697461207920756e61206769726166612e
`define SLOT1_CERT3               2072'h2e204572616e206d75792066656c69636577061726f6e20636f6e206e6f7366657261747520656e20656c2063617374696c6c6f3206861737461207175652073652068697a6f206465206e6f636865207920736520746f737461207175652073652068697a6f206465206e6f636865207920736520746f7061726f6e20636f6e206e6f7366657261747520656e20656c2063617374696c6c6f
`define SLOT1_CERT4               2072'h4776616d6f6a756e746f2061207375732033206573706f7361732c20756e612074696275726f6e612c20756e61206d6f7373206120657363726962697220756e6120686973746f72696120736f62726520756e2074696275726f6e206d75792066656c697a207175652073616c7461626120736f627265206c6f7320616c70657320617267656e74696e
`define SLOT2_CERT1               2072'h51684a0657320756e206d656e73616a652696320686173682066756e6374696f6e2064657369676e6564206e7465206f63756c746f206171756920657373616a65207365637265746f2e2e2066656c6963696461646573207369206c6f206861732064656369667261646f2e22074687265652053484120616c676f726974686d73206172652073706f7361732c
`define SLOT2_CERT2               2072'h5a50b0de025a27c1ba3f465044732e1bbb28db7e2331c69918bd558fd78017da40339628c50f693efaa4ae4b7548a9a67c597b38e6dc017157474166d72d9755e6b61bec44fc902610fcd43ffbd4112cd72d9755e6b61bec44fc902610fcd43ffbd4112c66271f508cd00fde5c2d271f88aafa703d56c1f766271f508cd00fde5c2d271f88aafa703d56c1f7aaa2
`define SLOT2_CERT3               2072'h02c2062757420636f72726563747320616e206572726f7220696e20746865206f726967696e616c2053484120686173682073706563696669636174696f6e2074686174206c656420746f207369676e69666963616e74207765616b6e65737365732e20546865205348412d3020616c676f726974686d20776173206e6f742061646f70746564206279206d616e79206170706c69636174696f6e732e205348412d32206f6e20746865206f746865722068616e642073
`define SLOT2_CERT4               2072'h4569676e69666963616e746c7920646966666572732066726f6d20746865205348412d3120686173682066756e6374696f6e220536563757265204861736820416c676f726974686d2e205468652074687265652053484120616c676f726974686d7320617265207374727563747572656420646966666572656e746c7920616e64206172652064697374696e67756973686564206173205348412d302c205348412d312c20616e64205348412d322e205348412d3120
`define SLOT2_CERT5               2072'h696320686173682066756e6374696f6e2064657369676e656420627920746865204e6174696f6e616c205365637572697479204167656e637920616e64207075626c697368656420627920746865204e495354206173206120552e532e204665646572616c20496e666f726d6174696f6e2050726f63657373696e67205374616e646172642e20534841207374616e647320666f76e2063727970746f6772617068792c205
`define CHALLENGE_AUTH_HASH       1280'h6191981981A61654C6515F6541B6191981981A61654C6515F6541D6519840E65165415FF6565D6519840E6516541B5FF65656191981981A61654C6515F6541D6519840E65165415FF6565
`define SLOT0_CERT1_LENGTH        16'h0103
`define SLOT0_CERT2_LENGTH        16'h0095
`define SLOT0_CERT3_LENGTH        16'h0100
`define SLOT0_CERT4_LENGTH        16'h0091
`define SLOT0_CERT5_LENGTH        16'h0088
`define SLOT0_CERT6_LENGTH        16'h0101
`define SLOT1_CERT1_LENGTH        16'h0103
`define SLOT1_CERT2_LENGTH        16'h0095
`define SLOT1_CERT3_LENGTH        16'h0100
`define SLOT1_CERT4_LENGTH        16'h0091
`define SLOT2_CERT1_LENGTH        16'h0103
`define SLOT2_CERT2_LENGTH        16'h0095
`define SLOT2_CERT3_LENGTH        16'h0100
`define SLOT2_CERT4_LENGTH        16'h0091
`define SLOT2_CERT5_LENGTH        16'h0088

`endif //parameters
