package com.crm.workbench.service.impl;

import com.crm.workbench.domain.Clue;
import com.crm.workbench.mapper.ClueMapper;
import com.crm.workbench.service.ClueService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;

@Service("clueService")
public class ClueServiceImpl implements ClueService {

    @Resource
    private ClueMapper clueMapper;

    @Override
    public int saveCreateClue(Clue clue) {
        return clueMapper.insertClue(clue);
    }
}
